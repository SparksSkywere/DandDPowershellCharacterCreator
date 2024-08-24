# Function to display the cantrip selection form
function Show-CantripForm {
    Debug-Log "[Debug] Displaying Cantrip Selection Form"

    # Filter cantrips based on the selected class
    $filteredCantrips = $CantripsJSON | Where-Object { $_.classes -contains $global:Class }

    $form = New-ProgramForm -Title 'Select Cantrips' -Width 500 -Height 600 -AcceptButtonText 'Next' -SkipButtonText 'Skip' -CancelButtonText 'Cancel'

    # Create list box controls for selecting up to 3 cantrips using the filtered cantrips
    $cantrip1Controls = Set-ListBox -LabelText 'Select Cantrip 1:' -X 10 -Y 20 -Width 460 -Height 150 -DataSource $filteredCantrips -DisplayMember 'name'
    $cantrip2Controls = Set-ListBox -LabelText 'Select Cantrip 2:' -X 10 -Y 180 -Width 460 -Height 150 -DataSource $filteredCantrips -DisplayMember 'name'
    $cantrip3Controls = Set-ListBox -LabelText 'Select Cantrip 3:' -X 10 -Y 340 -Width 460 -Height 150 -DataSource $filteredCantrips -DisplayMember 'name'

    # Add controls to the form
    $form.Controls.AddRange($cantrip1Controls)
    $form.Controls.AddRange($cantrip2Controls)
    $form.Controls.AddRange($cantrip3Controls)

    $form.Topmost = $true
    $form.Add_Shown({$form.Activate()})
    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        # Store the selected cantrips in global variables
        $global:Cantrip01 = $cantrip1Controls[1].SelectedItem.name
        $global:Cantrip02 = $cantrip2Controls[1].SelectedItem.name
        $global:Cantrip03 = $cantrip3Controls[1].SelectedItem.name

        # Debugging output
        Debug-Log "Selected Cantrip 1: $($global:Cantrip01)"
        Debug-Log "Selected Cantrip 2: $($global:Cantrip02)"
        Debug-Log "Selected Cantrip 3: $($global:Cantrip03)"
    } elseif ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
        Debug-Log "[Debug] Form was canceled by the user."
        exit
    }
}