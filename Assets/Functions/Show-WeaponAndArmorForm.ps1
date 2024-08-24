# Function to display the weapon and armor selection form
function Show-WeaponAndArmorForm {
    Debug-Log "[Debug] Displaying Weapon and Armor Form"
    $form = New-ProgramForm -Title 'Sparks D&D Character Creator' -Width 500 -Height 600 -AcceptButtonText 'Next' -SkipButtonText 'Skip' -CancelButtonText 'Cancel'

    $weapon1Controls = Set-ListBox -LabelText 'Select Weapon 1:' -X 15 -Y 20 -Width 140 -Height 230 -DataSource $WeaponJSON -DisplayMember 'name'
    $weapon2Controls = Set-ListBox -LabelText 'Select Weapon 2:' -X 165 -Y 20 -Width 140 -Height 230 -DataSource $WeaponJSON -DisplayMember 'name'
    $weapon3Controls = Set-ListBox -LabelText 'Select Weapon 3:' -X 315 -Y 20 -Width 140 -Height 230 -DataSource $WeaponJSON -DisplayMember 'name'
    $gearControls = Set-ListBox -LabelText 'Select extra Adventuring Gear:' -X 240 -Y 275 -Width 220 -Height 200 -DataSource $GearJSON -DisplayMember 'name'
    $armorControls = Set-ListBox -LabelText 'Select Armour:' -X 10 -Y 275 -Width 220 -Height 200 -DataSource $ArmourJSON -DisplayMember 'name'

    $checkboxShield = New-Object System.Windows.Forms.CheckBox
    $checkboxShield.Location = New-Object System.Drawing.Point(25, 487)
    $checkboxShield.Size = New-Object System.Drawing.Size(120, 40)
    $checkboxShield.Text = "Shield?"
    $checkboxShield.Checked = $false

    $form.Controls.AddRange($weapon1Controls)
    $form.Controls.AddRange($weapon2Controls)
    $form.Controls.AddRange($weapon3Controls)
    $form.Controls.AddRange($gearControls)
    $form.Controls.AddRange($armorControls)
    $form.Controls.Add($checkboxShield)

    $form.Topmost = $true
    $form.Add_Shown({$form.Activate()})
    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        # Weapon Selections
        $global:Weapon1 = $weapon1Controls[1].SelectedItem.Name
        $global:Weapon2 = $weapon2Controls[1].SelectedItem.Name
        $global:Weapon3 = $weapon3Controls[1].SelectedItem.Name
        $global:Gear = $gearControls[1].SelectedItem.Name

        # Extract properties for the first weapon
        $weapon1 = $weapon1Controls[1].SelectedItem
        $global:WPN1ATK_Bonus = $weapon1.WPN1ATK_Bonus
        $global:Weapon1Damage = $weapon1.Weapon1Damage
        $global:Weapon1Weight = $weapon1.Weapon1Weight
        $global:Weapon1Properties = $weapon1.Weapon1Properties

        # Extract properties for the second weapon
        $weapon2 = $weapon2Controls[1].SelectedItem
        $global:WPN2ATK_Bonus = $weapon2.WPN2ATK_Bonus
        $global:Weapon2Damage = $weapon2.Weapon2Damage
        $global:Weapon2Weight = $weapon2.Weapon2Weight
        $global:Weapon2Properties = $weapon2.Weapon2Properties

        # Extract properties for the third weapon
        $weapon3 = $weapon3Controls[1].SelectedItem
        $global:WPN3ATK_Bonus = $weapon3.WPN3ATK_Bonus
        $global:Weapon3Damage = $weapon3.Weapon3Damage
        $global:Weapon3Weight = $weapon3.Weapon3Weight
        $global:Weapon3Properties = $weapon3.Weapon3Properties

        $selectedArmor = $armorControls[1].SelectedItem
        $baseAC = [int]$selectedArmor.BaseAC
        $armorType = $selectedArmor.Type       
        $maxDexBonus = [int]$selectedArmor.MaxDexBonus  
        $dexModifier = [int]$global:DEXMod
        
        # Apply Dex Modifier if applicable
        if ($selectedArmor.DexModifierApplicable -and $armorType -eq 'Medium') {
            $dexModifier = [math]::Min($dexModifier, $maxDexBonus)
        }
        
        $global:ArmourClass = $baseAC + $dexModifier
        
        # Apply shield bonus if selected
        if ($checkboxShield.Checked) {
            $global:ArmourClass += 2
        }

        # Calculate total carried weight
        $global:ArmorWeight = $selectedArmor.Weight
        $global:GearWeight = $gearControls[1].SelectedItem.Weight
        Calculate-CharacterStats

        # Debugging Outputs Weapons
        Debug-Log "Weapon1: $($global:Weapon1)"
        Debug-Log "Weapon1Damage: $($global:Weapon1Damage)"
        Debug-Log "Weapon1ATK_Bonus: $($global:WPN1ATK_Bonus)"
        Debug-Log "Weapon1Weight: $($global:Weapon1Weight)"
        Debug-Log "Weapon1Properties: $($global:Weapon1Properties)"
        Debug-Log "Weapon2: $($global:Weapon2)"
        Debug-Log "Weapon2Damage: $($global:Weapon2Damage)"
        Debug-Log "Weapon2ATK_Bonus: $($global:WPN2ATK_Bonus)"
        Debug-Log "Weapon1Weight: $($global:Weapon2Weight)"
        Debug-Log "Weapon1Properties: $($global:Weapon2Properties)"
        Debug-Log "Weapon3: $($global:Weapon3)"
        Debug-Log "Weapon3Damage: $($global:Weapon3Damage)"
        Debug-Log "Weapon3ATK_Bonus: $($global:WPN3ATK_Bonus)"
        Debug-Log "Weapon1Weight: $($global:Weapon3Weight)"
        Debug-Log "Weapon1Properties: $($global:Weapon3Properties)"
        # Debugging Outputs Armour
        Debug-Log "Gear: $($global:Gear)"
        Debug-Log "Armour: $($global:Armour)"
        Debug-Log "Selected Armor: $($armorControls[1].SelectedItem)"
        Debug-Log "Armor Type: $armorType"
        # Debugging Calculations
        Debug-Log "Base AC: $baseAC"
        Debug-Log "Dexterity Modifier: $dexModifier"
        Debug-Log "Calculated ArmourClass: $($global:ArmourClass)"
        Debug-Log "Calculated ArmourWeight: $($global:ArmorWeight)"
        Debug-Log "Calculated GearWeight: $($global:GearWeight)"
    } elseif ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
        Debug-Log "[Debug] Form was canceled by the user."
        exit
    }
}