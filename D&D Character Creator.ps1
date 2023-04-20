clear-host
#All Functions
#Hide powershell's console so only the forms show, unhide during development or need to varify output
function Show-Console
{
    param ([Switch]$Show,[Switch]$Hide)
    if (-not ("Console.Window" -as [type])) { 

        Add-Type -Name Window -Namespace Console -MemberDefinition '
        [DllImport("Kernel32.dll")]
        public static extern IntPtr GetConsoleWindow();

        [DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
        '
    }
    if ($Show)
    {
        $consolePtr = [Console.Window]::GetConsoleWindow()
        $null = [Console.Window]::ShowWindow($consolePtr, 5)
    }
    if ($Hide)
    {
        $consolePtr = [Console.Window]::GetConsoleWindow()
        #0 hide
        $null = [Console.Window]::ShowWindow($consolePtr, 0)
    }
}
#To show the console change "-hide" to "-show"
show-console -show
#Form function
function New-ProgramForm {
    param (
        [Parameter(Mandatory)]
        [string]$Title,

        [Parameter(Mandatory)]
        [int]$Width,

        [Parameter(Mandatory)]
        [int]$Height,

        [Parameter(Mandatory)]
        [string]$AcceptButtonText,

        [Parameter(Mandatory)]
        [string]$SkipButtonText,

        [Parameter(Mandatory)]
        [string]$BackButtonText,

        [Parameter(Mandatory)]
        [string]$CancelButtonText
    )

    $form = New-Object System.Windows.Forms.Form
    $form.Text = $Title
    $form.Size = New-Object System.Drawing.Size($Width,$Height)
    $form.StartPosition = 'CenterScreen'
    $objIcon = New-Object system.drawing.icon ("$PSScriptRoot\Assets\installer.ico")
    $objImage = [system.drawing.image]::FromFile("$PSScriptRoot\Assets\form_background.png")
    $form.Icon = $objIcon
    $form.BackgroundImage = $objImage
    $form.BackgroundImageLayout = [System.Windows.Forms.ImageLayout]::Stretch
    
    #Create a panel to hold the buttons
    $buttonPanel = New-Object System.Windows.Forms.Panel
    $buttonPanel.Dock = [System.Windows.Forms.DockStyle]::Bottom
    $buttonPanel.Height = 50
    $form.Controls.Add($buttonPanel)

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(0,0)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = $AcceptButtonText
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $buttonPanel.Controls.Add($okButton)

    $skipButton = New-Object System.Windows.Forms.Button
    $skipButton.Location = New-Object System.Drawing.Point(75,0)
    $skipButton.Size = New-Object System.Drawing.Size(75,23)
    $skipButton.Text = $SkipButtonText
    $skipButton.DialogResult = [System.Windows.Forms.DialogResult]::Ignore
    $buttonPanel.Controls.Add($skipButton)

    $backButton = New-Object System.Windows.Forms.Button
    $backButton.Location = New-Object System.Drawing.Point(150,0)
    $backButton.Size = New-Object System.Drawing.Size(75,23)
    $backButton.Text = $BackButtonText
    $backButton.DialogResult = [System.Windows.Forms.DialogResult]::Retry
    $buttonPanel.Controls.Add($backButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(225,0)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = $CancelButtonText
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $buttonPanel.Controls.Add($cancelButton)

    return $form
}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#IF YOU HAVEN'T PLEASE READ THE RULEBOOK FOR D&D AS THIS POWERSHELL SCRIPT JUST SIMPLIFIES MAKING A CHARACTER
#CURRENTLY INDEV SO EXPECT ISSUES / BUGS OR DESIGN WEIRDNESS
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Sparks's D&D Character Creator powershell script, this is intended for fun and feel free to edit fields for future use but please keep me credited
#Remember to comment/remove all "Write-Host" statements as this is only for testing purposes
#This powershell script follows original 5E rules, the website to get the information is:
#Sources: https://www.dndbeyond.com/sources/basic-rules
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Further down the script you see $value.statement = New-Object System.Drawing.Size(240,50)
#The (240,50) means width,height for incase you forget
#(10,50) 50 = up/down, 10 = left/right - Orientation 
#Every part of the powershell script is changable, this is for custom games, hence why things aren't grouped together
#Majority of the stats used came from the cards for D&D
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#When adding $Var together for things like combined numbers or words you need to do:
#$TotalVar = $Var1 + $Var2 + $Var3 and not have {} in there as that does not work
#$PSScriptRoot <- Use for rooting to this script location
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#To pull information from a json example:
#Extract specific information from the JSON object
#$name = $jsonObject.name
#$age = $jsonObject.age
#$size = $jsonObject.size
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#You need to call these files inside the if -eq code! Example:
#$characterbackgroundselect.SelectedItem
#$SelectedRace = $ChosenRace.SelectedItem
#$ExportRace = $SelectedRace.Name
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Then you can call an array to loop the information
#foreach ($item in $jsonObject.items) {
#    Write-Host $item.property
#}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#The "return" for the retry is a temp if statement as I plan a future feature
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#----------------------------
#       Script Start
#----------------------------
#Type loader, forms
Add-Type -AssemblyName System.Windows.Forms
#Type loader, drawing for forms
Add-Type -AssemblyName System.Drawing
#Type loader, presentation framework
Add-Type -AssemblyName PresentationCore,PresentationFramework
#Imports Modules + Add Types
Import-Module -Name $PSScriptRoot\Assets\iText\PDFForm | Out-Null
Add-Type -Path "$PSScriptRoot\Assets\iText\itextsharp.dll"
#Import-Module -Name $PSScriptRoot\Assets\Modules\LangTranslate | Out-Null
#Form images
$objIcon = New-Object system.drawing.icon ("$PSScriptRoot\Assets\installer.ico")
$objImage = [system.drawing.image]::FromFile("$PSScriptRoot\Assets\form_background.png")
#----------------------------
#         JSON Load
#----------------------------
# Get the path to the folder containing the default JSON files
$defaultsPath = Join-Path $PSScriptRoot "Assets"
# Define a function to process JSON files
function Get-JsonData($path) {
    # Get all JSON files in the folder
    $jsonFiles = Get-ChildItem -Path $path -Filter *.json

    # Loop through each JSON file and process its contents
    foreach ($file in $jsonFiles) {
        # Read the contents of the JSON file
        $content = Get-Content -Path $file.FullName -Raw
        # Convert the JSON content to a PowerShell object and output it
        $content | ConvertFrom-Json
    }
}
#Process default JSON files
$defaultJSON = Get-JsonData -path $defaultsPath
#Process other JSON files
$CharacterBackgroundJSON = Get-JsonData -path "$PSScriptRoot\Assets\Backgrounds"
$RacesJSON = Get-JsonData -path "$PSScriptRoot\Assets\Races"
$EyesJSON = Get-JsonData -path "$PSScriptRoot\Assets\Character_Features\Eyes"
$HairJSON = Get-JsonData -path "$PSScriptRoot\Assets\Character_Features\Hair"
$SkinJSON = Get-JsonData -path "$PSScriptRoot\Assets\Character_Features\Skin"
$AlignmentJSON = Get-JsonData -path "$PSScriptRoot\Assets\Alignments"
$ClassesJSON = Get-JsonData -path "$PSScriptRoot\Assets\Classes"
$WeaponJSON = Get-JsonData -path "$PSScriptRoot\Assets\Weapons"
#---- Default Value's -----
$WrittenCharactername = $DefaultJSON.Charactername
$WrittenPlayername = $DefaultJSON.Playername
$WrittenAge = $DefaultJSON.Age
$ExportBackground = $DefaultJSON.Characterbackground
$Height = $DefaultJSON.Playerheight
$Size = $DefaultJSON.PlayerSize
$Eyes = $DefaultJSON.Characterfeatureseyes
$Hair = $DefaultJSON.characterfeatureshair
$Skin = $DefaultJSON.characterfeaturesskin
#$CharacterImage = $DefaultJSON.CharacterImage
$FactionSymbol = $DefaultJSON.FactionSymbol
$PersonalityTraits = $DefaultJSON.PersonalityTraits
$ProficencyBonus = $DefaultJSON.ProficencyBonus
$Class = $DefaultJSON.ClassLevel
$HP = $DefaultJSON.HP
$HD = $DefaultJSON.HD
$Speed = $DefaultJSON.SpeedTotal
$DEX = $DefaultJSON.DEX
$CON = $DefaultJSON.CON
$INT = $DefaultJSON.INT
$WIS = $DefaultJSON.WIS
$CHA = $DefaultJSON.CHA
$SpokenLanguages = $DefaultJSON.SpokenLanguages
$InitiativeTotal = $DefaultJSON.InitiativeTotal
$Characterbackstory = $DefaultJSON.Characterbackstory
$factionname = $DefaultJSON.factionname
$Allies = $DefaultJSON.alliesandorganisations
$AddionalfeatTraits = $DefaultJSON.AddionalfeatTraits
$Ideals = $DefaultJSON.Ideals
$Bonds = $DefaultJSON.Bonds
$Flaws = $DefaultJSON.Flaws
$CombinedWeaponStats = $DefaultJSON.CombinedWeaponStats
$ChosenArmour = $DefaultJSON.ChosenArmour
$ArmourClass = $DefaultJSON.ArmourClass
$HitDiceTotal = $DefaultJSON.HitDiceTotal
$XP = $DefaultJSON.XP
$Inspiration = $DefaultJSON.Inspiration
$CopperCP = $DefaultJSON.CopperCP
$SilverSP = $DefaultJSON.SilverSP
$ElectrumEP = $DefaultJSON.ElectrumEP
$GoldGP = $DefaultJSON.GoldGP
$PlatinumPP = $DefaultJSON.PlatinumPP
$SpellCastingClass = $DefaultJSON.SpellCastingClass
$SpellCastingAbility = $DefaultJSON.SpellCastingAbility
$SpellCastingSaveDC = $DefaultJSON.SpellCastingSaveDC
$SpellCastingAttackBonus = $DefaultJSON.SpellCastingAttackBonus
$Acrobatics = $DefaultJSON.Acrobatics
$AnimalHandling = $DefaultJSON.AnimalHandling
$Arcana = $DefaultJSON.Arcana
$Athletics = $DefaultJSON.Athletics
$Deception = $DefaultJSON.Deception
$History = $DefaultJSON.History
$Insight = $DefaultJSON.Insight
$Intimidation = $DefaultJSON.Intimidation
$Investigation = $DefaultJSON.Investigation
$Medicine = $DefaultJSON.Medicine
$Nature = $DefaultJSON.Nature
$Perception = $DefaultJSON.Perception
$Performance = $DefaultJSON.Performance
$Persuation = $DefaultJSON.Persuation
$Religion = $DefaultJSON.Religion
$SleightOfHand = $DefaultJSON.SleightOfHand
$Stealth = $DefaultJSON.Stealth
$Survival = $DefaultJSON.Survival
$Passive = $DefaultJSON.Passive
$Comma = ", "
Write-Host "Loaded Defaults"
#----------------------------
#        Form Load
#----------------------------
#Basic user information gathering - Basic Information
    #Basic form
#Create form for basic information gathering
$form = New-ProgramForm -Title 'Sparks D&D Character Creator' -Width 500 -Height 350 -AcceptButtonText 'Next' -SkipButtonText 'Skip' -BackButtonText 'Back' -CancelButtonText 'Cancel'
#Add character name label and textbox to form
$characterLabel = New-Object System.Windows.Forms.Label
$characterLabel.Location = New-Object System.Drawing.Point(10, 20)
$characterLabel.Size = New-Object System.Drawing.Size(118, 18)
$characterLabel.Text = 'Character Name:'
$characterLabel.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($characterLabel)

$characterName = New-Object System.Windows.Forms.TextBox
$characterName.Location = New-Object System.Drawing.Point(10, 40)
$characterName.Size = New-Object System.Drawing.Size(180, 20)
$characterName.MaxLength = 30
$form.Controls.Add($characterName)

#Add age label and textbox to form
$ageLabel = New-Object System.Windows.Forms.Label
$ageLabel.Location = New-Object System.Drawing.Point(10, 67)
$ageLabel.Size = New-Object System.Drawing.Size(110, 18)
$ageLabel.Text = 'Character Age:'
$ageLabel.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($ageLabel)

$age = New-Object System.Windows.Forms.TextBox
$age.Location = New-Object System.Drawing.Point(10, 85)
$age.Size = New-Object System.Drawing.Size(58, 20)
$age.MaxLength = 5
$age.Add_TextChanged({$age.Text = $age.Text -replace '\D'})
$form.Controls.Add($age)

# Add player name label and textbox to form
$playerLabel = New-Object System.Windows.Forms.Label
$playerLabel.Location = New-Object System.Drawing.Point(10, 108)
$playerLabel.Size = New-Object System.Drawing.Size(100, 18)
$playerLabel.Text = 'Player Name:'
$playerLabel.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($playerLabel)

$playerName = New-Object System.Windows.Forms.TextBox
$playerName.Location = New-Object System.Drawing.Point(10, 127)
$playerName.Size = New-Object System.Drawing.Size(180, 20)
$playerName.MaxLength = 30
$form.Controls.Add($playerName)

# Show the form and wait for a button to be clicked
$result = $form.ShowDialog()
# Check which button was clicked and perform the appropriate action
if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        #Output the written data from the form
        $WrittenCharactername = $charactername.Text
        $WrittenPlayername = $playername.Text
        $WrittenAge = $Age.Text
        #If the console is set to show, this is just for that
        Write-Host "Character Name is $WrittenCharactername"
        Write-Host "Character Age is $WrittenPlayername"
        Write-Host "Player Name is $WrittenAge"
} elseif ($result -eq [System.Windows.Forms.DialogResult]::Ignore) {
    # Skip button was clicked, do something else
} elseif ($result -eq [System.Windows.Forms.DialogResult]::Retry) {
    # Back button was clicked, do something else
} else {
    # Cancel button was clicked, exit the script
    exit
}
#Basic user information gathering - Class and race
    #Basic form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Sparks D&D Character Creator'
    $form.Size = New-Object System.Drawing.Size(450,350)
    $form.StartPosition = 'CenterScreen'
    $form.Icon = $objIcon
    $form.BackgroundImage = $objImage
    $form.BackgroundImageLayout = [System.Windows.Forms.ImageLayout]::Stretch
    #Ok button for form
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(75,270)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'Next'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)
    #Skip button for form
    $skipButton = New-Object System.Windows.Forms.Button
    $skipButton.Location = New-Object System.Drawing.Point(150,270)
    $skipButton.Size = New-Object System.Drawing.Size(75,23)
    $skipButton.Text = 'Skip'
    $skipButton.DialogResult = [System.Windows.Forms.DialogResult]::Ignore
    $form.AcceptButton = $skipButton
    $form.Controls.Add($skipButton)
    #Back button for form (still in development)
    $backButton = New-Object System.Windows.Forms.Button
    $backButton.Location = New-Object System.Drawing.Point(225,270)
    $backButton.Size = New-Object System.Drawing.Size(75,23)
    $backButton.Text = 'Back'
    $backButton.DialogResult = [System.Windows.Forms.DialogResult]::Retry
    $form.CancelButton = $backButton
    $form.Controls.Add($backButton)
    #Cancel button for form
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(300,270)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)
    #CharacterBackround form
    $characterbackground = New-Object System.Windows.Forms.Label
    $characterbackground.Location = New-Object System.Drawing.Point(10,20)
    $characterbackground.Size = New-Object System.Drawing.Size(160,18)
    $characterbackground.Text = 'Please Select a Background:'
    $form.Controls.Add($characterbackground)
    $characterbackgroundselect = New-Object System.Windows.Forms.ListBox
    $characterbackgroundselect.Location = New-Object System.Drawing.Point(10,40)
    $characterbackgroundselect.Size = New-Object System.Drawing.Size(160,68)
    $characterbackgroundselect.DataSource = [system.collections.arraylist]$CharacterBackgroundJSON
    $characterbackgroundselect.DisplayMember = "name"
    $characterbackgroundselect.Height = 170
    $form.Controls.Add($characterbackgroundselect)
    #Race form
    $racelabel = New-Object System.Windows.Forms.Label
    $racelabel.Location = New-Object System.Drawing.Point(220,20)
    $racelabel.Size = New-Object System.Drawing.Size(118,18)
    $racelabel.Text = 'Please select a Race:'
    $form.Controls.Add($racelabel)
    $ChosenRace = New-Object System.Windows.Forms.ListBox
    $ChosenRace.Location = New-Object System.Drawing.Point(220,40)
    $ChosenRace.Size = New-Object System.Drawing.Size(200,20)
    $ChosenRace.DataSource = [system.collections.arraylist]$RacesJSON
    $ChosenRace.DisplayMember = "name"
    $ChosenRace.Height = 170
    $form.Controls.Add($ChosenRace)
#(To add a custom race go to $PSScriptRoot\Assets\Races to add a JSON file)
#(A template.txt will show what you need to add)
    #Show form
    $form.Topmost = $true
    $Form.Add_Shown({$Form.Activate()})
    $characterbackgroundtextbox = $form.ShowDialog()
        if ($characterbackgroundtextbox -eq [System.Windows.Forms.DialogResult]::OK)
        {
            #Background Selection fillout
            $SelectedBackground = $characterbackgroundselect.SelectedItem
            $SelectedRace = $ChosenRace.SelectedItem
            #Background
            $ExportBackground = $SelectedBackground.Name
            #Race Selection
            $ExportRace = $SelectedRace.Name
            #Other Character Properties
            $Feature1TTraits1 = $SelectedRace.Description
            $HP = $SelectedRace.HP
            $Speed = $SelectedRace.Speed
            $Size = $SelectedRace.Size
            $Height = $SelectedRace.Height
            $SpokenLanguages = $SelectedRace.Languages
            $Special = $SelectedRace.Special
            #Image (for later)
            #Stats
            $STR = $SelectedRace.Strength
            $DEX = $SelectedRace.Dexterity
            $CON = $SelectedRace.Constitution
            $INT = $SelectedRace.Intelligence
            $WIS = $SelectedRace.Wisdom
            $CHA = $SelectedRace.Charisma
            $STRMod = $SelectedRace.StrengthMod
            $DEXMod = $SelectedRace.DexterityMod
            $CONMod = $SelectedRace.ConstitutionMod
            $INTMod = $SelectedRace.IntelligenceMod
            $WISMod = $SelectedRace.WisdomMod
            $CHAMod = $SelectedRace.CharismaMod
            $ST_STR = $SelectedRace.Saving_Strength
            $ST_DEX = $SelectedRace.Saving_Dexterity
            $ST_CON = $SelectedRace.Saving_Constitution
            $ST_INT = $SelectedRace.Saving_Intelligence
            $ST_WIS = $SelectedRace.Saving_Wisdom
            $ST_CHA = $SelectedRace.Saving_Charisma
            #If the console is set to show, this is just for that
            Write-Host "Race is $ExportRace"
            Write-Host "Background is $ExportBackground"
        }
        if ($characterbackgroundtextbox -eq [System.Windows.Forms.DialogResult]::Ignore)
        {
            #Defaults will load
        }
        if ($characterbackgroundtextbox -eq [System.Windows.Forms.DialogResult]::Retry)
        {
            return
        }
        if ($characterbackgroundtextbox -eq [System.Windows.Forms.DialogResult]::Cancel)
        {
            Exit
        }
#end of Character race and background
    
    #if ($ -match '**')
    #{
    #    $img = [System.Drawing.Image]::Fromfile('$PSScriptRoot\Assets\Race_Pictures\**.png')
    #    Add-Content -path "$PSScriptRoot\Assets\Race_Descriptions\**.txt"
    #}

    #Add this feature above, where you select from the list and an image + text loads
    #The race index can be fitted with selection data such as gold or speed
    #Please add all speed bonuses to match either class and race

#Make sure to fill out ALL required subrace data as there is a lot of subraces per primary
#race, this allows a waaay bigger pool of characters

#Small race choices like skin and hair
    #Basic form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Sparks D&D Character Creator'
    $form.Size = New-Object System.Drawing.Size(500,350)
    $form.StartPosition = 'CenterScreen'
    $form.Icon = $objIcon
    $form.BackgroundImage = $objImage
    $form.BackgroundImageLayout = [System.Windows.Forms.ImageLayout]::Stretch
    $form.Width = $objImage.Width
    $form.Height = $objImage.Height
    #Ok button for form
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(75,270)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'Next'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)
    #Skip button for form
    $skipButton = New-Object System.Windows.Forms.Button
    $skipButton.Location = New-Object System.Drawing.Point(150,270)
    $skipButton.Size = New-Object System.Drawing.Size(75,23)
    $skipButton.Text = 'Skip'
    $skipButton.DialogResult = [System.Windows.Forms.DialogResult]::Ignore
    $form.AcceptButton = $skipButton
    $form.Controls.Add($skipButton)
    #Back button for form (still in development)
    $backButton = New-Object System.Windows.Forms.Button
    $backButton.Location = New-Object System.Drawing.Point(225,270)
    $backButton.Size = New-Object System.Drawing.Size(75,23)
    $backButton.Text = 'Back'
    $backButton.DialogResult = [System.Windows.Forms.DialogResult]::Retry
    $form.CancelButton = $backButton
    $form.Controls.Add($backButton)
    #Cancel button for form
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(300,270)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)
    #Character features - Eyes
    $characterfeatureseyes = New-Object System.Windows.Forms.Label
    $characterfeatureseyes.Location = New-Object System.Drawing.Point(10,20)
    $characterfeatureseyes.Size = New-Object System.Drawing.Size(110,18)
    $characterfeatureseyes.Text = 'Select Eyes:'
    $form.Controls.Add($characterfeatureseyes)
    $characterfeaturesselecteyes = New-Object System.Windows.Forms.ListBox
    $characterfeaturesselecteyes.Location = New-Object System.Drawing.Point(10,50)
    $characterfeaturesselecteyes.Size = New-Object System.Drawing.Size(110,65)
    $characterfeaturesselecteyes.DataSource = [system.collections.arraylist]$EyesJSON
    $characterfeaturesselecteyes.DisplayMember = "name"
    $characterfeaturesselecteyes.Height = 170
    $form.Controls.Add($characterfeaturesselecteyes)
    #Character features - Hair
    $characterfeatureshair = New-Object System.Windows.Forms.Label
    $characterfeatureshair.Location = New-Object System.Drawing.Point(125,20)
    $characterfeatureshair.Size = New-Object System.Drawing.Size(110,18)
    $characterfeatureshair.Text = 'Select Hair:'
    $form.Controls.Add($characterfeatureshair)
    $characterfeaturesselecthair = New-Object System.Windows.Forms.ListBox
    $characterfeaturesselecthair.Location = New-Object System.Drawing.Point(125,50)
    $characterfeaturesselecthair.Size = New-Object System.Drawing.Size(110,65)
    $characterfeaturesselecthair.DataSource = [system.collections.arraylist]$HairJSON
    $characterfeaturesselecthair.DisplayMember = "name"
    $characterfeaturesselecthair.Height = 170
    $form.Controls.Add($characterfeaturesselecthair)
    #Character features - Skin
    $characterfeaturesskin = New-Object System.Windows.Forms.Label
    $characterfeaturesskin.Location = New-Object System.Drawing.Point(240,20)
    $characterfeaturesskin.Size = New-Object System.Drawing.Size(110,18)
    $characterfeaturesskin.Text = 'Select Skin:'
    $form.Controls.Add($characterfeaturesskin)
    $characterfeaturesselectskin = New-Object System.Windows.Forms.ListBox
    $characterfeaturesselectskin.Location = New-Object System.Drawing.Point(240,50)
    $characterfeaturesselectskin.Size = New-Object System.Drawing.Size(110,65)
    $characterfeaturesselectskin.DataSource = [system.collections.arraylist]$SkinJSON
    $characterfeaturesselectskin.DisplayMember = "name"
    $characterfeaturesselectskin.Height = 170
    $form.Controls.Add($characterfeaturesselectskin)
    #Show form
    $form.Topmost = $true
    $Form.Add_Shown({$Form.Activate()})
    $characterfeaturestextbox = $form.ShowDialog()
        if ($characterfeaturestextbox -eq [System.Windows.Forms.DialogResult]::OK)
        {
            $SelectedEyes = $characterfeaturesselecteyes.SelectedItem
            $SelectedHair = $characterfeaturesselecthair.SelectedItem
            $SelectedSkin = $characterfeaturesselectskin.SelectedItem
            $Eyes = $SelectedEyes.Name
            $Skin = $SelectedSkin.Name
            $Hair = $SelectedHair.Name
            #If the console is set to show, this is just for that
            Write-Host "Eyes: $Eyes"
            Write-Host "Skin: $Skin"
            Write-Host "Hair: $Hair"
        }
        if ($characterfeaturestextbox -eq [System.Windows.Forms.DialogResult]::Ignore)
        {
            #Defaults will load
        }
        if ($characterfeaturestextbox -eq [System.Windows.Forms.DialogResult]::Retry)
        {
            return
        }
        if ($characterfeaturestextbox -eq [System.Windows.Forms.DialogResult]::Cancel)
        {
            Exit
        }
#End of race additions
#Source: https://www.dandwiki.com/wiki/Random_Hair_and_Eye_Color_(DnD_Other)
#Basic user information gathering - SubRace
    #Basic form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Sparks D&D Character Creator'
    $form.Size = New-Object System.Drawing.Size(500,350)
    $form.StartPosition = 'CenterScreen'
    $form.Icon = $objIcon
    $form.BackgroundImage = $objImage
    $form.BackgroundImageLayout = [System.Windows.Forms.ImageLayout]::Stretch
    $form.Width = $objImage.Width
    $form.Height = $objImage.Height
    #Ok button for form
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(75,270)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'Next'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)
    #Skip button for form
    $skipButton = New-Object System.Windows.Forms.Button
    $skipButton.Location = New-Object System.Drawing.Point(150,270)
    $skipButton.Size = New-Object System.Drawing.Size(75,23)
    $skipButton.Text = 'Skip'
    $skipButton.DialogResult = [System.Windows.Forms.DialogResult]::Ignore
    $form.AcceptButton = $skipButton
    $form.Controls.Add($skipButton)
    #Back button for form (still in development)
    $backButton = New-Object System.Windows.Forms.Button
    $backButton.Location = New-Object System.Drawing.Point(225,270)
    $backButton.Size = New-Object System.Drawing.Size(75,23)
    $backButton.Text = 'Back'
    $backButton.DialogResult = [System.Windows.Forms.DialogResult]::Retry
    $form.CancelButton = $backButton
    $form.Controls.Add($backButton)
    #Cancel button for form
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(300,270)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)
    #Subrace form
    $subracelabel = New-Object System.Windows.Forms.Label
    $subracelabel.Location = New-Object System.Drawing.Point(10,20)
    $subracelabel.Size = New-Object System.Drawing.Size(145,18)
    $subracelabel.Text = 'Please select a SubRace:'
    $form.Controls.Add($subracelabel)
    #Set chosen subrace into name value's
    $Chosensubrace = New-Object System.Windows.Forms.ListBox
    $Chosensubrace.Location = New-Object System.Drawing.Point(10,40)
    $Chosensubrace.Size = New-Object System.Drawing.Size(260,20)
    $Chosensubrace.DataSource = [system.collections.arraylist]($SelectedRace.subraces)
    $Chosensubrace.DisplayMember = "subraces"
    $Chosensubrace.Height = 200
    $form.Controls.Add($ChosenSubRace)
    #Show form
    Write-Host $Subraces
    $form.Topmost = $true
    $subracetype = $form.ShowDialog()
        if ($subracetype -eq [System.Windows.Forms.DialogResult]::OK)
        {
            $SelectedSubRace = $ChosenSubRace.SelectedItem
            $ExportRace = $SelectedSubRace
            Write-Host "SubRace is: $SelectedSubRace"
        }
        if ($subracetype -eq [System.Windows.Forms.DialogResult]::Ignore)
        {
            #Defaults will load / chosen from the first race selection
        }
        if ($subracetype -eq [System.Windows.Forms.DialogResult]::Retry)
        {
            return
        }
        if ($subracetype -eq [System.Windows.Forms.DialogResult]::Cancel)
        {
            Exit
        }
#End of SubRace Selection
#Basic user information gathering - Primary Class + Alignment
    #Basic form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Sparks D&D Character Creator'
    $form.Size = New-Object System.Drawing.Size(500,350)
    $form.StartPosition = 'CenterScreen'
    $form.Icon = $objIcon
    $form.BackgroundImage = $objImage
    $form.BackgroundImageLayout = [System.Windows.Forms.ImageLayout]::Stretch
    $form.Width = $objImage.Width
    $form.Height = $objImage.Height
    #Ok button for form
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(75,270)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'Next'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)
    #Skip button for form
    $skipButton = New-Object System.Windows.Forms.Button
    $skipButton.Location = New-Object System.Drawing.Point(150,270)
    $skipButton.Size = New-Object System.Drawing.Size(75,23)
    $skipButton.Text = 'Skip'
    $skipButton.DialogResult = [System.Windows.Forms.DialogResult]::Ignore
    $form.AcceptButton = $skipButton
    $form.Controls.Add($skipButton)
    #Back button for form (still in development)
    $backButton = New-Object System.Windows.Forms.Button
    $backButton.Location = New-Object System.Drawing.Point(225,270)
    $backButton.Size = New-Object System.Drawing.Size(75,23)
    $backButton.Text = 'Back'
    $backButton.DialogResult = [System.Windows.Forms.DialogResult]::Retry
    $form.CancelButton = $backButton
    $form.Controls.Add($backButton)
    #Cancel button for form
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(300,270)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)
    #Class Form
    $classlabel = New-Object System.Windows.Forms.Label
    $classlabel.Location = New-Object System.Drawing.Point(10,20)
    $classlabel.Size = New-Object System.Drawing.Size(160,18)
    $classlabel.Text = 'Please select a Primary Class:'
    $form.Controls.Add($classlabel)
    #Class Form
    $ChosenClass = New-Object System.Windows.Forms.ListBox
    $ChosenClass.Location = New-Object System.Drawing.Point(10,40)
    $ChosenClass.Size = New-Object System.Drawing.Size(160,20)
    $ChosenClass.DataSource = [system.collections.arraylist]$ClassesJSON
    $ChosenClass.DisplayMember = "name"
    $ChosenClass.Height = 200
    $form.Controls.Add($ChosenClass)
    #Alignment Form
    $alignmentlabel = New-Object System.Windows.Forms.Label
    $alignmentlabel.Location = New-Object System.Drawing.Point(200,20)
    $alignmentlabel.Size = New-Object System.Drawing.Size(160,18)
    $alignmentlabel.Text = 'Please select an Alignment:'
    $form.Controls.Add($alignmentlabel)
    $ChosenAlignment = New-Object System.Windows.Forms.ListBox
    $ChosenAlignment.Location = New-Object System.Drawing.Point(200,40)
    $ChosenAlignment.Size = New-Object System.Drawing.Size(160,20)
    $ChosenAlignment.DataSource = [system.collections.arraylist]$AlignmentJSON
    $ChosenAlignment.DisplayMember = "name"
    $ChosenAlignment.Height = 200
    $form.Controls.Add($ChosenAlignment)
    #Show form
    $form.Topmost = $true
    $chosencharacter = $form.ShowDialog()
        if ($chosencharacter -eq [System.Windows.Forms.DialogResult]::OK)
        {
            #Class
            $SelectedClass = $ChosenClass.SelectedItem
            $SelectedAlignment = $ChosenAlignment.SelectedItem
            #Alignment
            $Alignment = $SelectedAlignment.Name
            #Set Class Stats
            $Class = $SelectedClass.Name
            $HD = $SelectedClass.HitDice
            $SpellCastingClass = $SelectedClass.SpellCastingClass
            $SpellCastingAbility = $SelectedClass.SpellcastingAbility
            $SelectedPack = $SelectedClass.Backpack
            #Cantrips
            $Cantrip01 = $SelectedClass.Cantrip01
            $Cantrip02 = $SelectedClass.Cantrip02
            $Cantrip03 = $SelectedClass.Cantrip03
            #If the console is set to show, this is just for that
            Write-Host "Class is $Class"
            Write-Host "Alignment is $Alignment"
        }
        if ($chosencharacter -eq [System.Windows.Forms.DialogResult]::Ignore)
        {
            #Defaults Will load
        }
        if ($chosencharacter -eq [System.Windows.Forms.DialogResult]::Retry)
        {
            return
        }
        if ($chosencharacter -eq [System.Windows.Forms.DialogResult]::Cancel)
        {
            Exit
        }
#end of class + alignment selection
#For future reference, setup the chosen class then tells the rest of the document what you can and cant select with IF statements
#This will mean that this powershell script is going to get BIG, but worth it!
#Make sure whaterver you set needs to be followed to the characterarray
#Basic user information gathering - SubClass
    #Basic form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Sparks D&D Character Creator'
    $form.Size = New-Object System.Drawing.Size(500,350)
    $form.StartPosition = 'CenterScreen'
    $form.Icon = $objIcon
    $form.BackgroundImage = $objImage
    $form.BackgroundImageLayout = [System.Windows.Forms.ImageLayout]::Stretch
    $form.Width = $objImage.Width
    $form.Height = $objImage.Height
    #Ok button for form
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(75,270)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'Next'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)
    #Skip button for form
    $skipButton = New-Object System.Windows.Forms.Button
    $skipButton.Location = New-Object System.Drawing.Point(150,270)
    $skipButton.Size = New-Object System.Drawing.Size(75,23)
    $skipButton.Text = 'Skip'
    $skipButton.DialogResult = [System.Windows.Forms.DialogResult]::Ignore
    $form.AcceptButton = $skipButton
    $form.Controls.Add($skipButton)
    #Back button for form (still in development)
    $backButton = New-Object System.Windows.Forms.Button
    $backButton.Location = New-Object System.Drawing.Point(225,270)
    $backButton.Size = New-Object System.Drawing.Size(75,23)
    $backButton.Text = 'Back'
    $backButton.DialogResult = [System.Windows.Forms.DialogResult]::Retry
    $form.CancelButton = $backButton
    $form.Controls.Add($backButton)
    #Cancel button for form
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(300,270)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)
    #Subclass form
    $subclasslabel = New-Object System.Windows.Forms.Label
    $subclasslabel.Location = New-Object System.Drawing.Point(10,20)
    $subclasslabel.Size = New-Object System.Drawing.Size(145,18)
    $subclasslabel.Text = 'Please select a SubClass:'
    $form.Controls.Add($subclasslabel)
    $Chosensubclass = New-Object System.Windows.Forms.ListBox
    $Chosensubclass.Location = New-Object System.Drawing.Point(10,40)
    $Chosensubclass.Size = New-Object System.Drawing.Size(260,20)
    $Chosensubclass.DataSource = [system.collections.arraylist]($SelectedClass.Subclasses)
    $Chosensubclass.DisplayMember = "subclasses"
    $Chosensubclass.Height = 200
    $form.Controls.Add($Chosensubclass)
    #Show form
    $form.Topmost = $true
    $SubClassformdialog = $form.ShowDialog()
    if ($SubClassformdialog -eq [System.Windows.Forms.DialogResult]::OK)
    {
        $SelectedSubClass = $Chosensubclass.SelectedItem
        $Class = $SelectedSubClass
        #If the console is set to show, this is just for that
        Write-Host "Subclass is $Class"
    }
    if ($SubClassformdialog -eq [System.Windows.Forms.DialogResult]::Ignore)
    {
        #Defaults will load
    }
    if ($SubClassformdialog -eq [System.Windows.Forms.DialogResult]::Retry)
    {
        Return
    }
    if ($SubClassformdialog -eq [System.Windows.Forms.DialogResult]::Cancel)
    {
        Exit
    }
#To add custom sub classes, you need to add the information into the json files in ./Assets/Classes
#When Chosen a subrace it will override the default class accordingly
#Weapon selection
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Sparks D&D Character Creator'
    $form.Size = New-Object System.Drawing.Size(500,600)
    $form.StartPosition = 'CenterScreen'
    $form.Icon = $objIcon
    $form.BackgroundImage = $objImage
    $form.BackgroundImageLayout = [System.Windows.Forms.ImageLayout]::Stretch
    #Ok button for form
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(75,530)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'Next'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)
    #Skip button for form
    $skipButton = New-Object System.Windows.Forms.Button
    $skipButton.Location = New-Object System.Drawing.Point(150,530)
    $skipButton.Size = New-Object System.Drawing.Size(75,23)
    $skipButton.Text = 'Skip'
    $skipButton.DialogResult = [System.Windows.Forms.DialogResult]::Ignore
    $form.AcceptButton = $skipButton
    $form.Controls.Add($skipButton)
    #Back button for form (still in development)
    $backButton = New-Object System.Windows.Forms.Button
    $backButton.Location = New-Object System.Drawing.Point(225,530)
    $backButton.Size = New-Object System.Drawing.Size(75,23)
    $backButton.Text = 'Back'
    $backButton.DialogResult = [System.Windows.Forms.DialogResult]::Retry
    $form.CancelButton = $backButton
    $form.Controls.Add($backButton)
    #Cancel button for form
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(300,530)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)
    #Weapon 1 form
    $selectweapon1label = New-Object System.Windows.Forms.Label
    $selectweapon1label.Location = New-Object System.Drawing.Point(15,20)
    $selectweapon1label.Size = New-Object System.Drawing.Size(140,18)
    $selectweapon1label.Text = 'Select Weapon 1:'
    $form.Controls.Add($selectweapon1label)
    $selectweapon1panel = New-Object System.Windows.Forms.ListBox
    $selectweapon1panel.Location = New-Object System.Drawing.Point(15,40)
    $selectweapon1panel.Size = New-Object System.Drawing.Size(140,18)
    $selectweapon1panel.DataSource = [system.collections.arraylist]$WeaponJSON
    $selectweapon1panel.DisplayMember = "name"
    $selectweapon1panel.Height = 230
    $form.Controls.Add($selectweapon1panel)
    #Weapon 2 form
    $selectweapon2label = New-Object System.Windows.Forms.Label
    $selectweapon2label.Location = New-Object System.Drawing.Point(165,20)
    $selectweapon2label.Size = New-Object System.Drawing.Size(140,18)
    $selectweapon2label.Text = 'Select Weapon 2:'
    $form.Controls.Add($selectweapon2label)
    $selectweapon2panel = New-Object System.Windows.Forms.ListBox
    $selectweapon2panel.Location = New-Object System.Drawing.Point(165,40)
    $selectweapon2panel.Size = New-Object System.Drawing.Size(140,18)
    $selectweapon2panel.DataSource = [system.collections.arraylist]$WeaponJSON
    $selectweapon2panel.DisplayMember = "name"
    $selectweapon2panel.Height = 230
    $form.Controls.Add($selectweapon2panel)
    #Weapon 3 form
    $selectweapon3label = New-Object System.Windows.Forms.Label
    $selectweapon3label.Location = New-Object System.Drawing.Point(315,20)
    $selectweapon3label.Size = New-Object System.Drawing.Size(140,18)
    $selectweapon3label.Text = 'Select Weapon 3:'
    $form.Controls.Add($selectweapon3label)
    $selectweapon3panel = New-Object System.Windows.Forms.ListBox
    $selectweapon3panel.Location = New-Object System.Drawing.Point(315,40)
    $selectweapon3panel.Size = New-Object System.Drawing.Size(140,18)
    $selectweapon3panel.DataSource = [system.collections.arraylist]$WeaponJSON
    $selectweapon3panel.DisplayMember = "name"
    $selectweapon3panel.Height = 230
    $form.Controls.Add($selectweapon3panel)
    #Gear form
    $selectadventuregearlabel = New-Object System.Windows.Forms.Label
    $selectadventuregearlabel.Location = New-Object System.Drawing.Point(240,270)
    $selectadventuregearlabel.Size = New-Object System.Drawing.Size(170,18)
    $selectadventuregearlabel.Text = 'Select 1 extra Adventuring Gear:'
    $form.Controls.Add($selectadventuregearlabel)
    $selectadventuinggearpanel = New-Object System.Windows.Forms.ListBox
    $selectadventuinggearpanel.Location = New-Object System.Drawing.Point(240,290)
    $selectadventuinggearpanel.Size = New-Object System.Drawing.Size(220,20)
    $selectadventuinggearpanel.DataSource = [system.collections.arraylist]$GearJSON
    $selectadventuinggearpanel.DisplayMember = "name"
    $selectadventuinggearpanel.Height = 230
    $form.Controls.Add($selectadventuinggearpanel)
    #Armour form
    $armourlabel = New-Object System.Windows.Forms.Label
    $armourlabel.Location = New-Object System.Drawing.Point(10,270)
    $armourlabel.Size = New-Object System.Drawing.Size(220,18)
    $armourlabel.Text = 'Please select Armour you wish to wear:'
    $form.Controls.Add($armourlabel)
    $ChosenArmour = New-Object System.Windows.Forms.ListBox
    $ChosenArmour.Location = New-Object System.Drawing.Point(10,290)
    $ChosenArmour.Size = New-Object System.Drawing.Size(220,20)
    $ChosenArmour.DataSource = [system.collections.arraylist]$ArmourJSON
    $ChosenArmour.DisplayMember = "name"
    $ChosenArmour.Height = 200
    $form.Controls.Add($ChosenArmour)
    #Shield form
    $checkboxshield = new-object System.Windows.Forms.checkbox
    $checkboxshield.Location = new-object System.Drawing.Size(25,490)
    $checkboxshield.Size = new-object System.Drawing.Size(120,40)
    $checkboxshield.Text = "Do you want a shield?"
    $checkboxshield.Checked = $false
    $Form.controls.AddRange(@($checkboxshield))
    #Shield as an option with tickbox, completely optional to a player
    $checkboxshield.Add_CheckStateChanged({
        $checkboxshield.Enabled = $checkboxshield.Checked 
    })
#Weapons are all in the /assets/weapons in json files, follow the template.txt
#Gear List from: https://www.dndbeyond.com/sources/basic-rules/equipment#AdventuringGear
#Each class needs to be limited to armour types to stop OP characters
    #Show form
    $form.Topmost = $true    
    $Form.Add_Shown({$Form.Activate()})
    $selectedweapons = $form.ShowDialog()
    if ($selectedweapons -eq [System.Windows.Forms.DialogResult]::OK)
    {
        #Weapon Panel Selection
        $ChosenWeapon1 = $selectweapon1panel.SelectedItem
        $ChosenWeapon2 = $selectweapon2panel.SelectedItem
        $ChosenWeapon3 = $selectweapon3panel.SelectedItem
        $ChosenGear = $selectadventuinggearpanel.SelectedItem
        $SelectedArmour = $ChosenArmour.SelectedItem
        #Weapon Stats
        $Weapon1 = $ChosenWeapon1.Name
        $Weapon2 = $ChosenWeapon2.Name
        $Weapon3 = $ChosenWeapon3.Name
        $Gear = $ChosenGear.Name
        $Armour = $SelectedArmour.Name
        $ArmourClass = $SelectedArmour.ArmourClass
        $WPN1ATK_Bonus = $ChosenWeapon1.WPN1ATK_Bonus
        $WPN2ATK_Bonus = $ChosenWeapon2.WPN2ATK_Bonus
        $WPN3ATK_Bonus = $ChosenWeapon3.WPN3ATK_Bonus
        $Weapon1Damage = $ChosenWeapon1.Weapon1Damage
        $Weapon2Damage = $ChosenWeapon2.Weapon2Damage
        $Weapon3Damage = $ChosenWeapon3.Weapon3Damage
        $Weapon1Weight = $ChosenWeapon1.Weapon1Weight
        $Weapon2Weight = $ChosenWeapon2.Weapon2Weight
        $Weapon3Weight = $ChosenWeapon3.Weapon3Weight
        $Weapon1Properties = $ChosenWeapon1.Weapon1Properties
        $Weapon2Properties = $ChosenWeapon2.Weapon1Properties
        $Weapon3Properties = $ChosenWeapon3.Weapon1Properties
        #If the console is set to show, this is just for that
        Write-Host "Weapon 1: $Weapon1"
        Write-Host "Weapon 2: $Weapon2"
        Write-Host "Weapon 3: $Weapon3"
        Write-Host "Gear: $Gear"
    }
    if ($selectedweapons -eq [System.Windows.Forms.DialogResult]::Ignore)
    {
        #Defaults will load
    }
    if ($selectedweapons -eq [System.Windows.Forms.DialogResult]::Retry)
    {
        return
    }
    if ($selectedweapons -eq [System.Windows.Forms.DialogResult]::Cancel)
    {
        Exit
    }
    if ($checkboxshield.Checked)
    {   
        $ArmourClassWithShield = "+2"
    }
#End of Equiptment choice
#Remember Dungeon Masters! These types of armour are affected with cost, armour class, strength, stealth and weight
#There is one type of shield with a base code of 10gp, armour class of +2 and weight of 453g
#Getting out of armour has times for "DON" and "DOFF" DON = Put on, DOff = Take off
#Light armour has a don of 1 min and doff of 1 min
#Medium armour has a don of 5 mins and doff of 1 min
#Heavy armour has a don of 10 mins and a doff off 5mins
#shield has a don of 1 action and doff of 1 action
#Weight calculations
$CombinedWeaponStats = $Weapon1Properties + $Weapon2Properties + $Weapon3Properties
$TotalWeight = $Weapon1Weight + $Weapon2Weight + $Weapon3Weight + $ArmourWeight + $AdventuringGearWeight
$TotalEquiptment = $Weapon1 + $Comma + $Weapon2 + $Comma + $Weapon3 + $Comma + $Gear + $Comma + $SelectedPack
#Custom Backstory
    #Basic form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Sparks D&D Character Creator'
    $form.Size = New-Object System.Drawing.Size(800,605)
    $form.StartPosition = 'CenterScreen'
    $form.Icon = $objIcon
    $form.BackgroundImage = $objImage
    $form.BackgroundImageLayout = [System.Windows.Forms.ImageLayout]::Stretch
    #Ok button for form
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(420,535)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'Next'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)
    #Skip button for form
    $skipButton = New-Object System.Windows.Forms.Button
    $skipButton.Location = New-Object System.Drawing.Point(495,535)
    $skipButton.Size = New-Object System.Drawing.Size(75,23)
    $skipButton.Text = 'Skip'
    $skipButton.DialogResult = [System.Windows.Forms.DialogResult]::Ignore
    $form.AcceptButton = $skipButton
    $form.Controls.Add($skipButton)
    #Back button for form (still in development)
    $backButton = New-Object System.Windows.Forms.Button
    $backButton.Location = New-Object System.Drawing.Point(570,535)
    $backButton.Size = New-Object System.Drawing.Size(75,23)
    $backButton.Text = 'Back'
    $backButton.DialogResult = [System.Windows.Forms.DialogResult]::Retry
    $form.CancelButton = $backButton
    $form.Controls.Add($backButton)
    #Cancel button for form
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(645,535)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)
    #Backstory form
    $backstorylabel = New-Object System.Windows.Forms.Label
    $backstorylabel.Location = New-Object System.Drawing.Point(10,20)
    $backstorylabel.Size = New-Object System.Drawing.Size(120,18)
    $backstorylabel.Text = 'Write your backstory:'
    $form.Controls.Add($backstorylabel)
    $characterbackstory = New-Object System.Windows.Forms.TextBox
    $characterbackstory.Location = New-Object System.Drawing.Point(10,40)
    $characterbackstory.Size = New-Object System.Drawing.Size(400,500)
    $characterbackstory.Multiline = 1
    $characterbackstory.ScrollBars = 2
    $characterbackstory.AcceptsReturn = 1
    $form.Controls.Add($characterbackstory)
    #Add hover text to the Character Name
    $toolTipBackstory = New-Object System.Windows.Forms.ToolTip
    $toolTipBackstory.SetToolTip($characterbackstory, "Write Character Backstory")
    #Personality form
    $personalitylabel = New-Object System.Windows.Forms.Label
    $personalitylabel.Location = New-Object System.Drawing.Point(420,20)
    $personalitylabel.Size = New-Object System.Drawing.Size(160,18)
    $personalitylabel.Text = 'Write your Personality Traits:'
    $form.Controls.Add($personalitylabel)
    $PersonalityTraits = New-Object System.Windows.Forms.TextBox
    $PersonalityTraits.Location = New-Object System.Drawing.Point(420,40)
    $PersonalityTraits.Size = New-Object System.Drawing.Size(300,100)
    $PersonalityTraits.Multiline = 1
    $PersonalityTraits.ScrollBars = 2
    $PersonalityTraits.AcceptsReturn = 1
    $form.Controls.Add($PersonalityTraits)
    #Add hover text to the Character Name
    $toolTipPlayer = New-Object System.Windows.Forms.ToolTip
    $toolTipPlayer.SetToolTip($PersonalityTraits, "Write Personality Traits")
    #Ideals form
    $Idealslabel = New-Object System.Windows.Forms.Label
    $Idealslabel.Location = New-Object System.Drawing.Point(420,150)
    $Idealslabel.Size = New-Object System.Drawing.Size(160,18)
    $Idealslabel.Text = 'Write your Ideals:'
    $form.Controls.Add($Idealslabel)
    $Ideals = New-Object System.Windows.Forms.TextBox
    $Ideals.Location = New-Object System.Drawing.Point(420,170)
    $Ideals.Size = New-Object System.Drawing.Size(300,100)
    $Ideals.Multiline = 1
    $Ideals.ScrollBars = 2
    $Ideals.AcceptsReturn = 1
    $form.Controls.Add($Ideals)
    #Add hover text to the Character Name
    $toolTipPlayer = New-Object System.Windows.Forms.ToolTip
    $toolTipPlayer.SetToolTip($playername, "Write Character Ideals")
    #Bonds form
    $Bondslabel = New-Object System.Windows.Forms.Label
    $Bondslabel.Location = New-Object System.Drawing.Point(420,280)
    $Bondslabel.Size = New-Object System.Drawing.Size(160,18)
    $Bondslabel.Text = 'Write About your Bonds:'
    $form.Controls.Add($Bondslabel)
    $Bonds = New-Object System.Windows.Forms.TextBox
    $Bonds.Location = New-Object System.Drawing.Point(420,300)
    $Bonds.Size = New-Object System.Drawing.Size(300,100)
    $Bonds.Multiline = 1
    $Bonds.ScrollBars = 2
    $Bonds.AcceptsReturn = 1
    $form.Controls.Add($Bonds)
    #Add hover text to the Character Name
    $toolTipPlayer = New-Object System.Windows.Forms.ToolTip
    $toolTipPlayer.SetToolTip($playername, "Write Character Bonds")
    #Flaws form
    $Flawslabel = New-Object System.Windows.Forms.Label
    $Flawslabel.Location = New-Object System.Drawing.Point(420,410)
    $Flawslabel.Size = New-Object System.Drawing.Size(160,18)
    $Flawslabel.Text = 'Write your Flaws:'
    $form.Controls.Add($Flawslabel)
    $Flaws = New-Object System.Windows.Forms.TextBox
    $Flaws.Location = New-Object System.Drawing.Point(420,430)
    $Flaws.Size = New-Object System.Drawing.Size(300,100)
    $Flaws.Multiline = 1
    $Flaws.ScrollBars = 2
    $Flaws.AcceptsReturn = 1
    $form.Controls.Add($Flaws)
    #Add hover text to the Character Name
    $toolTipPlayer = New-Object System.Windows.Forms.ToolTip
    $toolTipPlayer.SetToolTip($playername, "Write Character Flaws")
    #Show form
    $form.Topmost = $true
        if ($characterbackstoryformdialog -eq [System.Windows.Forms.DialogResult]::OK)
        {
            $characterbackstory.Text
            $PersonalityTraits.Text
            $Ideals.Text
            $Bonds.Text
            $Flaws.Text
        }
        if ($characterbackstoryformdialog -eq [System.Windows.Forms.DialogResult]::Ignore)
        {
            #Defaults will load
        }
        $characterbackstoryformdialog = $form.ShowDialog()
        if ($characterbackstoryformdialog -eq [System.Windows.Forms.DialogResult]::Retry)
        {
            Return
        }
        if ($characterbackstoryformdialog -eq [System.Windows.Forms.DialogResult]::Cancel)
        {
            Exit
        }
#More Background details
    #Basic form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Sparks D&D Character Creator'
    $form.Size = New-Object System.Drawing.Size(790,620)
    $form.StartPosition = 'CenterScreen'
    $form.Icon = $objIcon
    $form.BackgroundImage = $objImage
    $form.BackgroundImageLayout = [System.Windows.Forms.ImageLayout]::Stretch
    #Ok button for form
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(420,545)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'Next'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)
    #Skip button for form
    $skipButton = New-Object System.Windows.Forms.Button
    $skipButton.Location = New-Object System.Drawing.Point(495,545)
    $skipButton.Size = New-Object System.Drawing.Size(75,23)
    $skipButton.Text = 'Skip'
    $skipButton.DialogResult = [System.Windows.Forms.DialogResult]::Ignore
    $form.AcceptButton = $skipButton
    $form.Controls.Add($skipButton)
    #Back button for form (still in development)
    $backButton = New-Object System.Windows.Forms.Button
    $backButton.Location = New-Object System.Drawing.Point(570,545)
    $backButton.Size = New-Object System.Drawing.Size(75,23)
    $backButton.Text = 'Back'
    $backButton.DialogResult = [System.Windows.Forms.DialogResult]::Retry
    $form.CancelButton = $backButton
    $form.Controls.Add($backButton)
    #Cancel button for form
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(645,545)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)
    #Allies form
    $Allieslabel = New-Object System.Windows.Forms.Label
    $Allieslabel.Location = New-Object System.Drawing.Point(10,20)
    $Allieslabel.Size = New-Object System.Drawing.Size(220,18)
    $Allieslabel.Text = 'Write about your Allies and Organisations:'
    $form.Controls.Add($Allieslabel)
    $Allies = New-Object System.Windows.Forms.TextBox
    $Allies.Location = New-Object System.Drawing.Point(10,40)
    $Allies.Size = New-Object System.Drawing.Size(360,480)
    $Allies.Multiline = 1
    $Allies.ScrollBars = 2
    $Allies.AcceptsReturn = 1
    $form.Controls.Add($Allies)
    #Additional Feats and Traits form
    $addionalfeattraitslabel = New-Object System.Windows.Forms.Label
    $addionalfeattraitslabel.Location = New-Object System.Drawing.Point(420,20)
    $addionalfeattraitslabel.Size = New-Object System.Drawing.Size(220,18)
    $addionalfeattraitslabel.Text = 'Write your Additional features and traits:'
    $form.Controls.Add($addionalfeattraitslabel)
    $AddionalfeatTraits = New-Object System.Windows.Forms.TextBox
    $AddionalfeatTraits.Location = New-Object System.Drawing.Point(400,40)
    $AddionalfeatTraits.Size = New-Object System.Drawing.Size(360,480)
    $AddionalfeatTraits.Multiline = 1
    $AddionalfeatTraits.ScrollBars = 2
    $AddionalfeatTraits.AcceptsReturn = 1
    $form.Controls.Add($AddionalfeatTraits)
    #Factions form
    $factionslabel = New-Object System.Windows.Forms.Label
    $factionslabel.Location = New-Object System.Drawing.Point(10,530)
    $factionslabel.Size = New-Object System.Drawing.Size(220,18)
    $factionslabel.Text = 'Faction Name:'
    $form.Controls.Add($factionslabel)
    #Faction form
    $factionname = New-Object System.Windows.Forms.TextBox
    $factionname.Location = New-Object System.Drawing.Point(10,550)
    $factionname.Size = New-Object System.Drawing.Size(360,20)
    $factionname.AcceptsReturn = 1
    $form.Controls.Add($factionname)
    #Show form
    $form.Topmost = $true
        if ($characterextraformdialog -eq [System.Windows.Forms.DialogResult]::OK)
        {
            $Allies.Text
            $AddionalfeatTraits.Text
            $Factionname.Text
        }
        if ($characterextraformdialog -eq [System.Windows.Forms.DialogResult]::Ignore)
        {
            #Defaults will load
        }
        $characterextraformdialog = $form.ShowDialog()
        if ($characterextraformdialog -eq [System.Windows.Forms.DialogResult]::Retry)
        {
            Return
        }
        if ($characterextraformdialog -eq [System.Windows.Forms.DialogResult]::Cancel)
        {
            Exit
        }
#End of extra details
#----------------------------
#  If Statements for checks
#----------------------------
if ($SelectedClass.check11 -eq "enable")
{
    $Check11 = 'yes'
    Write-Host $SelectedClass.check11
}
if ($SelectedClass.check18 -eq "enable")
{
    $Check18 = 'yes'
    Write-Host $SelectedClass.check18
}
if ($SelectedClass.check19 -eq "enable")
{
    $Check19 = 'yes'
    Write-Host $SelectedClass.check19
}
if ($SelectedClass.check20 -eq "enable")
{
    $Check20 = 'yes'
    Write-Host $SelectedClass.check20
}
if ($SelectedClass.check21 -eq "enable")
{
    $Check21 = 'yes'
    Write-Host $SelectedClass.check21
}
if ($SelectedClass.check22 -eq "enable")
{
    $Check22 = 'yes'
    Write-Host $SelectedClass.check22
}
#Filter the JSON object to select only the properties whose values are "enable"
#$SavingthrowsFilteredJSON = $ChosenClass.SelectedItem | Select-Object -Property * -ExcludeProperty * | Where-Object { $_.Value -eq "enable" }
#Iterate through the properties of the filtered JSON object and convert the values to "yes"
#$SavingthrowsFilteredJSON | ForEach-Object {
#$_.Value = 'yes'
#}
#----------------------------
#      Save Form As
#----------------------------
#Select Path for export
$SaveChooser = New-Object -Typename System.Windows.Forms.SaveFileDialog
    $SaveChooser.Title = "Save as"
    $SaveChooser.FileName = "D&D Avatar - ChangeMe"
    $SaveChooser.DefaultExt = ".pdf"
    $SaveChooser.Filter = 'PDF File (*.pdf)|*.pdf'
    $SaveResult = $SaveChooser.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }))
if($SaveResult -eq [System.Windows.Forms.DialogResult]::OK ){
    $PathSelected = $SaveChooser.FileName
    $PathSelected
}
if ($SaveResult -eq [System.Windows.Forms.DialogResult]::Cancel){
    Exit
}
#End of path selection
#PDF Values Import before save
#PLEASE LEAVE ALL "NULL" STATEMENTS ALONE AS THEY ARE MEANT TO BE LEFT NULL
#Do not un-comment unless you know what you are writing in
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
        'CHARACTER IMAGE' = $CharacterImage;
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
    #Most of the above comments are to stop needing to add null statements to all.
    #If you want to add custom additions you will need to add all the code in
    InputPdfFilePath = "$PSScriptRoot\Assets\Empty_PDF\DnD_5E_CharacterSheet - Form Fillable.pdf"
    ITextSharpLibrary = "$PSScriptRoot\Assets\iText\itextsharp.dll"
    OutputPdfFilePath = $PathSelected
}
Save-PdfField @characterparameters
#End of character Creation Dialog box
    $ButtonType = [System.Windows.MessageBoxButton]::Ok
    $MessageIcon = [System.Windows.MessageBoxImage]::Information
    $MessageBody = "Dungeons And Dragons Character Successfully Created!"
    $MessageTitle = "Spark's D&D Character Creator"
[System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)
Exit
#----------------------------
#       Script End
#----------------------------
#Script Created By (Sparks Skywere) - Christopher Masters