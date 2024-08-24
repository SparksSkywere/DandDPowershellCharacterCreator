# Function to display the subclass selection form
function Show-SubClassForm {
    Debug-Log "[Debug] Displaying SubClass Form"
    $form = New-ProgramForm -Title 'Sparks D&D Character Creator' -Width 500 -Height 350 -AcceptButtonText 'Next' -SkipButtonText 'Skip' -CancelButtonText 'Cancel'

    if ($global:SelectedClass.Subclasses -and $global:SelectedClass.Subclasses.Count -gt 0) {
        $subClassControls = Set-ListBox -LabelText 'Select a SubClass:' -X 10 -Y 20 -Width 260 -Height 200 -DataSource $global:SelectedClass.Subclasses
        $form.Controls.AddRange($subClassControls)

        $form.Topmost = $true
        $form.Add_Shown({$form.Activate()})
        $result = $form.ShowDialog()

        if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
            if ($subClassControls[1].SelectedItem) {
                $global:SubClass = $subClassControls[1].SelectedItem
                $global:ClassAndSubClass = "$($global:Class) - $($global:SubClass)"
                Debug-Log "SubClass Selected: $($global:SubClass)"
                Debug-Log "Final Selection: $($global:ClassAndSubClass)"
            }
        } elseif ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
            Debug-Log "[Debug] Form was canceled by the user."
            exit
        }
    } else {
        Debug-Log "[Debug] No subclasses available for the selected class."
    }
}