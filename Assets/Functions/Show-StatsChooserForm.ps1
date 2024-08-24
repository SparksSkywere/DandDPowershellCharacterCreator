# Function to display the stats chooser form
function Show-StatsChooserForm {
    Debug-Log "[Debug] Displaying Stats Chooser Form"

    # Create form
    $form = New-ProgramForm -Title 'Allocate Character Stats' -Width 400 -Height 350 -AcceptButtonText 'OK' -SkipButtonText 'Skip' -CancelButtonText 'Cancel'

    # Label for remaining points
    $remainingPointsLabel = New-Object System.Windows.Forms.Label
    $remainingPointsLabel.Location = New-Object System.Drawing.Point(10, 10)
    $remainingPointsLabel.Size = New-Object System.Drawing.Size(150, 20)
    $remainingPointsLabel.Text = "Remaining Points: $($global:TotalPoints)"
    $form.Controls.Add($remainingPointsLabel)

    $resetButton = New-Object System.Windows.Forms.Button
    $resetButton.Location = New-Object System.Drawing.Point(170, 7)
    $resetButton.Size = New-Object System.Drawing.Size(60, 23)
    $resetButton.Text = 'Reset'
    $resetButton.Add_Click({
        $global:StatIncrements.Keys | ForEach-Object { $global:StatIncrements[$_] = 0 }
        UpdateFormControls -form $form -remainingPointsLabel $remainingPointsLabel
    })
    $form.Controls.Add($resetButton)

    # Dictionary to store label references
    $statLabels = @{}

    # Helper function to add stat controls
    function Add-StatControls {
        param (
            [string]$stat,
            [int]$yPosition
        )

        $label = New-Object System.Windows.Forms.Label
        $label.Location = New-Object System.Drawing.Point(10, $yPosition)
        $label.Size = New-Object System.Drawing.Size(80, 20)
        $label.Text = $stat

        $valueLabel = New-Object System.Windows.Forms.Label
        $valueLabel.Location = New-Object System.Drawing.Point(200, $yPosition)
        $valueLabel.Size = New-Object System.Drawing.Size(40, 20)
        $valueLabel.Text = ($global:BaseStats[$stat] + $global:StatIncrements[$stat]).ToString()
        $valueLabel.Tag = $stat

        # Store the reference in the dictionary
        $statLabels[$stat] = $valueLabel

        Debug-Log "[Debug] valueLabel created for $stat with type: $($valueLabel.GetType().FullName)"

        $upButton = New-Object System.Windows.Forms.Button
        $upButton.Location = New-Object System.Drawing.Point(100, $yPosition)
        $upButton.Size = New-Object System.Drawing.Size(40, 23)
        $upButton.Text = "+"

        $downButton = New-Object System.Windows.Forms.Button
        $downButton.Location = New-Object System.Drawing.Point(150, $yPosition)
        $downButton.Size = New-Object System.Drawing.Size(40, 23)
        $downButton.Text = "-"

        # Attach event handlers, using the dictionary to fetch the correct label
        $upButton.Add_Click({
            Debug-Log "[Debug] Handling click for $stat, direction up"
            HandleButtonClick -stat $stat -direction 'up' -valueLabel $statLabels[$stat] -remainingPointsLabel $remainingPointsLabel
        })

        $downButton.Add_Click({
            Debug-Log "[Debug] Handling click for $stat, direction down"
            HandleButtonClick -stat $stat -direction 'down' -valueLabel $statLabels[$stat] -remainingPointsLabel $remainingPointsLabel
        })

        $form.Controls.Add($label)
        $form.Controls.Add($upButton)
        $form.Controls.Add($downButton)
        $form.Controls.Add($valueLabel)
    }

    $yPosition = 40
    foreach ($stat in $global:BaseStats.Keys) {
        Add-StatControls -stat $stat -yPosition $yPosition
        $yPosition += 30
    }

    $form.Topmost = $true
    $form.Add_Shown({$form.Activate()})
    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        foreach ($stat in $global:BaseStats.Keys) {
            Set-Variable -Name $stat -Value ($global:BaseStats[$stat] + $global:StatIncrements[$stat]) -Scope Global
        }
        Debug-Log "[Debug] Stats allocated: STR=$($global:STR), DEX=$($global:DEX), CON=$($global:CON), INT=$($global:INT), WIS=$($global:WIS), CHA=$($global:CHA)"
    } elseif ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
        Debug-Log "[Debug] Form canceled by the user."
        exit
    }
}