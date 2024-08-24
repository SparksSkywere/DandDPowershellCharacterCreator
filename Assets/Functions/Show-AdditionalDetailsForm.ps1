# Function to display the additional details form
function Show-AdditionalDetailsForm {
    Debug-Log "[Debug] Displaying Additional Details Form"
    $form = New-ProgramForm -Title 'Sparks D&D Character Creator' -Width 790 -Height 620 -AcceptButtonText 'Next' -SkipButtonText 'Skip' -CancelButtonText 'Cancel'

    $alliesControls = Set-TextBox -LabelText 'Write about your Allies and Organisations:' -X 10 -Y 20 -Width 360 -Height 480 -MaxLength 0
    $alliesControls[1].Multiline = $true
    $alliesControls[1].ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical

    $featTraitsControls = Set-TextBox -LabelText 'Write your Additional features and traits:' -X 400 -Y 20 -Width 360 -Height 480 -MaxLength 0
    $featTraitsControls[1].Multiline = $true
    $featTraitsControls[1].ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical

    $factionNameControls = Set-TextBox -LabelText 'Faction Name:' -X 10 -Y 530 -Width 360 -Height 20 -MaxLength 0

    $form.Controls.AddRange($alliesControls)
    $form.Controls.AddRange($featTraitsControls)
    $form.Controls.AddRange($factionNameControls)

    $form.Topmost = $true
    $form.Add_Shown({$form.Activate()})
    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $global:Allies = $alliesControls[1].Text
        $global:AddionalfeatTraits = $featTraitsControls[1].Text
        $global:factionname = $factionNameControls[1].Text

        Debug-Log "Allies: $($global:Allies)"
        Debug-Log "AddionalfeatTraits: $($global:AddionalfeatTraits)"
        Debug-Log "FactionName: $($global:factionname)"
    } elseif ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
        Debug-Log "[Debug] Form was canceled by the user."
        exit
    }
}