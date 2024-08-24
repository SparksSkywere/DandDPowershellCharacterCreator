# Function to calculate ability modifiers and other derived stats
function Calculate-CharacterStats {
    # Calculate ability modifiers
    $global:STRMod = [math]::Floor(($global:STR - 10) / 2)
    $global:DEXMod = [math]::Floor(($global:DEX - 10) / 2)
    $global:CONMod = [math]::Floor(($global:CON - 10) / 2)
    $global:INTMod = [math]::Floor(($global:INT - 10) / 2)
    $global:WISMod = [math]::Floor(($global:WIS - 10) / 2)
    $global:CHAMod = [math]::Floor(($global:CHA - 10) / 2)
    
    # Calculate proficiency bonus based on character level
    if ($global:Class -match 'Level (\d+)') {
        $level = [int]($matches[1])
        if ($level -le 4) { $global:ProficiencyBonus = 2 }
        elseif ($level -le 8) { $global:ProficiencyBonus = 3 }
        elseif ($level -le 12) { $global:ProficiencyBonus = 4 }
        elseif ($level -le 16) { $global:ProficiencyBonus = 5 }
        else { $global:ProficiencyBonus = 6 }
    } else {
        $global:ProficiencyBonus = 2  # Default to 2 if level is not detected
    }

    # Calculate saving throws
    $global:ST_STR = $global:STRMod
    if ($global:SelectedClass.SavingThrows -contains 'Strength') {
        $global:ST_STR += $global:ProficiencyBonus
    }

    $global:ST_DEX = $global:DEXMod
    if ($global:SelectedClass.SavingThrows -contains 'Dexterity') {
        $global:ST_DEX += $global:ProficiencyBonus
    }

    $global:ST_CON = $global:CONMod
    if ($global:SelectedClass.SavingThrows -contains 'Constitution') {
        $global:ST_CON += $global:ProficiencyBonus
    }

    $global:ST_INT = $global:INTMod
    if ($global:SelectedClass.SavingThrows -contains 'Intelligence') {
        $global:ST_INT += $global:ProficiencyBonus
    }

    $global:ST_WIS = $global:WISMod
    if ($global:SelectedClass.SavingThrows -contains 'Wisdom') {
        $global:ST_WIS += $global:ProficiencyBonus
    }

    $global:ST_CHA = $global:CHAMod
    if ($global:SelectedClass.SavingThrows -contains 'Charisma') {
        $global:ST_CHA += $global:ProficiencyBonus
    }
    
    # Calculate initiative
    $global:InitiativeTotal = $global:DEXMod + $global:SelectedClass.InitiativeBonus

    # Calculate passive perception
    $global:Passive = 10 + $global:WISMod
    if ($global:SelectedClass.SkillProficiencies -contains 'Perception') {
        $global:Passive += $global:ProficiencyBonus
    }

    # Calculate hit points
    $global:HPMax = ($global:HD * $level) + ($global:CONMod * $level)

    # Calculate encumbrance
    $global:TotalWeightCarried = ($global:Weapon1Weight + $global:Weapon2Weight + $global:Weapon3Weight + $global:GearWeight + $global:ArmorWeight)
    $global:EncumbranceThreshold = $global:STR * 15  # Standard D&D encumbrance rule
    if ($global:TotalWeightCarried -gt $global:EncumbranceThreshold) {
        $global:Speed = [math]::Max(0, $global:Speed - 10)  # Reduce speed if over-encumbered
    }

    # Calculate spell slots
    if ($global:SpellCastingClass) {
        $global:SpellSlots = Get-SpellSlots -class $global:SpellCastingClass -level $level
    }
}