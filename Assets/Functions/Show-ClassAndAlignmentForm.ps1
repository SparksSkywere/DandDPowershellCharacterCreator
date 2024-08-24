# Function to display the class and alignment selection form
function Show-ClassAndAlignmentForm {
    Debug-Log "[Debug] Displaying Class and Alignment Form"
    $form = New-ProgramForm -Title 'Sparks D&D Character Creator' -Width 500 -Height 350 -AcceptButtonText 'Next' -SkipButtonText 'Skip' -CancelButtonText 'Cancel'

    $classControls = Set-ListBox -LabelText 'Select a Primary Class:' -X 10 -Y 20 -Width 160 -Height 200 -DataSource $ClassesJSON -DisplayMember 'name'
    $alignmentControls = Set-ListBox -LabelText 'Select an Alignment:' -X 200 -Y 20 -Width 160 -Height 200 -DataSource $AlignmentJSON -DisplayMember 'name'

    $form.Controls.AddRange($classControls)
    $form.Controls.AddRange($alignmentControls)

    $form.Topmost = $true
    $form.Add_Shown({$form.Activate()})
    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        # All the values that are pulled from the json files
        $global:SelectedClass = $classControls[1].SelectedItem
        $global:Class = $global:SelectedClass.Name
        $global:HD = $global:SelectedClass.HitDice
        $global:SpellCastingClass = $global:SelectedClass.spellcastingclass
        $global:SpellCastingAbility = $global:SelectedClass.SpellCastingAbility
        $global:SelectedPack = $global:SelectedClass.backpack
        $global:Alignment = $alignmentControls[1].SelectedItem.Name

        # Convert CanCastCantrips to a boolean
        $global:CanCastCantrips = [bool]::Parse($global:SelectedClass.CanCastCantrips)

        Debug-Log "SelectedClass: $($global:SelectedClass)"
        Debug-Log "Class: $($global:Class)"
        Debug-Log "Alignment: $($global:Alignment)"
        Debug-Log "HD: $($global:HD)"
        Debug-Log "SpellCastingClass: $($global:SpellCastingClass)"
        Debug-Log "SpellCastingAbility: $($global:SpellCastingAbility)"
        Debug-Log "SelectedPack: $($global:SelectedPack)"
        Debug-Log "CanCastCantrips: $($global:CanCastCantrips)"  # Log cantrip capability

        # Calculate the derived stats based on race and class
        Debug-Log "[Debug] Calculating Character Stats"
        Calculate-CharacterStats

        # Conditionally display the Cantrip Form if the class can cast cantrips
        if ($global:CanCastCantrips) {
            Show-CantripForm
        } else {
            Debug-Log "[Debug] Skipping Cantrip Selection as the class cannot cast cantrips."
        }
    } elseif ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
        Debug-Log "[Debug] [Debug] Form was canceled by the user."
        exit
    }
}