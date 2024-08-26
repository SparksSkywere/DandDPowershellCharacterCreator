Clear-Host
# Global variable to control logging
$global:DebugLoggingEnabled = $true | Out-Null

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
    $nCmdShow = if ($Show) { 5 } elseif ($Hide) { 0 } else { return }
    [Console.Window]::ShowWindow($consolePtr, $nCmdShow) | Out-Null
    $global:DebugLoggingEnabled = $Show.IsPresent
    Debug-Log "Console visibility set to: $($Show.IsPresent)"
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
Show-Console -Show
Debug-Log "Console shown [Debugging Enabled]"

# Detect system language and load corresponding localisation file
function Set-Localisation {
    # Get the current system culture (e.g., "en-US" or "es-ES")
    $currentCulture = [System.Globalization.CultureInfo]::CurrentCulture.Name
    $languageCode = $currentCulture.Split('-')[0]

    $localisationPath = Join-Path $PSScriptRoot "Assets\Localisation\localisation.$languageCode.json"
    if (Test-Path $localisationPath) {
        try {
            $global:Localisation = Get-Content -Path $localisationPath -Raw -Encoding UTF8 | ConvertFrom-Json
            Debug-Log "[Debug] Loaded localisation for language: $languageCode"
        } catch {
            Write-Warning "[Debug] Failed to load localisation file for language '$languageCode'. Error: $_"
            Set-DefaultLocalisation
        }
    } else {
        Write-Warning "[Debug] Localisation file not found for language '$languageCode'. Falling back to default (English)."
        Set-DefaultLocalisation
    }
}

# Fallback to default localisation (English) if specific localisation fails
function Set-DefaultLocalisation {
    $defaultLocalisationPath = Join-Path $PSScriptRoot "Assets\Localisation\localisation.en.json"
    try {
        $global:Localisation = Get-Content -Path $defaultLocalisationPath | ConvertFrom-Json
        Debug-Log "[Debug] Loaded default localisation (English)"
    } catch {
        throw "[Debug] Failed to load the default localisation file."
    }
}

# Load the localisation based on system language
Set-Localisation

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
$CantripsJSON = Get-JsonData -path (Join-Path $PSScriptRoot "Assets\Cantrips")

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
$global:WeaponDescription = $defaultJSON.WeaponDescription
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
Debug-Log "[Debug] Loaded Defaults"

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
    Debug-Log "[Debug] Initiative = $global:InitiativeTotal"

    # Calculate passive perception
    $global:Passive = 10 + $global:WISMod
    if ($global:SelectedClass.SkillProficiencies -contains 'Perception') {
        $global:Passive += $global:ProficiencyBonus
    }

    # Calculate hit points
    $global:HPMax = ($global:HD * $level) + ($global:CONMod * $level)
    Debug-Log "[Debug] Total HP = $global:HPMax"

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

# Function to retrieve spell slots based on class and level
function Get-SpellSlots {
    param (
        [string]$class,
        [int]$level
    )
    $slots = @{}
    switch ($class) {
        'Wizard' { $slots = @{ 1=4; 2=3; 3=3; 4=3; 5=1 } }  # Example data
        'Cleric' { $slots = @{ 1=3; 2=3; 3=2; 4=2 } }
        # Add other classes here
    }
    return $slots
}

# Function to display the basic information form
function Show-BasicInfoForm {
    Debug-Log "[Debug] Displaying Basic Info Form"

    # Create a new form with localized text
    $form = New-ProgramForm -Title $global:Localisation.FormTitle -Width 600 -Height 450 -AcceptButtonText $global:Localisation.AcceptButtonText -SkipButtonText $global:Localisation.SkipButtonText -CancelButtonText $global:Localisation.CancelButtonText

    # Create controls for Character Name
    $characterNameControls = Set-TextBox -LabelText $global:Localisation.CharacterNameLabel -X 10 -Y 20 -Width 200 -Height 20 -MaxLength 30

    # Create the Age controls
    $ageLabel = New-Object System.Windows.Forms.Label
    $ageLabel.Location = New-Object System.Drawing.Point(10, 75)
    $ageLabel.Size = New-Object System.Drawing.Size(110, 18)
    $ageLabel.Text = $global:Localisation.AgeLabel
    $ageLabel.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
    $form.Controls.Add($ageLabel)

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
    $playerNameControls = Set-TextBox -LabelText $global:Localisation.PlayerNameLabel -X 10 -Y 125 -Width 200 -Height 20 -MaxLength 30

    # Create the Browse Image controls
    $PlayerImageLabel = New-Object System.Windows.Forms.Label
    $PlayerImageLabel.Location = New-Object System.Drawing.Point(300, 275)
    $PlayerImageLabel.Size = New-Object System.Drawing.Size(180, 18)
    $PlayerImageLabel.Text = $global:Localisation.SelectImageLabel
    $PlayerImageLabel.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
    $form.Controls.Add($PlayerImageLabel)

    # Create the "Browse" button to select an image
    $browseButton = New-Object System.Windows.Forms.Button
    $browseButton.Location = New-Object System.Drawing.Point(300, 300)
    $browseButton.Size = New-Object System.Drawing.Size(80, 30)
    $browseButton.Text = $global:Localisation.BrowseButtonText

    # PictureBox to display the selected image
    $pictureBox = New-Object System.Windows.Forms.PictureBox
    $pictureBox.Location = New-Object System.Drawing.Point(300, 20)
    $pictureBox.Size = New-Object System.Drawing.Size(250, 250)
    $pictureBox.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
    $pictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage

    # Global flag to track if the user selected an image
    $global:ImageSelected = $false

    # Event handler for the Browse button click
    $browseButton.Add_Click({
        $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $openFileDialog.Title = $global:Localisation.SelectImageLabel
        $openFileDialog.Filter = "Image Files|*.jpg;*.jpeg;*.png;*.bmp"

        if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $global:CharacterImage = $openFileDialog.FileName
            $pictureBox.Image = [System.Drawing.Image]::FromFile($global:CharacterImage)
            $global:ImageSelected = $true
            Debug-Log "[Debug] Internal-Path = $global:ImageSelected"
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

    # Capture the values from the form controls
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $global:WrittenCharactername = $characterNameControls[1].Text
        $global:WrittenAge = $age.Text
        $global:WrittenPlayername = $playerNameControls[1].Text

        Debug-Log "`n[Debug] Character Name Captured: $($global:WrittenCharactername)"
        Debug-Log "[Debug] Age Captured: $($global:WrittenAge)"
        Debug-Log "[Debug] Player Name Captured: $($global:WrittenPlayername)"
        Debug-Log "[Debug] Internal check: $ImageSelected"
        Debug-Log "[Debug] Character Image Selected: $($global:CharacterImage)"
    } elseif ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
        Debug-Log "[Debug] Form was canceled by the user."
        exit
    }
}

# Function to display the race selection form
function Show-RaceForm {
    Debug-Log "[Debug] Displaying Race Form"
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
    } elseif ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
        Debug-Log "[Debug] Form was canceled by the user."
        exit
    }
}

# Function to display the subrace form
function Show-SubRaceForm {
    Debug-Log "[Debug] Displaying SubRace Form"
    $form = New-ProgramForm -Title 'Sparks D&D Character Creator' -Width 500 -Height 350 -AcceptButtonText 'Next' -SkipButtonText 'Skip' -CancelButtonText 'Cancel'

    if ($global:SelectedRace.subraces -and $global:SelectedRace.subraces.Count -gt 0) {
        $subRaceControls = Set-ListBox -LabelText 'Select a SubRace:' -X 10 -Y 20 -Width 260 -Height 200 -DataSource $global:SelectedRace.subraces -DisplayMember 'name'
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
            Debug-Log "[Debug] Form was canceled by the user."
            exit
        }
    } else {
        Debug-Log "[Debug] No subraces available for the selected race."
    }
}

# Function to display the character features form
function Show-CharacterFeaturesForm {
    Debug-Log "[Debug] Displaying Character Features Form"
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
        Debug-Log "[Debug] Form was canceled by the user."
        exit
    }
}

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
        $global:SpellCastingSaveDC = $global:SelectedClass.SpellCastingSaveDC
        $global:SelectedPack = $global:SelectedClass.backpack
        $global:Alignment = $alignmentControls[1].SelectedItem.Name
        # All checks
        $global:Check11 = $global:SelectedClass.Check11
        $global:Check18 = $global:SelectedClass.Check18
        $global:Check19 = $global:SelectedClass.Check19
        $global:Check20 = $global:SelectedClass.Check20
        $global:Check21 = $global:SelectedClass.Check21
        $global:Check22 = $global:SelectedClass.Check22

        # Convert CanCastCantrips to a boolean
        $global:CanCastCantrips = [bool]::Parse($global:SelectedClass.CanCastCantrips)

        Debug-Log "SelectedClass: $($global:SelectedClass)"
        Debug-Log "Class: $($global:Class)"
        Debug-Log "Alignment: $($global:Alignment)"
        Debug-Log "HD: $($global:HD)"
        Debug-Log "SpellCastingClass: $($global:SpellCastingClass)"
        Debug-Log "SpellCastingAbility: $($global:SpellCastingAbility)"
        Debug-Log "SpellCastingSaveDC: $($global:SpellCastingSaveDC)"
        Debug-Log "SelectedPack: $($global:SelectedPack)"
        Debug-Log "CanCastCantrips: $($global:CanCastCantrips)"
        Debug-Log "The Following Checks are enabled"
        Debug-Log "Strength: $global:Check11"
        Debug-Log "Dexterity: $global:Check18"
        Debug-Log "Constitution: $global:Check19"
        Debug-Log "Intelligence: $global:Check20"
        Debug-Log "Wisdom: $global:Check21"
        Debug-Log "Charisma: $global:Check22"

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

# Function to display the weapon and armor selection form
function Show-WeaponAndArmourForm {
    Debug-Log "[Debug] Displaying Weapon and Armor Form"
    
    # Create the form
    $form = New-ProgramForm -Title 'Sparks D&D Character Creator' -Width 500 -Height 600 -AcceptButtonText 'Next' -SkipButtonText 'Skip' -CancelButtonText 'Cancel'

    # Create individual ListBox controls for weapon selection
    $weapon1Controls = Set-ListBox -LabelText "Select Weapon 1" -X 15 -Y 20 -Width 140 -Height 230 -DataSource $WeaponJSON -DisplayMember 'name'
    $weapon2Controls = Set-ListBox -LabelText "Select Weapon 2" -X 165 -Y 20 -Width 140 -Height 230 -DataSource $WeaponJSON -DisplayMember 'name'
    $weapon3Controls = Set-ListBox -LabelText "Select Weapon 3" -X 315 -Y 20 -Width 140 -Height 230 -DataSource $WeaponJSON -DisplayMember 'name'
    
    # Add controls to the form
    $form.Controls.AddRange($weapon1Controls)
    $form.Controls.AddRange($weapon2Controls)
    $form.Controls.AddRange($weapon3Controls)

    # Additional controls for armor and gear
    $gearControls = Set-ListBox -LabelText 'Select Extra Adventuring Gear:' -X 240 -Y 275 -Width 220 -Height 200 -DataSource $GearJSON -DisplayMember 'name'
    $armorControls = Set-ListBox -LabelText 'Select Armour:' -X 10 -Y 275 -Width 220 -Height 200 -DataSource $ArmourJSON -DisplayMember 'name'

    $checkboxShield = New-Object System.Windows.Forms.CheckBox
    $checkboxShield.Location = New-Object System.Drawing.Point(25, 487)
    $checkboxShield.Size = New-Object System.Drawing.Size(120, 40)
    $checkboxShield.Text = "Shield?"
    $checkboxShield.Checked = $false

    $form.Controls.AddRange($gearControls)
    $form.Controls.AddRange($armorControls)
    $form.Controls.Add($checkboxShield)

    # Display the form and process result
    $form.Topmost = $true
    $form.Add_Shown({$form.Activate()})
    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        # Initialize weapons array and weapon descriptions
        $global:Weapons = @()
        $global:WeaponDescription = ""

        # Handle individual weapon slots and build the weapon description
        $global:WeaponDescription += Process-WeaponSelection -selectedWeapon $weapon1Controls[1].SelectedItem -slotNumber 1
        $global:WeaponDescription += Process-WeaponSelection -selectedWeapon $weapon2Controls[1].SelectedItem -slotNumber 2
        $global:WeaponDescription += Process-WeaponSelection -selectedWeapon $weapon3Controls[1].SelectedItem -slotNumber 3

        # Remove trailing comma and space from the description
        $global:WeaponDescription = $global:WeaponDescription.TrimEnd(", ")

        # Handle armor and gear selection
        $selectedArmor = $armorControls[1].SelectedItem
        if ($selectedArmor) {
            $baseAC = [int]$selectedArmor.BaseAC
            $armorType = $selectedArmor.Type
            $maxDexBonus = [int]$selectedArmor.MaxDexBonus
            $dexModifier = [int]$global:DEXMod

            if ($selectedArmor.DexModifierApplicable -and $armorType -eq 'Medium') {
                $dexModifier = [math]::Min($dexModifier, $maxDexBonus)
            }

            $global:ArmourClass = $baseAC + $dexModifier

            if ($checkboxShield.Checked) {
                $global:ArmourClass += 2
            }

            # Set weights
            $global:ArmorWeight = $selectedArmor.Weight
            $global:GearWeight = $gearControls[1].SelectedItem.Weight

            Debug-Log "Selected Armor: $($selectedArmor.Name)"
            Debug-Log "Armor Type: $armorType"
            Debug-Log "Base AC: $baseAC"
            Debug-Log "Dexterity Modifier: $dexModifier"
            Debug-Log "Calculated ArmourClass: $($global:ArmourClass)"
        } else {
            Debug-Log "No Armor Selected"
        }

        # Debug the combined WeaponDescription
        Debug-Log "Combined Weapon Description: $($global:WeaponDescription)"
    } elseif ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
        Debug-Log "[Debug] Form was canceled by the user."
        exit
    }
}

function Process-WeaponSelection {
    param (
        [object]$selectedWeapon,
        [int]$slotNumber
    )

    if ($selectedWeapon) {
        $global:Weapons += @{
            Name = $selectedWeapon.Name
            Damage = $selectedWeapon.WeaponDamage
            ATK_Bonus = $selectedWeapon.WPNATK_Bonus
            Weight = $selectedWeapon.WeaponWeight
            Properties = $selectedWeapon.WeaponProperties
        }

        # Build the weapon description string
        $description = "$($selectedWeapon.Name) - Damage: $($selectedWeapon.WeaponDamage), ATK Bonus: $($selectedWeapon.WPNATK_Bonus); "
        Debug-Log "Weapon$slotNumber Selected: $($selectedWeapon.Name)"

        return $description
    } else {
        Debug-Log "No Weapon Selected for Weapon Slot $slotNumber"
        return ""
    }
}

# Function to display the choose skills form
function Show-ChooseSkillsForm {
    Debug-Log "[Debug] Displaying Choose Skills Form"

    # Ensure $global:CharacterParameters is initialized
    if (-not $global:CharacterParameters) {
        $global:CharacterParameters = @{
            Fields = @{}
        }
    }

    # Mapping of skills to checkboxes
    $global:SkillToCheckboxMap = @{
        "Acrobatics"        = 'Check Box 23'
        "Animal Handling"   = 'Check Box 24'
        "Arcana"            = 'Check Box 25'
        "Athletics"         = 'Check Box 26'
        "Deception"         = 'Check Box 27'
        "History"           = 'Check Box 28'
        "Insight"           = 'Check Box 29'
        "Intimidation"      = 'Check Box 30'
        "Investigation"     = 'Check Box 31'
        "Medicine"          = 'Check Box 32'
        "Nature"            = 'Check Box 33'
        "Perception"        = 'Check Box 34'
        "Performance"       = 'Check Box 35'
        "Persuasion"        = 'Check Box 36'
        "Religion"          = 'Check Box 37'
        "Sleight of Hand"   = 'Check Box 38'
        "Stealth"           = 'Check Box 39'
        "Survival"          = 'Check Box 40'
    }
    
    # Create the form
    $form = New-ProgramForm -Title 'Select Skills' -Width 400 -Height 600 -AcceptButtonText 'Next' -SkipButtonText 'Skip' -CancelButtonText 'Cancel'

    # Create list box controls for selecting up to 3 skills
    $skill1Controls = Set-ListBox -LabelText 'Select Skill 1:' -X 10 -Y 20 -Width 360 -Height 150 -DataSource $global:SelectedClass.Skills
    $skill2Controls = Set-ListBox -LabelText 'Select Skill 2:' -X 10 -Y 190 -Width 360 -Height 150 -DataSource $global:SelectedClass.Skills
    $skill3Controls = Set-ListBox -LabelText 'Select Skill 3:' -X 10 -Y 360 -Width 360 -Height 150 -DataSource $global:SelectedClass.Skills

    # Add controls to the form
    $form.Controls.AddRange($skill1Controls)
    $form.Controls.AddRange($skill2Controls)
    $form.Controls.AddRange($skill3Controls)

    $form.Topmost = $true
    $form.Add_Shown({$form.Activate()})
    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        # Initialize SelectedSkills
        $global:SelectedSkills = @()

        # Capture the selected skills
        if ($skill1Controls[1].SelectedItem) {
            $global:SelectedSkills += $skill1Controls[1].SelectedItem.Name
            Debug-Log "[Debug] Selected Skill 1: $($skill1Controls[1].SelectedItem.Name)"
        } else {
            Debug-Log "[Debug] Skill 1 was not selected."
        }

        if ($skill2Controls[1].SelectedItem) {
            $global:SelectedSkills += $skill2Controls[1].SelectedItem.Name
            Debug-Log "[Debug] Selected Skill 2: $($skill2Controls[1].SelectedItem.Name)"
        } else {
            Debug-Log "[Debug] Skill 2 was not selected."
        }

        if ($skill3Controls[1].SelectedItem) {
            $global:SelectedSkills += $skill3Controls[1].SelectedItem.Name
            Debug-Log "[Debug] Selected Skill 3: $($skill3Controls[1].SelectedItem.Name)"
        } else {
            Debug-Log "[Debug] Skill 3 was not selected."
        }

        # Debugging the captured skills
        Debug-Log "Selected Skills: $($global:SelectedSkills -join ', ')"

        # Dynamically set the skill checkboxes based on the selected skills
        foreach ($skill in $global:SelectedSkills) {
            if ($skill -and $global:SkillToCheckboxMap.ContainsKey($skill)) {
                $checkboxField = $global:SkillToCheckboxMap[$skill]
                if ($checkboxField) {
                    $global:CharacterParameters.Fields[$checkboxField] = "Yes"
                    Debug-Log "[Debug] Set checkbox field '$checkboxField' to 'Yes' for skill '$skill'"
                }
            }
        }

        # Set other skills as "off" if not selected
        foreach ($key in $global:SkillToCheckboxMap.Keys) {
            if (-not $global:SelectedSkills -contains $key) {
                $checkboxField = $global:SkillToCheckboxMap[$key]
                if ($checkboxField) {
                    $global:CharacterParameters.Fields[$checkboxField] = "off"
                    Debug-Log "[Debug] Set checkbox field '$checkboxField' to 'off' for skill '$key'"
                }
            }
        }

    } elseif ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
        Debug-Log "[Debug] Form was canceled by the user."
        exit
    }
}

# Function to display the stats chooser form
function Show-StatsChooserForm {
    Debug-Log "[Debug] Displaying Stats Chooser Form"

    # Create form
    $form = New-ProgramForm -Title 'Allocate Character Stats' -Width 400 -Height 350 -AcceptButtonText 'OK' -SkipButtonText 'Skip' -CancelButtonText 'Cancel'

    # Label for remaining points
    $remainingPointsLabel = New-Object System.Windows.Forms.Label
    $remainingPointsLabel.Location = New-Object System.Drawing.Point(10, 10)
    $remainingPointsLabel.Size = New-Object System.Drawing.Size(150, 20)
    $remainingPointsLabel.Text = "Remaining Points: $($global:TotalPoints)"
    $form.Controls.Add($remainingPointsLabel)

    $resetButton = New-Object System.Windows.Forms.Button
    $resetButton.Location = New-Object System.Drawing.Point(170, 7)
    $resetButton.Size = New-Object System.Drawing.Size(60, 23)
    $resetButton.Text = 'Reset'
    $resetButton.Add_Click({
        $global:StatIncrements.Keys | ForEach-Object { $global:StatIncrements[$_] = 0 }
        UpdateFormControls -form $form -remainingPointsLabel $remainingPointsLabel
    })
    $form.Controls.Add($resetButton)

    # Dictionary to store label references
    $statLabels = @{}

    # Helper function to add stat controls
    function Add-StatControls {
        param (
            [string]$stat,
            [int]$yPosition
        )

        $label = New-Object System.Windows.Forms.Label
        $label.Location = New-Object System.Drawing.Point(10, $yPosition)
        $label.Size = New-Object System.Drawing.Size(80, 20)
        $label.Text = $stat

        $valueLabel = New-Object System.Windows.Forms.Label
        $valueLabel.Location = New-Object System.Drawing.Point(200, $yPosition)
        $valueLabel.Size = New-Object System.Drawing.Size(40, 20)
        $valueLabel.Text = ($global:BaseStats[$stat] + $global:StatIncrements[$stat]).ToString()
        $valueLabel.Tag = $stat

        # Store the reference in the dictionary
        $statLabels[$stat] = $valueLabel

        Debug-Log "[Debug] valueLabel created for $stat with type: $($valueLabel.GetType().FullName)"

        $upButton = New-Object System.Windows.Forms.Button
        $upButton.Location = New-Object System.Drawing.Point(100, $yPosition)
        $upButton.Size = New-Object System.Drawing.Size(40, 23)
        $upButton.Text = "+"

        $downButton = New-Object System.Windows.Forms.Button
        $downButton.Location = New-Object System.Drawing.Point(150, $yPosition)
        $downButton.Size = New-Object System.Drawing.Size(40, 23)
        $downButton.Text = "-"

        # Attach event handlers, using the dictionary to fetch the correct label
        $upButton.Add_Click({
            Debug-Log "[Debug] Handling click for $stat, direction up"
            HandleButtonClick -stat $stat -direction 'up' -valueLabel $statLabels[$stat] -remainingPointsLabel $remainingPointsLabel
        })

        $downButton.Add_Click({
            Debug-Log "[Debug] Handling click for $stat, direction down"
            HandleButtonClick -stat $stat -direction 'down' -valueLabel $statLabels[$stat] -remainingPointsLabel $remainingPointsLabel
        })

        $form.Controls.Add($label)
        $form.Controls.Add($upButton)
        $form.Controls.Add($downButton)
        $form.Controls.Add($valueLabel)
    }

    $yPosition = 40
    foreach ($stat in $global:BaseStats.Keys) {
        Add-StatControls -stat $stat -yPosition $yPosition
        $yPosition += 30
    }

    $form.Topmost = $true
    $form.Add_Shown({$form.Activate()})
    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        foreach ($stat in $global:BaseStats.Keys) {
            Set-Variable -Name $stat -Value ($global:BaseStats[$stat] + $global:StatIncrements[$stat]) -Scope Global
        }
        Debug-Log "[Debug] Stats allocated: STR=$($global:STR), DEX=$($global:DEX), CON=$($global:CON), INT=$($global:INT), WIS=$($global:WIS), CHA=$($global:CHA)"
    } elseif ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
        Debug-Log "[Debug] Form canceled by the user."
        exit
    }
}

# Button click handler
function HandleButtonClick {
    param (
        [string]$stat,
        [string]$direction,
        [System.Windows.Forms.Label]$valueLabel,
        [System.Windows.Forms.Label]$remainingPointsLabel
    )

    # Correct the logic: "up" should add points, "down" should subtract points
    if ($direction -eq 'up' -and $global:TotalPoints -gt 0) {
        $global:StatIncrements[$stat]++     # Increment the stat value
        $global:TotalPoints--               # Decrement the remaining points
    } elseif ($direction -eq 'down' -and $global:StatIncrements[$stat] -gt 0) {
        $global:StatIncrements[$stat]--     # Decrement the stat value
        $global:TotalPoints++               # Increment the remaining points
    }

    # Update the labels with the new values
    $valueLabel.Text = ($global:BaseStats[$stat] + $global:StatIncrements[$stat]).ToString()
    $remainingPointsLabel.Text = "Remaining Points: $($global:TotalPoints)"

    # Force the labels to refresh
    $valueLabel.Refresh()
    $remainingPointsLabel.Refresh()
}

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

# Initialize global variables for stat allocation
$global:TotalPoints = 27
$global:BaseStats = @{
    STR = 8
    DEX = 8
    CON = 8
    INT = 8
    WIS = 8
    CHA = 8
}
$global:StatIncrements = @{
    STR = 0
    DEX = 0
    CON = 0
    INT = 0
    WIS = 0
    CHA = 0
}

# Function to display the character backstory form
function Show-BackstoryForm {
    Debug-Log "[Debug] Displaying Backstory Form"
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
        Debug-Log "[Debug] Form was canceled by the user."
        exit
    }
}

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

# Show all forms in order
Show-BasicInfoForm
Show-RaceForm
Show-SubRaceForm
Show-CharacterFeaturesForm
Show-ClassAndAlignmentForm
Show-SubClassForm
Show-WeaponAndArmourForm
Show-ChooseSkillsForm
Show-StatsChooserForm
Show-BackstoryForm
Show-AdditionalDetailsForm

Debug-Log "[Debug] Calculating stats"
Calculate-CharacterStats
Debug-Log "[Debug] All forms have been displayed, proceeding with Save"

# Addvanced Debug purposes only for the PDF File inspect, not for normal debug
#$fieldNames = Get-PdfFieldNames -FilePath "$PSScriptRoot\Assets\Empty_PDF\DnD_5E_CharacterSheet - Form Fillable.pdf"
#$fieldNames | ForEach-Object { Write-Host $_ }

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
        'PersonalityTraits ' = $PersonalityTraits;
        'STRmod' = $STRmod;
        'ST Strength' = $ST_STR;
        'DEX' = $DEX;
        'Ideals' = $Ideals;
        'DEXmod ' = $DEXmod;
        'Bonds' = $Bonds;
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
        'Flaws' = $Flaws;
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
        'Wpn Name' = $global:Weapons[0].Name;
        'Wpn1 AtkBonus' = $global:Weapons[0].ATK_Bonus;
        'Wpn1 Damage' = $global:Weapons[0].Damage;
        'Insight' = $Insight;
        'Intimidation' = $Intimidation;
        'Wpn Name 2' = $global:Weapons[1].Name;
        'Wpn2 AtkBonus ' = $global:Weapons[1].ATK_Bonus;
        'Wpn Name 3' = $global:Weapons[2].Name;
        'Wpn3 AtkBonus  ' = $global:Weapons[2].ATK_Bonus;
        'Check Box 11' = if ($Check11) { "Yes" } else { "off" }; #Strength Button
        'Check Box 18' = if ($Check18) { "Yes" } else { "off" }; #Dexterity Button
        'Check Box 19' = if ($Check19) { "Yes" } else { "off" }; #Constitution Button
        'Check Box 20' = if ($Check20) { "Yes" } else { "off" }; #Intelligence Button
        'Check Box 21' = if ($Check21) { "Yes" } else { "off" }; #Wisdom Button
        'Check Box 22' = if ($Check22) { "Yes" } else { "off" }; #Charisma Button
        'INTmod' = $INTmod;
        'Wpn2 Damage ' = $global:Weapons[1].Damage;
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
        'Check Box 23' = if ($Check23) { "Yes" } else { "off" }; #Acrobatics Button
        'Check Box 24' = if ($Check24) { "Yes" } else { "off" }; #Animal Handling Button
        'Check Box 25' = if ($Check25) { "Yes" } else { "off" }; #Arcana Button
        'Check Box 26' = if ($Check26) { "Yes" } else { "off" }; #Athletics Button
        'Check Box 27' = if ($Check27) { "Yes" } else { "off" }; #Deception Button
        'Check Box 28' = if ($Check28) { "Yes" } else { "off" }; #History Button
        'Check Box 29' = if ($Check29) { "Yes" } else { "off" }; #Insight Button
        'Check Box 30' = if ($Check30) { "Yes" } else { "off" }; #Intimidation Button
        'Check Box 31' = if ($Check31) { "Yes" } else { "off" }; #Investigation Button
        'Check Box 32' = if ($Check32) { "Yes" } else { "off" }; #Medicine Button
        'Check Box 33' = if ($Check33) { "Yes" } else { "off" }; #Nature Button
        'Check Box 34' = if ($Check34) { "Yes" } else { "off" }; #Perception Button
        'Check Box 35' = if ($Check35) { "Yes" } else { "off" }; #Performance Button
        'Check Box 36' = if ($Check36) { "Yes" } else { "off" }; #Persuation Button
        'Check Box 37' = if ($Check37) { "Yes" } else { "off" }; #Religion Button
        'Check Box 38' = if ($Check38) { "Yes" } else { "off" }; #Slight of Hand Button
        'Check Box 39' = if ($Check39) { "Yes" } else { "off" }; #Stealth Button
        'Check Box 40' = if ($Check40) { "Yes" } else { "off" }; #Survival Button
        'Persuasion' = $Persuation;
        'HPMax' = $HPMax;
        'HPCurrent' = $HP;
        #'HPTemp' = ;
        'Wpn3 Damage ' = $global:Weapons[2].Damage;
        'SleightofHand' = $SleightOfHand;
        'CHamod' = $CHAmod;
        'Survival' = $Survival;
        'AttacksSpellcasting' = $WeaponDescription;
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
    ImageFields = @{
        'CHARACTER IMAGE' = $CharacterImage
    }
}

# Validate that the Fields and ImageField are correctly cast to Hashtable
$characterparameters.Fields = [hashtable]$characterparameters.Fields
$characterparameters.ImageFields = [hashtable]$characterparameters.ImageFields

# Execute the PDF save function
Save-PdfField @characterparameters

# End of character Creation Dialog box
$ButtonType = [System.Windows.MessageBoxButton]::Ok
$MessageIcon = [System.Windows.MessageBoxImage]::Information
$MessageBody = "Dungeons And Dragons Character Successfully Created!"
$MessageTitle = "Spark's D&D Character Creator"
[System.Windows.MessageBox]::Show($MessageBody, $MessageTitle, $ButtonType, $MessageIcon)
Debug-Log "[Debug] Character successfully created message displayed."
Exit