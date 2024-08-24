# Clear the host
Clear-Host

# Global variable to control logging
$global:DebugLoggingEnabled = $true

# Import all functions from the "Functions" folder
Get-ChildItem -Path "$PSScriptRoot\Assets\Functions" -Filter "*.ps1" | ForEach-Object { . $_.FullName }

# Initialize the console and logging
Show-Console -Show
Debug-Log "Console shown [Debugging Enabled]"

# Load the localisation file based on the system language
Set-Localisation

# Load JSON data from various directories
$defaultJSON = Get-JsonData -path (Join-Path $PSScriptRoot "Assets\Defaults")
$CharacterBackgroundJSON = Get-JsonData -path (Join-Path $PSScriptRoot "Assets\Backgrounds")
$RacesJSON = Get-JsonData -path (Join-Path $PSScriptRoot "Assets\Races")
$EyesJSON = Get-JsonData -path (Join-Path $PSScriptRoot "Assets\Character_Features\Eyes")
$HairJSON = Get-JsonData -path (Join-Path $PSScriptRoot "Assets\Character_Features\Hair")
$SkinJSON = Get-JsonData -path (Join-Path $PSScriptRoot "Assets\Character_Features\Skin")
$AlignmentJSON = Get-JsonData -path (Join-Path $PSScriptRoot "Assets\Alignments")
$ClassesJSON = Get-JsonData -path (Join-Path $PSScriptRoot "Assets\Classes")
$WeaponJSON = Get-JsonData -path (Join-Path $PSScriptRoot "Assets\Weapons")
$GearJSON = Get-JsonData -path (Join-Path $PSScriptRoot "Assets\Gear")
$ArmourJSON = Get-JsonData -path (Join-Path $PSScriptRoot "Assets\Armour")
$CantripsJSON = Get-JsonData -path (Join-Path $PSScriptRoot "Assets\Cantrips")

# Initialize global variables based on default JSON data
$global:WrittenCharactername = $defaultJSON.Charactername
$global:WrittenPlayername = $defaultJSON.Playername
$global:WrittenAge = $defaultJSON.Age
$global:ExportBackground = $defaultJSON.Characterbackground
$global:Height = $defaultJSON.Playerheight
$global:Size = $defaultJSON.PlayerSize
$global:Eyes = $defaultJSON.Characterfeatureseyes
$global:Hair = $defaultJSON.characterfeatureshair
$global:Skin = $defaultJSON.characterfeaturesskin
$global:FactionSymbol = $defaultJSON.FactionSymbol
$global:PersonalityTraits = $defaultJSON.PersonalityTraits
$global:ProficencyBonus = $defaultJSON.ProficencyBonus
$global:Class = $defaultJSON.ClassLevel
$global:HP = $defaultJSON.HP
$global:HD = $defaultJSON.HD
$global:Speed = $defaultJSON.SpeedTotal
$global:DEX = $defaultJSON.DEX
$global:CON = $defaultJSON.CON
$global:INT = $defaultJSON.INT
$global:WIS = $defaultJSON.WIS
$global:CHA = $defaultJSON.CHA
$global:SpokenLanguages = $defaultJSON.SpokenLanguages
$global:InitiativeTotal = $defaultJSON.InitiativeTotal
$global:Characterbackstory = $defaultJSON.Characterbackstory
$global:factionname = $defaultJSON.factionname
$global:Allies = $defaultJSON.alliesandorganisations
$global:AddionalfeatTraits = $defaultJSON.AddionalfeatTraits
$global:Ideals = $defaultJSON.Ideals
$global:Bonds = $defaultJSON.Bonds
$global:Flaws = $defaultJSON.Flaws
$global:CombinedWeaponStats = $defaultJSON.CombinedWeaponStats
$global:Armour = $defaultJSON.ChosenArmour
$global:ArmourClass = $defaultJSON.ArmourClass
$global:HitDiceTotal = $defaultJSON.HitDiceTotal
$global:XP = $defaultJSON.XP
$global:Inspiration = $defaultJSON.Inspiration
$global:CopperCP = $defaultJSON.CopperCP
$global:SilverSP = $defaultJSON.SilverSP
$global:ElectrumEP = $defaultJSON.ElectrumEP
$global:GoldGP = $defaultJSON.GoldGP
$global:PlatinumPP = $defaultJSON.PlatinumPP
$global:SpellCastingClass = $defaultJSON.SpellCastingClass
$global:SpellCastingAbility = $defaultJSON.SpellCastingAbility
$global:SpellCastingSaveDC = $defaultJSON.SpellCastingSaveDC
$global:SpellCastingAttackBonus = $defaultJSON.SpellCastingAttackBonus
$global:Acrobatics = $defaultJSON.Acrobatics
$global:AnimalHandling = $defaultJSON.AnimalHandling
$global:Arcana = $defaultJSON.Arcana
$global:Athletics = $defaultJSON.Athletics
$global:Deception = $defaultJSON.Deception
$global:History = $defaultJSON.History
$global:Insight = $defaultJSON.Insight
$global:Intimidation = $defaultJSON.Intimidation
$global:Investigation = $defaultJSON.Investigation
$global:Medicine = $defaultJSON.Medicine
$global:Nature = $defaultJSON.Nature
$global:Perception = $defaultJSON.Perception
$global:Performance = $defaultJSON.Performance
$global:Persuation = $defaultJSON.Persuation
$global:Religion = $defaultJSON.Religion
$global:SleightOfHand = $defaultJSON.SleightOfHand
$global:Stealth = $defaultJSON.Stealth
$global:Survival = $defaultJSON.Survival
$global:Passive = $defaultJSON.Passive
$global:ST_Strength = $defaultJSON.ST_Strength
$global:ST_Dexterity = $defaultJSON.ST_Dexterity
$global:ST_Constitution = $defaultJSON.ST_Constitution
$global:ST_Intelligence = $defaultJSON.ST_Intelligence
$global:ST_Wisdom = $defaultJSON.ST_Wisdom
$global:ST_Charisma = $defaultJSON.ST_Charisma
$global:WpnName = $defaultJSON.WpnName
$global:Wpn1AtkBonus = $defaultJSON.Wpn1AtkBonus
$global:Wpn1Damage = $defaultJSON.Wpn1Damage
$global:WpnName2 = $defaultJSON.WpnName2
$global:Wpn2AtkBonus = $defaultJSON.Wpn2AtkBonus
$global:Wpn2Damage = $defaultJSON.Wpn2Damage
$global:WpnName3 = $defaultJSON.WpnName3
$global:Wpn3AtkBonus = $defaultJSON.Wpn3AtkBonus
$global:Wpn3Damage = $defaultJSON.Wpn3Damage
$global:Backstory = $defaultJSON.Backstory
$global:Equipment = $defaultJSON.Equipment
$global:FeaturesAndTraits = $defaultJSON.'Features and Traits'
$global:Comma = ", "

# Show all forms in order
Show-BasicInfoForm
Show-RaceForm
Show-SubRaceForm
Show-CharacterFeaturesForm
Show-ClassAndAlignmentForm
Show-SubClassForm
Show-WeaponAndArmorForm
Show-StatsChooserForm
Show-BackstoryForm
Show-AdditionalDetailsForm

# Save Form As
$SaveChooser = New-Object -Typename System.Windows.Forms.SaveFileDialog
$SaveChooser.Title = "Save as"
$SaveChooser.FileName = "D&D Avatar - ChangeMe"
$SaveChooser.DefaultExt = ".pdf"
$SaveChooser.Filter = 'PDF File (*.pdf)|*.pdf'
$SaveResult = $SaveChooser.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }))
if ($SaveResult -eq [System.Windows.Forms.DialogResult]::OK) {
    $PathSelected = $SaveChooser.FileName
} elseif ($SaveResult -eq [System.Windows.Forms.DialogResult]::Cancel) {
    exit
}

# PDF Values Import before save
$characterparameters = @{
    Fields = @{
        'ClassLevel' = $Class;
        'PlayerName' = $WrittenPlayername;
        'CharacterName' = $WrittenCharactername;
        'Background' = $ExportBackground;
        'Race ' = $ExportRace;
        'Alignment' = $Alignment;
        'XP' = $XP;
        'Inspiration' = $Inspiration;
        'STR' = $STR;
        'ProfBonus' = $ProficencyBonus;
        'AC' = $ArmourClass;
        'Initiative' = $InitiativeTotal;
        'Speed' = $Speed;
        'PersonalityTraits ' = $PersonalityTraits.Text;
        'STRmod' = $STRmod;
        'ST Strength' = $ST_STR;
        'DEX' = $DEX;
        'Ideals' = $Ideals.Text;
        'DEXmod ' = $DEXmod;
        'Bonds' = $Bonds.Text;
        'CON' = $CON;
        'HDTotal' = $HitDiceTotal;
        'Check Box 12' = $Check12;
        'Check Box 13' = $Check13;
        'Check Box 14' = $Check14;
        'CONmod' = $CONmod;
        'Check Box 15' = $Check15;
        'Check Box 16' = $Check16;
        'Check Box 17' = $Check17;
        'HD' = $HD;
        'Flaws' = $Flaws.Text;
        'INT' = $INT;
        'ST Dexterity' = $ST_DEX;
        'ST Constitution' = $ST_CON;
        'ST Intelligence' = $ST_INT;
        'ST Wisdom' = $ST_WIS;
        'ST Charisma' = $ST_CHA;
        'Acrobatics' = $Acrobatics;
        'Animal' = $AnimalHandling;
        'Athletics' = $Athletics;
        'Deception ' = $Deception;
        'History ' = $History;
        'Wpn Name' = $Weapon1;
        'Wpn1 AtkBonus' = $WPN1ATK_Bonus;
        'Wpn1 Damage' = $Weapon1Damage;
        'Insight' = $Insight;
        'Intimidation' = $Intimidation;
        'Wpn Name 2' = $Weapon2;
        'Wpn2 AtkBonus ' = $WPN2ATK_Bonus;
        'Wpn Name 3' = $Weapon3;
        'Wpn3 AtkBonus  ' = $WPN3ATK_Bonus;
        'Check Box 11' = if ($Check11) { "Yes" } else { "off" };
        'Check Box 18' = if ($Check18) { "Yes" } else { "off" };
        'Check Box 19' = if ($Check19) { "Yes" } else { "off" };
        'Check Box 20' = if ($Check20) { "Yes" } else { "off" };
        'Check Box 21' = if ($Check21) { "Yes" } else { "off" };
        'Check Box 22' = if ($Check22) { "Yes" } else { "off" };
        'INTmod' = $INTmod;
        'Wpn2 Damage ' = $Weapon2Damage;
        'Investigation ' = $Investigation;
        'WIS' = $WIS;
        'Arcana' = $Arcana;
        'Perception ' = $Perception;
        'WISmod' = $WISmod;
        'CHA' = $CHA;
        'Nature' = $Nature;
        'Performance' = $Performance;
        'Medicine' = $Medicine;
        'Religion' = $Religion;
        'Stealth ' = $Stealth;
        'Check Box 23' = if ($Check23) { "Yes" } else { "off" };
        'Check Box 24' = if ($Check24) { "Yes" } else { "off" };
        'Check Box 25' = if ($Check25) { "Yes" } else { "off" };
        'Check Box 26' = if ($Check26) { "Yes" } else { "off" };
        'Check Box 27' = if ($Check27) { "Yes" } else { "off" };
        'Check Box 28' = if ($Check28) { "Yes" } else { "off" };
        'Check Box 29' = if ($Check29) { "Yes" } else { "off" };
        'Check Box 30' = if ($Check30) { "Yes" } else { "off" };
        'Check Box 31' = if ($Check31) { "Yes" } else { "off" };
        'Check Box 32' = if ($Check32) { "Yes" } else { "off" };
        'Check Box 33' = if ($Check33) { "Yes" } else { "off" };
        'Check Box 34' = if ($Check34) { "Yes" } else { "off" };
        'Check Box 35' = if ($Check35) { "Yes" } else { "off" };
        'Check Box 36' = if ($Check36) { "Yes" } else { "off" };
        'Check Box 37' = if ($Check37) { "Yes" } else { "off" };
        'Check Box 38' = if ($Check38) { "Yes" } else { "off" };
        'Check Box 39' = if ($Check39) { "Yes" } else { "off" };
        'Check Box 40' = if ($Check40) { "Yes" } else { "off" };
        'Persuasion' = $Persuation;
        'HPMax' = $HPMax;
        'HPCurrent' = $HP;
        'Wpn3 Damage ' = $Weapon3Damage;
        'SleightofHand' = $SleightOfHand;
        'CHamod' = $CHAmod;
        'Survival' = $Survival;
        'AttacksSpellcasting' = $CombinedWeaponStats;
        'Passive' = $Passive;
        'CP' = $CopperCP;
        'ProficienciesLang' = $SpokenLanguages;
        'SP' = $SilverSP;
        'EP' = $ElectrumEP;
        'GP' = $GoldGP;
        'PP' = $PlatinumPP;
        'Equipment' = $TotalEquiptment;
        'Features and Traits' = $Feature1TTraits1;
        'CharacterName 2' = $WrittenCharactername;
        'Age' = $WrittenAge;
        'Height' = $Height;
        'Weight' = $Size;
        'Eyes' = $Eyes;
        'Skin' = $Skin;
        'Hair' = $Hair;
        'Faction Symbol Image' = $FactionSymbol;
        'Allies' = $Allies.Text;
        'FactionName' = $Factionname.Text;
        'Backstory' = $Characterbackstory.Text;
        'Feat+Traits' = $AddionalfeatTraits.Text;
        'Spellcasting Class 2' = $SpellCastingClass;
        'SpellcastingAbility 2' = $SpellCastingAbility;
        'SpellSaveDC  2' = $SpellCastingSaveDC;
        'SpellAtkBonus 2' = $SpellCastingAttackBonus;
        'Spells 1014' = $Cantrip01;
        'Spells 1015' = $Cantrip11;
        'Spells 1016' = $Cantrip02;
        'Spells 1017' = $Cantrip03;
    }
    InputPdfFilePath = "$PSScriptRoot\Assets\Empty_PDF\DnD_5E_CharacterSheet - Form Fillable.pdf"
    ITextSharpLibrary = "$PSScriptRoot\Assets\iText\itextsharp.dll"
    OutputPdfFilePath = $PathSelected
    ImageFields = @{
        'CHARACTER IMAGE' = $CharacterImage
    }
}

# Validate that the Fields and ImageField are correctly cast to Hashtable
$characterparameters.Fields = [hashtable]$characterparameters.Fields
$characterparameters.ImageFields = [hashtable]$characterparameters.ImageFields

# Execute the PDF save function
Save-PdfField @characterparameters

# End of character creation dialog box
$ButtonType = [System.Windows.MessageBoxButton]::Ok
$MessageIcon = [System.Windows.MessageBoxImage]::Information
$MessageBody = "Dungeons And Dragons Character Successfully Created!"
$MessageTitle = "Spark's D&D Character Creator"
[System.Windows.MessageBox]::Show($MessageBody, $MessageTitle, $ButtonType, $MessageIcon)
Debug-Log "[Debug] Character successfully created message displayed."

# Exit script
Exit
