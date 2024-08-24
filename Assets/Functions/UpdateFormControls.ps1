# Function to update form controls
function UpdateFormControls {
    param (
        [System.Windows.Forms.Form]$form,
        [System.Windows.Forms.Label]$remainingPointsLabel
    )

    $remainingPointsLabel.Text = "Remaining Points: $($global:TotalPoints)"
    foreach ($control in $form.Controls) {
        if ($control.Tag -and $global:BaseStats.ContainsKey($control.Tag)) {
            $control.Text = ($global:BaseStats[$control.Tag] + $global:StatIncrements[$control.Tag]).ToString()
        }
    }
}