# Function to display the class and race selection form
function Show-RaceForm {
    Debug-Log "[Debug] Displaying Class and Race Form"
    $form = New-ProgramForm -Title 'Sparks D&D Character Creator' -Width 450 -Height 350 -AcceptButtonText 'Next' -SkipButtonText 'Skip' -CancelButtonText 'Cancel'

    $backgroundControls = Set-ListBox -LabelText 'Select a Background:' -X 10 -Y 20 -Width 200 -Height 170 -DataSource $CharacterBackgroundJSON -DisplayMember 'name'
    $raceControls = Set-ListBox -LabelText 'Select a Race:' -X 220 -Y 20 -Width 150 -Height 170 -DataSource $RacesJSON -DisplayMember 'name'

    $form.Controls.AddRange($backgroundControls)
    $form.Controls.AddRange($raceControls)

    $form.Topmost = $true
    $form.Add_Shown({$form.Activate()})
    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $global:ExportBackground = $backgroundControls[1].SelectedItem.Name
        $global:SelectedRace = $raceControls[1].SelectedItem
        $global:ExportRace = $global:SelectedRace.Name
        $global:Feature1TTraits1 = $global:SelectedRace.Description
        $global:HP = $global:SelectedRace.HP
        $global:Speed = $global:SelectedRace.Speed
        $global:Size = $global:SelectedRace.Size
        $global:Height = $global:SelectedRace.Height
        $global:SpokenLanguages = $global:SelectedRace.Languages
        $global:Special = $global:SelectedRace.Special
        $global:STR = [int]$global:SelectedRace.Strength
        $global:DEX = [int]$global:SelectedRace.Dexterity
        $global:CON = [int]$global:SelectedRace.Constitution
        $global:INT = [int]$global:SelectedRace.Intelligence
        $global:WIS = [int]$global:SelectedRace.Wisdom
        $global:CHA = [int]$global:SelectedRace.Charisma
        $global:STRMod = $global:SelectedRace.StrengthMod
        $global:DEXMod = $global:SelectedRace.DexterityMod
        $global:CONMod = $global:SelectedRace.ConstitutionMod
        $global:INTMod = $global:SelectedRace.IntelligenceMod
        $global:WISMod = $global:SelectedRace.WisdomMod
        $global:CHAMod = $global:SelectedRace.CharismaMod
        $global:ST_STR = $global:SelectedRace.Saving_Strength
        $global:ST_DEX = $global:SelectedRace.Saving_Dexterity
        $global:ST_CON = $global:SelectedRace.Saving_Constitution
        $global:ST_INT = $global:SelectedRace.Saving_Intelligence
        $global:ST_WIS = $global:SelectedRace.Saving_Wisdom
        $global:ST_CHA = $global:SelectedRace.Saving_Charisma

        # Assign default image if no image was selected by the user
        if (-not $global:ImageSelected) {
            $global:CharacterImage = Join-Path $PSScriptRoot "Assets\Races\Images\$($global:SelectedRace.image)"
            Debug-Log "No image selected, setting default race image: $($global:CharacterImage)"
        }

        # Debugging Character
        Debug-Log "$global:ExportBackground"
        Debug-Log "$global:SelectedRace"
        Debug-Log "$global:ExportRace"
        Debug-Log "$global:Feature1TTraits1"
        Debug-Log "$global:HP"
        Debug-Log "$global:Speed"
        Debug-Log "$global:Size"
        Debug-Log "$global:Height"
        Debug-Log "$global:SpokenLanguages"
        Debug-Log "$global:Special"

        # Debugging: Output the ability scores
        Debug-Log "`n[Debug] Ability Scores:"
        Debug-Log "STR: $global:STR, DEX: $global:DEX, CON: $global:CON, INT: $global:INT, WIS: $global:WIS, CHA: $global:CHA"
        Debug-Log "STRMod: $global:STRMod, DEXMod: $global:DEXMod, CONMod: $global:CONMod, INTMod: $global:INTMod, WISMod: $global:WISMod, CHAMod: $global:CHAMod"
        Debug-Log "ST_STR: $global:ST_STR, ST_DEX: $global:ST_DEX, ST_CON: $global:ST_CON, ST_INT: $global:ST_INT, ST_WIS: $global:ST_WIS, ST_CHA: $global:ST_CHA"

        # Calculate derived stats immediately after race selection
        Debug-Log "Calculating Character Stats"
        Calculate-CharacterStats
    } elseif ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
        Debug-Log "[Debug] Form was canceled by the user."
        exit
    }
}