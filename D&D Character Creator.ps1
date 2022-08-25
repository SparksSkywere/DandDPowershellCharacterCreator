clear-host
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
#end of powershell console hiding
#To show the console change "-hide" to "-show"
show-console -hide

#IF YOU HAVEN'T PLEASE READ THE RULEBOOK FOR D&D AS THIS POWERSHELL SCRIPT JUST SIMPLIFIES MAKING A CHARACTER
#CURRENTLY INDEV SO EXPECT ISSUES / BUGS OR DESIGN WEIRDNESS
#~
#Sparks's D&D Character Creator powershell script, this is intended for fun and feel free to edit fields for future use but please keep me credited
#Remember to comment/remove all "Write-Output" statements as this is only for testing purposes
#This powershell script follows original 5E rules, the website to get the information is:
#Sources: https://www.dndbeyond.com/sources/basic-rules
#~
#Further down the script you see $value.statement = New-Object System.Drawing.Size(240,50)
#The (240,50) means width,height for incase you forget
#(10,50) 50 = up/down, 10 = left/right - Orientation 
#Every part of the powershell script is changable, this is for custom games, hence why things aren't grouped together
#Majority of the stats used came from the cards for D&D
#~
#When adding $Var together for things like combined numbers or words you need to do:
#$TotalVar = $Var1 + $Var2 + $Var3 and not have {} in there as that does not work
#Script Start
#Type loader
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationCore,PresentationFramework
#PDF Module + Type
Import-Module -Name .\Assets\iText\PDFForm | Out-Null
Add-Type -Path ".\Assets\iText\itextsharp.dll"

#These values can also be used for indexing | Verify Output
#DO NOT DELETE, any of the values as they are needed for the skipping
#~Basic Character Information~
$charactername = "Unknown"
$playername = "Unknown"
$age = "Unknown"
$characterbackground = "Unknown"
#~Character Appearance~
$Age = "0"
$Playerheight = "0"
$PlayerSize = "0"
$characterfeatureseyes = "N/A"
$characterfeatureshair = "N/A"
$characterfeaturesskin = "N/A"
$CharacterImage = "N/A"
$FactionSymbol = "N/A"
#~Character Stats~
$ChosenRace = "N/A"
$ExportRace = "N/A"
$ChosenSubRace = "N/A"
$RaceDescription = "Unknown"
#$RacialSpecialAbility = "Unknown"
$PersonalityTraits = "Unknown"
$ProficencyBonus = "+0"
$ClassLevel = "0"
$HP = "0"
$HD = "0"
$SpeedTotal = "0"
$PlayerSize = "Unknown"
$Playerheight = "Unknown"
$STR = "0"
$DEX = "0"
$CON = "0"
$INT = "0"
$WIS = "0"
$CHA = "0"
$SpokenLanguages = "Unknown"
#$Skills = "Unknown"
#$Senses = "Unknown"
$ChosenClass = "None Selected"
$ChosenSubClass = "None Selected"
$ChosenAlignment = "None Selected"
$InitiativeTotal = "0"
#$Damage_Immunities = "Unknown"
#$Condition_Immunities = "Unknown"
#~Extra Character Information~
$characterbackstory = "Unknown"
$factionname = "Unknown"
$alliesandorganisations = "Unknown"
$AddionalfeatTraits = "Unknown"
$Ideals = "Unknown"
$Bonds = "Unknown"
$Flaws = "Unknown"
#~Weapon Stats~
$CombinedWeaponStats = "N/A"
$ChosenArmour = "Unknown"
$ArmourClass = "0"
$checkboxshield = "Unknown"
$ArmourClassWithShield = "Unknown"
#~Extra~
$HitDiceTotal = "0"
$XP = "1"
$Inspiration = "1"
#~Treasure~
$CopperCP = ""
$SilverSP = ""
$ElectrumEP = ""
$GoldGP = "10"
$PlatinumPP = ""
#~Spells~
$SpellCastingClass = "N/A"
$SpellCastingAbility = "N/A"
$SpellCastingSaveDC = "N/A"
$SpellCastingAttackBonus = "N/A"
#~Skills~
$Acrobatics = "0"
$AnimalHandling = "0"
$Arcana = "0"
$Athletics = "0"
$Deception = "0"
$History = "0"
$Insight = "0"
$Intimidation = "0"
$Investigation = "0"
$Medicine = "0"
$Nature = "0"
$Perception = "0"
$Performance = "0"
$Persuation = "0"
$Religion = "0"
$SleightOfHand = "0"
$Stealth = "0"
$Survival = "0"
#Passive Wisdom
$Passive = "0"
#~Special $Variables (DO NOT TOUCH THESE!)~
$Comma = ", "

#Hovertext (this is to help customisation)
$CharacternameHoverText = {"TestName"}
$CharacterAgeHoverText = {"TestAge"}

#Basic user information gathering - Basic Information
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Sparks D&D Character Creator'
    $form.Size = New-Object System.Drawing.Size(500,350)
    $form.StartPosition = 'CenterScreen'
    $objIcon = New-Object system.drawing.icon (".\Assets\installer.ico")
    $form.Icon = $objIcon
 
    $objImage = [system.drawing.image]::FromFile(".\Assets\form_background.png")
    $form.BackgroundImage = $objImage
    $form.BackgroundImageLayout = "Center"
 
    $form.Width = $objImage.Width
    $form.Height = $objImage.Height

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(75,270)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'Next'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    $skipButton = New-Object System.Windows.Forms.Button
    $skipButton.Location = New-Object System.Drawing.Point(150,270)
    $skipButton.Size = New-Object System.Drawing.Size(75,23)
    $skipButton.Text = 'Skip'
    $skipButton.DialogResult = [System.Windows.Forms.DialogResult]::Ignore
    $form.AcceptButton = $skipButton
    $form.Controls.Add($skipButton)

    $backButton = New-Object System.Windows.Forms.Button
    $backButton.Location = New-Object System.Drawing.Point(225,270)
    $backButton.Size = New-Object System.Drawing.Size(75,23)
    $backButton.Text = 'Back'
    $backButton.DialogResult = [System.Windows.Forms.DialogResult]::Retry
    $form.CancelButton = $backButton
    $form.Controls.Add($backButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(300,270)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

    $characterlabel = New-Object System.Windows.Forms.Label
    $characterlabel.Location = New-Object System.Drawing.Point(10,20)
    $characterlabel.Size = New-Object System.Drawing.Size(100,18)
    $characterlabel.Text = 'Character Name:'
    $form.Controls.Add($characterlabel)

    $charactername = New-Object System.Windows.Forms.TextBox
    $charactername.Location = New-Object System.Drawing.Point(10,40)
    $charactername.Size = New-Object System.Drawing.Size(180,20)
    $charactername.MaxLength = 30
    $charactername.add_mouseleave
    $charactername.add_mousehover($CharacternameHoverText)
    $charactername.OnmouseHover($CharacternameHoverText)
    #$CharacternameHoverText.SetToolTip($charactername, "This is a button")
    #$CharacternameHoverText.Active = $True
    $form.Controls.Add($charactername)
    $form.Topmost = $true

    $ageform = New-Object System.Windows.Forms.Label
    $ageform.Location = New-Object System.Drawing.Point(10,67)
    $ageform.Size = New-Object System.Drawing.Size(80,18)
    $ageform.Text = 'Character Age:'
    $form.Controls.Add($ageform)

    $age = New-Object System.Windows.Forms.TextBox
    $age.Location = New-Object System.Drawing.Point(10,85)
    $age.Size = New-Object System.Drawing.Size(58,20)
    $age.MaxLength = 5
    $form.Controls.Add($age)
    $form.Topmost = $true
    $age.Add_TextChanged({
        $age.Text = $age.Text -replace '\D'})
    
    $playerlabel = New-Object System.Windows.Forms.Label
    $playerlabel.Location = New-Object System.Drawing.Point(10,108)
    $playerlabel.Size = New-Object System.Drawing.Size(100,18)
    $playerlabel.Text = 'Player Name:'
    $form.Controls.Add($playerlabel)

    $playername = New-Object System.Windows.Forms.TextBox
    $playername.Location = New-Object System.Drawing.Point(10,127)
    $playername.Size = New-Object System.Drawing.Size(180,20)
    $playername.MaxLength = 30
    $form.Controls.Add($playername)
    $form.Topmost = $true
    
    #REMEMBER TO ADD THE ONLY LETTERS FUNCTION, NO NUMBERS ALLOWED
    #$form.Add_Shown({$charactername.Select()})
    #$charactername.Add_TextChanged({
    #    $charactername.Text = $charactername.Text -replace '\W'
    #})
        if ($characternameformdialog -eq [System.Windows.Forms.DialogResult]::OK)
        {
            $charactername = $charactername.Text
            $charactername

            $playername = $playername.Text
            $playername

            $ageformchosen = $age.Text
            $ageformchosen
        }
        if ($characternameformdialog -eq [System.Windows.Forms.DialogResult]::Ignore)
        {
            $charactername = "No-Name"
            $playername = "No-Name"
            $age = "Unknown"
        }
        $characternameformdialog = $form.ShowDialog()
        if ($characternameformdialog -eq [System.Windows.Forms.DialogResult]::Retry)
        {
            Return
        }
        if ($characternameformdialog -eq [System.Windows.Forms.DialogResult]::Cancel)
        {
            Exit
        }
#Basic user information gathering - Class and race
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Sparks D&D Character Creator'
    $form.Size = New-Object System.Drawing.Size(450,350)
    $form.StartPosition = 'CenterScreen'
    $objIcon = New-Object system.drawing.icon (".\Assets\installer.ico")
    $form.Icon = $objIcon
 
    $objImage = [system.drawing.image]::FromFile(".\Assets\form_background.png")
    $form.BackgroundImage = $objImage
    $form.BackgroundImageLayout = "Center"
 
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(75,270)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'Next'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    $skipButton = New-Object System.Windows.Forms.Button
    $skipButton.Location = New-Object System.Drawing.Point(150,270)
    $skipButton.Size = New-Object System.Drawing.Size(75,23)
    $skipButton.Text = 'Skip'
    $skipButton.DialogResult = [System.Windows.Forms.DialogResult]::Ignore
    $form.AcceptButton = $skipButton
    $form.Controls.Add($skipButton)

    $backButton = New-Object System.Windows.Forms.Button
    $backButton.Location = New-Object System.Drawing.Point(225,270)
    $backButton.Size = New-Object System.Drawing.Size(75,23)
    $backButton.Text = 'Back'
    $backButton.DialogResult = [System.Windows.Forms.DialogResult]::Retry
    $form.CancelButton = $backButton
    $form.Controls.Add($backButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(300,270)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

    $characterbackground = New-Object System.Windows.Forms.Label
    $characterbackground.Location = New-Object System.Drawing.Point(10,20)
    $characterbackground.Size = New-Object System.Drawing.Size(160,18)
    $characterbackground.Text = 'Please Select a Background:'
    $form.Controls.Add($characterbackground)

    $characterbackgroundselect = New-Object System.Windows.Forms.ListBox
    $characterbackgroundselect.Location = New-Object System.Drawing.Point(10,40)
    $characterbackgroundselect.Size = New-Object System.Drawing.Size(160,65)
    $characterbackgroundselect.Height = 170

    $racelabel = New-Object System.Windows.Forms.Label
    $racelabel.Location = New-Object System.Drawing.Point(220,20)
    $racelabel.Size = New-Object System.Drawing.Size(118,18)
    $racelabel.Text = 'Please select a Race:'
    $form.Controls.Add($racelabel)

    $ChosenRace = New-Object System.Windows.Forms.ListBox
    $ChosenRace.Location = New-Object System.Drawing.Point(220,40)
    $ChosenRace.Size = New-Object System.Drawing.Size(200,20)
    $ChosenRace.Height = 200
#Background List
        $characterbackgroundselect.Items.Add('Acolyte') | Out-Null
        $characterbackgroundselect.Items.Add('Criminal') | Out-Null
        $characterbackgroundselect.Items.Add('Noble') | Out-Null
        $characterbackgroundselect.Items.Add('Hero') | Out-Null
        $characterbackgroundselect.Items.Add('Folk Hero') | Out-Null
        $characterbackgroundselect.Items.Add('Soldier') | Out-Null
        $characterbackgroundselect.Items.Add('Entertainer') | Out-Null
        $characterbackgroundselect.Items.Add('Sage') | Out-Null
        $characterbackgroundselect.Items.Add('Lone Wanderer') | Out-Null
#Character backstory is part of the forms later down the script
#If you wish to add character backgrounds:
#$characterbackgroundselect.Items.Add('custom') | Out-Null
    #Race List
        $ChosenRace.Items.Add('Dragonborn') | Out-Null
        $ChosenRace.Items.Add('Dwarf') | Out-Null
        $ChosenRace.Items.Add('Cleric') | Out-Null
        $ChosenRace.Items.Add('Elf') | Out-Null
        $ChosenRace.Items.Add('Gnome') | Out-Null
        $ChosenRace.Items.Add('Half-Elf') | Out-Null
        $ChosenRace.Items.Add('Halfling') | Out-Null
        $ChosenRace.Items.Add('Half-Orc') | Out-Null
        $ChosenRace.Items.Add('Human') | Out-Null
        $ChosenRace.Items.Add('Tiefling') | Out-Null
        $ChosenRace.Items.Add('Orc') | Out-Null
        $ChosenRace.Items.Add('Leonin') | Out-Null
        $ChosenRace.Items.Add('Satyr') | Out-Null
        $ChosenRace.Items.Add('Fairy') | Out-Null
        $ChosenRace.Items.Add('Harengon') | Out-Null
        $ChosenRace.Items.Add('Aarakocra') | Out-Null
        $ChosenRace.Items.Add('Genasi') | Out-Null
        $ChosenRace.Items.Add('Goliath') | Out-Null
        $ChosenRace.Items.Add('Aasimar') | Out-Null
        $ChosenRace.Items.Add('Bugbear') | Out-Null
        $ChosenRace.Items.Add('Firbolg') | Out-Null
        $ChosenRace.Items.Add('Goblin') | Out-Null
        $ChosenRace.Items.Add('Hobgoblin') | Out-Null
        $ChosenRace.Items.Add('Kenku') | Out-Null
        $ChosenRace.Items.Add('Kobold') | Out-Null
        $ChosenRace.Items.Add('Lizardfolk') | Out-Null
        $ChosenRace.Items.Add('Tabaxi') | Out-Null
        $ChosenRace.Items.Add('Triton') | Out-Null
        $ChosenRace.Items.Add('Yuan-ti Pureblood') | Out-Null
        $ChosenRace.Items.Add('Feral Tiefling') | Out-Null
        $ChosenRace.Items.Add('Tortle') | Out-Null
        $ChosenRace.Items.Add('Changling') | Out-Null
        $ChosenRace.Items.Add('Kalashtar') | Out-Null
        $ChosenRace.Items.Add('Shifter') | Out-Null
        $ChosenRace.Items.Add('Warforged') | Out-Null
        $ChosenRace.Items.Add('Gith') | Out-Null
        $ChosenRace.Items.Add('Centaur') | Out-Null
        $ChosenRace.Items.Add('Loxodon') | Out-Null
        $ChosenRace.Items.Add('Minotaur') | Out-Null
        $ChosenRace.Items.Add('Simic Hybrid') | Out-Null
        $ChosenRace.Items.Add('Vedalken') | Out-Null
        $ChosenRace.Items.Add('Verdan') | Out-Null
        $ChosenRace.Items.Add('Locathah') | Out-Null
        $ChosenRace.Items.Add('Grung') | Out-Null
        $ChosenRace.Items.Add('Lycanth') | Out-Null
        $ChosenRace.Items.Add('Troll') | Out-Null
        $ChosenRace.Items.Add('Ogre') | Out-Null
        $ChosenRace.Items.Add('Half-Ogre') | Out-Null
        $ChosenRace.Items.Add('Orog') | Out-Null
        $ChosenRace.Items.Add('Gnoll') | Out-Null
        $ChosenRace.Items.Add('Wolf') | Out-Null

#To add a custom race use this line with a name given and then follow
#down the script to add it to the rest of the script
#$ChosenRace.Items.Add('Custom') | Out-Null
#You need to also add a race description if you wish other players to use it
#Along with a race picture, this is all in the "Assets" folder

    $form.Controls.Add($characterbackgroundselect)
    $form.Controls.AddRange($characterbackgroundselect)
    $form.Controls.Add($ChosenRace)
    $form.Topmost = $true
    $Form.Add_Shown({$Form.Activate()})
        if ($characterbackgroundtextbox -eq [System.Windows.Forms.DialogResult]::OK)
        {
            $chosenbackground = $characterbackgroundselect.SelectedItem
            $chosenbackground

            $selectedrace = $ChosenRace.SelectedItem
            $selectedrace
        }
        if ($characterbackgroundtextbox -eq [System.Windows.Forms.DialogResult]::Ignore)
        {
            $characterbackgroundselect = "Unknown"
            $selectedrace = "N/A"
        }
        $characterbackgroundtextbox = $form.ShowDialog()
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
    #    $img = [System.Drawing.Image]::Fromfile('.\Assets\Race_Pictures\**.png')
    #    Add-Content -path ".\Assets\Race_Descriptions\**.txt"
    #}

    #Add this feature above, where you select from the list and an image + text loads
    #The race index can be fitted with selection data such as gold or speed
    #Please add all speed bonuses to match either class and race

#Make sure to fill out ALL required subrace data as there is a lot of subraces per primary
#race, this allows a waaay bigger pool of characters

#Small race choices like skin and hair
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Sparks D&D Character Creator'
    $form.Size = New-Object System.Drawing.Size(500,350)
    $form.StartPosition = 'CenterScreen'
    $objIcon = New-Object system.drawing.icon (".\Assets\installer.ico")
    $form.Icon = $objIcon
 
    $objImage = [system.drawing.image]::FromFile(".\Assets\form_background.png")
    $form.BackgroundImage = $objImage
    $form.BackgroundImageLayout = "Center"
 
    $form.Width = $objImage.Width
    $form.Height = $objImage.Height

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(75,270)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'Next'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    $skipButton = New-Object System.Windows.Forms.Button
    $skipButton.Location = New-Object System.Drawing.Point(150,270)
    $skipButton.Size = New-Object System.Drawing.Size(75,23)
    $skipButton.Text = 'Skip'
    $skipButton.DialogResult = [System.Windows.Forms.DialogResult]::Ignore
    $form.AcceptButton = $skipButton
    $form.Controls.Add($skipButton)

    $backButton = New-Object System.Windows.Forms.Button
    $backButton.Location = New-Object System.Drawing.Point(225,270)
    $backButton.Size = New-Object System.Drawing.Size(75,23)
    $backButton.Text = 'Back'
    $backButton.DialogResult = [System.Windows.Forms.DialogResult]::Retry
    $form.CancelButton = $backButton
    $form.Controls.Add($backButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(300,270)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

    $characterfeatureseyes = New-Object System.Windows.Forms.Label
    $characterfeatureseyes.Location = New-Object System.Drawing.Point(10,20)
    $characterfeatureseyes.Size = New-Object System.Drawing.Size(110,18)
    $characterfeatureseyes.Text = 'Select Eyes:'
    $form.Controls.Add($characterfeatureseyes)

    $characterfeatureshair = New-Object System.Windows.Forms.Label
    $characterfeatureshair.Location = New-Object System.Drawing.Point(125,20)
    $characterfeatureshair.Size = New-Object System.Drawing.Size(110,18)
    $characterfeatureshair.Text = 'Select Hair:'
    $form.Controls.Add($characterfeatureshair)

    $characterfeaturesskin = New-Object System.Windows.Forms.Label
    $characterfeaturesskin.Location = New-Object System.Drawing.Point(240,20)
    $characterfeaturesskin.Size = New-Object System.Drawing.Size(110,18)
    $characterfeaturesskin.Text = 'Select Skin:'
    $form.Controls.Add($characterfeaturesskin)

    $characterfeaturesselecteyes = New-Object System.Windows.Forms.ListBox
    $characterfeaturesselecteyes.Location = New-Object System.Drawing.Point(10,50)
    $characterfeaturesselecteyes.Size = New-Object System.Drawing.Size(110,65)
    $characterfeaturesselecteyes.Height = 170

    $characterfeaturesselecthair = New-Object System.Windows.Forms.ListBox
    $characterfeaturesselecthair.Location = New-Object System.Drawing.Point(125,50)
    $characterfeaturesselecthair.Size = New-Object System.Drawing.Size(110,65)
    $characterfeaturesselecthair.Height = 170

    $characterfeaturesselectskin = New-Object System.Windows.Forms.ListBox
    $characterfeaturesselectskin.Location = New-Object System.Drawing.Point(240,50)
    $characterfeaturesselectskin.Size = New-Object System.Drawing.Size(110,65)
    $characterfeaturesselectskin.Height = 170

    #Feature Eyes List
        $characterfeaturesselecteyes.Items.Add('Blue') | Out-Null
        $characterfeaturesselecteyes.Items.Add('Green') | Out-Null
        $characterfeaturesselecteyes.Items.Add('Hazel') | Out-Null
        $characterfeaturesselecteyes.Items.Add('Yellow') | Out-Null
        $characterfeaturesselecteyes.Items.Add('Amber') | Out-Null
        $characterfeaturesselecteyes.Items.Add('Grey') | Out-Null
        $characterfeaturesselecteyes.Items.Add('Red') | Out-Null
        $characterfeaturesselecteyes.Items.Add('Teal') | Out-Null
        $characterfeaturesselecteyes.Items.Add('Red') | Out-Null
        $characterfeaturesselecteyes.Items.Add('Purple') | Out-Null
        $characterfeaturesselecteyes.Items.Add('Pale Brown') | Out-Null
        $characterfeaturesselecteyes.Items.Add('Pale Blue') | Out-Null
        $characterfeaturesselecteyes.Items.Add('Pale Green') | Out-Null
        $characterfeaturesselecteyes.Items.Add('Pale Grey') | Out-Null
        $characterfeaturesselecteyes.Items.Add('Deep Blue') | Out-Null
        $characterfeaturesselecteyes.Items.Add('Violet Red') | Out-Null
        $characterfeaturesselecteyes.Items.Add('Orange') | Out-Null
        $characterfeaturesselecteyes.Items.Add('Spring Green') | Out-Null
        $characterfeaturesselecteyes.Items.Add('Sea Green') | Out-Null
        $characterfeaturesselecteyes.Items.Add('Emerald Green') | Out-Null
        $characterfeaturesselecteyes.Items.Add('Pink') | Out-Null

    #Feature Hair List
        $characterfeaturesselecthair.Items.Add('Blue') | Out-Null
        $characterfeaturesselecthair.Items.Add('Green') | Out-Null
        $characterfeaturesselecthair.Items.Add('Black') | Out-Null
        $characterfeaturesselecthair.Items.Add('Grey') | Out-Null
        $characterfeaturesselecthair.Items.Add('Platinum') | Out-Null
        $characterfeaturesselecthair.Items.Add('White') | Out-Null
        $characterfeaturesselecthair.Items.Add('Dark Blonde') | Out-Null
        $characterfeaturesselecthair.Items.Add('Blonde') | Out-Null
        $characterfeaturesselecthair.Items.Add('Bleach Blonde') | Out-Null
        $characterfeaturesselecthair.Items.Add('Dark Redhead') | Out-Null
        $characterfeaturesselecthair.Items.Add('Redhead') | Out-Null
        $characterfeaturesselecthair.Items.Add('Light Redhead') | Out-Null
        $characterfeaturesselecthair.Items.Add('Brunette') | Out-Null
        $characterfeaturesselecthair.Items.Add('Auburn') | Out-Null
        $characterfeaturesselecthair.Items.Add('Yellow') | Out-Null
        $characterfeaturesselecthair.Items.Add('Amber') | Out-Null
        $characterfeaturesselecthair.Items.Add('Brown') | Out-Null
        $characterfeaturesselecthair.Items.Add('Hazel') | Out-Null
        $characterfeaturesselecthair.Items.Add('Teal') | Out-Null
        $characterfeaturesselecthair.Items.Add('Red') | Out-Null
        $characterfeaturesselecthair.Items.Add('Purple') | Out-Null
        $characterfeaturesselecthair.Items.Add('Pale Brown') | Out-Null
        $characterfeaturesselecthair.Items.Add('Pale Blue') | Out-Null
        $characterfeaturesselecthair.Items.Add('Pale Green') | Out-Null
        $characterfeaturesselecthair.Items.Add('Pale Grey') | Out-Null
        $characterfeaturesselecthair.Items.Add('Deep Blue') | Out-Null
        $characterfeaturesselecthair.Items.Add('Violet Red') | Out-Null
        $characterfeaturesselecthair.Items.Add('Orange') | Out-Null
        $characterfeaturesselecthair.Items.Add('Spring Green') | Out-Null
        $characterfeaturesselecthair.Items.Add('Sea Green') | Out-Null
        $characterfeaturesselecthair.Items.Add('Emerald Green') | Out-Null

    #Feature Skin List
        $characterfeaturesselectskin.Items.Add('Pale') | Out-Null
        $characterfeaturesselectskin.Items.Add('Fair') | Out-Null
        $characterfeaturesselectskin.Items.Add('Light') | Out-Null
        $characterfeaturesselectskin.Items.Add('Light Tan') | Out-Null
        $characterfeaturesselectskin.Items.Add('Tan') | Out-Null
        $characterfeaturesselectskin.Items.Add('Dark Tan') | Out-Null
        $characterfeaturesselectskin.Items.Add('Brown') | Out-Null
        $characterfeaturesselectskin.Items.Add('Dark Brown') | Out-Null
        $characterfeaturesselectskin.Items.Add('Black') | Out-Null
        $characterfeaturesselectskin.Items.Add('Grey') | Out-Null
        $characterfeaturesselectskin.Items.Add('White') | Out-Null
        $characterfeaturesselectskin.Items.Add('Gold') | Out-Null
        $characterfeaturesselectskin.Items.Add('Silver') | Out-Null
        $characterfeaturesselectskin.Items.Add('Bronze') | Out-Null
        $characterfeaturesselectskin.Items.Add('Red') | Out-Null
        $characterfeaturesselectskin.Items.Add('Orange') | Out-Null
        $characterfeaturesselectskin.Items.Add('Yellow') | Out-Null
        $characterfeaturesselectskin.Items.Add('Green') | Out-Null
        $characterfeaturesselectskin.Items.Add('Blue') | Out-Null
        $characterfeaturesselectskin.Items.Add('Purple') | Out-Null
        $characterfeaturesselectskin.Items.Add('Dark Purple') | Out-Null
        $characterfeaturesselectskin.Items.Add('Pale Yellow') | Out-Null
        $characterfeaturesselectskin.Items.Add('Dark Red') | Out-Null
        $characterfeaturesselectskin.Items.Add('Red-Orange') | Out-Null
        $characterfeaturesselectskin.Items.Add('Light Red') | Out-Null
        $characterfeaturesselectskin.Items.Add('Amber') | Out-Null
        $characterfeaturesselectskin.Items.Add('Olive') | Out-Null
        $characterfeaturesselectskin.Items.Add('Teal') | Out-Null
        $characterfeaturesselectskin.Items.Add('Pale Brown') | Out-Null
        $characterfeaturesselectskin.Items.Add('Pale Blue') | Out-Null
        $characterfeaturesselectskin.Items.Add('Pale Green') | Out-Null
        $characterfeaturesselectskin.Items.Add('Pale Grey') | Out-Null
        $characterfeaturesselectskin.Items.Add('Deep Blue') | Out-Null
        $characterfeaturesselectskin.Items.Add('Violet Red') | Out-Null
        $characterfeaturesselectskin.Items.Add('Spring Green') | Out-Null
        $characterfeaturesselectskin.Items.Add('Sea Green') | Out-Null
        $characterfeaturesselectskin.Items.Add('Emerald Green') | Out-Null

    $form.Controls.Add($characterfeaturesselecteyes)
    $form.Controls.AddRange($characterfeaturesselecteyes)
    $form.Controls.Add($characterfeaturesselecthair)
    $form.Controls.AddRange($characterfeaturesselecthair)
    $form.Controls.Add($characterfeaturesselectskin)
    $form.Controls.AddRange($characterfeaturesselectskin)
    $form.Topmost = $true
    $Form.Add_Shown({$Form.Activate()})
        if ($characterfeaturestextbox -eq [System.Windows.Forms.DialogResult]::OK)
        {
            $chosenfeatureseyes = $characterfeaturesselecteyes.SelectedItem
            $chosenfeatureseyes

            $chosenfeatureshair = $characterfeaturesselecthair.SelectedItem
            $chosenfeatureshair

            $chosenfeaturesskin = $characterfeaturesselectskin.SelectedItem
            $chosenfeaturesskin
        }
        if ($characterfeaturestextbox -eq [System.Windows.Forms.DialogResult]::Ignore)
        {
            $characterfeaturesselecteyes = "Unknown"
            $characterfeaturesselecthair = "Unknown"
            $characterfeaturesselectskin = "Unknown"
        }
        $characterfeaturestextbox = $form.ShowDialog()
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
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Sparks D&D Character Creator'
    $form.Size = New-Object System.Drawing.Size(500,350)
    $form.StartPosition = 'CenterScreen'
    $objIcon = New-Object system.drawing.icon (".\Assets\installer.ico")
    $form.Icon = $objIcon
    
    $objImage = [system.drawing.image]::FromFile(".\Assets\form_background.png")
    $form.BackgroundImage = $objImage
    $form.BackgroundImageLayout = "Center"
    
    $form.Width = $objImage.Width
    $form.Height = $objImage.Height

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(75,270)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'Next'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    $skipButton = New-Object System.Windows.Forms.Button
    $skipButton.Location = New-Object System.Drawing.Point(150,270)
    $skipButton.Size = New-Object System.Drawing.Size(75,23)
    $skipButton.Text = 'Skip'
    $skipButton.DialogResult = [System.Windows.Forms.DialogResult]::Ignore
    $form.AcceptButton = $skipButton
    $form.Controls.Add($skipButton)

    $backButton = New-Object System.Windows.Forms.Button
    $backButton.Location = New-Object System.Drawing.Point(225,270)
    $backButton.Size = New-Object System.Drawing.Size(75,23)
    $backButton.Text = 'Back'
    $backButton.DialogResult = [System.Windows.Forms.DialogResult]::Retry
    $form.CancelButton = $backButton
    $form.Controls.Add($backButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(300,270)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,20)
    $label.Size = New-Object System.Drawing.Size(145,18)
    $label.Text = 'Please select a SubRace:'
    $form.Controls.Add($label)
    
    $Chosensubrace = New-Object System.Windows.Forms.ListBox
    $Chosensubrace.Location = New-Object System.Drawing.Point(10,40)
    $Chosensubrace.Size = New-Object System.Drawing.Size(260,20)
    $Chosensubrace.Height = 200

    $form.Controls.Add($ChosenSubRace)
    $form.Topmost = $true

        if ($ChosenRace.SelectedItem -match 'Dragonborn')
        {
            $ChosenSubRace.Items.Add('Dragonborn') | Out-Null
            $ChosenSubRace.Items.Add('Draconic Ancestory') | Out-Null
            $ChosenSubRace.Items.Add('DraconBlood Dragonborn') | Out-Null
            $ChosenSubRace.Items.Add('Chromatic Dragonborn') | Out-Null
            $ChosenSubRace.Items.Add('Gem Dragonborn') | Out-Null
            $ChosenSubRace.Items.Add('Ravenite Dragonborn') | Out-Null
            $ChosenSubRace.Items.Add('Metallic Dragonborn') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Dwarf')
        {
            $ChosenSubRace.Items.Add('Dwarf') | Out-Null
            $ChosenSubRace.Items.Add('Hill Dwarves') | Out-Null
            $ChosenSubRace.Items.Add('Mountain Dwarves') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Elf')
        {
            $ChosenSubRace.Items.Add('Elf') | Out-Null
            $ChosenSubRace.Items.Add('Eladrin') | Out-Null
            $ChosenSubRace.Items.Add('High Elf') | Out-Null
            $ChosenSubRace.Items.Add('Wood Elf') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Gnome')
        {
            $ChosenSubRace.Items.Add('Gnome') | Out-Null
            $ChosenSubRace.Items.Add('Deep Gnome') | Out-Null
            $ChosenSubRace.Items.Add('Rock Gnome') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Half-Elf')
        {
            $ChosenSubRace.Items.Add('Half-Elf') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Halfling')
        {
            $ChosenSubRace.Items.Add('Halfling') | Out-Null
            $ChosenSubRace.Items.Add('Lightfoot Halfling') | Out-Null
            $ChosenSubRace.Items.Add('Stout Halfling') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Half-Orc')
        {
            $ChosenSubRace.Items.Add('Half-Orc') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Human')
        {
            $ChosenSubRace.Items.Add('Human') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Tiefling')
        {
            $ChosenSubRace.Items.Add('Tiefling') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Orc')
        {
            $ChosenSubRace.Items.Add('Orc') | Out-Null
            $ChosenSubRace.Items.Add('Eye of Gruumsh') | Out-Null
            $ChosenSubRace.Items.Add('Ranging Scavengers') | Out-Null
            $ChosenSubRace.Items.Add('Orc Crossbreed') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Leonin')
        {
            $ChosenSubRace.Items.Add('Leonin') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Satyr')
        {
            $ChosenSubRace.Items.Add('Satyr') | Out-Null
            $ChosenSubRace.Items.Add('Hedonistic Revelers') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Fairy')
        {
            $ChosenSubRace.Items.Add('Fairy') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Harengon')
        {
            $ChosenSubRace.Items.Add('Herengon') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Aarakocra')
        {
            $ChosenSubRace.Items.Add('Aarakocra') | Out-Null
            $ChosenSubRace.Items.Add('Enemies of Elemental Evil') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Genasi')
        {
            $ChosenSubRace.Items.Add('Genasi') | Out-Null
            $ChosenSubRace.Items.Add('Air Genasi') | Out-Null
            $ChosenSubRace.Items.Add('Earth Genasi') | Out-Null
            $ChosenSubRace.Items.Add('Fire Genasi') | Out-Null
            $ChosenSubRace.Items.Add('Water Genasi') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Goliath')
        {
            $ChosenSubRace.Items.Add('Goliath') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Aasimar')
        {
            $ChosenSubRace.Items.Add('Aasimar') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Bugbear')
        {
            $ChosenSubRace.Items.Add('Bugbear') | Out-Null
            $ChosenSubRace.Items.Add('Bugbear Chief') | Out-Null
            $ChosenSubRace.Items.Add('Followers of Hruggek') | Out-Null
            $ChosenSubrace.Items.Add('Venal Ambushers') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Firbolg')
        {
            $ChosenSubRace.Items.Add('Firbolg') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Goblin')
        {
            $ChosenSubRace.Items.Add('Goblin') | Out-Null
            $ChosenSubRace.Items.Add('Goblinoids') | Out-Null
            $ChosenSubRace.Items.Add('Malicious Glee') | Out-Null
            $ChosenSubRace.Items.Add('Challenging Liers') | Out-Null
            $ChosenSubRace.Items.Add('Rat Keepers and Wolf Riders') | Out-Null
            $ChosenSubRace.Items.Add('Worshipers of Maglubiyet') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Hobgoblin')
        {
            $ChosenSubRace.Items.Add('Hobgoblin') | Out-Null
            $ChosenSubRace.Items.Add('Hobgoblin Captain') | Out-Null
            $ChosenSubRace.Items.Add('Legion of Maglubiyet') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Kenku')
        {
            $ChosenSubRace.Items.Add('Kenku') | Out-Null
            $ChosenSubRace.Items.Add('Fallen Flocks') | Out-Null
            $ChosenSubRace.Items.Add('The Whistful Wingless') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Kobold')
        {
            $ChosenSubRace.Items.Add('Kobold') | Out-Null
            $ChosenSubRace.Items.Add('Winged Kobold') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Lizardfolk')
        {
            $ChosenSubRace.Items.Add('Lizardfolk') | Out-Null
            $ChosenSubRace.Items.Add('Lizardfolk Shamen') | Out-Null
            $ChosenSubRace.Items.Add('Territorial Xenophobes') | Out-Null
            $ChosenSubRace.Items.Add('Great Feasts and Sacrifices') | Out-Null
            $ChosenSubRace.Items.Add('Canny Crafters') | Out-Null
            $ChosenSubRace.Items.Add('Lizardfolk Leaders') | Out-Null
            $ChosenSubRace.Items.Add('Dragon Worshipers') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Tabaxi')
        {
            $ChosenSubRace.Items.Add('Tabaxi') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Triton')
        {
            $ChosenSubRace.Items.Add('Triton') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Yuan-ti Pureblood')
        {
            $ChosenSubRace.Items.Add('Yuan-ti Pureblood') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Feral Tiefling')
        {
            $ChosenSubRace.Items.Add('Feral Tiefling') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Tortle')
        {
            $ChosenSubRace.Items.Add('Tortle') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Changling')
        {
            $ChosenSubRace.Items.Add('Changling') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Kalashtar')
        {
            $ChosenSubRace.Items.Add('Kalashtar') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Shifter')
        {
            $ChosenSubRace.Items.Add('Shifter') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Warforged')
        {
            $ChosenSubRace.Items.Add('Warforged') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Gith')
        {
            $ChosenSubRace.Items.Add('Gith') | Out-Null
            $ChosenSubRace.Items.Add('Githyanki') | Out-Null
            $ChosenSubRace.Items.Add('Githyanki Warrior') | Out-Null
            $ChosenSubRace.Items.Add('Githyanki Knight') | Out-Null
            $ChosenSubRace.Items.Add('Astral Raiders') | Out-Null
            $ChosenSubRace.Items.Add('Followers of Gith') | Out-Null
            $ChosenSubRace.Items.Add('Silver Swords') | Out-Null
            $ChosenSubRace.Items.Add('Red Dragon Riders') | Out-Null
            $ChosenSubRace.Items.Add('Githzerai') | Out-Null
            $ChosenSubRace.Items.Add('Githzerai Monk') | Out-Null
            $ChosenSubRace.Items.Add('Githzerai Zerth') | Out-Null
            $ChosenSubRace.Items.Add('Psionic Adepts') | Out-Null
            $ChosenSubRace.Items.Add('Order amid Chaos') | Out-Null
            $ChosenSubRace.Items.Add('Disciples of Zerthimon') | Out-Null
            $ChosenSubRace.Items.Add('Beyond Limbo') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Centaur')
        {
            $ChosenSubRace.Items.Add('Centaur') | Out-Null
            $ChosenSubRace.Items.Add('Wilderness Nomads') | Out-Null
            $ChosenSubRace.Items.Add('Reluctant Settlers') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Loxodon')
        {
            $ChosenSubRace.Items.Add('Loxodon') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Minotaur')
        {
            $ChosenSubRace.Items.Add('Minotaur') | Out-Null
            $ChosenSubRace.Items.Add('The Beast Within') | Out-Null
            $ChosenSubRace.Items.Add('Cults of the Horned King') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Simic Hybrid')
        {
            $ChosenSubRace.Items.Add('Simic Hybrid') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Vedalken')
        {
            $ChosenSubRace.Items.Add('Vadelken') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Verdan')
        {
            $ChosenSubRace.Items.Add('Verdan') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Locathah')
        {
            $ChosenSubRace.Items.Add('Locathah') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Grung')
        {
            $ChosenSubRace.Items.Add('Grung') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Lycanth')
        {
            $ChosenSubRace.Items.Add('Lycanth') | Out-Null
            $ChosenSubRace.Items.Add('Curse of Lycanthropy') | Out-Null
            $ChosenSubRace.Items.Add('Werebear') | Out-Null
            $ChosenSubRace.Items.Add('Wereboar') | Out-Null
            $ChosenSubRace.Items.Add('Wererat') | Out-Null
            $ChosenSubRace.Items.Add('Weretiger') | Out-Null
            $ChosenSubRace.Items.Add('Werewolf') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Troll')
        {
            $ChosenSubRace.Items.Add('Troll') | Out-Null
            $ChosenSubRace.Items.Add('Troll Freaks') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Ogre')
        {
            $ChosenSubRace.Items.Add('Ogre') | Out-Null
            $ChosenSubRace.Items.Add('Furious Tempers') | Out-Null
            $ChosenSubRace.Items.Add('Gruesome Gluttons') | Out-Null
            $ChosenSubRace.Items.Add('Greedy Collectors') | Out-Null
            $ChosenSubRace.Items.Add('Legendary Stupidity') | Out-Null
            $ChosenSubRace.Items.Add('Primitive Wanderers') | Out-Null
        }
        if ($ChosenRace.SelectedItem -match 'Wolf')
        {
            $ChosenSubRace.Items.Add('Wolf') | Out-Null
            $ChosenSubRace.Items.Add('Winter Wolf') | Out-Null
            $ChosenSubRace.Items.Add('Timber Wolf') | Out-Null
            $ChosenSubRace.Items.Add('Dire Wolf') | Out-Null
        }
        
        if ($subracetype -eq [System.Windows.Forms.DialogResult]::OK)
        {
            $selectedsubrace = $ChosenSubRace.SelectedItem
            $selectedsubrace
        }
        if ($subracetype -eq [System.Windows.Forms.DialogResult]::Ignore)
        {
            $ChosenSubRace = "N/A"
        }
        $subracetype = $form.ShowDialog()
        if ($subracetype -eq [System.Windows.Forms.DialogResult]::Retry)
        {
            return
        }
        if ($subracetype -eq [System.Windows.Forms.DialogResult]::Cancel)
        {
            Exit
        }
#End of SubRace Selection

#Books need to be purchased so the rest of these creatures can be filled out, or found on the internet
#Preferably purchased for table-top reasons

#To add a custom race list to the subraces do:
#if ($ChosenSubRace.SelectedItem -match 'Custom')
#{
#   $ChosenSubRace.Items.Add('**') | Out-Null
#}

#Basic user information gathering - Primary Class + Alignment
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Sparks D&D Character Creator'
    $form.Size = New-Object System.Drawing.Size(500,350)
    $form.StartPosition = 'CenterScreen'
    $objIcon = New-Object system.drawing.icon (".\Assets\installer.ico")
    $form.Icon = $objIcon
    
    $objImage = [system.drawing.image]::FromFile(".\Assets\form_background.png")
    $form.BackgroundImage = $objImage
    $form.BackgroundImageLayout = "Center"
    
    $form.Width = $objImage.Width
    $form.Height = $objImage.Height

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(75,270)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'Next'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    $skipButton = New-Object System.Windows.Forms.Button
    $skipButton.Location = New-Object System.Drawing.Point(150,270)
    $skipButton.Size = New-Object System.Drawing.Size(75,23)
    $skipButton.Text = 'Skip'
    $skipButton.DialogResult = [System.Windows.Forms.DialogResult]::Ignore
    $form.AcceptButton = $skipButton
    $form.Controls.Add($skipButton)

    $backButton = New-Object System.Windows.Forms.Button
    $backButton.Location = New-Object System.Drawing.Point(225,270)
    $backButton.Size = New-Object System.Drawing.Size(75,23)
    $backButton.Text = 'Back'
    $backButton.DialogResult = [System.Windows.Forms.DialogResult]::Retry
    $form.CancelButton = $backButton
    $form.Controls.Add($backButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(300,270)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,20)
    $label.Size = New-Object System.Drawing.Size(160,18)
    $label.Text = 'Please select a Primary Class:'
    $form.Controls.Add($label)

    $ChosenClass = New-Object System.Windows.Forms.ListBox
    $ChosenClass.Location = New-Object System.Drawing.Point(10,40)
    $ChosenClass.Size = New-Object System.Drawing.Size(160,20)
    $ChosenClass.Height = 200

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(200,20)
    $label.Size = New-Object System.Drawing.Size(160,18)
    $label.Text = 'Please select an Alignment:'
    $form.Controls.Add($label)

    $ChosenAlignment = New-Object System.Windows.Forms.ListBox
    $ChosenAlignment.Location = New-Object System.Drawing.Point(200,40)
    $ChosenAlignment.Size = New-Object System.Drawing.Size(160,20)
    $ChosenAlignment.Height = 200

    #Alignment List
        $ChosenAlignment.Items.Add('Chaotic Evil') | Out-Null
        $ChosenAlignment.Items.Add('Chaotic Neutral') | Out-Null
        $ChosenAlignment.Items.Add('Chaotic Good') | Out-Null
        $ChosenAlignment.Items.Add('Neutral Evil') | Out-Null
        $ChosenAlignment.Items.Add('Neutral') | Out-Null
        $ChosenAlignment.Items.Add('Neutral Good') | Out-Null
        $ChosenAlignment.Items.Add('Lawful Evil') | Out-Null
        $ChosenAlignment.Items.Add('Lawful Neutral') | Out-Null
        $ChosenAlignment.Items.Add('Lawful Good') | Out-Null

        #To add a custom alignment use this line with a name given and then follow
        #down the script to add it to the rest of the script
        #$ChosenAlignment.Items.Add('Custom') | Out-Null
        #You need to also add a race description if you wish other players to use it
        #Along with a race picture, this is all in the "Assets" folder
        #Alignment can also be just a race trait, potentially pulling out choice?
        #TO DO! Add hover text for each race
 
    #Class List
        $ChosenClass.Items.Add('Artificer') | Out-Null
        $ChosenClass.Items.Add('Barbarian') | Out-Null
        $ChosenClass.Items.Add('Bard') | Out-Null
        $ChosenClass.Items.Add('Cleric') | Out-Null
        $ChosenClass.Items.Add('Druid') | Out-Null
        $ChosenClass.Items.Add('Fighter') | Out-Null
        $ChosenClass.Items.Add('Monk') | Out-Null
        $ChosenClass.Items.Add('Paladin') | Out-Null
        $ChosenClass.Items.Add('Ranger') | Out-Null
        $ChosenClass.Items.Add('Rogue') | Out-Null
        $ChosenClass.Items.Add('Sorcerer') | Out-Null
        $ChosenClass.Items.Add('Warlock') | Out-Null
        $ChosenClass.Items.Add('Wizard') | Out-Null

    #To add a custom class use: #$ChosenClass.Items.Add('CUSTOM') | Out-Null
    #Then make sure to add below on the "IF" statements

        if ($ChosenClass.SelectedItem -match 'Artificer')
        {
            $ChosenClassArtificer = $ChosenClassArtificer.SelectedItem 
        }
        if ($ChosenClass.SelectedItem -match 'Barbarian')
        {
            $ChosenClassBarbarian = $ChosenClassBarbarian.SelectedItem 
        }
        if ($ChosenClass.SelectedItem -match 'Bard')
        {
            $ChosenClassBard = $ChosenClassBard.SelectedItem 
        }
        if ($ChosenClass.SelectedItem -match 'Cleric')
        {
            $ChosenClassCleric = $ChosenClassCleric.SelectedItem 
        }
        if ($ChosenClass.SelectedItem -match 'Druid')
        {
            $ChosenClassDruid = $ChosenClassDruid.SelectedItem 
        }
        if ($ChosenClass.SelectedItem -match 'Fighter')
        {
            $ChosenClassFighter = $ChosenClassFighter.SelectedItem 
        }
        if ($ChosenClass.SelectedItem -match 'Monk')
        {
            $ChosenClassMonk = $ChosenClassMonk.SelectedItem 
        }
        if ($ChosenClass.SelectedItem -match 'Paladin')
        {
            $ChosenClassPaladin = $ChosenClassPaladin.SelectedItem 
        }
        if ($ChosenClass.SelectedItem -match 'Ranger')
        {
            $ChosenClassRanger = $ChosenClassRanger.SelectedItem 
        }
        if ($ChosenClass.SelectedItem -match 'Rogue')
        {
            $ChosenClassRogue = $ChosenClassRogue.SelectedItem 
        }
        if ($ChosenClass.SelectedItem -match 'Sorcerer')
        {
            $ChosenClassSorcerer = $ChosenClassSorcerer.SelectedItem 
        }
        if ($ChosenClass.SelectedItem -match 'Warlock')
        {
            $ChosenClassWarlock = $ChosenClassWarlock.SelectedItem 
        }
        if ($ChosenClass.SelectedItem -match 'Wizard')
        {
            $ChosenClassWizard = $ChosenClassWizard.SelectedItem 
        }
        $form.Controls.Add($ChosenClass)
        $form.Controls.Add($ChosenAlignment)
        $form.Topmost = $true

        if ($chosencharacter -eq [System.Windows.Forms.DialogResult]::OK)
        {
            $SelectedClass = $ChosenClass.SelectedItem
            $SelectedClass
            
            $selectedalignment = $ChosenAlignment.SelectedItem
            $selectedalignment
        }
        if ($chosencharacter -eq [System.Windows.Forms.DialogResult]::Ignore)
        {
            $ChosenClass = "None Selected"
            $ChosenAlignment = "None Selected"
        }
        $chosencharacter = $form.ShowDialog()
        if ($chosencharacter -eq [System.Windows.Forms.DialogResult]::Retry)
        {
            return
        }
        if ($chosencharacter -eq [System.Windows.Forms.DialogResult]::Cancel)
        {
            Exit
        }
    #use this for an example when adding a chosen class for future script parts
    #    if ($ChosenClass.SelectedItem -match 'Custom')
    #{
    #    $ChosenClassCustom = $ChosenClassCustom.SelectedItem 
    #}
#end of class + alignment selection
#For future reference, setup the chosen class then tells the rest of the document what you can and cant select with IF statements
#This will mean that this powershell script is going to get BIG, but worth it!
#Make sure whaterver you set needs to be followed to the characterarray

#Basic user information gathering - SubClass
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Sparks D&D Character Creator'
    $form.Size = New-Object System.Drawing.Size(500,350)
    $form.StartPosition = 'CenterScreen'
    $objIcon = New-Object system.drawing.icon (".\Assets\installer.ico")
    $form.Icon = $objIcon
    
    $objImage = [system.drawing.image]::FromFile(".\Assets\form_background.png")
    $form.BackgroundImage = $objImage
    $form.BackgroundImageLayout = "Center"
    
    $form.Width = $objImage.Width
    $form.Height = $objImage.Height

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(75,270)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'Next'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    $skipButton = New-Object System.Windows.Forms.Button
    $skipButton.Location = New-Object System.Drawing.Point(150,270)
    $skipButton.Size = New-Object System.Drawing.Size(75,23)
    $skipButton.Text = 'Skip'
    $skipButton.DialogResult = [System.Windows.Forms.DialogResult]::Ignore
    $form.AcceptButton = $skipButton
    $form.Controls.Add($skipButton)

    $backButton = New-Object System.Windows.Forms.Button
    $backButton.Location = New-Object System.Drawing.Point(225,270)
    $backButton.Size = New-Object System.Drawing.Size(75,23)
    $backButton.Text = 'Back'
    $backButton.DialogResult = [System.Windows.Forms.DialogResult]::Retry
    $form.CancelButton = $backButton
    $form.Controls.Add($backButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(300,270)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,20)
    $label.Size = New-Object System.Drawing.Size(145,18)
    $label.Text = 'Please select a SubClass:'
    $form.Controls.Add($label)
    
    $Chosensubclass = New-Object System.Windows.Forms.ListBox
    $Chosensubclass.Location = New-Object System.Drawing.Point(10,40)
    $Chosensubclass.Size = New-Object System.Drawing.Size(260,20)
    $Chosensubclass.Height = 200
    $form.Topmost = $true

    #Subclass Lists, all split up to only match a primary class list
    #Post any class stats here that are needed as this is the best place for the information to go to
    #~Starting packs by class~
    #Barbarian = Explorers pack 
    #Bard = Diplomat pack / Entertainers pack 
    #Cleric = Priest pack / explorer pack 
    #Druid = Explorers pack 
    #Fighter = Dungeoneers pack / explorer pack 
    #Monk = Dungeoneers pack / explorer pack 
    #Paladin = Priest pack / explorer pack 
    #Ranger = Dungeoneers pack / explorer pack 
    #Rogue = Burgular pack / dungeoneer pack / explorer pack 
    #Sorcerer = Dungeroneer pack / explorer pack 
    #Warlock = Scholar pack / dungeoneer pack 
    #Wizard = Scholar pack / explorer pack 
    #~Back Selection Data~
    #Burgulars Pack | $Selectedpack = "A backpack, a bag of 1,000 ball bearings, 10 feet of string, a bell, 5 candles, a crowbar, a hammer, 10 pitons, a hooded lantern, 2 flasks of oil, 5 days rations, a tinderbox and a waterskin, the backpack has 50 feet of hempen rope strapped to the side of it"
    #Diplomats Pack | $Selectedpack = "A chest, 2 cases of maps and scrolls, a set of fine clothes, a bottle of ink, an ink pen, a lamp, 2 flasks of oil, 5 sheets of paper, a vial of perfume, sealing wax and soap"
    #Dungeoneers Pack | $Selectedpack = "A backpack, a crowbar, a hammer, 10 pitons, 10 torches, a tinderbox, 10 days of rations and a waterskin, the backpack has 50 feet of hempen rope strapped to the side of it"
    #Entertainers Pack | $Selectedpack = "A backpack, a bedroll, 2 costumes, 5 candles,5 days of rations, a waterskin and a disguise kit"
    #Explorers Pack | $Selectedpack = "A backpack, a bedroll, a mess kit, a tinderbox, 10 torches, 10 days of rations and a waterskin, the backpack also has 50 feet of hempen rope strapped to the side of it"
    #Priests Pack | $Selectedpack = "A backpack, a blanket, 10 candles, a tinderbox, an alms box, 2 blocks of incense, a censer, vestments, 2 days of rations and a waterskin"
    #Scholar's Pack | $Selectedpack = "A backpack, a book of lore, a bottle of ink, an ink pen, 10 sheets of parchment, a little bag of sand and a small knife"
    
        if ($ChosenClass.SelectedItem -match 'Barbarian')
        {
            $form.Controls.Add($Chosensubclass)        
                $Chosensubclass.Items.Add('Berserker') | Out-Null
                $Chosensubclass.Items.Add('Totem Warrior') | Out-Null
                $Chosensubclass.Items.Add('Battlerager') | Out-Null
                $Chosensubclass.Items.Add('Ancestorial Guardian') | Out-Null
                $Chosensubclass.Items.Add('Storm Herald') | Out-Null
                $Chosensubclass.Items.Add('Zealot') | Out-Null
                $Chosensubclass.Items.Add('Beast') | Out-Null
                $Chosensubclass.Items.Add('Wild Magic') | Out-Null
                $HitDiceTotal = "1d12"
                $ClassLevel = "Barbarian 1"
                $Check11 = 'Yes'
                $Check19 = 'Yes'
                $Selectedpack = "A backpack, a bedroll, a mess kit, a tinderbox, 10 torches, 10 days of rations and a waterskin, the backpack also has 50 feet of hempen rope strapped to the side of it"

                if ($subclass -eq [System.Windows.Forms.DialogResult]::OK)
                {
                    $SelectedSubClass = $ChosenSubClass.SelectedItem
                    $SelectedSubClass
                }
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Ignore)
                {
                    $ChosenSubClass = "None Selected"
                }
                $subclass = $form.ShowDialog()
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Retry)
                {
                    return
                }
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Cancel)
                {
                    Exit
                }
        }
        if ($ChosenClass.SelectedItem -match 'Bard')
        {
            $form.Controls.Add($Chosensubclass) 
                $Chosensubclass.Items.Add('College of Lore') | Out-Null
                $Chosensubclass.Items.Add('College of Valor') | Out-Null
                $Chosensubclass.Items.Add('College of Glamour') | Out-Null
                $Chosensubclass.Items.Add('College of Swords') | Out-Null
                $Chosensubclass.Items.Add('College of Whispers') | Out-Null
                $Chosensubclass.Items.Add('College of Eloquence') | Out-Null
                $Chosensubclass.Items.Add('College of Creation') | Out-Null
                $HitDiceTotal = "1d8"
                $ClassLevel = "Bard 1"
                $SpellCastingClass = "Bard"
                $Cantrip01 = "Blaze Ward"
                $Cantrip02 = "Dancing Lights"
                $Cantrip03 = "Friends"
                $Check18 = 'Yes'
                $Check22 = 'Yes'
                $Selectedpack = "A backpack, a bedroll, 2 costumes, 5 candles,5 days of rations, a waterskin and a disguise kit"
                
                if ($subclass -eq [System.Windows.Forms.DialogResult]::OK)
                {
                    $SelectedSubClass = $ChosenSubClass.SelectedItem
                    $SelectedSubClass
                }
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Ignore)
                {
                    $ChosenSubClass = "None Selected"
                    $SelectedSubClass = $ChosenSubClass
                    $SelectedSubClass
                }
                $subclass = $form.ShowDialog()
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Retry)
                {
                    return
                }
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Cancel)
                {
                    Exit
                }
        }
        if ($ChosenClass.SelectedItem -match 'Cleric')
        {
            $form.Controls.Add($Chosensubclass)
                $Chosensubclass.Items.Add('Knowledge Domain') | Out-Null
                $Chosensubclass.Items.Add('Life Domain') | Out-Null
                $Chosensubclass.Items.Add('Light Domain') | Out-Null
                $Chosensubclass.Items.Add('Nature Domain') | Out-Null
                $Chosensubclass.Items.Add('Tempest Domain') | Out-Null
                $Chosensubclass.Items.Add('Trickery Domain') | Out-Null
                $Chosensubclass.Items.Add('War Domain') | Out-Null
                $Chosensubclass.Items.Add('Death Domain') | Out-Null
                $Chosensubclass.Items.Add('Arcana Domain') | Out-Null
                $Chosensubclass.Items.Add('Solidarity Domain') | Out-Null
                $Chosensubclass.Items.Add('Strength Domain') | Out-Null
                $Chosensubclass.Items.Add('Ambition Domain') | Out-Null
                $Chosensubclass.Items.Add('Zeal Domain') | Out-Null
                $Chosensubclass.Items.Add('Forge Domain') | Out-Null
                $Chosensubclass.Items.Add('Grave Domain') | Out-Null
                $Chosensubclass.Items.Add('Order Domain') | Out-Null
                $Chosensubclass.Items.Add('Peace Domain') | Out-Null
                $Chosensubclass.Items.Add('Twilight Domain') | Out-Null
                $HitDiceTotal = "1d8"
                $ClassLevel = "Cleric 1"
                $SpellCastingClass = "Cleric"
                $Cantrip01 = "Guidance"
                $Cantrip02 = "Light"
                $Cantrip03 = "Mending"
                $Check21 = 'Yes'
                $Check22 = 'Yes'
                $Selectedpack = "A backpack, a blanket, 10 candles, a tinderbox, an alms box, 2 blocks of incense, a censer, vestments, 2 days of rations and a waterskin"
                
                if ($subclass -eq [System.Windows.Forms.DialogResult]::OK)
                {
                    $SelectedSubClass = $ChosenSubClass.SelectedItem
                    $SelectedSubClass
                }
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Ignore)
                {
                    $ChosenSubClass = "None Selected"
                    $SelectedSubClass = $ChosenSubClass
                    $SelectedSubClass
                }
                $subclass = $form.ShowDialog()
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Retry)
                {
                    return
                }
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Cancel)
                {
                    Exit
                }
        }
        if ($ChosenClass.SelectedItem -match 'Druid')
        {
            $form.Controls.Add($Chosensubclass)
                $Chosensubclass.Items.Add('Circle of Land') | Out-Null
                $Chosensubclass.Items.Add('Circle of The Moon') | Out-Null
                $Chosensubclass.Items.Add('Circle of Dreams') | Out-Null
                $Chosensubclass.Items.Add('Circle of The Shepherd') | Out-Null
                $Chosensubclass.Items.Add('Circle of Spores') | Out-Null
                $Chosensubclass.Items.Add('Circle of Stars') | Out-Null
                $Chosensubclass.Items.Add('Circle of Wildlife') | Out-Null
                $HitDiceTotal = "1d8"
                $ClassLevel = "Druid 1"
                $SpellCastingClass = "Druid"
                $Cantrip01 = "Druidcraft"
                $Cantrip02 = "Guidance"
                $Cantrip03 = "Mending"
                $Check20 = 'Yes'
                $Check21 = 'Yes'
                $Selectedpack = "A backpack, a bedroll, a mess kit, a tinderbox, 10 torches, 10 days of rations and a waterskin, the backpack also has 50 feet of hempen rope strapped to the side of it"
                
                if ($subclass -eq [System.Windows.Forms.DialogResult]::OK)
                {
                    $SelectedSubClass = $ChosenSubClass.SelectedItem
                    $SelectedSubClass
                }
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Ignore)
                {
                    $ChosenSubClass = "None Selected"
                    $SelectedSubClass = $ChosenSubClass
                    $SelectedSubClass
                }
                $subclass = $form.ShowDialog()
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Retry)
                {
                    return
                }
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Cancel)
                {
                    Exit
                }
        }
        if ($ChosenClass.SelectedItem -match 'Fighter')
        {
            $form.Controls.Add($Chosensubclass)
                $Chosensubclass.Items.Add('Champion') | Out-Null
                $Chosensubclass.Items.Add('Battle Master') | Out-Null
                $Chosensubclass.Items.Add('Eldritch Knight') | Out-Null
                $Chosensubclass.Items.Add('Purple Dragon Knight') | Out-Null
                $Chosensubclass.Items.Add('Arcane Archer') | Out-Null
                $Chosensubclass.Items.Add('Cavalier') | Out-Null
                $Chosensubclass.Items.Add('Samurai') | Out-Null
                $Chosensubclass.Items.Add('Echo Knight') | Out-Null
                $Chosensubclass.Items.Add('Psi Worrior') | Out-Null
                $Chosensubclass.Items.Add('Rune Knight') | Out-Null
                $HitDiceTotal = "1d10"
                $ClassLevel = "Fighter 1"
                $Check11 = 'Yes'
                $Check19 = 'Yes'
                $Selectedpack = "A backpack, a crowbar, a hammer, 10 pitons, 10 torches, a tinderbox, 10 days of rations and a waterskin, the backpack has 50 feet of hempen rope strapped to the side of it"
                
                if ($subclass -eq [System.Windows.Forms.DialogResult]::OK)
                {
                    $SelectedSubClass = $ChosenSubClass.SelectedItem
                    $SelectedSubClass
                }
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Ignore)
                {
                    $ChosenSubClass = "None Selected"
                    $SelectedSubClass = $ChosenSubClass
                    $SelectedSubClass
                }
                $subclass = $form.ShowDialog()
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Retry)
                {
                    return
                }
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Cancel)
                {
                    Exit
                }
        }
        if ($ChosenClass.SelectedItem -match 'Monk')
        {
            $form.Controls.Add($Chosensubclass)
                $Chosensubclass.Items.Add('Way Of The Open Hand') | Out-Null
                $Chosensubclass.Items.Add('Way of Shadow') | Out-Null
                $Chosensubclass.Items.Add('Way of The Four Elements') | Out-Null
                $Chosensubclass.Items.Add('Way of Long Death') | Out-Null
                $Chosensubclass.Items.Add('Way of Sun Soul') | Out-Null
                $Chosensubclass.Items.Add('Way of Drunken Master') | Out-Null
                $Chosensubclass.Items.Add('Way of Kensei') | Out-Null
                $Chosensubclass.Items.Add('Way of Mercy') | Out-Null
                $Chosensubclass.Items.Add('Way of Astral Self') | Out-Null
                $HitDiceTotal = "1d8"
                $ClassLevel = "Monk 1"
                $Check11 = 'Yes'
                $Check18 = 'Yes'
                $Selectedpack = "A backpack, a crowbar, a hammer, 10 pitons, 10 torches, a tinderbox, 10 days of rations and a waterskin, the backpack has 50 feet of hempen rope strapped to the side of it"
                
                if ($subclass -eq [System.Windows.Forms.DialogResult]::OK)
                {
                    $SelectedSubClass = $ChosenSubClass.SelectedItem
                    $SelectedSubClass
                }
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Ignore)
                {
                    $ChosenSubClass = "None Selected"
                    $SelectedSubClass = $ChosenSubClass
                    $SelectedSubClass
                }
                $subclass = $form.ShowDialog()
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Retry)
                {
                    return
                }
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Cancel)
                {
                    Exit
                }
        }
        if ($ChosenClass.SelectedItem -match 'Paladin')
        {
            $form.Controls.Add($Chosensubclass)
                $Chosensubclass.Items.Add('Oath Of Devotion') | Out-Null
                $Chosensubclass.Items.Add('Oath Of The Ancients') | Out-Null
                $Chosensubclass.Items.Add('Oath Of Vengeance') | Out-Null
                $Chosensubclass.Items.Add('Oathbreaker') | Out-Null
                $Chosensubclass.Items.Add('Oath Of The Crown') | Out-Null
                $Chosensubclass.Items.Add('Oath Of Conquest') | Out-Null
                $Chosensubclass.Items.Add('Oath Of Redemption') | Out-Null
                $Chosensubclass.Items.Add('Oath Of Glory') | Out-Null
                $Chosensubclass.Items.Add('Oath Of The Watchers') | Out-Null
                $HitDiceTotal = "1d10"
                $ClassLevel = "Paladin 1"
                $SpellCastingClass = "Paladin"
                $Cantrip01 = "Bless"
                $Cantrip02 = "Command"
                $Cantrip03 = "Compelled Duel"
                $Check21 = 'Yes'
                $Check22 = 'Yes'
                $Selectedpack = "A backpack, a blanket, 10 candles, a tinderbox, an alms box, 2 blocks of incense, a censer, vestments, 2 days of rations and a waterskin"
                
                if ($subclass -eq [System.Windows.Forms.DialogResult]::OK)
                {
                    $SelectedSubClass = $ChosenSubClass.SelectedItem
                    $SelectedSubClass
                }
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Ignore)
                {
                    $ChosenSubClass = "None Selected"
                    $SelectedSubClass = $ChosenSubClass
                    $SelectedSubClass
                }
                $subclass = $form.ShowDialog()
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Retry)
                {
                    return
                }
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Cancel)
                {
                    Exit
                }
        }
        if ($ChosenClass.SelectedItem -match 'Ranger')
        {
            $form.Controls.Add($Chosensubclass)
                $Chosensubclass.Items.Add('Hunter') | Out-Null
                $Chosensubclass.Items.Add('Beast Master') | Out-Null
                $Chosensubclass.Items.Add('Gloom Stalker') | Out-Null
                $Chosensubclass.Items.Add('Horizon Walker') | Out-Null
                $Chosensubclass.Items.Add('Monster Slayer') | Out-Null
                $Chosensubclass.Items.Add('Fey Wanderer') | Out-Null
                $Chosensubclass.Items.Add('Swarmkeeper') | Out-Null
                $HitDiceTotal = "1d10"
                $ClassLevel = "Ranger 1"
                $SpellCastingClass = "Ranger"
                $Cantrip01 = "Alarm"
                $Cantrip02 = "Animal Friendship"
                $Cantrip03 = "Cure Wounds"
                $Check11 = 'Yes'
                $Check18 = 'Yes'
                $Selectedpack = "A backpack, a crowbar, a hammer, 10 pitons, 10 torches, a tinderbox, 10 days of rations and a waterskin, the backpack has 50 feet of hempen rope strapped to the side of it"
                
                if ($subclass -eq [System.Windows.Forms.DialogResult]::OK)
                {
                    $SelectedSubClass = $ChosenSubClass.SelectedItem
                    $SelectedSubClass
                }
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Ignore)
                {
                    $ChosenSubClass = "None Selected"
                    $SelectedSubClass = $ChosenSubClass
                    $SelectedSubClass
                }
                $subclass = $form.ShowDialog()
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Retry)
                {
                    return
                }
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Cancel)
                {
                    Exit
                }
        }
        if ($ChosenClass.SelectedItem -match 'Rogue')
        {
            $form.Controls.Add($Chosensubclass)
                $Chosensubclass.Items.Add('Theif') | Out-Null
                $Chosensubclass.Items.Add('Assassin') | Out-Null
                $Chosensubclass.Items.Add('Arcane Trickster') | Out-Null
                $Chosensubclass.Items.Add('Mastermind') | Out-Null
                $Chosensubclass.Items.Add('Swashbuckler') | Out-Null
                $Chosensubclass.Items.Add('Inquisitive') | Out-Null
                $Chosensubclass.Items.Add('Scout') | Out-Null
                $Chosensubclass.Items.Add('Phantom') | Out-Null
                $Chosensubclass.Items.Add('Soulknife') | Out-Null
                $HitDiceTotal = "1d8"
                $ClassLevel = "Rogue 1"
                $Check18 = 'Yes'
                $Check20 = 'Yes'
                $Selectedpack = "A backpack, a bag of 1,000 ball bearings, 10 feet of string, a bell, 5 candles, a crowbar, a hammer, 10 pitons, a hooded lantern, 2 flasks of oil, 5 days rations, a tinderbox and a waterskin, the backpack has 50 feet of hempen rope strapped to the side of it"
                
                if ($subclass -eq [System.Windows.Forms.DialogResult]::OK)
                {
                    $SelectedSubClass = $ChosenSubClass.SelectedItem
                    $SelectedSubClass
                }
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Ignore)
                {
                    $ChosenSubClass = "None Selected"
                    $SelectedSubClass = $ChosenSubClass
                    $SelectedSubClass
                }
                $subclass = $form.ShowDialog()
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Retry)
                {
                    return
                }
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Cancel)
                {
                    Exit
                }
        }
        if ($ChosenClass.SelectedItem -match 'Sorcerer')
        {
            $form.Controls.Add($Chosensubclass)
                $Chosensubclass.Items.Add('Draconic Bloodline') | Out-Null
                $Chosensubclass.Items.Add('Wild Magic') | Out-Null
                $Chosensubclass.Items.Add('Storm Sorcery') | Out-Null
                $Chosensubclass.Items.Add('Pyromancer') | Out-Null
                $Chosensubclass.Items.Add('Divine Soul') | Out-Null
                $Chosensubclass.Items.Add('Shadow Magic') | Out-Null
                $Chosensubclass.Items.Add('Aberrant Mind') | Out-Null
                $Chosensubclass.Items.Add('Clockwork Soul') | Out-Null
                $HitDiceTotal = "1d6"
                $ClassLevel = "Sorcerer 1"
                $SpellCastingClass = "Sorcerer"
                $Cantrip01 = "Acid Splash"
                $Cantrip02 = "Blade Ward"
                $Cantrip03 = "Chill Torch"
                $Check19 = 'Yes'
                $Check22 = 'Yes'
                $Selectedpack = "A backpack, a crowbar, a hammer, 10 pitons, 10 torches, a tinderbox, 10 days of rations and a waterskin, the backpack has 50 feet of hempen rope strapped to the side of it"
                
                if ($subclass -eq [System.Windows.Forms.DialogResult]::OK)
                {
                    $SelectedSubClass = $ChosenSubClass.SelectedItem
                    $SelectedSubClass
                }
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Ignore)
                {
                    $ChosenSubClass = "None Selected"
                    $SelectedSubClass = $ChosenSubClass
                    $SelectedSubClass
                }
                $subclass = $form.ShowDialog()
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Retry)
                {
                    return
                }
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Cancel)
                {
                    Exit
                }
        }
        if ($ChosenClass.SelectedItem -match 'Warlock')
        {
            $form.Controls.Add($Chosensubclass)
                $Chosensubclass.Items.Add('The Archfey') | Out-Null
                $Chosensubclass.Items.Add('The Fiend') | Out-Null
                $Chosensubclass.Items.Add('The Great Old One') | Out-Null
                $Chosensubclass.Items.Add('The Undying') | Out-Null
                $Chosensubclass.Items.Add('The Celestial') | Out-Null
                $Chosensubclass.Items.Add('The Hexblade') | Out-Null
                $Chosensubclass.Items.Add('The Fathomless') | Out-Null
                $Chosensubclass.Items.Add('The Genie') | Out-Null
                $HitDiceTotal = "1d8"
                $ClassLevel = "Warlock 1"
                $SpellCastingClass = "Warlock"
                $Cantrip01 = "Blade Ward"
                $Cantrip02 = "Chill Torch"
                $Cantrip03 = "Eldritch Blast"
                $Check21 = 'Yes'
                $Check22 = 'Yes'
                $Selectedpack = "A backpack, a book of lore, a bottle of ink, an ink pen, 10 sheets of parchment, a little bag of sand and a small knife"
                
                if ($subclass -eq [System.Windows.Forms.DialogResult]::OK)
                {
                    $SelectedSubClass = $ChosenSubClass.SelectedItem
                    $SelectedSubClass
                }
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Ignore)
                {
                    $ChosenSubClass = "None Selected"
                    $SelectedSubClass = $ChosenSubClass
                    $SelectedSubClass
                }
                $subclass = $form.ShowDialog()
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Retry)
                {
                    return
                }
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Cancel)
                {
                    Exit
                }
        }
        if ($ChosenClass.SelectedItem -match 'Wizard')
        {
            $form.Controls.Add($Chosensubclass)
                $Chosensubclass.Items.Add('School Of Abjuration') | Out-Null
                $Chosensubclass.Items.Add('School Of Conjuration') | Out-Null
                $Chosensubclass.Items.Add('School Of Divination') | Out-Null
                $Chosensubclass.Items.Add('School Of Enchantment') | Out-Null
                $Chosensubclass.Items.Add('School Of Evocation') | Out-Null
                $Chosensubclass.Items.Add('School Of Illusion') | Out-Null
                $Chosensubclass.Items.Add('School Of Necromancy') | Out-Null
                $Chosensubclass.Items.Add('School Of Transmutation') | Out-Null
                $Chosensubclass.Items.Add('Bladesinging') | Out-Null
                $Chosensubclass.Items.Add('War Magic') | Out-Null
                $Chosensubclass.Items.Add('Chronurgy Magic') | Out-Null
                $Chosensubclass.Items.Add('Gravitygy Magic') | Out-Null
                $Chosensubclass.Items.Add('Order Of Scribes') | Out-Null
                $HitDiceTotal = "1d6"
                $ClassLevel = "Wizard 1"
                $SpellCastingClass = "Wizard"
                $Cantrip01 = "Acid Splash"
                $Cantrip02 = "Blade Ward"
                $Cantrip03 = "Chill Touch"
                $Check20 = 'Yes'
                $Check21 = 'Yes'
                $Selectedpack = "A backpack, a book of lore, a bottle of ink, an ink pen, 10 sheets of parchment, a little bag of sand and a small knife"
                
                if ($subclass -eq [System.Windows.Forms.DialogResult]::OK)
                {
                    $SelectedSubClass = $ChosenSubClass.SelectedItem
                    $SelectedSubClass
                }
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Ignore)
                {
                    $ChosenSubClass = "N/A"
                    $SelectedSubClass = $ChosenSubClass
                    $SelectedSubClass
                    $ClassLevel = "N/A"
                }
                $subclass = $form.ShowDialog()
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Retry)
                {
                    return
                }
                if ($subclass -eq [System.Windows.Forms.DialogResult]::Cancel)
                {
                    Exit
                } 
        }
        #To add a list of subclasses to a chosen class follow this:
        #if ($ChosenClass.SelectedItem -match 'Custom')
        #{
        #    $form.Controls.Add($Chosensubclass)
        #        $Chosensubclass.Items.Add('Starting name - Custom Class')
        #   $subclass = $form.ShowDialog()
            #$HitDiceTotal = "*"
            #$ClassLevel = "*"
            #$SpellCastingClass = "*"
            #$Cantrip01 = "*"
            #$Cantrip02 = "*"
            #$Cantrip03 = "*"
            #$Check** = 'Yes'
            #$Check** = 'Yes'
            #Selectedpack = "*Equiptment*"
        #}    
#End of subclass selection
#Filling out final details from selected above
if ($ChosenRace.SelectedItem -match 'Dragonborn')
    {
        #Race Stats
        $ChosenRaceDragonborn = $ChosenRaceDragonborn.SelectedItem
        $ChosenRaceDragonborn
        $ExportRace = "Dragonborn"
        $HP = "20"
        $SpeedTotal = "30"
        $PlayerSize = "250 Pounds, Medium"
        $Playerheight = "6 Feet"
    
        #Attributes Basic
        $STR = "15"
        $DEX = "11"
        $CON = "12"
        $INT = "10"
        $WIS = "15"
        $CHA = "15"

        #Attribute Modifiers
        $STRmod = "+3"
        $DEXmod = "+2"
        $CONmod = "+3"
        $INTmod = "+0"
        $WISmod = "+2"
        $CHAmod = "+4"

        #Saving Throws Attributes
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"
        #Saving Throws Tickbox's

        ##Skills Values

        ##Skills Tickbox's

        #RaceExtra's
        #$Senses = "Unknown"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"

        $RaceDescription = "Dragonborn look very much like dragons standing erect in humanoid form, though they lack wings or a tail. The first dragonborn had scales of vibrant hues matching the colors of their dragon kin, but generations of interbreeding have created a more uniform appearance. Their small, fine scales are usually brass or bronze in color, sometimes ranging to scarlet, rust, gold, or copper-green. They are tall and strongly built, often standing close to 6½ feet tall and weighing 300 pounds or more. Their hands and feet are strong, talonlike claws with three fingers and a thumb on each hand.

        The blood of a particular type of dragon runs very strong through some dragonborn clans. These dragonborn often boast scales that more closely match those of their dragon ancestor bright red, green, blue, or white, lustrous black, or gleaming metallic gold, silver, brass, copper, or bronze."
        $RaceDescription
        $SpokenLanguages = "You can speak, read, and write Common and Draconic. Draconic is thought to be one of the oldest languages and is often used in the study of magic. The language sounds harsh to most other creatures and includes numerous hard consonants and sibilants."
        $RacialSpecialAbility = "Breath Weapon, You can use your action to exhale destructive energy. Your draconic ancestry determines the size, shape, and damage type of the exhalation. When you use your breath weapon, each creature in the area of the exhalation must make a saving throw, the type of which is determined by your draconic ancestry. The DC for this saving throw equals 8 and your Constitution modifier and your proficiency bonus. A creature takes 2d6 damage on a failed save, and half as much damage on a successful one. The damage increases to 3d6 at 6th level, 4d6 at 11th level, and 5d6 at 16th level. After you use your breath weapon, you cant use it again until you complete a short or long rest."
        $CharacterImage = '.\Assets\Race_Pictures\Dragonborn.png'
        #$CharacterImage = Get-Item -path '.\Assets\Race_Pictures\Dragonborn.png'
    }
    if ($ChosenRace.SelectedItem -match 'Dwarf')
    {
        $ChosenRaceDwarf = $ChosenRaceDwarf.SelectedItem 
        $ChosenRaceDwarf
        $ExportRace = "Dwarf"
        $HP = "0"
        $SpeedTotal = "25"
        $PlayerSize = "150 Pounds, Medium"
        $Playerheight = "5 Feet"

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Unknown"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "You can speak, read, and write Common and Dwarvish. Dwarvish is full of hard consonants and guttural sounds, and those characteristics spill over into whatever other language a dwarf might speak."
        $RaceDescription = "Kingdoms rich in ancient grandeur, halls carved into the roots of mountains, the echoing of picks and hammers in deep mines and blazing forges, a commitment to clan and tradition, and a burning hatred of goblins and orcs, these common threads unite all dwarves."
        $RacialSpecialAbility = "Unknown"
    }
    if ($ChosenRace.SelectedItem -match 'Elf')
    {
        $ChosenRaceElf = $ChosenRaceElf.SelectedItem 
        $ChosenRaceElf
        $ExportRace = "Elf"
        $HP = "0"
        $SpeedTotal = "30"
        $PlayerSize = "Slender Builds, Medium"
        $Playerheight = "6 Feet"

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+4"
        $CONmod = "+3"
        $INTmod = "+0"
        $WISmod = "+1"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Unknown"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "You can speak, read, and write Common and Elvish. Elvish is fluid, with subtle intonations and intricate grammar. Elven literature is rich and varied, and their songs and poems are famous among other races. Many bards learn their language so they can add Elvish ballads to their repertoires."
        $RaceDescription = "Elves are a magical people of otherworldly grace, living in the world but not entirely part of it. They live in places of ethereal beauty, in the midst of ancient forests or in silvery spires glittering with faerie light, where soft music drifts through the air and gentle fragrances waft on the breeze. Elves love nature and magic, art and artistry, music and poetry, and the good things of the world."
        $RacialSpecialAbility = "Unknown"
    }
    if ($ChosenRace.SelectedItem -match 'Gnome')
    {
        $ChosenRaceGnome = $ChosenRaceGnome.SelectedItem 
        $ChosenRaceGnome
        $ExportRace = "Gnome"
        $HP = "16"
        $SpeedTotal = "25"
        $PlayerSize = "40 Pounds, Small"
        $Playerheight = "4 Feet"

        #Attributes
        $STR = "15"
        $DEX = "14"
        $CON = "14"
        $INT = "12"
        $WIS = "10"
        $CHA = "9"

        #Attribute Modifiers
        $STRmod = "+2"
        $DEXmod = "+2"
        $CONmod = "+2"
        $INTmod = "++1"
        $WISmod = "+0"
        $CHAmod = "-1"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"
        #$Skills = "Unknown"
        #$Senses = "Unknown"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "You can speak, read, and write Common and Gnomish. The Gnomish language, which uses the Dwarvish script, is renowned for its technical treatises and its catalogs of knowledge about the natural world."
        $RaceDescription = "A constant hum of busy activity pervades the warrens and neighborhoods where gnomes form their close knit communities. Louder sounds punctuate the hum: a crunch of grinding gears here, a minor explosion there, a yelp of surprise or triumph, and especially bursts of laughter. Gnomes take delight in life, enjoying every moment of invention, exploration, investigation, creation, and play."
        $RacialSpecialAbility = "Stone Camouflage. The gnome has advantage on Dexterity (stealth) checks made to hide in rocky terrain. 
        Gnome Cunning. The gnome has advantage on Intelligence, Wisdom and Charisma saving throws against magic. 
        Innate Spellcasting. The gnome's innate spellcasting ability is Intelligence (spell save DC 11). It can innately cast the following spells, requiring no material components: 
        At will: nondetection (self only) 1/day each: blindness/deafness, blur, disguise self"
    }
    if ($ChosenRace.SelectedItem -match 'Half-Elf')
    {
        $ChosenRaceHalf_Elf = $ChosenRaceHalf_Elf.SelectedItem 
        $ChosenRaceHalf_Elf
        $ExportRace = "Half-Elf"
        $HP = "0"
        $SpeedTotal = "30"
        $PlayerSize = "Varies On Build, Medium"
        $Playerheight = "6 Feet"

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Unknown"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "You can speak, read, and write Common, Elvish, and one extra language of your choice."
        $RaceDescription = "Walking in two worlds but truly belonging to neither, half elves combine what some say are the best qualities of their elf and human parents: human curiosity, inventiveness, and ambition tempered by the refined senses, love of nature, and artistic tastes of the elves. Some half elves live among humans, set apart by their emotional and physical differences, watching friends and loved ones age while time barely touches them. Others live with the elves, growing restless as they reach adulthood in the timeless elven realms, while their peers continue to live as children. Many half elves, unable to fit into either society, choose lives of solitary wandering or join with other misfits and outcasts in the adventuring life."
        $RacialSpecialAbility = "Unknown"
    }
    if ($ChosenRace.SelectedItem -match 'Halfling')
    {
        $ChosenRaceHalfling = $ChosenRaceHalfling.SelectedItem 
        $ChosenRaceHalfling
        $ExportRace = "Halfling"
        $HP = "0"
        $SpeedTotal = "25"
        $PlayerSize = "40 Pounds, Small"
        $Playerheight = "3 Feet"

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Unknown"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "You can speak, read, and write Common and Halfling. The Halfling language isnt secret, but halflings are loath to share it with others. They write very little, so they dont have a rich body of literature. Their oral tradition, however, is very strong. Almost all halflings speak Common to converse with the people in whose lands they dwell or through which they are traveling."
        $RaceDescription = "The comforts of home are the goals of most halflings lives: a place to settle in peace and quiet, far from marauding monsters and clashing armies; a blazing fire and a generous meal; fine drink and fine conversation. Though some halflings live out their days in remote agricultural communities, others form nomadic bands that travel constantly, lured by the open road and the wide horizon to discover the wonders of new lands and peoples. But even these wanderers love peace, food, hearth, and home, though home might be a wagon jostling along a dirt road or a raft floating downriver."
        $RacialSpecialAbility = "Unknown"
    }
    if ($ChosenRace.SelectedItem -match 'Half-Orc')
    {
        $ChosenRaceHalf_Orc = $ChosenRaceHalf_Orc.SelectedItem 
        $ChosenRaceHalf_Orc
        $ExportRace = "Half-Orc"
        $HP = "0"
        $SpeedTotal = "30"
        $PlayerSize = "Larger Than Humans, Medium"
        $Playerheight = "6 Feet"

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Unknown"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "You can speak, read, and write Common and Orc. Orc is a harsh, grating language with hard consonants. It has no script of its own but is written in the Dwarvish script."
        $RaceDescription = "Whether united under the leadership of a mighty warlock or having fought to a standstill after years of conflict, orc and human tribes sometimes form alliances, joining forces into a larger horde to the terror of civilized lands nearby. When these alliances are sealed by marriages, half orcs are born. Some half orcs rise to become proud chiefs of orc tribes, their human blood giving them an edge over their full blooded orc rivals. Some venture into the world to prove their worth among humans and other more civilized races. Many of these become adventurers, achieving greatness for their mighty deeds and notoriety for their barbaric customs and savage fury."
        $RacialSpecialAbility = "Unknown"
    }
    if ($ChosenRace.SelectedItem -match 'Human')
    {
        $ChosenRaceHuman = $ChosenRaceHuman.SelectedItem 
        $ChosenRaceHuman
        $ExportRace = "Human"
        $HP = "0"
        $SpeedTotal = "30"
        $PlayerSize = "Varies On Build, Medium"
        $Playerheight = "6 Feet"

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Unknown"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "You can speak, read, and write Common and one extra language of your choice. Humans typically learn the languages of other peoples they deal with, including obscure dialects. They are fond of sprinkling their speech with words borrowed from other tongues: Orc curses, Elvish musical expressions, Dwarvish military phrases, and so on."
        $RaceDescription = "In the reckonings of most worlds, humans are the youngest of the common races, late to arrive on the world scene and short, lived in comparison to dwarves, elves, and dragons. Perhaps it is because of their shorter lives that they strive to achieve as much as they can in the years they are given. Or maybe they feel they have something to prove to the elder races, and thats why they build their mighty empires on the foundation of conquest and trade. Whatever drives them, humans are the innovators, the achievers, and the pioneers of the worlds."
        $RacialSpecialAbility = "Unknown"
    }
    if ($ChosenRace.SelectedItem -match 'Tiefling')
    {
        $ChosenRaceTiefling = $ChosenRaceTiefling.SelectedItem 
        $ChosenRaceTiefling
        $ExportRace = "Tiefling"
        $HP = "0"
        $SpeedTotal = "30"
        $PlayerSize = "Varies On Build, Medium"
        $Playerheight = "6 Feet"

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Unknown"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "You can speak, read, and write Common and Infernal."
        $RaceDescription = "To be greeted with stares and whispers, to suffer violence and insult on the street, to see mistrust and fear in every eye: this is the lot of the tiefling. And to twist the knife, tieflings know that this is because a pact struck generations ago infused the essence of Asmodeus overlord of the Nine Hells, into their bloodline. Their appearance and their nature are not their fault but the result of an ancient sin, for which they and their children and their childrens children will always be held accountable."
        $RacialSpecialAbility = "Unknown"
    }
    if ($ChosenRace.SelectedItem -match 'Orc')
    {
        $ChosenRaceOrc = $ChosenRaceOrc.SelectedItem 
        $ChosenRaceOrc
        $ExportRace = "Orc"
        $HP = "15"      
        $SpeedTotal = "30"
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        #Attributes
        $STR = "16"
        $DEX = "12"
        $CON = "16"
        $INT = "7"
        $WIS = "11"
        $CHA = "10"

        #Attribute Modifiers
        $STRmod = "+3"
        $DEXmod = "+1"
        $CONmod = "+3"
        $INTmod = "-2"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Intimidation +2"
        #$Senses = "darkvision 60ft, passive perception 10"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Common, Orc"
        $RaceDescription = "Orcs are savage raiders and pillagers with stooped postures, low foreheads and piggish faces with prominent lower canines that resemble tusks."
        $RacialSpecialAbility = "Aggressive. As a bonus action, the orc can move up to its speed toward a hostile creature that it can see."
    }
    if ($ChosenRace.SelectedItem -match 'Leonin')
    {
        $ChosenRaceLeonin = $ChosenRaceLeonin.SelectedItem 
        $ChosenRaceLeonin
        $ExportRace = "Leonin"
        $HP = "0"      
        $SpeedTotal = "0"
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Unknown"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = ""
        $RaceDescription = ""
        $RacialSpecialAbility = "Unknown"
    }
    if ($ChosenRace.SelectedItem -match 'Satyr')
    {
        $ChosenRaceSatyr = $ChosenRaceSatyr.SelectedItem 
        $ChosenRaceSatyr
        $ExportRace = "Satyr"
        $HP = "31"      
        $SpeedTotal = "40"
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        #Attributes
        $STR = "12"
        $DEX = "16"
        $CON = "11"
        $INT = "12"
        $WIS = "10"
        $CHA = "14"

        #Attribute Modifiers
        $STRmod = "+1"
        $DEXmod = "+3"
        $CONmod = "+0"
        $INTmod = "+1"
        $WISmod = "+0"
        $CHAmod = "+2"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Perception +2, Performance +6, Stealth +5"
        #$Senses = "Passive Perception 12"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Common, Elvish, Sylvan"
        $RaceDescription = "Satyrs are raucous fey that frolic in the wild forests, driven by curosity and hedonism in equal measure. Satyrs resemble stout male humans with the furry lower bodies and cloven hooves of goats. Horns sprout from their heads, ranging in shape from pair of small nubs to large, curling rams' horns. They typically sport facial hair."
        $RacialSpecialAbility = "Magic Resistance. The satyr had advantage on saving throws against spells and other magical effects."
    }
    if ($ChosenRace.SelectedItem -match 'Fairy')
    {
        $ChosenRaceFairy = $ChosenRaceFairy.SelectedItem 
        $ChosenRaceFairy
        $ExportRace = "Fairy"
        $HP = "0"
        $SpeedTotal = "0"
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Unknown"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Unknown"
        $RaceDescription = "Unknown"
        $RacialSpecialAbility = "Unknown"
    }
    if ($ChosenRace.SelectedItem -match 'Harengon')
    {
        $ChosenRaceHarengon = $ChosenRaceHarengon.SelectedItem 
        $ChosenRaceHarengon
        $ExportRace = "Harengon"
        $HP = "0"
        $SpeedTotal = "0"
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Unknown"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Unknown"
        $RaceDescription = "Unknown"
        $RacialSpecialAbility = "Unknown"
    }
    if ($ChosenRace.SelectedItem -match 'Aarakocra')
    {
        $ChosenRaceAarakocra = $ChosenRaceAarakocra.SelectedItem 
        $ChosenRaceAarakocra
        $ExportRace = "Aarakocra"
        $HP = "13"
        $SpeedTotal = "25, 50 if flying"
        $PlayerSize = "100 Pounds, Medium"
        $Playerheight = "5 Feet"

        #Attributes
        $STR = "10"
        $DEX = "14"
        $CON = "10"
        $INT = "11"
        $WIS = "12"
        $CHA = "11"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+2"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+1"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Perception +5"
        #$Senses = "Passive perception 15"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "You can speak, read, and write Common, Aarakocra, and Auran."
        $RaceDescription = "From below, aarakocra look much like large birds. Only when they descend to roost on a branch or walk across the ground does their humanoid appearance reveal itself. Standing upright, aarakocra might reach 5 feet tall, and they have long, narrow legs that taper to sharp talons.
        
        Feathers cover their bodies. Their plumage typically denotes membership in a tribe. Males are brightly colored, with feathers of red, orange, or yellow. Females have more subdued colors, usually brown or gray. Their heads complete the avian appearance, being something like a parrot or eagle with distinct tribal variations."
        $RacialSpecialAbility = "Dive Attack"
    }
    if ($ChosenRace.SelectedItem -match 'Genasi')
    {
        $ChosenRaceGenasi = $ChosenRaceGenasi.SelectedItem 
        $ChosenRaceGenasi
        $ExportRace = "Genasi"
        $HP = "0"
        $SpeedTotal = "30"
        $PlayerSize = "Varies On Build, Medium"
        $Playerheight = "6 Feet"

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Unknown"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "You can speak, read, and write Common and Primordial. Primordial is a guttural language, filled with harsh syllables and hard consonants."
        $RaceDescription = "Those who think of other planes at all consider them remote, distant realms, but planar influence can be felt throughout the world. It sometimes manifests in beings who, through an accident of birth, carry the power of the planes in their blood. The genasi are one such people, the offspring of genies and mortals.

        The Elemental Planes are often inhospitable to natives of the Material Plane: crushing earth, searing flames, boundless skies, and endless seas make visiting these places dangerous for even a short time. The powerful genies, however, dont face such troubles when venturing into the mortal world. They adapt well to the mingled elements of the Material Plane, and they sometimes visit, whether of their own volition or compelled by magic. Some genies can adopt mortal guise and travel incognito.
        
        During these visits, a mortal might catch a genies eye. Friendship forms, romance blooms, and sometimes children result. These children are genasi, individuals with ties to two worlds, yet belonging to neither. Some genasi are born of mortal genie unions, others have two genasi as parents, and a rare few have a genie further up their family tree, manifesting an elemental heritage thats lain dormant for generations.
        
        Occasionally, genasi result from exposure to a surge of elemental power, through phenomena such as an eruption from the Inner Planes or a planar convergence. Elemental energy saturates any creatures in the area and might alter their nature enough that their offspring with other mortals are born as genasi."
        $RacialSpecialAbility = "Unknown"
    }
    if ($ChosenRace.SelectedItem -match 'Goliath')
    {
        $ChosenRaceGoliath = $ChosenRaceGoliath.SelectedItem 
        $ChosenRaceGoliath
        $ExportRace = "Goliath"
        $HP = "0"
        $SpeedTotal = "30"
        $PlayerSize = "280-340 Pounds"
        $Playerheight = "8 Feet"

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Unknown"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "You can speak, read, and write Common and Giant."
        $RaceDescription = "At the highest mountain peaks, far above the slopes where trees grow and where the air is thin and the frigid winds howl dwell the reclusive goliaths. Few folk can claim to have seen a goliath, and fewer still can claim friendship with them. Goliaths wander a bleak realm of rock, wind, and cold. Their bodies look as if they are carved from mountain stone and give them great physical power. Their spirits take after the wandering wind, making them nomads who wander from peak to peak. Their hearts are infused with the cold regard of their frigid realm, leaving each goliath with the responsibility to earn a place in the tribe or die trying."
        $RacialSpecialAbility = "Unknown"
    }
    if ($ChosenRace.SelectedItem -match 'Aasimar')
    {
        $ChosenRaceAasimar = $ChosenRaceAasimar.SelectedItem 
        $ChosenRaceAasimar
        $ExportRace = "Aasimar"
        $HP = "0"      
        $SpeedTotal = "0"
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Unknown"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Unknown"
        $RaceDescription = "Unknown"
        $RacialSpecialAbility = "Unknown"
    }
    if ($ChosenRace.SelectedItem -match 'Bugbear')
    {
        $ChosenRaceBugbear = $ChosenRaceBugbear.SelectedItem 
        $ChosenRaceBugbear
        $ExportRace = "Bugbear"
        $HP = "27"
        $SpeedTotal = "30"
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        #Attributes
        $STR = "15"
        $DEX = "14"
        $CON = "13"
        $INT = "8"
        $WIS = "11"
        $CHA = "9"

        #Attribute Modifiers
        $STRmod = "+2"
        $DEXmod = "+2"
        $CONmod = "+1"
        $INTmod = "-1"
        $WISmod = "+0"
        $CHAmod = "-1"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Stealth +6, Survival +2"
        #$Senses = "Darkvision 60ft, passive perception 10"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Common, Goblin"
        $RaceDescription = "Bugbears are born for battle and mayhem, Surviving by raiding and hunting, they bully the weak and despise being bossed around, but their love for carnage means they fight for powerful masters if bloodshed and treasure are assured."
        $RacialSpecialAbility = "Brute. A Melee weapon deals one extra die of damage when the bugbear hits with it (included in the attack)
        Surprise Attack. If the bugbear surprises a creature and hits with an attack during the first round of combat, the target takes an extra 7 (2d6) damage from the attack."
    }
    if ($ChosenRace.SelectedItem -match 'Firbolg')
    {
        $ChosenRaceFirbolg = $ChosenRaceFirbolg.SelectedItem 
        $ChosenRaceFirbolg
        $ExportRace = "Firbolg"
        $HP = "0"
        $SpeedTotal = "30"
        $PlayerSize = "240-300 Pounds"
        $Playerheight = "6 Feet"

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Unknown"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "You can speak, read and write Common, Elvish and giant"
        $RaceDescription = "Firbolgs are the fores-dwelling race native to the Greying Wildlands, particularly the mysterious Savlirwood. Their bodie are covered with thick fur ranging from tones of earthen brown and ruddy red to cool grays and blues , and even to wild hues of pink and green. Their bodies are bovine or camelid in appearance with floppy, pointed ears and broad, pink noses, but they are bipdal and have hands that manipulate weapons and objects
        Most Firbolgs live in extended family units, and it is unusual to find one living alone. However, they are introverted to the point where they seldom engage with other firbolgs outside the family unit, and firbolgs rarely form their own cities, villages or even large tribes. Despite this, many firbolgs enjoy visiting other nations and settlements for a short time for trade, signseeing, and to visit friends."
        $RacialSpecialAbility = "Unknown"
    }
    if ($ChosenRace.SelectedItem -match 'Goblin')
    {
        $ChosenRaceGoblin = $ChosenRaceGoblin.SelectedItem 
        $ChosenRaceGoblin
        $ExportRace = "Goblin"
        $HP = "7"
        $SpeedTotal = "30"
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        #Attributes
        $STR = "8"
        $DEX = "14"
        $CON = "10"
        $INT = "10"
        $WIS = "8"
        $CHA = "8"

        #Attribute Modifiers
        $STRmod = "-1"
        $DEXmod = "+2"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "-1"
        $CHAmod = "-1"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Stealth +6"
        #$Senses = "Darkvision 60ft, passive perception 9"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Common, Goblin"
        $RaceDescription = "Goblins are small, black-hearted, selfish humanoids that lair in caves, abandoned mines, depsoiled dungeons and other dismal settings. Individually weak, goblins gather in large - sometimes overwhelming - numbers. They crave power and regularly abuse whatever authority they obtain."
        $RacialSpecialAbility = "Nimble Escape. The goblin can take the disengage or hide action as a bonus action on each of it's turns."
    }
    if ($ChosenRace.SelectedItem -match 'Hobgoblin')
    {
        $ChosenRaceHobGoblin = $ChosenRaceHobGoblin.SelectedItem 
        $ChosenRaceHobGoblin
        $ExportRace = "Hobgoblin"
        $HP = "11"
        $SpeedTotal = "30"
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        #Attributes
        $STR = "13"
        $DEX = "12"
        $CON = "12"
        $INT = "10"
        $WIS = "10"
        $CHA = "9"

        #Attribute Modifiers
        $STRmod = "+1"
        $DEXmod = "+1"
        $CONmod = "+1"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "-1"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Darkvision 60ft, Passive perception 10"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Common, Goblin"
        $RaceDescription = "War horns sound, stones fly from catapults adnt the thunder of thousand booted feet echoes across the land as hobgoblins march to battle. Across the borderlands of civilization, settlements and settlers must contend with these aggressive humanoids, whos thirst for conquest is never satisfied. Hobgoblins have dark orange or red-orange skin and hair ranging from dark red-brown to dark gray. Yellow or dark brown eyes peer out beneath their beetling brows and their wide mouths sport sharp and yellowed teeth. A male hobgoblin might have a large blue or red nose, which symbolizes verility and power among goblinkin. Hobgoblins can live as long as humans, though their love of warfare and battle means that few do."
        $RacialSpecialAbility = "Martial Advantage. Once per turn, the hobgoblin can deal an extra 7 (2d6) damage to a creature it hits with a weapon attack if they creature is within 5 feet of an ally of the hobgoblin that isn't incapacitated."
    }
    if ($ChosenRace.SelectedItem -match 'Kenku')
    {
        $ChosenRaceKenku = $ChosenRaceKenku.SelectedItem 
        $ChosenRaceKenku
        $ExportRace = "Kenku"
        $HP = "13"
        $SpeedTotal = "30"
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        #Attributes
        $STR = "10"
        $DEX = "16"
        $CON = "10"
        $INT = "11"
        $WIS = "10"
        $CHA = "10"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+3"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Deception +4, Perception +2, Stealth +5"
        #$Senses = "Passive Perception 12"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Common, Auran (only using mimicry trait)"
        $RaceDescription = "Kenku are feathered humanoids that wander the world as vagabonds, driven by greed. They can perfectly imitate any sounds they hear."
        $RacialSpecialAbility = "Ambusher. In the first round of combat, the kenku has advantage on attack rolls against any creature it surpsied.
        Mimicry. The kenku can mimic any sounds it has heard, including voices. A creature that hears the sounds can tell they are imitations with a successful DC 14 Wisdom (insight) check."
    }
    if ($ChosenRace.SelectedItem -match 'Kobold')
    {
        #Race Stats
        $ChosenRaceKobold = $ChosenRaceKobold.SelectedItem 
        $ChosenRaceKobold
        $ExportRace = "Kobold"
        $HP = "5"
        $SpeedTotal = "30"
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        #Attributes
        $STR = "7"
        $DEX = "15"
        $CON = "9"
        $INT = "8"
        $WIS = "7"
        $CHA = "8"

        #Attribute Modifiers
        $STRmod = "-2"
        $DEXmod = "+2"
        $CONmod = "-1"
        $INTmod = "-1"
        $WISmod = "-2"
        $CHAmod = "-1"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Darkvision 60ft, Passive perception 8"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Common, Draconic"
        $RaceDescription = "Kobolds are craven reptilian humanoids that worship evil dragons as demigods and serve them as minions and toadies. Kobolds inhabit dragons' lairs when they can but more commonly infest dungeons, gathering trasures and trinkets to add to their own tiny hoards."
        $RacialSpecialAbility = "Sunlight Sensitivity. While in sunlight, the kobold has a disadvantage on attack rolls, as on Wisdom (Perception) checks that rely on sight.
        Pack Tactics. The kobold has advantage on an attack roll against a creature if at least one of the kobold's allies is within 5 feet of the creature and that the ally isn't incapacitated."
    }
    if ($ChosenRace.SelectedItem -match 'Lizardfolk')
    {
        $ChosenRaceLizardfolk = $ChosenRaceLizardfolk.SelectedItem 
        $ChosenRaceLizardfolk
        $ExportRace = "Lizardfolk"
        $HP = "22"
        $SpeedTotal = "30"
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        #Attributes
        $STR = "15"
        $DEX = "10"
        $CON = "13"
        $INT = "7"
        $WIS = "12"
        $CHA = "7"

        #Attribute Modifiers
        $STRmod = "+2"
        $DEXmod = "+0"
        $CONmod = "+1"
        $INTmod = "-2"
        $WISmod = "+1"
        $CHAmod = "-2"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Perception +3, Stealth +4, Survival +5"
        #$Senses = "Passive perception 13"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Draconic"
        $RaceDescription = "Lizardfolk are primitive reptilian humanoids that lurk in the swamps and jungles of the world. Their hut villages thrive in forbidding grottos, half-sunken ruins and watery caverns."
        $RacialSpecialAbility = "Hold Breath. The lizardfolk can hold its breath for 15 minutes."
    }
    if ($ChosenRace.SelectedItem -match 'Tabaxi')
    {
        $ChosenRaceTabaxi = $ChosenRaceTabaxi.SelectedItem 
        $ChosenRaceTabaxi
        $ExportRace = "Tabaxi"  
        $HP = "0"
        $SpeedTotal = "0"
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        
        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Unknown"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Unknown"
        $RaceDescription = "Unknown"
        $RacialSpecialAbility = "Unknown"
    }
    if ($ChosenRace.SelectedItem -match 'Triton')
    {
        $ChosenRaceTriton = $ChosenRaceTriton.SelectedItem 
        $ChosenRaceTriton
        $ExportRace = "Triton"
        $HP = "0"
        $SpeedTotal = "0"
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Unknown"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Unknown"
        $RaceDescription = "Unknown"
        $RacialSpecialAbility = "Unknown"
    }
    if ($ChosenRace.SelectedItem -match 'Yuan-ti Pureblood')
    {
        $ChosenRaceYuan_Ti_Pureblood = $ChosenRaceYuan_Ti_Pureblood.SelectedItem 
        $ChosenRaceYuan_Ti_Pureblood
        $ExportRace = "Yuan-ti Pureblood"
        $HP = "40"
        $SpeedTotal = "30"
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        #Attributes
        $STR = "11"
        $DEX = "12"
        $CON = "11"
        $INT = "13"
        $WIS = "12"
        $CHA = "14"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+1"
        $CONmod = "+0"
        $INTmod = "+1"
        $WISmod = "+1"
        $CHAmod = "+2"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Unknown"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Abyssal, Common, Draconic"
        $RaceDescription = "Purebloods from the lowest case of yuan-ti society. They closely resemble humans, yet a pureblood can't pass for human under close scrutiny because there's always some hint of its true nature, such as caly patches of skin, serpentine eyes, pointed teeth, or a forked tongue. Wearing cloaks and cowls, they masquerade as humans and infiltrate civilised lands to gather information, kidnap prisoners for interrogation and sacrifice, and trade with anyone who has something that can further their myriad plots."
        $RacialSpecialAbility = "Innate Spellcasting. The yuan-ti's spellcasting ability is Charisma (spell save DC 12). The yuan-ti can innately cast the following spells, requiring no material components:
        At will: animal friendship (snakes only) 
        3/day each: poison spray, suggestion
        Magic Resistance. The yuan-ti has advantage on saving throws against spells and other magical effects."
    }
    if ($ChosenRace.SelectedItem -match 'Feral Tiefling')
    {
        $ChosenRaceFeral_Tiefling = $ChosenRaceFeral_Tiefling.SelectedItem 
        $ChosenRaceFeral_Tiefling
        $ExportRace = "Feral Tiefling"
        $HP = "0"
        $SpeedTotal = "0"
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Unknown"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Unknown"
        $RaceDescription = "Unknown"
        $RacialSpecialAbility = "Unknown"
    }
    if ($ChosenRace.SelectedItem -match 'Tortle')
    {
        $ChosenRaceTortle = $ChosenRaceTortle.SelectedItem 
        $ChosenRaceTortle
        $ExportRace = "Tortle"
        $HP = "0"
        $SpeedTotal = "0"
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Unknown"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Unknown"
        $RaceDescription = "Unknown"
        $RacialSpecialAbility = "Unknown"
    }
    if ($ChosenRace.SelectedItem -match 'Changling')
    {
        $ChosenRaceChangling = $ChosenRaceChangling.SelectedItem 
        $ChosenRaceChangling
        $ExportRace = "Changling"
        $HP = "0"
        $SpeedTotal = "0"
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Unknown"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Unknown"
        $RaceDescription = "Unknown"
        $RacialSpecialAbility = "Unknown"
    }
    if ($ChosenRace.SelectedItem -match 'Kalashtar')
    {
        $ChosenRaceKalashtar = $ChosenRaceKalashtar.SelectedItem 
        $ChosenRaceKalashtar
        $ExportRace = "Kalashtar"
        $HP = "0"
        $SpeedTotal = "0"
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Unknown"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Unknown"
        $RaceDescription = "Unknown"
        $RacialSpecialAbility = "Unknown"
    }
    if ($ChosenRace.SelectedItem -match 'Shifter')
    {
        $ChosenRaceShifter = $ChosenRaceShifter.SelectedItem 
        $ChosenRaceShifter
        $ExportRace = "Shifter"
        $HP = "0"
        $SpeedTotal = "0"
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Unknown"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Unknown"
        $RaceDescription = "Unknown"
        $RacialSpecialAbility = "Unknown"
    }
    if ($ChosenRace.SelectedItem -match 'Warforged')
    {
        $ChosenRaceWarforged = $ChosenRaceWarforged.SelectedItem 
        $ChosenRaceWarforged
        $ExportRace = "Warforged"
        $HP = "0"
        $SpeedTotal = "0"
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Unknown"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Unknown"
        $RaceDescription = "Unknown"
        $RacialSpecialAbility = "Unknown"
    }
    if ($ChosenRace.SelectedItem -match 'Gith')
    {
        $ChosenRaceGith = $ChosenRaceGith.SelectedItem 
        $ChosenRaceGith
        $ExportRace = "Gith"
        
        $HP = "49"
        $SpeedTotal = "0"
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        #Attributes
        $STR = "+2"
        $DEX = "+2"
        $CON = "+1"
        $INT = "+1"
        $WIS = "1"
        $CHA = "+0"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "None"
        #$Senses = "Passive perception 11"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Gith"
        $RaceDescription = "The warlike githyanki and the contemplative githzerai are sundered people - two cultures that utterly despide one another. Before there were githyanki or githzerai, these creatures were a single race enslaved by the mind flayers. Although they attempted to overthrow their masters many times, their rebellions were repeatedly crushed until a great leader named Gith arose. After much bloodshed, Gith and her followers threw off the yoke of their illithid masters, but another leader named Zerthimon emerged in the aftermath of battle. Zerthimon challenged Gith's motives, claiming that her strict martial leadership and desire for vengeance amounted a little more than another form of slavery for her people. A rift erupted between followers of each leader and they eventually became two races whose enmity endures to this day. Whether these tall, gaunt creatures were peaceful of savage, cultured or primitive before the mind flayers enslaved and changed them, none can say. Not even the original name of their race remails from that distant time."
        $RacialSpecialAbility = "innate Spellcasting (Psionics). The githyanki's innate spellcasting ability is intelligence. It can innately cast the following spells, requiring no component: 
        At will: mage hand (the hand is invisible)
        3/day each: jump, misty step, nondetection (self only)."
    }
    if ($ChosenRace.SelectedItem -match 'Centaur')
    {
        $ChosenRaceCentaur = $ChosenRaceCentaur.SelectedItem 
        $ChosenRaceCentaur
        $ExportRace = "Centaur"
        $HP = "45"
        $SpeedTotal = "50"
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        #Attributes
        $STR = "18"
        $DEX = "14"
        $CON = "14"
        $INT = "9"
        $WIS = "13"
        $CHA = "11"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Athletics +6, Perception +3, Survival +3"
        #$Senses = "Passive perception 13"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Elvish, Sylvan"
        $RaceDescription = "Reclusive wanderers and omen-readers of the wild, centaurs avoid conflict but fight fiercely when pressed. They roam the vast wilderness, keeping far from borders, law and the company of other creatures."
        $RacialSpecialAbility = "Charge. If the cenntaur moves at least 30 feet straight toward a target and then hits with a pike attack on the same turn, the target takes an extra 10 (3d6) piercing damage."
    }
    if ($ChosenRace.SelectedItem -match 'Loxodon')
    {
        $ChosenRaceLoxodon = $ChosenRaceLoxodon.SelectedItem 
        $ChosenRaceLoxodon
        $ExportRace = "Loxodon"
        $HP = "0"
        $SpeedTotal = "0"
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Unknown"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Unknown"
        $RaceDescription = "Unknown"
        $RacialSpecialAbility = "Unknown"
    }
    if ($ChosenRace.SelectedItem -match 'Minotaur')
    {
        $ChosenRaceMinotaur = $ChosenRaceMinotaur.SelectedItem 
        $ChosenRaceMinotaur
        $ExportRace = "Minotaur"
        $HP = "76"
        $SpeedTotal = "40"
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        #Attributes
        $STR = "18"
        $DEX = "11"
        $CON = "16"
        $INT = "6"
        $WIS = "16"
        $CHA = "9"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Perception +7"
        #$Senses = "Darkvision 60ft, passive perception 17"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Abyssal"
        $RaceDescription = "A minotaur's roar is a savage battle cry that most civilized creatures fear. Born into the mortal realm by the demonic rites, minotaurs are savage conquerors and carnivores that live for the hunt. Their brown and black fur is stained with the blood of fallen foes and they carry the stench of death."
        $RacialSpecialAbility = "Charge. If the minotaur moves at least 10 feet straight toward a target and then hits it with a gore attack on the same turn, the target takes an extra 9 (2d8) piercing damage. If the target is a creature, it must succeed on a DC 14 strength saving throw or be pushed up to 10 feet away and knocked prone.
        Labyrinthine Recall. The minotaur can perfectly recall any path it has travelled.
        Reckless. At the start of it's turn, the minotaur can gain advantage on all melee weapon attack rolls it makes during that turn, but attack rolls against it have advantage until the start of it's next turn."
    }
    if ($ChosenRace.SelectedItem -match 'Simic Hybrid')
    {
        $ChosenRaceSimic_Hybrid = $ChosenRaceSimic_Hybridr.SelectedItem 
        $ChosenRaceSimic_Hybrid
        $ExportRace = "Simic Hybrid"
        $HP = "0"
        $SpeedTotal = "0"
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Unknown"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Unknown"
        $RaceDescription = "Unknown"
        $RacialSpecialAbility = "Unknown"
    }
    if ($ChosenRace.SelectedItem -match 'Vedalken')
    {
        $ChosenRaceSimic_Hybrid = $ChosenRaceSimic_Hybrid.SelectedItem 
        $ChosenRaceSimic_Hybrid
        $ExportRace = "Vedalken"
        $HP = "0"
        $SpeedTotal = "0"
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Unknown"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Unknown"
        $RaceDescription = "Unknown"
        $RacialSpecialAbility = "Unknown"
    }
    if ($ChosenRace.SelectedItem -match 'Verdan')
    {
        $ChosenRaceVerdan = $ChosenRaceVerdan.SelectedItem 
        $ChosenRaceVerdan
        $ExportRace = "Verdan"
        $HP = "0"
        $SpeedTotal = "0"
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Unknown"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Unknown"
        $RaceDescription = "Unknown"
        $RacialSpecialAbility = "Unknown"
    }
    if ($ChosenRace.SelectedItem -match 'Locathah')
    {
        $ChosenRaceLocathah = $ChosenRaceLocathah.SelectedItem 
        $ChosenRaceLocathah
        $ExportRace = "Locathah"
        $HP = "0"
        $SpeedTotal = "0"
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Unknown"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Unknown"
        $RaceDescription = "Unknown"
        $RacialSpecialAbility = "Unknown"
    }
    if ($ChosenRace.SelectedItem -match 'Grung')
    {
        $ChosenRaceGrung = $ChosenRaceGrung.SelectedItem 
        $ChosenRaceGrung
        $ExportRace = "Grung"
        $HP = "0"
        $SpeedTotal = "0"
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Unknown"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Unknown"
        $RaceDescription = "Unknown"
        $RacialSpecialAbility = "Unknown"
    }
    if ($ChosenRace.SelectedItem -match 'Lycanth')
    {
        $ChosenRaceLycanth = $ChosenRaceLycanth.SelectedItem 
        $ChosenRaceLycanth
        $ExportRace = "Lycanth"
        $HP = "70"
        $SpeedTotal = "30"
        $SpeedTotal
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        #Attributes
        $STR = "+2"
        $DEX = "+1"
        $CON = "+2"
        $INT = "+0"
        $WIS = "+1"
        $CHA = "0"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Perception +3, Stealth +2"
        #$Senses = "Perception 14"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Common (can't speak in form)"
        $RaceDescription = "One of the most ancient and feared of all curses, lycanthropy can transform the most civilised humanoid into a ravening beast. In it's natural humanoid form, a creature cursed by lycanthropy appears as it's normal self. Over time, however, many lycanthropes acquire features suggestive of their animal form. In that animal form, a lycanthrope resembles a powerful version of a normal animal. On close inspection, it's eyes show a faint spark of unnatural intelligence and might glow red in the dark. Evil lycanthropes hide among normal folk, emerging in animal form at night to spread terror and bloodshed, especially under a full moon. Good lycanthropes are reclusive and uncomfortable around other civilised creatures, often living alone in wilderness areas far from villages and towns."
        $RacialSpecialAbility = "Shapechanger. The lycanth can use it's polymorph to change into it's were form, any equipment it is wearing or carrying is not transformed."
    }
    if ($ChosenRace.SelectedItem -match 'Troll')
    {
        $ChosenRaceTroll = $ChosenRaceTroll.SelectedItem 
        $ChosenRaceTroll
        $ExportRace = "Troll"
        $HP = "84"
        $SpeedTotal = "30"
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        #Attributes
        $STR = "18"
        $DEX = "13"
        $CON = "20"
        $INT = "7"
        $WIS = "9"
        $CHA = "7"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Perception +2"
        #$Senses = "Darkvision 60ft, passive perception 12"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Giant"
        $RaceDescription = "Born with horrific appetites, trolls eat anything they can catch and devour. They have no society to speak of, but they do serve as mercenaries to orcs, ogres, ettins, hags and giants. As payment, trolls demand food and treasure. Trolls are difficult to control, however, doing as they please even when working with more powerful creatures."
        $RacialSpecialAbility = "Keen Smell. The troll has advantage on wisdom (perception) checks that rely on smell.
        Regeneration. The troll regains 10 hit points at the start of it's turn. If the troll takes acid or fire damage, this trait doesn't function at the start of the troll's next turn. The troll dies only if it sarts it's turn with 0 hit point and doesn't regenerate."
    }
    if ($ChosenRace.SelectedItem -match 'Ogre')
    {
        $ChosenRaceOrge = $ChosenRaceOrge.SelectedItem 
        $ChosenRaceOrge
        $ExportRace = "Ogre"
        $HP = "59"
        $SpeedTotal = "40"
        $PlayerSize = "900 Pounds"
        $Playerheight = "10 Feet"

        #Attributes
        $STR = "19"
        $DEX = "8"
        $CON = "16"
        $INT = "5"
        $WIS = "7"
        $CHA = "7"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Darkvision 60ft, passive perception 8"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Common, Giant"
        $RaceDescription = "Ogres are as lazy of the mind as they are strong of the body. They live by raiding, scavenging and killing for food and pleasure. The average adult specimen stands between 9 and 10 feet tall and weighs close to a thousand pounds."
        $RacialSpecialAbility = "Unknown"
    }
    if ($ChosenRace.SelectedItem -match 'Feral Wolf')
    {
        $ChosenRaceFera_Wolf = $ChosenRaceFera_Wolf.SelectedItem 
        $ChosenRaceFera_Wolf
        $ExportRace = "Feral Wolf"
        $HP = "0"
        $SpeedTotal = "0"
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Unknown"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Unknown"
        $RaceDescription = "Unknown"
        $RacialSpecialAbility = "Unknown"
    }
    if ($ChosenRace.SelectedItem -match 'Wolf')
    {
        $ChosenRaceWolf = $ChosenRaceWolf.SelectedItem 
        $ChosenRaceWolf
        $ExportRace = "Wolf"
        $HP = "15"
        $SpeedTotal = "35"
        $PlayerSize = "0 Pounds"
        $Playerheight = "0 Feet"

        #Attributes
        $STR = "12"
        $DEX = "15"
        $CON = "12"
        $INT = "3"
        $WIS = "12"
        $CHA = "6"

        #Attribute Modifiers
        $STRmod = "+1"
        $DEXmod = "+2"
        $CONmod = "+1"
        $INTmod = "-4"
        $WISmod = "+1"
        $CHAmod = "-2"

        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"

        #$Skills = "Perception +3, Stealth +4"
        #$Senses = "Passive Perception 13"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"
        $SpokenLanguages = "Unknown"
        $RaceDescription = "Unknown"
        $RacialSpecialAbility = "Keen Hearing and Smell"
    }
#End of race details
#If adding a new race, please use the code below as an example:
    #if ($ChosenRace.SelectedItem -match '**')
    #{
        #Race Stats
        #$ChosenRace** = $ChosenRace**.SelectedItem 
        #$ChosenRace**
        #$ExportRace = **
        #$HP = "0"
        #$SpeedTotal = "0"
        #$RaceLifeTime = "0"
        #$PlayerSize = "0 Pounds"
        #$Playerheight = "0 Feet"

        #Attributes
        #$STR = "0"
        #$DEX = "0"
        #$CON = "0"
        #$INT = "0"
        #$WIS = "0"
        #$CHA = "0"

        #Attribute Modifiers
        #$STRmod = "+0"
        #$DEXmod = "+0"
        #$CONmod = "+0"
        #$INTmod = "+0"
        #$WISmod = "+0"
        #$CHAmod = "+0"

        #Saving Throws
        #$ST_STR = "0"
        #$ST_DEX = "0"
        #$ST_CON = "0"
        #$ST_INT = "0"
        #$ST_WIS = "0"
        #$ST_CHA = "0"

        #$Skills = "Unknown"
        #$Senses = "Unknown"
        #$Damage_Immunities = "Unknown"
        #$Condition_Immunities = "Unknown"

        #$SpokenLanguages = "Unknown"
        #$RaceDescription = "Unknown"
        #$RacialSpecialAbility = "Unknown"
    #}
#Sizes and squares
#Size 	        Space	            Number of 5×5 foot squares
#Tiny	    2 ½ ft x 2 ½ ft.	        ½ of a square
#Small	    5 x 5 ft.	                   1 square
#Medium	    5 x 5 ft.	                   1 square
#Large	    10 x 10 ft.	                   4 squares 
#Huge	    15 x 15 ft.	                   9 squares
#Gargantuan	20 x 20 ft.                    16 squares

#Default sizes of main races
#Race               Base Height	 Base Weight    Height Modifier	Weight Modifier	Average Height and Weight
#Aarakocra	            4’4″	    90	        1d6	                1d6	            4’8″ 106 lbs.
#Bugbear	            6’0″	    110	        2d10	            2d4	            7’1″ 291 lbs.
#Centaur	            6′	        600	        1d10	            2d12	        8’7″ 678 lbs.
#Dragonborn	            5′ 6″	    175	        2d8	                2d6	            6′ 3″ 238 lbs.
#Dwarf, Hill	        3′ 8″	    115	        2d4	                2d6	            4′ 1″ 150 lbs.
#Dwarf, Mountain	    4′ 0″	    130	        2d4	                2d6	            4′ 5″ 165 lbs.
#Elf	                54	        90	        2d10	            1d4	            5’4″ 119 lbs.
#Elf, Drow	            4’5″	    75	        2d6	                1d6	            5’0″ 103 lbs.
#Elf, High	            4′ 6″	    90	        2d10	            1d4	            5′ 5″ 123 lbs.
#Elf, Shadar-kai	    4’8″	    90	        2d8	                1d4	            5’5″ 133 lbs.
#Elf, Wood	            4’6″	    100	        2d10	            1d4	            5’5″ 133 lbs.
#Firbolg	            6′ 2″	    175	        2d12	            2d6	            7′ 3″ 266 lbs.
#Giff	                6′ 6″	    400	        2d8	                2d8	            7′ 3″, 517 lbs.
#Githyanki	            5’0″	    100	        2d12	            2d4	            6’1″ 165 lbs.
#Githzerai	            4’11”	    90	        2d12	            1d4	            6’0″ 129 lbs.
#Gnoll	                6’11”	    276	        1d6	                2d4	            7’3″, 296 lbs.
#Gnome	                2′ 11″	    35	        2d4	                1	            3′ 4″ 40 lbs.
#Goliath	            6′ 2″	    200	        2d10	            2d6	            7′ 1″ 277 lbs.
#Grung	                24	        23	        1d12	            1	            2’7″ 30 lbs.
#Half-Elf	            4′ 9″	    110	        2d8	                2d4	            5′ 6″ 155 lbs.
#Half-Orc	            4′ 10″	    140	        2d10	            2d6	            5′ 9″ 217 lbs.
#Halfling	            2’7″	    35	        2d4	                1	            3’0″ 40 lbs.
#Longshanks	            4′ 2″ (50″)	80	        2d8	                1d6	            4′ 11″ 116 lbs.
#Human	                4’8″	    110	        2d10	            2d4	            5’7″ 165 lbs.
#Kenku	                4′ 4″	    50	        2d8	                1d6	            5′ 1″ 86 lbs.
#Kuo-toa	            4′ 7″	    110	        3d6	                2d4	            5′ 6″ 165 lbs.
#Leonin	                6′ 6″	    180	        2d10	            2d6	            8’5″ 257 lbs.
#Lizardfolk	            4′ 9″	    120	        2d10	            2d6	            5′ 8″ 197 lbs.
#Loxodon	            6′ 5″	    295	        2d10	            2d4	            5′ 8″ 197 lbs.
#Minotaur	            5′ 4″	    175	        2d8	                2d6	            6′ 1″ 238 lbs.
#Orc	                5′ 4″	    175	        2d8	                2d6	            6′ 1″ 238 lbs.
#Satyr	                4′ 8″	    100	        2d8	                2d4	            5’5″ 145 lbs.
#Tabaxi	                4′ 8″	    90	        2d10	            2d4	            5′ 0″ 120 lbs.
#Tiefling	            4′ 9″	    110	        2d8	                2d4	            5′ 6″ 155 lbs.
#Tortle	                4′ 11″	    415	        1d12	            2d4	            5′ 6″ 350 lbs.
#Vedalken	            5′ 4″	    110	        2d10	            2d4d	        5′ 10″ 140 lbs.
#Warforged	            5’10”	    270	        2d6	                4	            6’5″ 298 lbs.
#Yuan-ti	            4′ 8″	    110	        2d10	            2d4	            5′ 7″ 165 lbs.

#Source: https://blackcitadelrpg.com/height-age-weight-5e/
#Chosen Subrace override for name of race, this is for anyone who chose a subrace
#This also can be used to add more custom Subraces to a single race (for custom games)
    if ($ChosenSubRace.SelectedItem -match 'Draconic Ancestory')
    {
        $ExportRace = "Draconic Ancestory"
    }
    if ($ChosenSubRace.SelectedItem -match 'DraconBlood Dragonborn')
    {
        $ExportRace = "DraconBlood Dragonborn"
    }
    if ($ChosenSubRace.SelectedItem -match 'Chromatic Dragonborn')
    {
        $ExportRace = "Chromatic Dragonborn"
    }
    if ($ChosenSUbRace.SelectedItem -match 'Gem Dragonborn')
    {
        $ExportRace = "Gem Dragonborn"
    }
    if ($ChosenSubRace.SelectedItem -match 'Revenite Dragonborn')
    {
        $ExportRace = "Revenite Dragonborn"
    }
    if ($ChosenSubRace.SelectedItem -match 'Metallic Dragonborn')
    {
        $ExportRace = "Metallic Dragonborn"
    }
    if ($ChosenSubRace.SelectedItem -match 'Hill Dwarves')
    {
        $ExportRace = "Hill Dwarves"
    }
    if ($ChosenSubRace.SelectedItem -match 'Mountain Dwarves')
    {
        $ExportRace = "Mountain Dwarves"
    }
    if ($ChosenSubRace.SelectedItem -match 'Eladrin')
    {
        $ExportRace = "Eladrin"
    }
    if ($ChosenSubRace.SelectedItem -match 'High Elf')
    {
        $ExportRace = "High Elf"
    }
    if ($ChosenSubRace.SelectedItem -match 'Wood Elf')
    {
        $ExportRace = "Wood Elf"
    }
    if ($ChosenSubRace.SelectedItem -match 'Deep Gnome')
    {
        $ExportRace = "Deep Gnome"
    }
    if ($ChosenSubRace.SelectedItem -match 'Rock Gnome')
    {
        $ExportRace = "Rock Gnome"
    }
    if ($ChosenSubRace.SelectedItem -match 'Lightfoot Halfling')
    {
        $ExportRace = "Lightfoot Halfling"
    }
    if ($ChosenSubRace.SelectedItem -match 'Stout Halfling')
    {
        $ExportRace = "Stout Halfling"
    }
    if ($ChosenSubRace.SelectedItem -match 'Eye of Gruumsh')
    {
        $ExportRace = "Orc Eye of Gruumsh"
        #Attributes Basic
        $STR = "16"
        $DEX = "12"
        $CON = "16"
        $INT = "9"
        $WIS = "13"
        $CHA = "12"
        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"
        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"
    }
    if ($ChosenSubRace.SelectedItem -match 'Ranging Scavengers')
    {
        $ExportRace = "Orc Ranging Scavengers"
    }
    if ($ChosenSubRace.SelectedItem -match 'Orc Crossbreed')
    {
        $ExportRace = "Orc Crossbreed"
    }
    if ($ChosenSubRace.SelectedItem -match 'Hedonistic Revelers')
    {
        $ExportRace = "Satyr Hedonistic Revelers"
    }
    if ($ChosenSubRace.SelectedItem -match 'Enemies of Elemental Evil')
    {
        $ExportRace = "Aarakocra Enemies of Elemental Evil"
    }
    if ($ChosenSubRace.SelectedItem -match 'Air Genasi')
    {
        $ExportRace = "Air Genasi"
    }
    if ($ChosenSubRace.SelectedItem -match 'Earch Genasi')
    {
        $ExportRace = "Air Genasi"
    }
    if ($ChosenSubRace.SelectedItem -match 'Fire Genasi')
    {
        $ExportRace = "Fire Genasi"
    }
    if ($ChosenSubRace.SelectedItem -match 'Water Genasi')
    {
        $ExportRace = "Water Genasi"
    }
    if ($ChosenSubRace.SelectedItem -match 'Bugbear Chief')
    {
        $ExportRace = "Bugbear Chief"
        #Attributes Basic
        $STR = "17"
        $DEX = "14"
        $CON = "14"
        $INT = "11"
        $WIS = "12"
        $CHA = "11"
        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"
        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"
    }
    if ($ChosenSubRace.SelectedItem -match 'Followers of Hruggek')
    {
        $ExportRace = "Bugbear Followers of Hruggek"
    }
    if ($ChosenSubRace.SelectedItem -match 'Venal Ambushers')
    {
        $ExportRace = "Bugbear Venal Ambushers"
    }
    if ($ChosenSubRace.SelectedItem -match 'Goblinoids')
    {
        $ExportRace = "Goblinoids"
    }
    if ($ChosenSubRace.SelectedItem -match 'Malicious Glee')
    {
        $ExportRace = "Goblin Malicious Glee"
    }
    if ($ChosenSubRace.SelectedItem -match 'Challenging Liers')
    {
        $ExportRace = "Goblin Challenging Liers"
    }
    if ($ChosenSubRace.SelectedItem -match 'Rat Keepers and Wolf Riders')
    {
        $ExportRace = "Goblin Rat Keepers and Wolf Riders"
    }
    if ($ChosenSubRace.SelectedItem -match 'Worshipers of Maglubiyet')
    {
        $ExportRace = "Goblin Worshipers of Maglubiyet"
    }
    if ($ChosenSubRace.SelectedItem -match 'Hobgoblin Captain')
    {
        $ExportRace = "Hobgoblin Captain"
        #Attributes Basic
        $STR = "15"
        $DEX = "14"
        $CON = "14"
        $INT = "12"
        $WIS = "10"
        $CHA = "13"
        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"
        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"
    }
    if ($ChosenSubRace.SelectedItem -match 'Legion of Maglubiyet')
    {
        $ExportRace = "Hobgoblin Legion of Maglubiyet"
    }
    if ($ChosenSubRace.SelectedItem -match 'Fallen Flocks')
    {
        $ExportRace = "Kenku Fallen Flocks"
    }
    if ($ChosenSubRace.SelectedItem -match 'The Whistful Wingless')
    {
        $ExportRace = "Kenku The Whistful Wingless"
    }
    if ($ChosenSubRace.SelectedItem -match 'Winged Kobold')
    {
        $ExportRace = "Winged Kobold"
        #Attributes Basic
        $STR = "7"
        $DEX = "16"
        $CON = "9"
        $INT = "8"
        $WIS = "7"
        $CHA = "8"
        #Attribute Modifiers
        $STRmod = "-2"
        $DEXmod = "+3"
        $CONmod = "-1"
        $INTmod = "-1"
        $WISmod = "-2"
        $CHAmod = "-1"
        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"
    }
    if ($ChosenSubRace.SelectedItem -match 'Lizardfolk Shamen')
    {
        $ExportRace = "Lizardfolk Shamen"
        #Attributes Basic
        $STR = "15"
        $DEX = "10"
        $CON = "13"
        $INT = "10"
        $WIS = "15"
        $CHA = "8"
        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"
        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"
    }
    if ($ChosenSubRace.SelectedItem -match 'Territorial Xenophobes')
    {
        $ExportRace = "Lizardfolk Territorial Xenophobes"
    }
    if ($ChosenSubrace.SelectedItem -match 'Great Feasts and Sacrifices')
    {
        $ExportRace = "Lizardfolk Great Feasts and Sacrifices"
    }
    if ($ChosenSubRace.SelectedItem -match 'Canny Crafters')
    {
        $ExportRace = "Lizardfolk Canny Crafters"
    }
    if ($ChosenSubRace.SelectedItem -match 'Lizardfolk Leaders')
    {
        $ExportRace = "Lizardfolk Leaders"
    }
    if ($ChosenSubRace.SelectedItem -match 'Dragon Worshipers')
    {
        $ExportRace = "Lizardfolk Dragon Worshipers"
    }
    if ($ChosenSubRace.SelectedItem -match 'Githyanki')
    {
        $ExportRace = "Githyanki"
    }
    if ($ChosenSubRace.SelectedItem -match 'Githyanki Warrior')
    {
        $ExportRace = "Githyanki Warrior"
        #Atttributes Basic
        $STR = "15"
        $DEX = "14"
        $CON = "12"
        $INT = "13"
        $WIS = "13"
        $CHA = "10"
        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"
        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"
    }
    if ($ChosenSubRace.SelectedItem -match 'Githyanki Knight')
    {
        $ExportRace = "Githyanki Knight"
        #Attributes Basic
        $STR = "16"
        $DEX = "14"
        $CON = "15"
        $INT = "14"
        $WIS = "14"
        $CHA = "15"
        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"
        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"
    }
    if ($ChosenSubRace.SelectedItem -match 'Astral Raiders')
    {
        $ExportRace = "Gith Astral Raiders"
    }
    if ($ChosenSubRace.SelectedItem -match 'Followers of Gith')
    {
        $ExportRace = "Followers of Gith"
    }
    if ($ChosenSubRace.SelectedItem -match 'Silver Swords')
    {
        $ExportRace = "Gith Silver Swords"
    }
    if ($ChosenSubRace.SelectedItem -match 'Red Dragon Riders')
    {
        $ExportRace = "Gith Red Dragon Riders"
    }
    if ($ChosenSubRace.SelectedItem -match 'Githzerai')
    {
        $ExportRace = "Githzerai"
    }
    if ($ChosenSubRace.SelectedItem -match 'Githzerai Monk')
    {
        $ExportRace = "Githzerai Monk"
        #Attributes Basic
        $STR = "12"
        $DEX = "15"
        $CON = "12"
        $INT = "13"
        $WIS = "14"
        $CHA = "10"
        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"
        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"
    }
    if ($ChosenSubRace.SelectedItem -match 'Githzerai Zerth')
    {
        $ExportRace = "Githzerai Zerth"
        #Attributes Basic
        $STR = "13"
        $DEX = "18"
        $CON = "15"
        $INT = "16"
        $WIS = "17"
        $CHA = "12"
        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"
        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"
    }
    if ($ChosenSubRace.SelectedItem -match 'Psionic Adepts')
    {
        $ExportRace = "Gith Psionic Adepts"
    }
    if ($ChosenSubRace.SelectedItem -match 'Disciples of Zerthimon')
    {
        $ExportRace = "Gith Disciples of Zerthimon"
    }
    if ($ChosenSubRace.SelectedItem -match 'Beyond Limbo')
    {
        $ExportRace = "Gith Beyond Limbo"
    }
    if ($ChosenSubRace.SelectedItem -match 'Wilderness Nomads')
    {
        $ExportRace = "Centaur Wilderness Nomads"
    }
    if ($ChosenSubRace.SelectedItem -match 'Reluctant Settlers')
    {
        $ExportRace = "Centaur Reluctant Settlers"
    }
    if ($ChosenSubRace.SelectedItem -match 'The Beast Within')
    {
        $ExportRace = "Minotaur The Beast Within"
    }
    if ($ChosenSubRace.SelectedItem -match 'Cults of the Horned King')
    {
        $ExportRace = "Minotaur Cults of the Horned King"
    }
    if ($ChosenSubRace.SelectedItem -match 'Curse of Lycanthropy')
    {
        $ExportRace = "Cursed Human Lycanth"
    }
    if ($ChosenSubRace.SelectedItem -match 'Werebear')
    {
        $ExportRace = "Werebear"
        #Attributes Basic
        $STR = "19"
        $DEX = "10"
        $CON = "17"
        $INT = "11"
        $WIS = "12"
        $CHA = "12"
        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"
        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"
    }
    if ($ChosenSubRace.SelectedItem -match 'Wereboar')
    {
        $ExportRace = "Wereboar"
        #Attributes Basic
        $STR = "17"
        $DEX = "10"
        $CON = "15"
        $INT = "10"
        $WIS = "11"
        $CHA = "8"
        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"
        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"
    }
    if ($ChosenSubRace.SelectedItem -match 'Wererat')
    {
        $ExportRace = "Wererat"
        #Attributes Basic
        $STR = "10"
        $DEX = "15"
        $CON = "12"
        $INT = "11"
        $WIS = "10"
        $CHA = "8"
        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"
        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"
    }
    if ($ChosenSubRace.SelectedItem -match 'Weretiger')
    {
        $ExportRace = "Weretiger"
        #Attributes Basic
        $STR = "17"
        $DEX = "15"
        $CON = "16"
        $INT = "10"
        $WIS = "13"
        $CHA = "11"
        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"
        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"
    }
    if ($ChosenSubRace.SelectedItem -match 'Werewolf')
    {
        $ExportRace = "Werewolf"
        #Attributes Basic
        $STR = "15"
        $DEX = "13"
        $CON = "14"
        $INT = "10"
        $WIS = "11"
        $CHA = "10"
        #Attribute Modifiers
        $STRmod = "+0"
        $DEXmod = "+0"
        $CONmod = "+0"
        $INTmod = "+0"
        $WISmod = "+0"
        $CHAmod = "+0"
        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"
    }
    if ($ChosenSubRace.SelectedItem -match 'Troll Freaks')
    {
        $ExportRace = "Troll Freaks"
    }
    if ($ChosenSubRace.SelectedItem -match 'Furious Tempers')
    {
        $ExportRace = "Ogre Furious Tempers"
    }
    if ($ChosenSubRace.SelectedItem -match 'Gruesome Gluttons')
    {
        $ExportRace = "Ogre Gruesome Gluttons"
    }
    if ($ChosenSubRace.SelectedItem -match 'Greedy Collectors')
    {
        $ExportRace = "Ogre Greedy Collectors"
    }
    if ($ChosenSubRace.SelectedItem -match 'Legendary Stupidity')
    {
        $ExportRace = "Ogre Legendary Stupidity"
    }
    if ($ChosenSubRace.SelectedItem -match 'Primaitive Wanderers')
    {
        $ExportRace = "Primitive Wanderers"
    }
    if ($ChosenSubRace.SelectedItem -match 'Winter Wolf')
    {
        $ExportRace = "Primitive Wanderers"
    }
    if ($ChosenSubRace.SelectedItem -match 'Timber Wolf')
    {
        $ExportRace = "Timber Wolf"
    }
    if ($ChosenSubRace.SelectedItem -match 'Dire Wolf')
    {
        $ExportRace = "Dire Wolf"
        #Attributes Basic
        $STR = "17"
        $DEX = "15"
        $CON = "15"
        $INT = "3"
        $WIS = "12"
        $CHA = "7"
        #Attribute Modifiers
        $STRmod = "+3"
        $DEXmod = "+2"
        $CONmod = "+2"
        $INTmod = "-4"
        $WISmod = "+1"
        $CHAmod = "-2"
        #Saving Throws
        $ST_STR = "0"
        $ST_DEX = "0"
        $ST_CON = "0"
        $ST_INT = "0"
        $ST_WIS = "0"
        $ST_CHA = "0"
        #$Skills = "Perception +3, stealth +4"
        #$Senses = "passive perception 13"
    }
    #If adding a custom SubRace, you can add the override using:    
    #    if ($ChosenSubRace.SelectedItem -match '**')
    #{
    #   $ExportRace = "**"
        #Attributes Basic
        #$STR = "0"
        #$DEX = "0"
        #$CON = "0"
        #$INT = "0"
        #$WIS = "0"
        #$CHA = "0"
        #Attribute Modifiers
        #$STRmod = "+0"
        #$DEXmod = "+0"
        #$CONmod = "+0"
        #$INTmod = "+0"
        #$WISmod = "+0"
        #$CHAmod = "+0"
        #Saving Throws
        #$ST_STR = "0"
        #$ST_DEX = "0"
        #$ST_CON = "0"
        #$ST_INT = "0"
        #$ST_WIS = "0"
        #$ST_CHA = "0"
    #}
#End of Subrace Extra's
#Weapon selection
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Sparks D&D Character Creator'
    $form.Size = New-Object System.Drawing.Size(500,600)
    $form.StartPosition = 'CenterScreen'
    $objIcon = New-Object system.drawing.icon (".\Assets\installer.ico")
    $form.Icon = $objIcon
    
    $objImage = [system.drawing.image]::FromFile(".\Assets\form_background.png")
    $form.BackgroundImage = $objImage
    $form.BackgroundImageLayout = "Center"
    
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(75,530)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'Next'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    $skipButton = New-Object System.Windows.Forms.Button
    $skipButton.Location = New-Object System.Drawing.Point(150,530)
    $skipButton.Size = New-Object System.Drawing.Size(75,23)
    $skipButton.Text = 'Skip'
    $skipButton.DialogResult = [System.Windows.Forms.DialogResult]::Ignore
    $form.AcceptButton = $skipButton
    $form.Controls.Add($skipButton)

    $backButton = New-Object System.Windows.Forms.Button
    $backButton.Location = New-Object System.Drawing.Point(225,530)
    $backButton.Size = New-Object System.Drawing.Size(75,23)
    $backButton.Text = 'Back'
    $backButton.DialogResult = [System.Windows.Forms.DialogResult]::Retry
    $form.CancelButton = $backButton
    $form.Controls.Add($backButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(300,530)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

    $selectweapon1label = New-Object System.Windows.Forms.Label
    $selectweapon1label.Location = New-Object System.Drawing.Point(15,20)
    $selectweapon1label.Size = New-Object System.Drawing.Size(140,18)
    $selectweapon1label.Text = 'Select Weapon 1:'
    $form.Controls.Add($selectweapon1label)

    $selectweapon2label = New-Object System.Windows.Forms.Label
    $selectweapon2label.Location = New-Object System.Drawing.Point(165,20)
    $selectweapon2label.Size = New-Object System.Drawing.Size(140,18)
    $selectweapon2label.Text = 'Select Weapon 2:'
    $form.Controls.Add($selectweapon2label)

    $selectweapon3label = New-Object System.Windows.Forms.Label
    $selectweapon3label.Location = New-Object System.Drawing.Point(315,20)
    $selectweapon3label.Size = New-Object System.Drawing.Size(140,18)
    $selectweapon3label.Text = 'Select Weapon 3:'
    $form.Controls.Add($selectweapon3label)

    $selectweapon1panel = New-Object System.Windows.Forms.ListBox
    $selectweapon1panel.Location = New-Object System.Drawing.Point(15,40)
    $selectweapon1panel.Size = New-Object System.Drawing.Size(140,18)
    $selectweapon1panel.Height = 230

    $selectweapon2panel = New-Object System.Windows.Forms.ListBox
    $selectweapon2panel.Location = New-Object System.Drawing.Point(165,40)
    $selectweapon2panel.Size = New-Object System.Drawing.Size(140,18)
    $selectweapon2panel.Height = 230

    $selectweapon3panel = New-Object System.Windows.Forms.ListBox
    $selectweapon3panel.Location = New-Object System.Drawing.Point(315,40)
    $selectweapon3panel.Size = New-Object System.Drawing.Size(140,18)
    $selectweapon3panel.Height = 230

    $selectadventuregearlabel = New-Object System.Windows.Forms.Label
    $selectadventuregearlabel.Location = New-Object System.Drawing.Point(240,270)
    $selectadventuregearlabel.Size = New-Object System.Drawing.Size(170,18)
    $selectadventuregearlabel.Text = 'Select 1 extra Adventuring Gear:'
    $form.Controls.Add($selectadventuregearlabel)

    $selectadventuinggearpanel = New-Object System.Windows.Forms.ListBox
    $selectadventuinggearpanel.Location = New-Object System.Drawing.Point(240,290)
    $selectadventuinggearpanel.Size = New-Object System.Drawing.Size(220,20)
    $selectadventuinggearpanel.Height = 230

    $armourlabel = New-Object System.Windows.Forms.Label
    $armourlabel.Location = New-Object System.Drawing.Point(10,270)
    $armourlabel.Size = New-Object System.Drawing.Size(220,18)
    $armourlabel.Text = 'Please select Armour you wish to wear:'
    $form.Controls.Add($armourlabel)

    $ChosenArmour = New-Object System.Windows.Forms.ListBox
    $ChosenArmour.Location = New-Object System.Drawing.Point(10,290)
    $ChosenArmour.Size = New-Object System.Drawing.Size(220,20)
    $ChosenArmour.Height = 200

    $checkboxshield = new-object System.Windows.Forms.checkbox
    $checkboxshield.Location = new-object System.Drawing.Size(25,490)
    $checkboxshield.Size = new-object System.Drawing.Size(120,40)
    $checkboxshield.Text = "Do you want a shield?"
    $checkboxshield.Checked = $false
#Weapon Lists, they correspond to the actual GUI, so don't mess up the co-ordinates
    #Weapon 1
        $selectweapon1panel.Items.Add('Iron Dagger') | Out-Null
        $selectweapon1panel.Items.Add('Steel Dagger') | Out-Null
        $selectweapon1panel.Items.Add('Club') | Out-Null
        $selectweapon1panel.Items.Add('Great Club') | Out-Null
        $selectweapon1panel.Items.Add('HandAxe') | Out-Null
        $selectweapon1panel.Items.Add('Javelin') | Out-Null
        $selectweapon1panel.Items.Add('Light Hammer') | Out-Null
        $selectweapon1panel.Items.Add('Mace') | Out-Null
        $selectweapon1panel.Items.Add('QuarterStaff') | Out-Null
        $selectweapon1panel.Items.Add('Spear') | Out-Null
        $selectweapon1panel.Items.Add('Nunchucks') | Out-Null
        $selectweapon1panel.Items.Add('Iron Sword') | Out-Null
        $selectweapon1panel.Items.Add('Iron Short Sword') | Out-Null
        $selectweapon1panel.Items.Add('Crossbow - Light') | Out-Null
        $selectweapon1panel.Items.Add('Shortbow') | Out-Null
        $selectweapon1panel.Items.Add('Dart') | Out-Null
        $selectweapon1panel.Items.Add('Sling') | Out-Null
        $selectweapon1panel.Items.Add('BattleAxe') | Out-Null
        $selectweapon1panel.Items.Add('Flail') | Out-Null
        $selectweapon1panel.Items.Add('Great Axe') | Out-Null
        $selectweapon1panel.Items.Add('Great Sword') | Out-Null
        $selectweapon1panel.Items.Add('Halberd') | Out-Null
        $selectweapon1panel.Items.Add('Longsword') | Out-Null
        $selectweapon1panel.Items.Add('Maul') | Out-Null
        $selectweapon1panel.Items.Add('MorningStar') | Out-Null
        $selectweapon1panel.Items.Add('Rapier') | Out-Null
        $selectweapon1panel.Items.Add('Sicimitar') | Out-Null
        $selectweapon1panel.Items.Add('ShortSword') | Out-Null
        $selectweapon1panel.Items.Add('Trident') | Out-Null
        $selectweapon1panel.Items.Add('Warhammer') | Out-Null
        $selectweapon1panel.Items.Add('DoomHammer') | Out-Null
        $selectweapon1panel.Items.Add('Dual-Wield Staff') | Out-Null
        $selectweapon1panel.Items.Add('Broadsword') | Out-Null
        $selectweapon1panel.Items.Add('Steel Sword') | Out-Null
        $selectweapon1panel.Items.Add('Crossbow - Heavy') | Out-Null
        $selectweapon1panel.Items.Add('Crossbow - Hand') | Out-Null
        $selectweapon1panel.Items.Add('Longbow') | Out-Null
    #Weapon 2
        $selectweapon2panel.Items.Add('Iron Dagger') | Out-Null
        $selectweapon2panel.Items.Add('Steel Dagger') | Out-Null
        $selectweapon2panel.Items.Add('Club') | Out-Null
        $selectweapon2panel.Items.Add('Great Club') | Out-Null
        $selectweapon2panel.Items.Add('HandAxe') | Out-Null
        $selectweapon2panel.Items.Add('Javelin') | Out-Null
        $selectweapon2panel.Items.Add('Light Hammer') | Out-Null
        $selectweapon2panel.Items.Add('Mace') | Out-Null
        $selectweapon2panel.Items.Add('QuarterStaff') | Out-Null
        $selectweapon2panel.Items.Add('Spear') | Out-Null
        $selectweapon2panel.Items.Add('Nunchucks') | Out-Null
        $selectweapon2panel.Items.Add('Iron Sword') | Out-Null
        $selectweapon2panel.Items.Add('Iron Short Sword') | Out-Null
        $selectweapon2panel.Items.Add('Crossbow - Light') | Out-Null
        $selectweapon2panel.Items.Add('Shortbow') | Out-Null
        $selectweapon2panel.Items.Add('Dart') | Out-Null
        $selectweapon2panel.Items.Add('Sling') | Out-Null
        $selectweapon2panel.Items.Add('BattleAxe') | Out-Null
        $selectweapon2panel.Items.Add('Flail') | Out-Null
        $selectweapon2panel.Items.Add('Great Axe') | Out-Null
        $selectweapon2panel.Items.Add('Great Sword') | Out-Null
        $selectweapon2panel.Items.Add('Halberd') | Out-Null
        $selectweapon2panel.Items.Add('Longsword') | Out-Null
        $selectweapon2panel.Items.Add('Maul') | Out-Null
        $selectweapon2panel.Items.Add('MorningStar') | Out-Null
        $selectweapon2panel.Items.Add('Rapier') | Out-Null
        $selectweapon2panel.Items.Add('Sicimitar') | Out-Null
        $selectweapon2panel.Items.Add('ShortSword') | Out-Null
        $selectweapon2panel.Items.Add('Trident') | Out-Null
        $selectweapon2panel.Items.Add('Warhammer') | Out-Null
        $selectweapon2panel.Items.Add('DoomHammer') | Out-Null
        $selectweapon2panel.Items.Add('Dual-Wield Staff') | Out-Null
        $selectweapon2panel.Items.Add('Broadsword') | Out-Null
        $selectweapon2panel.Items.Add('Steel Sword') | Out-Null
        $selectweapon2panel.Items.Add('Crossbow - Heavy') | Out-Null
        $selectweapon2panel.Items.Add('Crossbow - Hand') | Out-Null
        $selectweapon2panel.Items.Add('Longbow') | Out-Null
    #Weapon 3
        $selectweapon3panel.Items.Add('Iron Dagger') | Out-Null
        $selectweapon3panel.Items.Add('Steel Dagger') | Out-Null
        $selectweapon3panel.Items.Add('Club') | Out-Null
        $selectweapon3panel.Items.Add('Great Club') | Out-Null
        $selectweapon3panel.Items.Add('HandAxe') | Out-Null
        $selectweapon3panel.Items.Add('Javelin') | Out-Null
        $selectweapon3panel.Items.Add('Light Hammer') | Out-Null
        $selectweapon3panel.Items.Add('Mace') | Out-Null
        $selectweapon3panel.Items.Add('QuarterStaff') | Out-Null
        $selectweapon3panel.Items.Add('Spear') | Out-Null
        $selectweapon3panel.Items.Add('Nunchucks') | Out-Null
        $selectweapon3panel.Items.Add('Iron Sword') | Out-Null
        $selectweapon3panel.Items.Add('Iron Short Sword') | Out-Null
        $selectweapon3panel.Items.Add('Crossbow - Light') | Out-Null
        $selectweapon3panel.Items.Add('Shortbow') | Out-Null
        $selectweapon3panel.Items.Add('Dart') | Out-Null
        $selectweapon3panel.Items.Add('Sling') | Out-Null
        $selectweapon3panel.Items.Add('BattleAxe') | Out-Null
        $selectweapon3panel.Items.Add('Flail') | Out-Null
        $selectweapon3panel.Items.Add('Great Axe') | Out-Null
        $selectweapon3panel.Items.Add('Great Sword') | Out-Null
        $selectweapon3panel.Items.Add('Halberd') | Out-Null
        $selectweapon3panel.Items.Add('Longsword') | Out-Null
        $selectweapon3panel.Items.Add('Maul') | Out-Null
        $selectweapon3panel.Items.Add('MorningStar') | Out-Null
        $selectweapon3panel.Items.Add('Rapier') | Out-Null
        $selectweapon3panel.Items.Add('Sicimitar') | Out-Null
        $selectweapon3panel.Items.Add('ShortSword') | Out-Null
        $selectweapon3panel.Items.Add('Trident') | Out-Null
        $selectweapon3panel.Items.Add('Warhammer') | Out-Null
        $selectweapon3panel.Items.Add('DoomHammer') | Out-Null
        $selectweapon3panel.Items.Add('Dual-Wield Staff') | Out-Null
        $selectweapon3panel.Items.Add('Broadsword') | Out-Null
        $selectweapon3panel.Items.Add('Steel Sword') | Out-Null
        $selectweapon3panel.Items.Add('Crossbow - Heavy') | Out-Null
        $selectweapon3panel.Items.Add('Crossbow - Hand') | Out-Null
        $selectweapon3panel.Items.Add('Longbow') | Out-Null
    #Adventuring Gear List
        $selectadventuinggearpanel.Items.Add('Abacus') | Out-Null
        $selectadventuinggearpanel.Items.Add('Acid (vial)') | Out-Null
        $selectadventuinggearpanel.Items.Add('Alchemists fire (flask)') | Out-Null
        $selectadventuinggearpanel.Items.Add('Antitoxin (vial)') | Out-Null
        $selectadventuinggearpanel.Items.Add('Backpack') | Out-Null
        $selectadventuinggearpanel.Items.Add('Ball Bearings (bag of 1,000)') | Out-Null
        $selectadventuinggearpanel.Items.Add('Barrel') | Out-Null
        $selectadventuinggearpanel.Items.Add('Nasket') | Out-Null
        $selectadventuinggearpanel.Items.Add('Bedroll') | Out-Null
        $selectadventuinggearpanel.Items.Add('Bell') | Out-Null
        $selectadventuinggearpanel.Items.Add('Blanket') | Out-Null
        $selectadventuinggearpanel.Items.Add('Block and tackle') | Out-Null
        $selectadventuinggearpanel.Items.Add('Book') | Out-Null
        $selectadventuinggearpanel.Items.Add('Bottle, glass') | Out-Null
        $selectadventuinggearpanel.Items.Add('Bucket') | Out-Null
        $selectadventuinggearpanel.Items.Add('Caltrops (bag of 20)') | Out-Null
        $selectadventuinggearpanel.Items.Add('Candle') | Out-Null
        $selectadventuinggearpanel.Items.Add('Case, crossbow bolt') | Out-Null
        $selectadventuinggearpanel.Items.Add('Case, map or scroll') | Out-Null
        $selectadventuinggearpanel.Items.Add('Chain (10 feet)') | Out-Null
        $selectadventuinggearpanel.Items.Add('Chalk (1 piece)') | Out-Null
        $selectadventuinggearpanel.Items.Add('Chest') | Out-Null
        $selectadventuinggearpanel.Items.Add('Climbers kit') | Out-Null
        $selectadventuinggearpanel.Items.Add('Clothes, common') | Out-Null
        $selectadventuinggearpanel.Items.Add('Clothes, costume') | Out-Null
        $selectadventuinggearpanel.Items.Add('Clothes, fine') | Out-Null
        $selectadventuinggearpanel.Items.Add('Clothes, travelers') | Out-Null
        $selectadventuinggearpanel.Items.Add('Component pouch') | Out-Null
        $selectadventuinggearpanel.Items.Add('Crowbar') | Out-Null
        $selectadventuinggearpanel.Items.Add('Fishing Tackle') | Out-Null
        $selectadventuinggearpanel.Items.Add('Flask or tankard') | Out-Null
        $selectadventuinggearpanel.Items.Add('Grappling hook') | Out-Null
        $selectadventuinggearpanel.Items.Add('Hammer') | Out-Null
        $selectadventuinggearpanel.Items.Add('Sledgehammer') | Out-Null
        $selectadventuinggearpanel.Items.Add('Healers kit') | Out-Null
        $selectadventuinggearpanel.Items.Add('Holy water (flask)') | Out-Null
        $selectadventuinggearpanel.Items.Add('Hourglass') | Out-Null
        $selectadventuinggearpanel.Items.Add('Hunting trap') | Out-Null
        $selectadventuinggearpanel.Items.Add('Ink (1 ounce bottle) + Ink pen') | Out-Null
        $selectadventuinggearpanel.Items.Add('Jug or pitcher') | Out-Null
        $selectadventuinggearpanel.Items.Add('Ladder (10 foot)') | Out-Null
        $selectadventuinggearpanel.Items.Add('Lamp') | Out-Null
        $selectadventuinggearpanel.Items.Add('Lantern, bullseye') | Out-Null
        $selectadventuinggearpanel.Items.Add('Lantern, hooded') | Out-Null
        $selectadventuinggearpanel.Items.Add('Lock') | Out-Null
        $selectadventuinggearpanel.Items.Add('Magnifying glass') | Out-Null
        $selectadventuinggearpanel.Items.Add('Manacles') | Out-Null
        $selectadventuinggearpanel.Items.Add('Mess kit') | Out-Null
        $selectadventuinggearpanel.Items.Add('Mirror, steel') | Out-Null
        $selectadventuinggearpanel.Items.Add('Oil (flask)') | Out-Null
        $selectadventuinggearpanel.Items.Add('Paper (one sheet)') | Out-Null
        $selectadventuinggearpanel.Items.Add('Parchment (one sheet)') | Out-Null
        $selectadventuinggearpanel.Items.Add('Perfume (vial)') | Out-Null
        $selectadventuinggearpanel.Items.Add('Pick, miners') | Out-Null
        $selectadventuinggearpanel.Items.Add('Piton') | Out-Null
        $selectadventuinggearpanel.Items.Add('Poison, basic (vial)') | Out-Null
        $selectadventuinggearpanel.Items.Add('Pole (10-foot)') | Out-Null
        $selectadventuinggearpanel.Items.Add('Pot, iron') | Out-Null
        $selectadventuinggearpanel.Items.Add('Potion of healing') | Out-Null
        $selectadventuinggearpanel.Items.Add('Pouch') | Out-Null
        $selectadventuinggearpanel.Items.Add('Quiver') | Out-Null
        $selectadventuinggearpanel.Items.Add('Ram, portable') | Out-Null
        $selectadventuinggearpanel.Items.Add('Rations (1 day)') | Out-Null
        $selectadventuinggearpanel.Items.Add('Robes') | Out-Null
        $selectadventuinggearpanel.Items.Add('Rope, hempen (50 feet)') | Out-Null
        $selectadventuinggearpanel.Items.Add('Rope, silk (50 feet)') | Out-Null
        $selectadventuinggearpanel.Items.Add('Sack') | Out-Null
        $selectadventuinggearpanel.Items.Add('Scale, merchants') | Out-Null
        $selectadventuinggearpanel.Items.Add('Sealing wax') | Out-Null
        $selectadventuinggearpanel.Items.Add('Shovel') | Out-Null
        $selectadventuinggearpanel.Items.Add('Signal whistle') | Out-Null
        $selectadventuinggearpanel.Items.Add('Signet ring') | Out-Null
        $selectadventuinggearpanel.Items.Add('Soap') | Out-Null
        $selectadventuinggearpanel.Items.Add('Spellbook') | Out-Null
        $selectadventuinggearpanel.Items.Add('Spikes, iron (10)') | Out-Null
        $selectadventuinggearpanel.Items.Add('Spyglass') | Out-Null
        $selectadventuinggearpanel.Items.Add('Tent, two-person') | Out-Null
        $selectadventuinggearpanel.Items.Add('Tinderbox') | Out-Null
        $selectadventuinggearpanel.Items.Add('Torch') | Out-Null
        $selectadventuinggearpanel.Items.Add('Vial') | Out-Null
        $selectadventuinggearpanel.Items.Add('Waterskin') | Out-Null
        $selectadventuinggearpanel.Items.Add('Whetstone') | Out-Null
    #List from: https://www.dndbeyond.com/sources/basic-rules/equipment#AdventuringGear
    #Each class needs to be limited to armour types to stop OP characters
    #Make this a later thing to do as classes are still being worked on
        $ChosenArmour.Items.Add('Light Armour - Naked') | Out-Null
        $ChosenArmour.Items.Add('Light Armour - Padded') | Out-Null
        $ChosenArmour.Items.Add('Light Armour - Leather') | Out-Null
        $ChosenArmour.Items.Add('Light Armour - Studded Leather') | Out-Null
        $ChosenArmour.Items.Add('Medium Armour - Hide') | Out-Null
        $ChosenArmour.Items.Add('Medium Armour - Chain Shirt') | Out-Null
        $ChosenArmour.Items.Add('Medium Armour - Scale Mail') | Out-Null
        $ChosenArmour.Items.Add('Medium Armour - Breastplate') | Out-Null
        $ChosenArmour.Items.Add('Medium Armour - Half Plate') | Out-Null
        $ChosenArmour.Items.Add('Heavy Armour - Ring Mail') | Out-Null
        $ChosenArmour.Items.Add('Heavy Armour - Chain Mail') | Out-Null
        $ChosenArmour.Items.Add('Heavy Armour - Splint') | Out-Null
        $ChosenArmour.Items.Add('Heavy Armour - Plate') | Out-Null
    #Shield as an option with tickbox, completely optional to a player
        $checkboxshield.Add_CheckStateChanged({
            $checkboxshield.Enabled = $checkboxshield.Checked 
        })
        $Form.Add_Shown({$Form.Activate()})
        
        $form.Controls.Add($selectweapon1panel)
        $form.Controls.Add($selectweapon2panel)
        $form.Controls.Add($selectweapon3panel)
        $form.Controls.Add($selectadventuinggearpanel)
        $form.Controls.Add($ChosenArmour)
        $Form.controls.AddRange(@($checkboxshield))
        $form.Topmost = $true    

        if ($selectedweapons -eq [System.Windows.Forms.DialogResult]::OK)
        {
            $selectedweapon1 = $selectweapon1panel.SelectedItem
            $selectedweapon1

            $selectedweapon2 = $selectweapon2panel.SelectedItem
            $selectedweapon2

            $selectedweapon3 = $selectweapon3panel.SelectedItem
            $selectedweapon3

            $selectedadventuregear = $selectadventuinggearpanel.SelectedItem
            $selectedadventuregear

            $SelectedArmour = $ChosenArmour.SelectedItem
            $SelectedArmour
        }
        if ($selectedweapons -eq [System.Windows.Forms.DialogResult]::Ignore)
        {
            $selectedweapon1 = "Non-Selected"
            $selectedweapon2 = "Non-Selected"
            $selectedweapon3 = "Non-Selected"
            $ChosenArmour = "None Selected"
        }
        $selectedweapons = $form.ShowDialog()
        if ($selectedweapons -eq [System.Windows.Forms.DialogResult]::Retry)
        {
            return
        }
        if ($selectedweapons -eq [System.Windows.Forms.DialogResult]::Cancel)
        {
            Exit
        }
#End of Weapon choice

#If added custom to the weapon list, make sure to add the correct listed item to the weapon selection below
#Above:
#$selectweapon1panel.Items.Add('**') | Out-Null
#$selectweapon2panel.Items.Add('**') | Out-Null
#$selectweapon3panel.Items.Add('**') | Out-Null
#$selectadventuinggearpanel.Items.Add('**') | Out-Null
#$ChosenArmour.Items.Add('**') | Out-Null

#Remember DM's! These types of armour are affected with cost, armour class, strength, stealth and weight
#There is one type of shield with a base code of 10gp, armour class of +2 and weight of 453g
#Getting out of armour has times for "DON" and "DOFF" DON = Put on, DOff = Take off
#Light armour has a don of 1 min and doff of 1 min
#Medium armour has a don of 5 mins and doff of 1 min
#Heavy armour has a don of 10 mins and a doff off 5mins
#shield has a don of 1 action and doff of 1 action

#Weapons+Gear+Armour
    #Weapon 1 Choice
    if ($selectweapon1panel.SelectedItem -match 'Iron Dagger')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d4 Piercing"
        $Weapon1Weight = "1lb"
        $Weapon1Properties = "Finesse, Light, thrown (range 20/60)"
    }
    if ($selectweapon1panel.SelectedItem -match 'Steel Dagger')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d4 Piercing"
        $Weapon1Weight = "2lb"
        $Weapon1Properties = "Finesse, Light, thrown (range 20/60)"
    }
    if ($selectweapon1panel.SelectedItem -match 'Club')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d4 Bludgeoning"
        $Weapon1Weight = "2lb"
        $Weapon1Properties = "Light"
    }
    if ($selectweapon1panel.SelectedItem -match 'Great Club')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d8 Bludgeoning"
        $Weapon1Weight = "10lb"
        $Weapon1Properties = "Two-Handed"
    }
    if ($selectweapon1panel.SelectedItem -match 'HandAxe')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d6 slashing"
        $Weapon1Weight = "2lb"
        $Weapon1Properties = "Light, Thrown (range 20/60)"
    }
    if ($selectweapon1panel.SelectedItem -match 'Javelin')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d6 piercing"
        $Weapon1Weight = "2lb"
        $Weapon1Properties = "Thrown (range 30/120"
    }
    if ($selectweapon1panel.SelectedItem -match 'Light Hammer')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d4 Bludgeoning"
        $Weapon1Weight = "2lb"
        $Weapon1Properties = "Light, Thrown (range 20/60)"
    }
    if ($selectweapon1panel.SelectedItem -match 'Mace')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d6 Bludgeoning"
        $Weapon1Weight = "4lb"
        $Weapon1Properties = "One-Handed"
    }
    if ($selectweapon1panel.SelectedItem -match 'QuarterStaff')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d6 Bludgeoning"
        $Weapon1Weight = "4lb"
        $Weapon1Properties = "Versatile (1d8)"
    }
    if ($selectweapon1panel.SelectedItem -match 'Spear')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d6 Piercing"
        $Weapon1Weight = "3lb"
        $Weapon1Properties = "Thrown (range 20/60, versatile (qd8)"
    }
    if ($selectweapon1panel.SelectedItem -match 'Nunchucks')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d4 Bludgeoning"
        $Weapon1Weight = "5lb"
        $Weapon1Properties = "Two-Handed, Thrown (range 20/30)"
    }
    if ($selectweapon1panel.SelectedItem -match 'Iron Sword')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d6 Piercing"
        $Weapon1Weight = "6lb"
        $Weapon1Properties = "One-Handed"
    }
    if ($selectweapon1panel.SelectedItem -match 'Iron Short Sword')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d4 Piercing"
        $Weapon1Weight = "3lb"
        $Weapon1Properties = "One-Handed"
    }
    if ($selectweapon1panel.SelectedItem -match 'Crossbow - Light')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d8 Piercing"
        $Weapon1Weight = "5lb"
        $Weapon1Properties = "Ammunition (range 80/320), Loading, Two-Handed"
    }
    if ($selectweapon1panel.SelectedItem -match 'Shortbow')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d6 Piercing"
        $Weapon1Weight = "2lb"
        $Weapon1Properties = "Ammunition (range 80/320), Two-Handed"
    }
    if ($selectweapon1panel.SelectedItem -match 'Sling')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d4 Bludgeoning"
        $Weapon1Weight = "0lb"
        $Weapon1Properties = "Ammunition (range 30/120)"
    }
    if ($selectweapon1panel.SelectedItem -match 'Dart')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d4 Piercing"
        $Weapon1Weight = "1/4lb"
        $Weapon1Properties = "Finesse, thrown (range 20/60)"
    }
    if ($selectweapon1panel.SelectedItem -match 'BattleAxe')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d8 Slashing"
        $Weapon1Weight = "4lb"
        $Weapon1Properties = "Versatile (1d10)"
    }
    if ($selectweapon1panel.SelectedItem -match 'Flail')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d8 Bludgeoning"
        $Weapon1Weight = "2lb"
        $Weapon1Properties = "One-Handed"
    }
    if ($selectweapon1panel.SelectedItem -match 'Great Axe')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d12 Slashing"
        $Weapon1Weight = "7lb"
        $Weapon1Properties = "Heavy, Two-Handed"
    }
    if ($selectweapon1panel.SelectedItem -match 'Great Sword')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "2d6 Slashing"
        $Weapon1Weight = "6lb"
        $Weapon1Properties = "Heavy, Two-Handed"
    }
    if ($selectweapon1panel.SelectedItem -match 'Halberd')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d10 Slashing"
        $Weapon1Weight = "6lb"
        $Weapon1Properties = "Heavy, Reach, Two-Handed"
    }
    if ($selectweapon1panel.SelectedItem -match 'Longsword')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d8 Slashing"
        $Weapon1Weight = "3lb"
        $Weapon1Properties = "Versatile (1d10)"
    }
    if ($selectweapon1panel.SelectedItem -match 'Maul')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "2d6 Bludgeoning"
        $Weapon1Weight = "10lb"
        $Weapon1Properties = "Heavy, Two-Handed"
    }
    if ($selectweapon1panel.SelectedItem -match 'MorningStar')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d8 Piercing"
        $Weapon1Weight = "4lb"
        $Weapon1Properties = "Two-Handed"
    }
    if ($selectweapon1panel.SelectedItem -match 'Rapier')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d8 Piercing"
        $Weapon1Weight = "2lb"
        $Weapon1Properties = "Finesse"
    }
    if ($selectweapon1panel.SelectedItem -match 'Sicimitar')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d6 Slashing"
        $Weapon1Weight = "3lb"
        $Weapon1Properties = "Finesse, Light"
    }
    if ($selectweapon1panel.SelectedItem -match 'ShortSword')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d6 Piercing"
        $Weapon1Weight = "2lb"
        $Weapon1Properties = "Finesse, Light"
    }
    if ($selectweapon1panel.SelectedItem -match 'Trident')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d6 Piercing"
        $Weapon1Weight = "4lb"
        $Weapon1Properties = "Thrown (range 20/60), Versatile (1d8)"
    }
    if ($selectweapon1panel.SelectedItem -match 'Warhammer')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d8 Bludgeoning"
        $Weapon1Weight = "2lb"
        $Weapon1Properties = "Versatile (1d10)"
    }
    if ($selectweapon1panel.SelectedItem -match 'DoomHammer')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d12 Bludgeoning"
        $Weapon1Weight = "10lb"
        $Weapon1Properties = "Heavy, Two-Handed"
    }
    if ($selectweapon1panel.SelectedItem -match 'Dual-Wield Staff')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d8 Budgeoning"
        $Weapon1Weight = "7lb"
        $Weapon1Properties = "Two-Handed, Light"
    }
    if ($selectweapon1panel.SelectedItem -match 'Broadsword')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d8 Piercing"
        $Weapon1Weight = "8lb"
        $Weapon1Properties = "Heavy, Two-Handed"
    }
    if ($selectweapon1panel.SelectedItem -match 'Steel Sword')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d8 Piercing"
        $Weapon1Weight = "8lb"
        $Weapon1Properties = "One-Handed"
    }
    if ($selectweapon1panel.SelectedItem -match 'Crossbow - Heavy')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d10 Piercing"
        $Weapon1Weight = "18lb"
        $Weapon1Properties = "Ammunition (range 30/120), light, loading"
    }
    if ($selectweapon1panel.SelectedItem -match 'Crossbow - Hand')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d6 Piercing"
        $Weapon1Weight = "3lb"
        $Weapon1Properties = "Ammunition (range 100/400), Heavy, Loading, Two-Handed"
    }
    if ($selectweapon1panel.SelectedItem -match 'Longbow')
    {
        $WPN1ATK_Bonus = "+4"
        $Weapon1Damage = "1d8 Piercing"
        $Weapon1Weight = "2lb"
        $Weapon1Properties = "Ammunition (range 150/600), Heavy, Two-Handed"
    }
    #Weapon 2 Choice
    if ($selectweapon2panel.SelectedItem -match 'Iron Dagger')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d4 Piercing"
        $Weapon2Weight = "1lb"
        $Weapon2Properties = "Finesse, Light, thrown (range 20/60)"
    }
    if ($selectweapon2panel.SelectedItem -match 'Steel Dagger')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d4 Piercing"
        $Weapon2Weight = "2lb"
        $Weapon2Properties = "Finesse, Light, thrown (range 20/60)"
    }
    if ($selectweapon2panel.SelectedItem -match 'Club')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d4 Bludgeoning"
        $Weapon2Weight = "2lb"
        $Weapon2Properties = "Light"
    }
    if ($selectweapon2panel.SelectedItem -match 'Great Club')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d8 Bludgeoning"
        $Weapon2Weight = "10lb"
        $Weapon2Properties = "Two-Handed"
    }
    if ($selectweapon2panel.SelectedItem -match 'HandAxe')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d6 slashing"
        $Weapon2Weight = "2lb"
        $Weapon2Properties = "Light, Thrown (range 20/60)"
    }
    if ($selectweapon2panel.SelectedItem -match 'Javelin')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d6 piercing"
        $Weapon2Weight = "2lb"
        $Weapon2Properties = "Thrown (range 30/120"
    }
    if ($selectweapon2panel.SelectedItem -match 'Light Hammer')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d4 Bludgeoning"
        $Weapon2Weight = "2lb"
        $Weapon2Properties = "Light, Thrown (range 20/60)"
    }
    if ($selectweapon2panel.SelectedItem -match 'Mace')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d6 Bludgeoning"
        $Weapon2Weight = "4lb"
        $Weapon2Properties = "One-Handed"
    }
    if ($selectweapon2panel.SelectedItem -match 'QuarterStaff')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d6 Bludgeoning"
        $Weapon2Weight = "4lb"
        $Weapon2Properties = "Versatile (1d8)"
    }
    if ($selectweapon2panel.SelectedItem -match 'Spear')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d6 Piercing"
        $Weapon2Weight = "3lb"
        $Weapon2Properties = "Thrown (range 20/60, versatile (qd8)"
    }
    if ($selectweapon2panel.SelectedItem -match 'Nunchucks')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d4 Bludgeoning"
        $Weapon2Weight = "5lb"
        $Weapon2Properties = "Two-Handed, Thrown (range 20/30)"
    }
    if ($selectweapon2panel.SelectedItem -match 'Iron Sword')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d6 Piercing"
        $Weapon2Weight = "6lb"
        $Weapon2Properties = "One-Handed"
    }
    if ($selectweapon2panel.SelectedItem -match 'Iron Short Sword')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d4 Piercing"
        $Weapon2Weight = "3lb"
        $Weapon2Properties = "One-Handed"
    }
    if ($selectweapon2panel.SelectedItem -match 'Crossbow - Light')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d8 Piercing"
        $Weapon2Weight = "5lb"
        $Weapon2Properties = "Ammunition (range 80/320), Loading, Two-Handed"
    }
    if ($selectweapon2panel.SelectedItem -match 'Shortbow')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d6 Piercing"
        $Weapon2Weight = "2lb"
        $Weapon2Properties = "Ammunition (range 80/320), Two-Handed"
    }
    if ($selectweapon2panel.SelectedItem -match 'Sling')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d4 Bludgeoning"
        $Weapon2Weight = "0lb"
        $Weapon2Properties = "Ammunition (range 30/120)"
    }
    if ($selectweapon2panel.SelectedItem -match 'Dart')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d4 Piercing"
        $Weapon2Weight = "1/4lb"
        $Weapon2Properties = "Finesse, thrown (range 20/60)"
    }
    if ($selectweapon2panel.SelectedItem -match 'BattleAxe')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d8 Slashing"
        $Weapon2Weight = "4lb"
        $Weapon2Properties = "Versatile (1d10)"
    }
    if ($selectweapon2panel.SelectedItem -match 'Flail')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d8 Bludgeoning"
        $Weapon2Weight = "2lb"
        $Weapon2Properties = "One-Handed"
    }
    if ($selectweapon2panel.SelectedItem -match 'Great Axe')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d12 Slashing"
        $Weapon2Weight = "7lb"
        $Weapon2Properties = "Heavy, Two-Handed"
    }
    if ($selectweapon2panel.SelectedItem -match 'Great Sword')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "2d6 Slashing"
        $Weapon2Weight = "6lb"
        $Weapon2Properties = "Heavy, Two-Handed"
    }
    if ($selectweapon2panel.SelectedItem -match 'Halberd')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d10 Slashing"
        $Weapon2Weight = "6lb"
        $Weapon2Properties = "Heavy, Reach, Two-Handed"
    }
    if ($selectweapon2panel.SelectedItem -match 'Longsword')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d8 Slashing"
        $Weapon2Weight = "3lb"
        $Weapon2Properties = "Versatile (1d10)"
    }
    if ($selectweapon2panel.SelectedItem -match 'Maul')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "2d6 Bludgeoning"
        $Weapon2Weight = "10lb"
        $Weapon2Properties = "Heavy, Two-Handed"
    }
    if ($selectweapon2panel.SelectedItem -match 'MorningStar')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d8 Piercing"
        $Weapon2Weight = "4lb"
        $Weapon2Properties = "Two-Handed"
    }
    if ($selectweapon2panel.SelectedItem -match 'Rapier')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d8 Piercing"
        $Weapon2Weight = "2lb"
        $Weapon2Properties = "Finesse"
    }
    if ($selectweapon2panel.SelectedItem -match 'Sicimitar')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d6 Slashing"
        $Weapon2Weight = "3lb"
        $Weapon2Properties = "Finesse, Light"
    }
    if ($selectweapon2panel.SelectedItem -match 'ShortSword')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d6 Piercing"
        $Weapon2Weight = "2lb"
        $Weapon2Properties = "Finesse, Light"
    }
    if ($selectweapon2panel.SelectedItem -match 'Trident')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d6 Piercing"
        $Weapon2Weight = "4lb"
        $Weapon2Properties = "Thrown (range 20/60), Versatile (1d8)"
    }
    if ($selectweapon2panel.SelectedItem -match 'Warhammer')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d8 Bludgeoning"
        $Weapon2Weight = "2lb"
        $Weapon2Properties = "Versatile (1d10)"
    }
    if ($selectweapon2panel.SelectedItem -match 'DoomHammer')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d12 Bludgeoning"
        $Weapon2Weight = "10lb"
        $Weapon2Properties = "Heavy, Two-Handed"
    }
    if ($selectweapon2panel.SelectedItem -match 'Dual-Wield Staff')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d8 Budgeoning"
        $Weapon2Weight = "7lb"
        $Weapon2Properties = "Two-Handed, Light"
    }
    if ($selectweapon2panel.SelectedItem -match 'Broadsword')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d8 Piercing"
        $Weapon2Weight = "8lb"
        $Weapon2Properties = "Heavy, Two-Handed"
    }
    if ($selectweapon2panel.SelectedItem -match 'Steel Sword')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d8 Piercing"
        $Weapon2Weight = "8lb"
        $Weapon2Properties = "One-Handed"
    }
    if ($selectweapon2panel.SelectedItem -match 'Crossbow - Heavy')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d10 Piercing"
        $Weapon2Weight = "18lb"
        $Weapon2Properties = "Ammunition (range 30/120), light, loading"
    }
    if ($selectweapon2panel.SelectedItem -match 'Crossbow - Hand')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d6 Piercing"
        $Weapon2Weight = "3lb"
        $Weapon2Properties = "Ammunition (range 100/400), Heavy, Loading, Two-Handed"
    }
    if ($selectweapon2panel.SelectedItem -match 'Longbow')
    {
        $WPN2ATK_Bonus = "+4"
        $Weapon2Damage = "1d8 Piercing"
        $Weapon2Weight = "2lb"
        $Weapon2Properties = "Ammunition (range 150/600), Heavy, Two-Handed"
    }
    #Weapon 3 Choice
    if ($selectweapon3panel.SelectedItem -match 'Iron Dagger')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d4 Piercing"
        $Weapon3Weight = "1lb"
        $Weapon3Properties = "Finesse, Light, thrown (range 20/60)"
    }
    if ($selectweapon3panel.SelectedItem -match 'Steel Dagger')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d4 Piercing"
        $Weapon3Weight = "2lb"
        $Weapon3Properties = "Finesse, Light, thrown (range 20/60)"
    }
    if ($selectweapon3panel.SelectedItem -match 'Club')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d4 Bludgeoning"
        $Weapon3Weight = "2lb"
        $Weapon3Properties = "Light"
    }
    if ($selectweapon3panel.SelectedItem -match 'Great Club')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d8 Bludgeoning"
        $Weapon3Weight = "10lb"
        $Weapon3Properties = "Two-Handed"
    }
    if ($selectweapon3panel.SelectedItem -match 'HandAxe')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d6 slashing"
        $Weapon3Weight = "2lb"
        $Weapon3Properties = "Light, Thrown (range 20/60)"
    }
    if ($selectweapon3panel.SelectedItem -match 'Javelin')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d6 piercing"
        $Weapon3Weight = "2lb"
        $Weapon3Properties = "Thrown (range 30/120"
    }
    if ($selectweapon3panel.SelectedItem -match 'Light Hammer')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d4 Bludgeoning"
        $Weapon3Weight = "2lb"
        $Weapon3Properties = "Light, Thrown (range 20/60)"
    }
    if ($selectweapon3panel.SelectedItem -match 'Mace')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d6 Bludgeoning"
        $Weapon3Weight = "4lb"
        $Weapon3Properties = "One-Handed"
    }
    if ($selectweapon3panel.SelectedItem -match 'QuarterStaff')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d6 Bludgeoning"
        $Weapon3Weight = "4lb"
        $Weapon3Properties = "Versatile (1d8)"
    }
    if ($selectweapon3panel.SelectedItem -match 'Spear')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d6 Piercing"
        $Weapon3Weight = "3lb"
        $Weapon3Properties = "Thrown (range 20/60, versatile (qd8)"
    }
    if ($selectweapon3panel.SelectedItem -match 'Nunchucks')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d4 Bludgeoning"
        $Weapon3Weight = "5lb"
        $Weapon3Properties = "Two-Handed, Thrown (range 20/30)"
    }
    if ($selectweapon3panel.SelectedItem -match 'Iron Sword')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d6 Piercing"
        $Weapon3Weight = "6lb"
        $Weapon3Properties = "One-Handed"
    }
    if ($selectweapon3panel.SelectedItem -match 'Iron Short Sword')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d4 Piercing"
        $Weapon3Weight = "3lb"
        $Weapon3Properties = "One-Handed"
    }
    if ($selectweapon3panel.SelectedItem -match 'Crossbow - Light')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d8 Piercing"
        $Weapon3Weight = "5lb"
        $Weapon3Properties = "Ammunition (range 80/320), Loading, Two-Handed"
    }
    if ($selectweapon3panel.SelectedItem -match 'Shortbow')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d6 Piercing"
        $Weapon3Weight = "2lb"
        $Weapon3Properties = "Ammunition (range 80/320), Two-Handed"
    }
    if ($selectweapon3panel.SelectedItem -match 'Sling')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d4 Bludgeoning"
        $Weapon3Weight = "0lb"
        $Weapon3Properties = "Ammunition (range 30/120)"
    }
    if ($selectweapon3panel.SelectedItem -match 'Dart')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d4 Piercing"
        $Weapon3Weight = "1/4lb"
        $Weapon3Properties = "Finesse, thrown (range 20/60)"
    }
    if ($selectweapon3panel.SelectedItem -match 'BattleAxe')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d8 Slashing"
        $Weapon3Weight = "4lb"
        $Weapon3Properties = "Versatile (1d10)"
    }
    if ($selectweapon3panel.SelectedItem -match 'Flail')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d8 Bludgeoning"
        $Weapon3Weight = "2lb"
        $Weapon3Properties = "One-Handed"
    }
    if ($selectweapon3panel.SelectedItem -match 'Great Axe')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d12 Slashing"
        $Weapon3Weight = "7lb"
        $Weapon3Properties = "Heavy, Two-Handed"
    }
    if ($selectweapon3panel.SelectedItem -match 'Great Sword')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "2d6 Slashing"
        $Weapon3Weight = "6lb"
        $Weapon3Properties = "Heavy, Two-Handed"
    }
    if ($selectweapon3panel.SelectedItem -match 'Halberd')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d10 Slashing"
        $Weapon3Weight = "6lb"
        $Weapon3Properties = "Heavy, Reach, Two-Handed"
    }
    if ($selectweapon3panel.SelectedItem -match 'Longsword')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d8 Slashing"
        $Weapon3Weight = "3lb"
        $Weapon3Properties = "Versatile (1d10)"
    }
    if ($selectweapon3panel.SelectedItem -match 'Maul')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "2d6 Bludgeoning"
        $Weapon3Weight = "10lb"
        $Weapon3Properties = "Heavy, Two-Handed"
    }
    if ($selectweapon3panel.SelectedItem -match 'MorningStar')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d8 Piercing"
        $Weapon3Weight = "4lb"
        $Weapon3Properties = "Two-Handed"
    }
    if ($selectweapon3panel.SelectedItem -match 'Rapier')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d8 Piercing"
        $Weapon3Weight = "2lb"
        $Weapon3Properties = "Finesse"
    }
    if ($selectweapon3panel.SelectedItem -match 'Sicimitar')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d6 Slashing"
        $Weapon3Weight = "3lb"
        $Weapon3Properties = "Finesse, Light"
    }
    if ($selectweapon3panel.SelectedItem -match 'ShortSword')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d6 Piercing"
        $Weapon3Weight = "2lb"
        $Weapon3Properties = "Finesse, Light"
    }
    if ($selectweapon3panel.SelectedItem -match 'Trident')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d6 Piercing"
        $Weapon3Weight = "4lb"
        $Weapon3Properties = "Thrown (range 20/60), Versatile (1d8)"
    }
    if ($selectweapon3panel.SelectedItem -match 'Warhammer')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d8 Bludgeoning"
        $Weapon3Weight = "2lb"
        $Weapon3Properties = "Versatile (1d10)"
    }
    if ($selectweapon3panel.SelectedItem -match 'DoomHammer')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d12 Bludgeoning"
        $Weapon3Weight = "10lb"
        $Weapon3Properties = "Heavy, Two-Handed"
    }
    if ($selectweapon3panel.SelectedItem -match 'Dual-Wield Staff')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d8 Budgeoning"
        $Weapon3Weight = "7lb"
        $Weapon3Properties = "Two-Handed, Light"
    }
    if ($selectweapon3panel.SelectedItem -match 'Broadsword')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d8 Piercing"
        $Weapon3Weight = "8lb"
        $Weapon3Properties = "Heavy, Two-Handed"
    }
    if ($selectweapon3panel.SelectedItem -match 'Steel Sword')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d8 Piercing"
        $Weapon3Weight = "8lb"
        $Weapon3Properties = "One-Handed"
    }
    if ($selectweapon3panel.SelectedItem -match 'Crossbow - Heavy')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d10 Piercing"
        $Weapon3Weight = "18lb"
        $Weapon3Properties = "Ammunition (range 30/120), light, loading"
    }
    if ($selectweapon3panel.SelectedItem -match 'Crossbow - Hand')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d6 Piercing"
        $Weapon3Weight = "3lb"
        $Weapon3Properties = "Ammunition (range 100/400), Heavy, Loading, Two-Handed"
    }
    if ($selectweapon3panel.SelectedItem -match 'Longbow')
    {
        $WPN3ATK_Bonus = "+4"
        $Weapon3Damage = "1d8 Piercing"
        $Weapon3Weight = "2lb"
        $Weapon3Properties = "Ammunition (range 150/600), Heavy, Two-Handed"
    }
#End of attack bonuses
#for a custom attack bonuse use:
#if ($chosenprimaryweapon.selectedItem -match 'Custom')
#{
#    $WPN*ATK_Bonus = "+0"
     #$Weapon*Damage = "0"
     #$Weapon*Weight = "0"
     #$Weapon*Properties = ""
#}
#Armour Class additions
$ArmourClass = 0

    if ($chosenArmour.SelectedItem -match 'Light Armour - Naked')
    {
      $ArmourClass = 1
      $ArmourClass
    }
    if ($chosenArmour.SelectedItem -match 'Light Armour - Padded')
    {
      $ArmourClass = 11
      $ArmourClass
    }
    if ($chosenArmour.SelectedItem -match 'Light Armour - Leather')
    {
      $ArmourClass = 11
      $ArmourClass
    }
    if ($chosenArmour.SelectedItem -match 'Light Armour - Studded Leather')
    {
      $ArmourClass = 12
      $ArmourClass
    }
    if ($chosenArmour.SelectedItem -match 'Medium Armour - Hide')
    {
      $ArmourClass = 12
      $ArmourClass
    }
    if ($chosenArmour.SelectedItem -match 'Medium Armour - Chain Shirt')
    {
      $ArmourClass = 13
      $ArmourClass
    }
    if ($chosenArmour.SelectedItem -match 'Medium Armour - Scale Mail')
    {
      $ArmourClass = 14
      $ArmourClass
    }
    if ($chosenArmour.SelectedItem -match 'Medium Armour - Breastplate')
    {
      $ArmourClass = 14
      $ArmourClass
    }
    if ($chosenArmour.SelectedItem -match 'Medium Armour - Half Plate')
    {
      $ArmourClass = 13
      $ArmourClass
    }
    if ($chosenArmour.SelectedItem -match 'Heavy Armour - Ring Mail')
    {
      $ArmourClass = 14
      $ArmourClass
    }
    if ($chosenArmour.SelectedItem -match 'Heavy Armour - Chain Mail')
    {
      $ArmourClass = 16
      $ArmourClass
    }
    if ($chosenArmour.SelectedItem -match 'Heavy Armour - Splint')
    {
      $ArmourClass = 17
      $ArmourClass
    }
    if ($chosenArmour.SelectedItem -match 'Heavy Armour - Plate')
    {
      $ArmourClass = 15
      $ArmourClass
    }
    if ($chosenArmour -eq [System.Windows.Forms.DialogResult]::Ignore)
    {
        $ArmourClass = "Unknown"
    }
    if ($chosenArmour -eq [System.Windows.Forms.DialogResult]::Retry)
    {
        return
    }
    if ($chosenArmour -eq [System.Windows.Forms.DialogResult]::Cancel)
    {
        Exit
    }
    if ($checkboxshield.Checked)
    {   
        $ArmourClassWithShield = "+2"
        $ArmourClassWithShield
    }
#End Armour Class additions
#Weight calculations
$CombinedWeaponStats = $Weapon1Properties + $Weapon2Properties + $Weapon3Properties
$TotalWeight = $Weapon1Weight + $Weapon2Weight + $Weapon3Weight + $ArmourWeight + $AdventuringGearWeight
$TotalEquiptment = $selectweapon1panel.SelectedItem + $Comma + $selectweapon2panel.SelectedItem + $Comma + $selectweapon3panel.SelectedItem + $Comma + $selectadventuinggearpanel.SelectedItem + $Comma + $SelectedPack
#Custom Backstory
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Sparks D&D Character Creator'
    $form.Size = New-Object System.Drawing.Size(800,605)
    $form.StartPosition = 'CenterScreen'
    $objIcon = New-Object system.drawing.icon (".\Assets\installer.ico")
    $form.Icon = $objIcon
 
    $objImage = [system.drawing.image]::FromFile(".\Assets\form_background.png")
    $form.BackgroundImage = $objImage
    $form.BackgroundImageLayout = "Center"
 
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(420,535)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'Next'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    $skipButton = New-Object System.Windows.Forms.Button
    $skipButton.Location = New-Object System.Drawing.Point(495,535)
    $skipButton.Size = New-Object System.Drawing.Size(75,23)
    $skipButton.Text = 'Skip'
    $skipButton.DialogResult = [System.Windows.Forms.DialogResult]::Ignore
    $form.AcceptButton = $skipButton
    $form.Controls.Add($skipButton)

    $backButton = New-Object System.Windows.Forms.Button
    $backButton.Location = New-Object System.Drawing.Point(570,535)
    $backButton.Size = New-Object System.Drawing.Size(75,23)
    $backButton.Text = 'Back'
    $backButton.DialogResult = [System.Windows.Forms.DialogResult]::Retry
    $form.CancelButton = $backButton
    $form.Controls.Add($backButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(645,535)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

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

    $form.Topmost = $true
        if ($characterbackstoryformdialog -eq [System.Windows.Forms.DialogResult]::OK)
        {
            $characterbackstory = $characterbackstory.Text
            $characterbackstory

            $PersonalityTraits = $PersonalityTraits.Text
            $PersonalityTraits

            $Ideals = $Ideals.Text
            $Ideals

            $Bonds = $Bonds.Text
            $Bonds

            $Flaws = $Flaws.Text
            $Flaws

        }
        if ($characterbackstoryformdialog -eq [System.Windows.Forms.DialogResult]::Ignore)
        {
            $characterbackstory = "Unknown"
            $PersonalityTraits = "Unknown"
            $Ideals = "Unknown"
            $Bonds = "Unknown"
            $Flaws = "Unknown"
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
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Sparks D&D Character Creator'
    $form.Size = New-Object System.Drawing.Size(790,620)
    $form.StartPosition = 'CenterScreen'
    $objIcon = New-Object system.drawing.icon (".\Assets\installer.ico")
    $form.Icon = $objIcon

    $objImage = [system.drawing.image]::FromFile(".\Assets\form_background.png")
    $form.BackgroundImage = $objImage
    $form.BackgroundImageLayout = "Center"

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(420,545)
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'Next'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    $skipButton = New-Object System.Windows.Forms.Button
    $skipButton.Location = New-Object System.Drawing.Point(495,545)
    $skipButton.Size = New-Object System.Drawing.Size(75,23)
    $skipButton.Text = 'Skip'
    $skipButton.DialogResult = [System.Windows.Forms.DialogResult]::Ignore
    $form.AcceptButton = $skipButton
    $form.Controls.Add($skipButton)

    $backButton = New-Object System.Windows.Forms.Button
    $backButton.Location = New-Object System.Drawing.Point(570,545)
    $backButton.Size = New-Object System.Drawing.Size(75,23)
    $backButton.Text = 'Back'
    $backButton.DialogResult = [System.Windows.Forms.DialogResult]::Retry
    $form.CancelButton = $backButton
    $form.Controls.Add($backButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(645,545)
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

    $alliesandorganisationslabel = New-Object System.Windows.Forms.Label
    $alliesandorganisationslabel.Location = New-Object System.Drawing.Point(10,20)
    $alliesandorganisationslabel.Size = New-Object System.Drawing.Size(220,18)
    $alliesandorganisationslabel.Text = 'Write about your Allies and Organisations:'
    $form.Controls.Add($alliesandorganisationslabel)

    $alliesandorganisations = New-Object System.Windows.Forms.TextBox
    $alliesandorganisations.Location = New-Object System.Drawing.Point(10,40)
    $alliesandorganisations.Size = New-Object System.Drawing.Size(360,480)
    $alliesandorganisations.Multiline = 1
    $alliesandorganisations.ScrollBars = 2
    $alliesandorganisations.AcceptsReturn = 1
    $form.Controls.Add($alliesandorganisations)

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

    $factionslabel = New-Object System.Windows.Forms.Label
    $factionslabel.Location = New-Object System.Drawing.Point(10,530)
    $factionslabel.Size = New-Object System.Drawing.Size(220,18)
    $factionslabel.Text = 'Faction Name:'
    $form.Controls.Add($factionslabel)

    $factionname = New-Object System.Windows.Forms.TextBox
    $factionname.Location = New-Object System.Drawing.Point(10,550)
    $factionname.Size = New-Object System.Drawing.Size(360,20)
    $factionname.AcceptsReturn = 1
    $form.Controls.Add($factionname)

    $form.Topmost = $true
        if ($characterextraformdialog -eq [System.Windows.Forms.DialogResult]::OK)
        {
            $alliesandorganisations = $alliesandorganisations.Text
            $alliesandorganisations

            $AddionalfeatTraits = $AddionalfeatTraits.Text
            $AddionalfeatTraits

            $factionname = $factionname.Text
            $factionname
        }
        if ($characterextraformdialog -eq [System.Windows.Forms.DialogResult]::Ignore)
        {
            $AddionalfeatTraits = "Unknown"
            $alliesandorganisations = "Unknown"
            $factionname = "Unknown"
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
        'ClassLevel' = $ClassLevel;
        'PlayerName' = $playername.Text;
        'CharacterName' = $charactername.Text;
        'Background' = $characterbackgroundselect.SelectedItem;
        'Race ' = $ExportRace;
        'Alignment' = $ChosenAlignment.SelectedItem;
        'XP' = $XP;
        'Inspiration' = $Inspiration;
        'STR' = $STR;
        'ProfBonus' = $ProficencyBonus;
        'AC' = $ArmourClass;
        'Initiative' = $InitiativeTotal;
        'Speed' = $SpeedTotal;
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
        'Wpn Name' = $selectweapon1panel.SelectedItem;
        'Wpn1 AtkBonus' = $WPN1ATK_Bonus;
        'Wpn1 Damage' = $Weapon1Damage;
        'Insight' = $Insight;
        'Intimidation' = $Intimidation;
        'Wpn Name 2' = $selectweapon2panel.SelectedItem;
        'Wpn2 AtkBonus ' = $WPN2ATK_Bonus;
        'Wpn Name 3' = $selectweapon3panel.SelectedItem;
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
        'Features and Traits' = $RacialSpecialAbility;
        'CharacterName 2' = $charactername.Text;
        'Age' = $age.Text;
        'Height' = $Playerheight;
        'Weight' = $PlayerSize;
        'Eyes' = $characterfeaturesselecteyes.SelectedItem;
        'Skin' = $characterfeaturesselectskin.SelectedItem;
        'Hair' = $characterfeaturesselecthair.SelectedItem;
        'CHARACTER IMAGE' = $CharacterImage;
        'Faction Symbol Image' = $FactionSymbol;
        'Allies' = $alliesandorganisations.Text;
        'FactionName' = $factionname.Text;
        'Backstory' = $characterbackstory.Text;
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
    InputPdfFilePath = ".\Assets\Empty_PDF\DnD_5E_CharacterSheet - Form Fillable.pdf"
    ITextSharpLibrary = '.\Assets\iText\itextsharp.dll'
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
#Script Created By (Sparks Skywere) - Christopher Masters

#~Friends Notes:~

# Hey Sparks, 
# Nice code you've got here >:3
# - Quasar <3