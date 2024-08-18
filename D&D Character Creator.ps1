Clear-Host

# Global variable to control logging
$global:DebugLoggingEnabled = $true

# Function to show or hide the console window
function Show-Console {
    param ([Switch]$Show, [Switch]$Hide)
    if (-not ("Console.Window" -as [type])) {
        Add-Type -Name Window -Namespace Console -MemberDefinition '
        [DllImport("Kernel32.dll")]
        public static extern IntPtr GetConsoleWindow();

        [DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
        '
    }
    $consolePtr = [Console.Window]::GetConsoleWindow()
    if ($Show) {
        [Console.Window]::ShowWindow($consolePtr, 5) | Out-Null
        $global:DebugLoggingEnabled = $true # Enable logging
        Debug-Log "$DebugLoggingEnabled"
    }
    if ($Hide) {
        [Console.Window]::ShowWindow($consolePtr, 0) | Out-Null
        $global:DebugLoggingEnabled = $false # Disable logging
    }
}

# Wrapper function to handle conditional logging
function Debug-Log {
    param (
        [string]$Message
    )
    if ($global:DebugLoggingEnabled) {
        Write-Host $Message
    }
}
# Change the line below to show debugging information
# "-Show" to show the console "-Hide" to hide the console
Show-Console -Show
Debug-Log "Console shown [Debugging Enabled]"

# Function to create a form with specific buttons and styles
function New-ProgramForm {
    param (
        [string]$Title,
        [int]$Width,
        [int]$Height,
        [string]$AcceptButtonText,
        [string]$SkipButtonText,
        [string]$CancelButtonText
    )

    $form = New-Object System.Windows.Forms.Form
    $form.Text = $Title
    $form.Size = New-Object System.Drawing.Size($Width, $Height)
    $form.StartPosition = 'CenterScreen'
    $form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$PSScriptRoot\Assets\installer.ico")
    $form.BackgroundImage = [System.Drawing.Image]::FromFile("$PSScriptRoot\Assets\form_background.png")
    $form.BackgroundImageLayout = [System.Windows.Forms.ImageLayout]::Stretch

    $buttonPanel = New-Object System.Windows.Forms.Panel
    $buttonPanel.Dock = [System.Windows.Forms.DockStyle]::Bottom
    $buttonPanel.Height = 50
    $form.Controls.Add($buttonPanel)

    $buttons = @(
        @{Text = $AcceptButtonText; DialogResult = [System.Windows.Forms.DialogResult]::OK},
        @{Text = $SkipButtonText; DialogResult = [System.Windows.Forms.DialogResult]::Ignore},
        @{Text = $CancelButtonText; DialogResult = [System.Windows.Forms.DialogResult]::Cancel}
    )

    $i = 0
    foreach ($button in $buttons) {
        $btn = New-Object System.Windows.Forms.Button
        $btn.Location = New-Object System.Drawing.Point([int]($i * 85), 10)
        $btn.Size = New-Object System.Drawing.Size(75, 30)
        $btn.Text = $button.Text
        $btn.DialogResult = $button.DialogResult
        $buttonPanel.Controls.Add($btn)
        $i++
    }

    return $form
}

# Function to create text boxes dynamically
function Set-TextBox {
    param (
        [string]$LabelText,
        [int]$X,
        [int]$Y,
        [int]$Width,
        [int]$Height,
        [int]$MaxLength,
        [string]$TooltipText = ""
    )
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point([int]$X, [int]$Y)
    $label.Size = New-Object System.Drawing.Size($Width, 18)
    $label.Text = $LabelText
    $label.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point([int]$X, [int]($Y + 25))
    $textBox.Size = New-Object System.Drawing.Size($Width, $Height)
    $textBox.MaxLength = $MaxLength

    if ($TooltipText) {
        $toolTip = New-Object System.Windows.Forms.ToolTip
        $toolTip.SetToolTip($textBox, $TooltipText)
    }

    return @($label, $textBox)
}

# Function to create list boxes dynamically
function Set-ListBox {
    param (
        [string]$LabelText,
        [int]$X,
        [int]$Y,
        [int]$Width,
        [int]$Height,
        [array]$DataSource,
        [string]$DisplayMember
    )
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point([int]$X, [int]$Y)
    $label.Size = New-Object System.Drawing.Size($Width, 18)
    $label.Text = $LabelText
    $label.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)

    $listBox = New-Object System.Windows.Forms.ListBox
    $listBox.Location = New-Object System.Drawing.Point([int]$X, [int]($Y + 25))
    $listBox.Size = New-Object System.Drawing.Size($Width, $Height)
    $listBox.DataSource = [System.Collections.ArrayList]$DataSource
    $listBox.DisplayMember = $DisplayMember

    return @($label, $listBox)
}

# Function to display a form and get user input
function Show-Form {
    param (
        [System.Windows.Forms.Form]$form,
        [ScriptBlock]$onOK,
        [ScriptBlock]$onIgnore,
        [ScriptBlock]$onCancel
    )

    $form.Topmost = $true
    $form.Add_Shown({$form.Activate()})
    $result = $form.ShowDialog()

    switch ($result) {
        [System.Windows.Forms.DialogResult]::OK {
            & $onOK
        }
        [System.Windows.Forms.DialogResult]::Ignore {
            & $onIgnore
        }
        [System.Windows.Forms.DialogResult]::Cancel {
            & $onCancel
        }
    }
}

# Type loader, forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationCore,PresentationFramework

# Imports Modules + Add Types
Import-Module -Name "$PSScriptRoot\Assets\iText\PDFForm" | Out-Null
Add-Type -Path "$PSScriptRoot\Assets\iText\itextsharp.dll"

# Paths to JSON data
$defaultsPath = Join-Path $PSScriptRoot "Assets"

# Function to load JSON data from a given path
function Get-JsonData($path) {
    $jsonFiles = Get-ChildItem -Path $path -Filter *.json -ErrorAction Stop
    $data = @()

    foreach ($file in $jsonFiles) {
        try {
            $content = Get-Content -Path $file.FullName -Raw -ErrorAction Stop
            $jsonData = $content | ConvertFrom-Json -ErrorAction Stop
            $data += $jsonData
        } catch {
            Write-Warning "Failed to load JSON from file: $($file.FullName). Error: $($_.Exception.Message)"
        }
    }

    return $data
}

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

# ---- Default Values -----
$global:WrittenCharactername = $defaultJSON.Charactername
$global:WrittenPlayername = $defaultJSON.Playername
$global:WrittenAge = $defaultJSON.Age
$global:ExportBackground = $defaultJSON.Characterbackground
$global:Height = $defaultJSON.Playerheight
$global:Size = $defaultJSON.PlayerSize
$global:Eyes = $defaultJSON.Characterfeatureseyes
$global:Hair = $defaultJSON.characterfeatureshair
$global:Skin = $defaultJSON.characterfeaturesskin
#$global:CharacterImage = $defaultJSON.CharacterImage
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
Debug-Log "Loaded Defaults"

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
    #$global:InitiativeTotal = $global:DEXMod

    # Calculate passive perception
    $global:Passive = 10 + $global:WISMod
    if ($global:SelectedClass.SkillProficiencies -contains 'Perception') {
        $global:Passive += $global:ProficiencyBonus
    }
}

# Function to display the basic information form
function Show-BasicInfoForm {
    Debug-Log "Displaying Basic Info Form"

    # Create a new form
    $form = New-ProgramForm -Title 'Sparks D&D Character Creator' -Width 600 -Height 450 -AcceptButtonText 'Next' -SkipButtonText 'Skip' -CancelButtonText 'Cancel'

    # Create controls for Character Name
    $characterNameControls = Set-TextBox -LabelText 'Character Name:' -X 10 -Y 20 -Width 200 -Height 20 -MaxLength 30

    # Create the Age controls
    $PlayerImageLabel = New-Object System.Windows.Forms.Label
    $PlayerImageLabel.Location = New-Object System.Drawing.Point(10, 75)
    $PlayerImageLabel.Size = New-Object System.Drawing.Size(110, 18)
    $PlayerImageLabel.Text = 'Character Age:'
    $PlayerImageLabel.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
    $form.Controls.Add($PlayerImageLabel)

    $age = New-Object System.Windows.Forms.TextBox
    $age.Location = New-Object System.Drawing.Point(10, 95)
    $age.Size = New-Object System.Drawing.Size(58, 20)
    $age.MaxLength = 5

    $age.Add_TextChanged({
        if ($age.Text -match '\D') {
            $age.Text = $age.Text -replace '\D', ''
            $age.SelectionStart = $age.Text.Length
        }
    })

    # Create controls for the Player Name
    $playerNameControls = Set-TextBox -LabelText 'Player Name:' -X 10 -Y 125 -Width 200 -Height 20 -MaxLength 30

    # Create the Browse Image controls
    $ageLabel = New-Object System.Windows.Forms.Label
    $ageLabel.Location = New-Object System.Drawing.Point(300, 275)
    $ageLabel.Size = New-Object System.Drawing.Size(180, 18)
    $ageLabel.Text = 'Select Character Image'
    $ageLabel.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
    $form.Controls.Add($ageLabel)

    # Create the "Browse" button to select an image
    $browseButton = New-Object System.Windows.Forms.Button
    $browseButton.Location = New-Object System.Drawing.Point(300, 300)
    $browseButton.Size = New-Object System.Drawing.Size(80, 30)
    $browseButton.Text = "Browse"

    # PictureBox to display the selected image
    $pictureBox = New-Object System.Windows.Forms.PictureBox
    $pictureBox.Location = New-Object System.Drawing.Point(300, 20)
    $pictureBox.Size = New-Object System.Drawing.Size(250, 250)
    $pictureBox.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
    $pictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage

    # Event handler for the Browse button click
    $browseButton.Add_Click({
        $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $openFileDialog.Title = "Select Character Image"
        $openFileDialog.Filter = "Image Files|*.jpg;*.jpeg;*.png;*.bmp"

        if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $global:CharacterImage = $openFileDialog.FileName
            $pictureBox.Image = [System.Drawing.Image]::FromFile($global:CharacterImage)
        }
    })

    # Add controls to the form
    $form.Controls.AddRange($characterNameControls)
    $form.Controls.Add($age)
    $form.Controls.Add($PlayerImageLabel)
    $form.Controls.AddRange($playerNameControls)
    $form.Controls.Add($browseButton)
    $form.Controls.Add($pictureBox)

    # Display the form
    $form.Topmost = $true
    $form.Add_Shown({$form.Activate()})
    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        # Capture the values from the form controls
        $global:WrittenCharactername = $characterNameControls[1].Text
        $global:WrittenAge = $age.Text
        $global:WrittenPlayername = $playerNameControls[1].Text

        Debug-Log "`n[Debug] Character Name Captured: $($global:WrittenCharactername)"
        Debug-Log "[Debug] Age Captured: $($global:WrittenAge)"
        Debug-Log "[Debug] Player Name Captured: $($global:WrittenPlayername)"
        Debug-Log "[Debug] Character Image Selected: $($global:CharacterImage)"
    } elseif ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
        Debug-Log "Form was canceled by the user."
        exit
    }
}

Debug-Log "Passed Show-BasicInfoForm"
Show-BasicInfoForm

# Function to display the class and race selection form
function Show-ClassAndRaceForm {
    Debug-Log "Displaying Class and Race Form"
    $form = New-ProgramForm -Title 'Sparks D&D Character Creator' -Width 450 -Height 350 -AcceptButtonText 'Next' -SkipButtonText 'Skip' -CancelButtonText 'Cancel'

    $backgroundControls = Set-ListBox -LabelText 'Please Select a Background:' -X 10 -Y 20 -Width 200 -Height 170 -DataSource $CharacterBackgroundJSON -DisplayMember 'name'
    $raceControls = Set-ListBox -LabelText 'Please select a Race:' -X 220 -Y 20 -Width 150 -Height 170 -DataSource $RacesJSON -DisplayMember 'name'

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
        Debug-Log "Form was canceled by the user."
        exit
    }
}
Debug-Log "Passed Show-ClassAndRaceForm"
Show-ClassAndRaceForm

# Function to display the subrace form
function Show-SubRaceForm {
    Debug-Log "Displaying SubRace Form"
    $form = New-ProgramForm -Title 'Sparks D&D Character Creator' -Width 500 -Height 350 -AcceptButtonText 'Next' -SkipButtonText 'Skip' -CancelButtonText 'Cancel'

    if ($global:SelectedRace.subraces -and $global:SelectedRace.subraces.Count -gt 0) {
        $subRaceControls = Set-ListBox -LabelText 'Please select a SubRace:' -X 10 -Y 20 -Width 260 -Height 200 -DataSource $global:SelectedRace.subraces -DisplayMember 'name'
        $form.Controls.AddRange($subRaceControls)

        $form.Topmost = $true
        $form.Add_Shown({$form.Activate()})
        $result = $form.ShowDialog()

        if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
            $global:SelectedSubRace = $subRaceControls[1].SelectedItem
            $global:ExportSubrace = $global:SelectedSubRace.Name

            Debug-Log "SelectedSubRace: $($global:SelectedSubRace)"
            Debug-Log "ExportSubrace: $($global:ExportSubrace)"
        } elseif ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
            Debug-Log "Form was canceled by the user."
            exit
        }
    } else {
        Debug-Log "No subraces available for the selected race."
    }
}
Debug-Log "Passed Show-SubRaceForm"
Show-SubRaceForm

# Function to display the character features form
function Show-CharacterFeaturesForm {
    Debug-Log "Displaying Character Features Form"
    $form = New-ProgramForm -Title 'Sparks D&D Character Creator' -Width 500 -Height 350 -AcceptButtonText 'Next' -SkipButtonText 'Skip' -CancelButtonText 'Cancel'

    $eyesControls = Set-ListBox -LabelText 'Select Eyes:' -X 10 -Y 20 -Width 110 -Height 170 -DataSource $EyesJSON -DisplayMember 'name'
    $hairControls = Set-ListBox -LabelText 'Select Hair:' -X 125 -Y 20 -Width 110 -Height 170 -DataSource $HairJSON -DisplayMember 'name'
    $skinControls = Set-ListBox -LabelText 'Select Skin:' -X 240 -Y 20 -Width 110 -Height 170 -DataSource $SkinJSON -DisplayMember 'name'

    $form.Controls.AddRange($eyesControls)
    $form.Controls.AddRange($hairControls)
    $form.Controls.AddRange($skinControls)

    $form.Topmost = $true
    $form.Add_Shown({$form.Activate()})
    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $global:Eyes = $eyesControls[1].SelectedItem.Name
        $global:Hair = $hairControls[1].SelectedItem.Name
        $global:Skin = $skinControls[1].SelectedItem.Name

        Debug-Log "Eyes: $($global:Eyes)"
        Debug-Log "Hair: $($global:Hair)"
        Debug-Log "Skin: $($global:Skin)"
    } elseif ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
        Debug-Log "Form was canceled by the user."
        exit
    }
}
Debug-Log "Passed Show-CharacterFeaturesForm"
Show-CharacterFeaturesForm

# Function to display the class and alignment selection form
function Show-ClassAndAlignmentForm {
    Debug-Log "Displaying Class and Alignment Form"
    $form = New-ProgramForm -Title 'Sparks D&D Character Creator' -Width 500 -Height 350 -AcceptButtonText 'Next' -SkipButtonText 'Skip' -CancelButtonText 'Cancel'

    $classControls = Set-ListBox -LabelText 'Please select a Primary Class:' -X 10 -Y 20 -Width 160 -Height 200 -DataSource $ClassesJSON -DisplayMember 'name'
    $alignmentControls = Set-ListBox -LabelText 'Please select an Alignment:' -X 200 -Y 20 -Width 160 -Height 200 -DataSource $AlignmentJSON -DisplayMember 'name'

    $form.Controls.AddRange($classControls)
    $form.Controls.AddRange($alignmentControls)

    $form.Topmost = $true
    $form.Add_Shown({$form.Activate()})
    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $global:SelectedClass = $classControls[1].SelectedItem
        $global:Class = $global:SelectedClass.Name
        $global:HD = $global:SelectedClass.HitDice
        $global:SpellCastingClass = $global:SelectedClass.SpellCastingClass
        $global:SpellCastingAbility = $global:SelectedClass.SpellcastingAbility
        $global:SelectedPack = $global:SelectedClass.Backpack
        $global:Alignment = $alignmentControls[1].SelectedItem.Name

        Debug-Log "SelectedClass: $($global:SelectedClass)"
        Debug-Log "Class: $($global:Class)"
        Debug-Log "Alignment: $($global:Alignment)"
        Debug-Log "HD: $($global:HD)"
        Debug-Log "HD: $($global:SpellCastingClass)"
        Debug-Log "HD: $($global:SpellCastingAbility)"
        Debug-Log "HD: $($global:SelectedPack)"

        # Calculate the derived stats based on race and class
        Debug-Log "Calculating Character Stats"
        Calculate-CharacterStats
    } elseif ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
        Debug-Log "Form was canceled by the user."
        exit
    }
}
Debug-Log "Passed Show-ClassAndAlignmentForm"
Show-ClassAndAlignmentForm

# Function to display the subclass selection form
function Show-SubClassForm {
    Debug-Log "Displaying SubClass Form"
    $form = New-ProgramForm -Title 'Sparks D&D Character Creator' -Width 500 -Height 350 -AcceptButtonText 'Next' -SkipButtonText 'Skip' -CancelButtonText 'Cancel'

    if ($global:SelectedClass.Subclasses -and $global:SelectedClass.Subclasses.Count -gt 0) {
        $subClassControls = Set-ListBox -LabelText 'Please select a SubClass:' -X 10 -Y 20 -Width 260 -Height 200 -DataSource $global:SelectedClass.Subclasses
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
            Debug-Log "Form was canceled by the user."
            exit
        }
    } else {
        Debug-Log "No subclasses available for the selected class."
    }
}
Debug-Log "Passed Show-SubClassForm"
Show-SubClassForm

# Function to display the weapon and armor selection form
function Show-WeaponAndArmorForm {
    Debug-Log "Displaying Weapon and Armor Form"
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
        $baseAC = [int]$selectedArmor.BaseAC   # Now correctly mapped to the JSON structure
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

        # Debugging Outputs
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
        Debug-Log "Gear: $($global:Gear)"
        Debug-Log "Armour: $($global:Armour)"
        Debug-Log "Calculated ArmourClass: $($global:ArmourClass)"
        Debug-Log "Selected Armor: $($armorControls[1].SelectedItem)"
        Debug-Log "Base AC: $baseAC"
        Debug-Log "Armor Type: $armorType"
        Debug-Log "Dexterity Modifier: $dexModifier"
    } elseif ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
        Debug-Log "Form was canceled by the user."
        exit
    }
}
Debug-Log "Passed Show-WeaponAndArmorForm"
Show-WeaponAndArmorForm

# Function to display the character backstory form
function Show-BackstoryForm {
    Debug-Log "Displaying Backstory Form"
    $form = New-ProgramForm -Title 'Sparks D&D Character Creator' -Width 800 -Height 605 -AcceptButtonText 'Next' -SkipButtonText 'Skip' -CancelButtonText 'Cancel'

    $backstoryControls = Set-TextBox -LabelText 'Write your backstory:' -X 10 -Y 20 -Width 400 -Height 500 -MaxLength 0
    $backstoryControls[1].Multiline = $true
    $backstoryControls[1].ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical

    $personalityControls = Set-TextBox -LabelText 'Write your Personality Traits:' -X 420 -Y 20 -Width 300 -Height 100 -MaxLength 0
    $personalityControls[1].Multiline = $true
    $personalityControls[1].ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical

    $idealsControls = Set-TextBox -LabelText 'Write your Ideals:' -X 420 -Y 150 -Width 300 -Height 100 -MaxLength 0
    $idealsControls[1].Multiline = $true
    $idealsControls[1].ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical

    $bondsControls = Set-TextBox -LabelText 'Write About your Bonds:' -X 420 -Y 280 -Width 300 -Height 100 -MaxLength 0
    $bondsControls[1].Multiline = $true
    $bondsControls[1].ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical

    $flawsControls = Set-TextBox -LabelText 'Write your Flaws:' -X 420 -Y 410 -Width 300 -Height 100 -MaxLength 0
    $flawsControls[1].Multiline = $true
    $flawsControls[1].ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical

    $form.Controls.AddRange($backstoryControls)
    $form.Controls.AddRange($personalityControls)
    $form.Controls.AddRange($idealsControls)
    $form.Controls.AddRange($bondsControls)
    $form.Controls.AddRange($flawsControls)

    $form.Topmost = $true
    $form.Add_Shown({$form.Activate()})
    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $global:Characterbackstory = $backstoryControls[1].Text
        $global:PersonalityTraits = $personalityControls[1].Text
        $global:Ideals = $idealsControls[1].Text
        $global:Bonds = $bondsControls[1].Text
        $global:Flaws = $flawsControls[1].Text

        Debug-Log "Characterbackstory: $($global:Characterbackstory)"
        Debug-Log "PersonalityTraits: $($global:PersonalityTraits)"
        Debug-Log "Ideals: $($global:Ideals)"
        Debug-Log "Bonds: $($global:Bonds)"
        Debug-Log "Flaws: $($global:Flaws)"
    } elseif ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
        Debug-Log "Form was canceled by the user."
        exit
    }
}
Debug-Log "Passed Show-BackstoryForm"
Show-BackstoryForm

# Function to display the additional details form
function Show-AdditionalDetailsForm {
    Debug-Log "Displaying Additional Details Form"
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
        Debug-Log "Form was canceled by the user."
        exit
    }
}
Debug-Log "Passed Show-AdditionalDetailsForm"
Show-AdditionalDetailsForm
Debug-Log "All forms have been displayed, proceeding with Save"

# Addvanced Debug purposes only for the PDF File inspect, not for normal debug
$fieldNames = Get-PdfFieldNames -FilePath "$PSScriptRoot\Assets\Empty_PDF\DnD_5E_CharacterSheet - Form Fillable.pdf"
$fieldNames

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
        'Check Box 12' = $Check12; #first success button (from left)
        'Check Box 13' = $Check13; #second success button
        'Check Box 14' = $Check14; #last success button
        'CONmod' = $CONmod;
        'Check Box 15' = $Check15; #first failure button (from left)
        'Check Box 16' = $Check16; #second failure button
        'Check Box 17' = $Check17; #last failure button
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
        'Check Box 11' = $Check11; #Strength Button
        'Check Box 18' = $Check18; #Dexterity Button
        'Check Box 19' = $Check19; #Constitution Button
        'Check Box 20' = $Check20; #Intelligence Button
        'Check Box 21' = $Check21; #Wisdom Button
        'Check Box 22' = $Check22; #Charisma Button
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
        'Stealth ' =  $Stealth;
        'Check Box 23' = $Check23; #Acrobatics Button
        'Check Box 24' = $Check24; #Animal Handling Button
        'Check Box 25' = $Check25; #Arcana Button
        'Check Box 26' = $Check26; #Athletics Button
        'Check Box 27' = $Check27; #Deception Button
        'Check Box 28' = $Check28; #History Button
        'Check Box 29' = $Check29; #Insight Button
        'Check Box 30' = $Check30; #Intimidation Button
        'Check Box 31' = $Check31; #Investigation Button
        'Check Box 32' = $Check32; #Medicine Button
        'Check Box 33' = $Check33; #Nature Button
        'Check Box 34' = $Check34; #Perception Button
        'Check Box 35' = $Check35; #Performance Button
        'Check Box 36' = $Check36; #Persuation Button
        'Check Box 37' = $Check37; #Religion Button
        'Check Box 38' = $Check38; #Slight of Hand Button
        'Check Box 39' = $Check39; #Stealth Button
        'Check Box 40' = $Check40; #Survival Button
        'Persuasion' = $Persuation;
        'HPMax' = $HP;
        'HPCurrent' = $HP;
        #'HPTemp' = ;
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
        #'CHARACTER IMAGE' = $CharacterImage; # Do not uncomment this line
        'Faction Symbol Image' = $FactionSymbol;
        'Allies' = $Allies.Text;
        'FactionName' = $Factionname.Text;
        'Backstory' = $Characterbackstory.Text;
        'Feat+Traits' = $AddionalfeatTraits.Text;
        #'Treasure' = ;
        'Spellcasting Class 2' = $SpellCastingClass;
        'SpellcastingAbility 2' = $SpellCastingAbility;
        'SpellSaveDC  2' = $SpellCastingSaveDC;
        'SpellAtkBonus 2' = $SpellCastingAttackBonus;
        #'SlotsTotal 19' =  ;
        #'SlotsRemaining 19' =  ;
        'Spells 1014' = $Cantrip01; #Cantrip 0 slot 1 (top)
        'Spells 1015' = $Cantrip11; #Cantrip 1 slot 1 (top)
        'Spells 1016' = $Cantrip02; #Cantrip 0 slot 2
        'Spells 1017' = $Cantrip03; #Cantrip 0 slot 3
        'Spells 1018' = $Cantrip04; #Cantrip 0 slot 4
        'Spells 1019' = $Cantrip05; #Cantrip 0 slot 5
        'Spells 1020' = $Cantrip06; #Cantrip 0 slot 6
        'Spells 1021' = $Cantrip07; #Cantrip 0 slot 7
        'Spells 1022' = $Cantrip08; #Cantrip 0 slot 8
        #'Check Box 314' =  ;
        #'Check Box 3031' =  ;
        #'Check Box 3032' =  ;
        #'Check Box 3033' =  ;
        #'Check Box 3034' =  ;
        #'Check Box 3035' =  ;
        #'Check Box 3036' =  ;
        #'Check Box 3037' =  ;
        #'Check Box 3038' =  ;
        #'Check Box 3039' =  ;
        #'Check Box 3040' =  ;
        #'Check Box 321' =  ;
        #'Check Box 320' =  ;
        #'Check Box 3060' =  ;
        #'Check Box 3061' =  ;
        #'Check Box 3062' =  ;
        #'Check Box 3063' =  ;
        #'Check Box 3064' =  ;
        #'Check Box 3065' =  ;
        #'Check Box 3066' =  ;
        #'Check Box 315' =  ;
        #'Check Box 3041' =  ;
        #'Spells 1023' =  ;
        #'Check Box 251' =  ;
        #'Check Box 309' =  ;
        #'Check Box 3010' =  ;
        #'Check Box 3011' =  ;
        #'Check Box 3012' =  ;
        #'Check Box 3013' =  ;
        #'Check Box 3014' =  ;
        #'Check Box 3015' =  ;
        #'Check Box 3016' =  ;
        #'Check Box 3017' =  ;
        #'Check Box 3018' =  ;
        #'Check Box 3019' =  ;
        #'Spells 1024' =  ;
        #'Spells 1025' =  ;
        #'Spells 1026' =  ;
        #'Spells 1027' =  ;
        #'Spells 1028' =  ;
        #'Spells 1029' =  ;
        #'Spells 1030' =  ;
        #'Spells 1031' =  ;
        #'Spells 1032' =  ;
        #'Spells 1033' =  ;
        #'SlotsTotal 20' =  ;
        #'SlotsRemaining 20' =  ;
        #'Spells 1034' =  ;
        #'Spells 1035' =  ;
        #'Spells 1036' =  ;
        #'Spells 1037' =  ;
        #'Spells 1038' =  ;
        #'Spells 1039' =  ;
        #'Spells 1040' =  ;
        #'Spells 1041' =  ;
        #'Spells 1042' =  ;
        #'Spells 1043' =  ;
        #'Spells 1044' =  ;
        #'Spells 1045' =  ;
        #'Spells 1046' =  ;
        #'SlotsTotal 21' =  ;
        #'SlotsRemaining 21' =  ;
        #'Spells 1047' =  ;
        #'Spells 1048' =  ;
        #'Spells 1049' =  ;
        #'Spells 1050' =  ;
        #'Spells 1051' =  ;
        #'Spells 1052' =  ;
        #'Spells 1053' =  ;
        #'Spells 1054' =  ;
        #'Spells 1055' =  ;
        #'Spells 1056' =  ;
        #'Spells 1057' =  ;
        #'Spells 1058' =  ;
        #'Spells 1059' =  ;
        #'SlotsTotal 22' =  ;
        #'SlotsRemaining 22' =  ;
        #'Spells 1060' =  ;
        #'Spells 1061' =  ;
        #'Spells 1062' =  ;
        #'Spells 1063' =  ;
        #'Spells 1064' =  ;
        #'Check Box 323' =  ;
        #'Check Box 322' =  ;
        #'Check Box 3067' =  ;
        #'Check Box 3068' =  ;
        #'Check Box 3069' =  ;
        #'Check Box 3070' =  ;
        #'Check Box 3071' =  ;
        #'Check Box 3072' =  ;
        #'Check Box 3073' =  ;
        #'Spells 1065' =  ;
        #'Spells 1066' =  ;
        #'Spells 1067' =  ;
        #'Spells 1068' =  ;
        #'Spells 1069' =  ;
        #'Spells 1070' =  ;
        #'Spells 1071' =  ;
        #'Check Box 317' =  ;
        #'Spells 1072' =  ;
        #'SlotsTotal 23' =  ;
        #'SlotsRemaining 23' =  ;
        #'Spells 1073' =  ;
        #'Spells 1074' =  ;
        #'Spells 1075' =  ;
        #'Spells 1076' =  ;
        #'Spells 1077' =  ;
        #'Spells 1078' =  ;
        #'Spells 1079' =  ;
        #'Spells 1080' =  ;
        #'Spells 1081' =  ;
        #'SlotsTotal 24' =  ;
        #'SlotsRemaining 24' =  ;
        #'Spells 1082' =  ;
        #'Spells 1083' =  ;
        #'Spells 1084' =  ;
        #'Spells 1085' =  ;
        #'Spells 1086' =  ;
        #'Spells 1087' =  ;
        #'Spells 1088' =  ;
        #'Spells 1089' =  ;
        #'Spells 1090' =  ;
        #'SlotsTotal 25' =  ;
        #'SlotsRemaining 25' =  ;
        #'Spells 1091' =  ;
        #'Spells 1092' =  ;
        #'Spells 1093' =  ;
        #'Spells 1094' =  ;
        #'Spells 1095' =  ;
        #'Spells 1096' =  ;
        #'Spells 1097' =  ;
        #'Spells 1098' =  ;
        #'Spells 1099' =  ;
        #'SlotsTotal 26' =  ;
        #'SlotsRemaining 26' =  ;
        #'Spells 10100' =  ;
        #'Spells 10101' =  ;
        #'Spells 10102' =  ;
        #'Spells 10103' =  ;
        #'Check Box 316' =  ;
        #'Check Box 3042' =  ;
        #'Check Box 3043' =  ;
        #'Check Box 3044' =  ;
        #'Check Box 3045' =  ;
        #'Check Box 3046' =  ;
        #'Check Box 3047' =  ;
        #'Check Box 3048' =  ;
        #'Check Box 3049' =  ;
        #'Check Box 3050' =  ;
        #'Check Box 3051' =  ;
        #'Check Box 3052' =  ;
        #'Spells 10104' =  ;
        #'Check Box 325' =  ;
        #'Check Box 324' =  ;
        #'Check Box 3074' =  ;
        #'Check Box 3075' =  ;
        #'Check Box 3076' =  ;
        #'Check Box 3077' =  ;
        #'Spells 10105' =  ;
        #'Spells 10106' =  ;
        #'Check Box 3078' =  ;
        #'SlotsTotal 27' =  ;
        #'SlotsRemaining 27' =  ;
        #'Check Box 313' =  ;
        #'Check Box 310' =  ;
        #'Check Box 3020' =  ;
        #'Check Box 3021' =  ;
        #'Check Box 3022' =  ;
        #'Check Box 3023' =  ;
        #'Check Box 3024' =  ;
        #'Check Box 3025' =  ;
        #'Check Box 3026' =  ;
        #'Check Box 3027' =  ;
        #'Check Box 3028' =  ;
        #'Check Box 3029' =  ;
        #'Check Box 3030' =  ;
        #'Spells 10107' =  ;
        #'Spells 10108' =  ;
        #'Spells 10109' =  ;
        #'Spells 101010' =  ;
        #'Spells 101011' =  ;
        #'Spells 101012' =  ;
        #'Check Box 319' =  ;
        #'Check Box 318' =  ;
        #'Check Box 3053' =  ;
        #'Check Box 3054' =  ;
        #'Check Box 3055' =  ;
        #'Check Box 3056' =  ;
        #'Check Box 3057' =  ;
        #'Check Box 3058' =  ;
        #'Check Box 3059' =  ;
        #'Check Box 327' =  ;
        #'Check Box 326' =  ;
        #'Check Box 3079' =  ;
        #'Check Box 3080' =  ;
        #'Check Box 3081' =  ;
        #'Check Box 3082' =  ;
        #'Spells 101013' =  ;
        #'Check Box 3083' =  ;
    }
    InputPdfFilePath = "$PSScriptRoot\Assets\Empty_PDF\DnD_5E_CharacterSheet - Form Fillable.pdf"
    ITextSharpLibrary = "$PSScriptRoot\Assets\iText\itextsharp.dll"
    OutputPdfFilePath = $PathSelected
    ImageField = @{
        'CHARACTER IMAGE' = $CharacterImage
    }
}

# Debug output for all fields before saving
Debug-Log "Saving PDF with the following fields:"
foreach ($key in $characterparameters.Fields.Keys) {
    if ($null -eq $characterparameters.Fields[$key]) {
        Debug-Log "WARNING: $key has a null value."
    } else {
        Debug-Log "$key = $($characterparameters.Fields[$key])"
    }
}

# Debug output for image fields
if ($characterparameters.ImageField) {
    foreach ($imageField in $characterparameters.ImageField.Keys) {
        if ($null -eq $characterparameters.ImageField[$imageField]) {
            Debug-Log "WARNING: $imageField image path is null."
        } else {
            Debug-Log "$imageField image path = $($characterparameters.ImageField[$imageField])"
        }
    }
}

# Execute the PDF save function
Save-PdfField @characterparameters

# End of character Creation Dialog box
$ButtonType = [System.Windows.MessageBoxButton]::Ok
$MessageIcon = [System.Windows.MessageBoxImage]::Information
$MessageBody = "Dungeons And Dragons Character Successfully Created!"
$MessageTitle = "Spark's D&D Character Creator"
[System.Windows.MessageBox]::Show($MessageBody, $MessageTitle, $ButtonType, $MessageIcon)
Debug-Log "Character successfully created message displayed."
Exit