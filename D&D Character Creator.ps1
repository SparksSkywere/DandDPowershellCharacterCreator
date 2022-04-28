clear-host
#Sparks's D&D Character Creator powershell script, this is intended for fun and feel free to edit fields for future use but please keep me credited
#This is a powershell produced program, it is written in C#
#Due to the way paths are written in some parts this script is tied to Windows ONLY
#Remember to comment/remove all "Write-Output" statements as this is only for testing purposes
#This powershell script follows original 5E rules, the website to get the information is:
#https://www.dndbeyond.com/sources/basic-rules

#IF YOU HAVEN'T PLEASE READ THE RULEBOOK FOR D&D AS THIS POWERSHELL SCRIPT JUST SIMPLIFIES MAKING A CHARACTER
#CURRENTLY INDEV SO EXPECT ISSUES / BUGS OR DESIGN WEIRDNESS

#Further down the script you see $value.statement = New-Object System.Drawing.Size(240,50)
#The (240,50) means width,height for incase you forget
#(10,50) 50 = up/down, 10 = left/right - Orientation 
#Every part of the powershell script is changable, this is for custom games, hence why things aren't grouped together
#Majority of the stats used came from the cards for D&D

# Hey Sparks, 
# Nice code you've got here >:3
# - Quasar <3

#START OF THE POWERSHELL SCRIPT
#Hide powershell's console so only the forms show, only unhide during development
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

#Copy PDF Module + Import PDF Reader/Editor
Import-Module -Name .\Assets\iText\PDFForm | Out-Null
Add-Type -Path ".\Assets\iText\itextsharp.dll"

#Some default value's for later in the script, this is to fill out empty fields / references for later code
#DO NOT MODIFY THE DEFAULT VALUE'S, EVEN IF YOU DO IT WOULDN'T SAVE AT THE END UPON CHOOSING STATS
#These values can also be used for indexing
#Do not delete any of the values as they are needed
#-Basic Character Information-
$charactername = "No-Name"
$playername = "No-Name"
$age = "Unknown"
$characterbackground = "Unknown"
#-Character Stats-
$ChosenRace = "None Selected"
$ChosenSubRace = "None Selected"
$RaceDescription = "Unknown"
$RacialTraits = "Unknown"
$RacialSpecialAbility = "Unknown"
$PersonalityTraits = "Unknown"
$ProficencyBonus = "+0"
$ClassLevel = "N/A"
$Ideals = "Unknown"
$Bonds = "Unknown"
$Flaws = "Unknown"
$HP = "0"
$SpeedTotal = "0"
$RaceLifeTime = "Unknown"
$PlayerSize = "Unknown"
$Playerheight = "Unknown"
$STR = "0"
$DEX = "0"
$CON = "0"
$INT = "0"
$WIS = "0"
$CHA = "0"
$Skills = "Unknown"
$Senses = "Unknown"
$SpokenLanguages = "Unknown"
$ChosenClass = "None Selected"
$ChosenSubClass = "None Selected"
$ChosenAlignment = "None Selected"
$InitiativeTotal = "0"
$Damage_Immunities = "Unknown"
$Condition_Immunities = "Unknown"
$Racesavingrolls = "0"
#-Weapon Stats-
$ATK_Bonus = "0"
$selectedweapon1 = "Unknown"
$selectedweapon2 = "Unknown"
$selectedweapon3 = "Unknown"
$CombinedWeaponStats = "Null"
$ChosenArmour = "Unknown"
$ArmourClass = "0"
$checkboxshield = "Unknown"
$ArmourClassWithShield = "Unknown"
$Totalweaponweight = "0"
#-Extra-
$HitDiceTotal = "0"
$Gold = "10"
$XP = "1"
$Inspiration = "1"

#Checkbox Death saves test
$Check12 = 'Yes'
$Check13 = 'Yes'
$Check14 = 'Yes'
$Check15 = 'Yes'
$Check16 = 'Yes'
$Check17 = 'Yes'

#Checkbox Saving throws
$Check11 = 'Yes'
$Check18 = 'Yes'
$Check19 = 'Yes'
$Check20 = 'Yes'
$Check21 = 'Yes'
$Check22 = 'Yes'

#Checkbox Skills
$Check23 = 'Yes' 
$Check24 = 'Yes'
$Check25 = 'Yes'
$Check26 = 'Yes'
$Check27 = 'Yes'
$Check28 = 'Yes'
$Check29 = 'Yes'
$Check30 = 'Yes'
$Check31 = 'Yes'
$Check32 = 'Yes'
$Check33 = 'Yes'
$Check34 = 'Yes'
$Check35 = 'Yes'
$Check36 = 'Yes'
$Check37 = 'Yes'
$Check38 = 'Yes'
$Check39 = 'Yes'
$Check40 = 'Yes'

#End of default value's
#Basic user information gathering - Basic Information
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

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
    $okButton.Text = 'OK'
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
    $form.Controls.Add($charactername)
    $form.Topmost = $true

    $playerlabel = New-Object System.Windows.Forms.Label
    $playerlabel.Location = New-Object System.Drawing.Point(10,67)
    $playerlabel.Size = New-Object System.Drawing.Size(100,18)
    $playerlabel.Text = 'Player Name:'
    $form.Controls.Add($playerlabel)

    $playername = New-Object System.Windows.Forms.TextBox
    $playername.Location = New-Object System.Drawing.Point(10,85)
    $playername.Size = New-Object System.Drawing.Size(180,20)
    $playername.MaxLength = 30
    $form.Controls.Add($playername)
    $form.Topmost = $true

    $ageform = New-Object System.Windows.Forms.Label
    $ageform.Location = New-Object System.Drawing.Point(10,108)
    $ageform.Size = New-Object System.Drawing.Size(50,18)
    $ageform.Text = 'Age:'
    $form.Controls.Add($ageform)

    $age = New-Object System.Windows.Forms.TextBox
    $age.Location = New-Object System.Drawing.Point(10,127)
    $age.Size = New-Object System.Drawing.Size(58,20)
    $age.MaxLength = 5
    $form.Controls.Add($age)
    $form.Topmost = $true
    $age.Add_TextChanged({
        $age.Text = $age.Text -replace '\D'})
    
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
#Basic user information gathering - Background
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

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
    $okButton.Text = 'OK'
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
    $characterbackgroundselect.Location = New-Object System.Drawing.Point(10,50)
    $characterbackgroundselect.Size = New-Object System.Drawing.Size(260,65)
    $characterbackgroundselect.Height = 170

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

    #To add custom player backgrounds you can either type in the box provided
    #If you wish to set only pre-generated backgrounds use this:
    #$characterbackgroundgenerated.Items.Add('custom')
    #you may also comment out the "$characterbackgroundtextbox = $form.ShowDialog()"

    $form.Controls.Add($characterbackgroundselect)
    $form.Controls.AddRange($characterbackgroundselect)
    $form.Topmost = $true
    $Form.Add_Shown({$Form.Activate()})
    if ($characterbackgroundtextbox -eq [System.Windows.Forms.DialogResult]::OK)
    {
        $chosenbackground = $characterbackgroundselect.SelectedItem
        $chosenbackground
    }
    if ($characterbackgroundtextbox -eq [System.Windows.Forms.DialogResult]::Ignore)
    {
        $characterbackgroundselect = "Unknown"
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
#end of Background

#Basic user information gathering - Race
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

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
    $okButton.Text = 'OK'
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
    $label.Size = New-Object System.Drawing.Size(118,18)
    $label.Text = 'Please select a Race:'
    $form.Controls.Add($label)

    $ChosenRace = New-Object System.Windows.Forms.ListBox
    $ChosenRace.Location = New-Object System.Drawing.Point(10,40)
    $ChosenRace.Size = New-Object System.Drawing.Size(200,20)
    $ChosenRace.Height = 200

    $pictureBox = new-object Windows.Forms.PictureBox
    $pictureBox.Location = New-Object System.Drawing.Point(300,40)
    $pictureBox.Size = New-Object System.Drawing.Size(200,20)
    #$pictureBox.Width = $img.Size.Width
    #$pictureBox.Height = $img.Size.Height
    $pictureBox.Image = $img
    $form.controls.add($pictureBox)

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
        #$ChosenRace.Items.Add('Custom')
        #You need to also add a race description if you wish other players to use it
        #Along with a race picture, this is all in the "Assets" folder

        #TO DO! Add hover text for each race
        #Test hover

        #IF statements ONLY for after selecting

    $form.Controls.Add($ChosenRace)
    $form.Topmost = $true
    
    #if ($ -match 'Dragonborn')
    #{
    #    $img = [System.Drawing.Image]::Fromfile('.\Assets\Race_Pictures\Dragonborn.png')
    #    Add-Content -path ".\Assets\Race_Descriptions\Dragonborn.txt"
    #}

    #Add this feature above, where you select from the list and an image + text loads
    #The race index can be fitted with selection data such as gold or speed
    #Please add all speed bonuses to match either class and race
    
    if ($racetype -eq [System.Windows.Forms.DialogResult]::OK)
    {
        $selectedrace = $ChosenRace.SelectedItem
        $selectedrace
    }
    if ($racetype -eq [System.Windows.Forms.DialogResult]::Ignore)
    {
        $selectedrace = "N/A"
        $selectedrace
    }
    $racetype = $form.ShowDialog()
    if ($racetype -eq [System.Windows.Forms.DialogResult]::Retry)
    {
        return
    }
    if ($racetype -eq [System.Windows.Forms.DialogResult]::Cancel)
    {
        Exit
    }

#End of race selection

#Make sure to fill out ALL required subrace data as there is a lot of subraces per primary
#race, this allows a waaay bigger pool of characters

#Small race choices like skin and hair
#Reference: https://www.dandwiki.com/wiki/Random_Hair_and_Eye_Color_(DnD_Other)
#Start of race features
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

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
    $okButton.Text = 'OK'
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
#Basic user information gathering - SubRace
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

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
    $okButton.Text = 'OK'
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
    }
    if ($ChosenRace.SelectedItem -match 'Leonin')
    {
        $ChosenSubRace.Items.Add('Leonin') | Out-Null
    }
    if ($ChosenRace.SelectedItem -match 'Satyr')
    {
        $ChosenSubRace.Items.Add('Satyr') | Out-Null
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
    }
    if ($ChosenRace.SelectedItem -match 'Firbolg')
    {
        $ChosenSubRace.Items.Add('Firbolg') | Out-Null
    }
    if ($ChosenRace.SelectedItem -match 'Goblin')
    {
        $ChosenSubRace.Items.Add('Goblin') | Out-Null
    }
    if ($ChosenRace.SelectedItem -match 'Hobgoblin')
    {
        $ChosenSubRace.Items.Add('Hobgoblin') | Out-Null
        $ChosenSubRace.Items.Add('Hobgoblin Captain') | Out-Null
    }
    if ($ChosenRace.SelectedItem -match 'Kenku')
    {
        $ChosenSubRace.Items.Add('Kenku') | Out-Null
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
    }
    if ($ChosenRace.SelectedItem -match 'Centaur')
    {
        $ChosenSubRace.Items.Add('Centaur') | Out-Null
    }
    if ($ChosenRace.SelectedItem -match 'Loxodon')
    {
        $ChosenSubRace.Items.Add('Loxodon') | Out-Null
    }
    if ($ChosenRace.SelectedItem -match 'Minotaur')
    {
        $ChosenSubRace.Items.Add('Minotaur') | Out-Null
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
    }
    if ($ChosenRace.SelectedItem -match 'Troll')
    {
        $ChosenSubRace.Items.Add('Troll') | Out-Null
    }
    if ($ChosenRace.SelectedItem -match 'Ogre')
    {
        $ChosenSubRace.Items.Add('Ogre') | Out-Null
    }
    if ($ChosenRace.SelectedItem -match 'Wolf')
    {
        $ChosenSubRace.Items.Add('Wolf') | Out-Null
        $ChosenSubRace.Items.Add('Winter Wolf') | Out-Null
        $ChosenSubRace.Items.Add('Timber Wolf') | Out-Null
    }
    
    if ($subracetype -eq [System.Windows.Forms.DialogResult]::OK)
    {
        $selectedsubrace = $ChosenSubRace.SelectedItem
        $selectedsubrace
    }
    if ($subracetype -eq [System.Windows.Forms.DialogResult]::Ignore)
    {
        $selectedsubrace = "N/A"
        $selectedsubrace
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
#
#}

#Basic user information gathering - Primary Class
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

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
    $okButton.Text = 'OK'
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
    $label.Size = New-Object System.Drawing.Size(170,18)
    $label.Text = 'Please select a Primary Class:'
    $form.Controls.Add($label)

    $ChosenClass = New-Object System.Windows.Forms.ListBox
    $ChosenClass.Location = New-Object System.Drawing.Point(10,40)
    $ChosenClass.Size = New-Object System.Drawing.Size(200,20)
    $ChosenClass.Height = 200

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

    #To add a custom class use: #$ChosenClass.Items.Add('CUSTOM')

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
    $form.Topmost = $true

    if ($chosencharacter -eq [System.Windows.Forms.DialogResult]::OK)
    {
        $SelectedClass = $ChosenClass.SelectedItem
        $SelectedClass
    }
    if ($chosencharacter -eq [System.Windows.Forms.DialogResult]::Ignore)
    {
        $ChosenClass = "None Selected"
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
    #    $ChosenClassCustom
    #}

#end of class selection
#For future reference, setup the chosen class then tells the rest of the document what you can and cant select with IF statements
#This will mean that this powershell script is going to get BIG, but worth it!
#Make sure whaterver you set needs to be followed to the characterarray

#Basic user information gathering - SubClass
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

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
    $okButton.Text = 'OK'
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

    #Subclass Lists, all split up to only match a primary class list
    #Post any class stats here that are needed as this is the best place for the information to go to

    $form.Topmost = $true
    
    if ($ChosenClass.SelectedItem -match 'Artificer')
    {
        $form.Controls.Add($Chosensubclass)        
            $Chosensubclass.Items.Add('Alchemist') | Out-Null
            $Chosensubclass.Items.Add('Armorer') | Out-Null
            $Chosensubclass.Items.Add('Artillerist') | Out-Null
            $Chosensubclass.Items.Add('Battle Smith') | Out-Null
            $HitDiceTotal = "d12"
            $ClassLevel = "Artificer 1"
            
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
            $HitDiceTotal = "d12"
            $ClassLevel = "Barbarian 1"
            
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
            $HitDiceTotal = "d8"
            $ClassLevel = "Bard 1"
            
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
            $HitDiceTotal = "d8"
            $ClassLevel = "Cleric 1"
            
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
            $HitDiceTotal = "d8"
            $ClassLevel = "Druid 1"
            
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
            $HitDiceTotal = "d10"
            $ClassLevel = "Fighter 1"
            
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
            $HitDiceTotal = "d8"
            $ClassLevel = "Monk 1"
            
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
            $HitDiceTotal = "d10"
            $ClassLevel = "Paladin 1"
            
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
            $HitDiceTotal = "d10"
            $ClassLevel = "Ranger 1"
            
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
            $HitDiceTotal = "d8"
            $ClassLevel = "Rogue 1"
            
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
            $HitDiceTotal = "d6"
            $ClassLevel = "Sorcerer 1"
            
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
            $HitDiceTotal = "d8"
            $ClassLevel = "Warlock 1"
            
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
            $HitDiceTotal = "d6"
            $ClassLevel = "Wizard 1"
            
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
        #    $subclass = $form.ShowDialog()
        #}    

#End of subclass selection

#Alignment Choice
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

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
    $okButton.Text = 'OK'
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
    $label.Text = 'Please select an Alignment:'
    $form.Controls.Add($label)

    $ChosenAlignment = New-Object System.Windows.Forms.ListBox
    $ChosenAlignment.Location = New-Object System.Drawing.Point(10,40)
    $ChosenAlignment.Size = New-Object System.Drawing.Size(200,20)
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
        #$ChosenAlignment.Items.Add('Custom')
        #You need to also add a race description if you wish other players to use it
        #Along with a race picture, this is all in the "Assets" folder
        #Alignment can also be just a race trait, potentially pulling out choice?
        #TO DO! Add hover text for each race

    $form.Controls.Add($ChosenAlignment)
    $form.Topmost = $true
    
    if ($alignmenttype -eq [System.Windows.Forms.DialogResult]::OK)
    {
        $selectedalignment = $ChosenAlignment.SelectedItem
        $selectedalignment
    }
    if ($alignmenttype -eq [System.Windows.Forms.DialogResult]::Ignore)
    {
        $ChosenAlignment = "None Selected"
    }
    $alignmenttype = $form.ShowDialog()
    if ($alignmenttype -eq [System.Windows.Forms.DialogResult]::Retry)
    {
        return
    }
    if ($alignmenttype -eq [System.Windows.Forms.DialogResult]::Cancel)
    {
        Exit
    }
    
#End of Alignment Choice

#Armour + Shield Selection
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

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
    $okButton.Text = 'OK'
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
    $label.Size = New-Object System.Drawing.Size(220,18)
    $label.Text = 'Please select Armour you wish to wear:'
    $form.Controls.Add($label)

    $ChosenArmour = New-Object System.Windows.Forms.ListBox
    $ChosenArmour.Location = New-Object System.Drawing.Point(10,40)
    $ChosenArmour.Size = New-Object System.Drawing.Size(220,20)
    $ChosenArmour.Height = 200

    $checkboxshield = new-object System.Windows.Forms.checkbox
    $checkboxshield.Location = new-object System.Drawing.Size(25,245)
    $checkboxshield.Size = new-object System.Drawing.Size(120,32)
    $checkboxshield.Text = "Do you want a shield?"
    $checkboxshield.Checked = $false
    
    #Armour List
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

    #make these armours assigned to a specific class
    #this can be altered using abilities too

    $form.Controls.Add($ChosenArmour)
    $Form.controls.AddRange(@($checkboxshield))
    $form.Topmost = $true
    $Form.Add_Shown({$Form.Activate()})
    
    #Shield as an option with tickbox, completely optional to a player
    $checkboxshield.Add_CheckStateChanged({
        $checkboxshield.Enabled = $checkboxshield.Checked 
    })
    $Armourtype = $form.ShowDialog()
    if ($Armourtype -eq [System.Windows.Forms.DialogResult]::OK)
    {
        $SelectedArmour = $ChosenArmour.SelectedItem
        $SelectedArmour
    }
    if ($Armourtype -eq [System.Windows.Forms.DialogResult]::Ignore)
    {
        $ChosenArmour = "None Selected"
    }
    if ($Armourtype -eq [System.Windows.Forms.DialogResult]::Retry)
    {
        return
    }
    if ($Armourtype -eq [System.Windows.Forms.DialogResult]::Cancel)
    {
        Exit
    }
#End of armour and shields
#remember these types of armour are affected with cost, armour class, strength, stealth and weight
#There is one type of shield with a base code of 10gp, armour class of +2 and weight of 453g
#Getting out of armour has times for "DON" and "DOFF" DON = Put on, DOff = Take off
#Light armour has a don of 1 min and doff of 1 min
#Medium armour has a don of 5 mins and doff of 1 min
#Heavy armour has a don of 10 mins and a doff off 5mins
#shield has a don of 1 action and doff of 1 action

#end of armour type selection

#Filling out final details from selected above
if ($ChosenRace.SelectedItem -match 'Dragonborn')
    {
        #Race Stats
        $ChosenRaceDragonborn = $ChosenRaceDragonborn.SelectedItem 
        $ChosenRace = "Dragonborn"
        $HP = "20"
        $SpeedTotal = "30"
        $RaceLifeTime = "80 Years"
        $PlayerSize = "250 Pounds, Medium"
        $Playerheight = "6 Feet"

        #Saving Throws Attributes
        $ST_STR = "2456"
        $ST_DEX = "5"
        $ST_CON = "262"
        $ST_INT = "765"
        $ST_WIS = "987"
        $ST_CHA = "6557"

        #Saving Throws Tickbox's
        

        #Attributes Basic
        $STR = "99"
        $DEX = "0"
        $CON = "50"
        $INT = "30"
        $WIS = "03"
        $CHA = "01"

        #Attribute Modifiers
        $STRmod = "99"
        $DEXmod = "40"
        $CONmod = "65"
        $INTmod = "01"
        $WISmod = "25"
        $CHAmod = "71"

        #Skills Values


        #Skills Tickbox's

        #RaceExtra's
        $Senses = "Unknown"
        $Damage_Immunities = "Unknown"
        $Condition_Immunities = "Unknown"
        $Racesavingrolls = "0"

        $RaceDescription = Get-Content .\Assets\Races\Dragonborn.json | ConvertFrom-Json
        $RaceDescription | Select-Object -Property 'description'

        $SpokenLanguages = "You can speak, read, and write Common and Draconic. Draconic is thought to be one of the oldest languages and is often used in the study of magic. The language sounds harsh to most other creatures and includes numerous hard consonants and sibilants."

        $RacialSpecialAbility = "Breath Weapon, You can use your action to exhale destructive energy. Your draconic ancestry determines the size, shape, and damage type of the exhalation. When you use your breath weapon, each creature in the area of the exhalation must make a saving throw, the type of which is determined by your draconic ancestry. The DC for this saving throw equals 8 and your Constitution modifier and your proficiency bonus. A creature takes 2d6 damage on a failed save, and half as much damage on a successful one. The damage increases to 3d6 at 6th level, 4d6 at 11th level, and 5d6 at 16th level. After you use your breath weapon, you cant use it again until you complete a short or long rest."
        $CharacterImage = '.\Assets\Race_Pictures\Dragonborn.png'

        #Personality
        $PersonalityTraits = "Test_Personality"
        $Ideals = "Not Ideal"
        $Bonds = "Unknown"
        $Flaws = "Unknown"

    }
    if ($ChosenRace.SelectedItem -match 'Dwarf')
    {
        $ChosenRaceDwarf = $ChosenRaceDwarf.SelectedItem 
        $ChosenRaceDwarf

        $HP = "0"
        $HP

        $SpeedTotal = "25"
        $SpeedTotal

        $RaceLifeTime = "400 Years"
        $RaceLifeTime

        $PlayerSize = "150 Pounds, Medium"
        $PlayerSize

        $Playerheight = "5 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "You can speak, read, and write Common and Dwarvish. Dwarvish is full of hard consonants and guttural sounds, and those characteristics spill over into whatever other language a dwarf might speak."

        $RaceDescription = "Kingdoms rich in ancient grandeur, halls carved into the roots of mountains, the echoing of picks and hammers in deep mines and blazing forges, a commitment to clan and tradition, and a burning hatred of goblins and orcs, these common threads unite all dwarves."
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

        $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Elf')
    {
        $ChosenRaceElf = $ChosenRaceElf.SelectedItem 
        $ChosenRaceElf

        $HP = "0"
        $HP

        $SpeedTotal = "30"
        $SpeedTotal

        $RaceLifeTime = "750 Years"
        $RaceLifeTime

        $PlayerSize = "Slender Builds, Medium"
        $PlayerSize

        $Playerheight = "6 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "You can speak, read, and write Common and Elvish. Elvish is fluid, with subtle intonations and intricate grammar. Elven literature is rich and varied, and their songs and poems are famous among other races. Many bards learn their language so they can add Elvish ballads to their repertoires."

        $RaceDescription = "Elves are a magical people of otherworldly grace, living in the world but not entirely part of it. They live in places of ethereal beauty, in the midst of ancient forests or in silvery spires glittering with faerie light, where soft music drifts through the air and gentle fragrances waft on the breeze. Elves love nature and magic, art and artistry, music and poetry, and the good things of the world."
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

        $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Gnome')
    {
        $ChosenRaceGnome = $ChosenRaceGnome.SelectedItem 
        $ChosenRaceGnome

        $HP = "0"
        $HP

        $SpeedTotal = "25"
        $SpeedTotal

        $RaceLifeTime = "500 Years"
        $RaceLifeTime

        $PlayerSize = "40 Pounds, Small"
        $PlayerSize

        $Playerheight = "4 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls


        $SpokenLanguages = "You can speak, read, and write Common and Gnomish. The Gnomish language, which uses the Dwarvish script, is renowned for its technical treatises and its catalogs of knowledge about the natural world."

        $RaceDescription = "A constant hum of busy activity pervades the warrens and neighborhoods where gnomes form their close knit communities. Louder sounds punctuate the hum: a crunch of grinding gears here, a minor explosion there, a yelp of surprise or triumph, and especially bursts of laughter. Gnomes take delight in life, enjoying every moment of invention, exploration, investigation, creation, and play."
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

        $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Half-Elf')
    {
        $ChosenRaceHalf_Elf = $ChosenRaceHalf_Elf.SelectedItem 
        $ChosenRaceHalf_Elf

        $HP = "0"
        $HP

        $SpeedTotal = "30"
        $SpeedTotal

        $RaceLifeTime = "180"
        $RaceLifeTime

        $PlayerSize = "Varies On Build, Medium"
        $PlayerSize

        $Playerheight = "6 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "You can speak, read, and write Common, Elvish, and one extra language of your choice."

        $RaceDescription = "Walking in two worlds but truly belonging to neither, half elves combine what some say are the best qualities of their elf and human parents: human curiosity, inventiveness, and ambition tempered by the refined senses, love of nature, and artistic tastes of the elves. Some half elves live among humans, set apart by their emotional and physical differences, watching friends and loved ones age while time barely touches them. Others live with the elves, growing restless as they reach adulthood in the timeless elven realms, while their peers continue to live as children. Many half elves, unable to fit into either society, choose lives of solitary wandering or join with other misfits and outcasts in the adventuring life."
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

        $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Halfling')
    {
        $ChosenRaceHalfling = $ChosenRaceHalfling.SelectedItem 
        $ChosenRaceHalfling

        $HP = "0"
        $HP

        $SpeedTotal = "25"
        $SpeedTotal

        $RaceLifeTime = "200"
        $RaceLifeTime

        $PlayerSize = "40 Pounds, Small"
        $PlayerSize

        $Playerheight = "3 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "You can speak, read, and write Common and Halfling. The Halfling language isnt secret, but halflings are loath to share it with others. They write very little, so they dont have a rich body of literature. Their oral tradition, however, is very strong. Almost all halflings speak Common to converse with the people in whose lands they dwell or through which they are traveling."

        $RaceDescription = "The comforts of home are the goals of most halflings lives: a place to settle in peace and quiet, far from marauding monsters and clashing armies; a blazing fire and a generous meal; fine drink and fine conversation. Though some halflings live out their days in remote agricultural communities, others form nomadic bands that travel constantly, lured by the open road and the wide horizon to discover the wonders of new lands and peoples. But even these wanderers love peace, food, hearth, and home, though home might be a wagon jostling along a dirt road or a raft floating downriver."
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

        $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Half-Orc')
    {
        $ChosenRaceHalf_Orc = $ChosenRaceHalf_Orc.SelectedItem 
        $ChosenRaceHalf_Orc

        $HP = "0"
        $HP
        
        $SpeedTotal = "30"
        $SpeedTotal

        $RaceLifeTime = "75"
        $RaceLifeTime

        $PlayerSize = "Larger Than Humans, Medium"
        $PlayerSize

        $Playerheight = "6 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "You can speak, read, and write Common and Orc. Orc is a harsh, grating language with hard consonants. It has no script of its own but is written in the Dwarvish script."

        $RaceDescription = "Whether united under the leadership of a mighty warlock or having fought to a standstill after years of conflict, orc and human tribes sometimes form alliances, joining forces into a larger horde to the terror of civilized lands nearby. When these alliances are sealed by marriages, half orcs are born. Some half orcs rise to become proud chiefs of orc tribes, their human blood giving them an edge over their full blooded orc rivals. Some venture into the world to prove their worth among humans and other more civilized races. Many of these become adventurers, achieving greatness for their mighty deeds and notoriety for their barbaric customs and savage fury."
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

        $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Human')
    {
        $ChosenRaceHuman = $ChosenRaceHuman.SelectedItem 
        $ChosenRaceHuman

        $HP = "0"
        $HP
        
        $SpeedTotal = "30"
        $SpeedTotal

        $RaceLifeTime = "100"
        $RaceLifeTime

        $PlayerSize = "Varies On Build, Medium"
        $PlayerSize

        $Playerheight = "6 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "You can speak, read, and write Common and one extra language of your choice. Humans typically learn the languages of other peoples they deal with, including obscure dialects. They are fond of sprinkling their speech with words borrowed from other tongues: Orc curses, Elvish musical expressions, Dwarvish military phrases, and so on."

        $RaceDescription = "In the reckonings of most worlds, humans are the youngest of the common races, late to arrive on the world scene and short, lived in comparison to dwarves, elves, and dragons. Perhaps it is because of their shorter lives that they strive to achieve as much as they can in the years they are given. Or maybe they feel they have something to prove to the elder races, and thats why they build their mighty empires on the foundation of conquest and trade. Whatever drives them, humans are the innovators, the achievers, and the pioneers of the worlds."
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

        $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Tiefling')
    {
        $ChosenRaceTiefling = $ChosenRaceTiefling.SelectedItem 
        $ChosenRaceTiefling

        $HP = "0"
        $HP
        
        $SpeedTotal = "30"
        $SpeedTotal

        $RaceLifeTime = "150"
        $RaceLifeTime

        $PlayerSize = "Varies On Build, Medium"
        $PlayerSize

        $Playerheight = "6 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "You can speak, read, and write Common and Infernal."

        $RaceDescription = "To be greeted with stares and whispers, to suffer violence and insult on the street, to see mistrust and fear in every eye: this is the lot of the tiefling. And to twist the knife, tieflings know that this is because a pact struck generations ago infused the essence of Asmodeus overlord of the Nine Hells, into their bloodline. Their appearance and their nature are not their fault but the result of an ancient sin, for which they and their children and their childrens children will always be held accountable."
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

        $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Orc')
    {
        $ChosenRaceOrc = $ChosenRaceOrc.SelectedItem 
        $ChosenRaceOrc

        $HP = "0"
        $HP
        
        $SpeedTotal = "30"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "Common, Orc"

        $RaceDescription = ""
        $RaceDescription

        $RacialTraits = "Aggressive. As a bonus action, the orc can move up to its speed toward a hostile creature that it can see."
        $RacialTraits

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

        $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Leonin')
    {
        $ChosenRaceLeonin = $ChosenRaceLeonin.SelectedItem 
        $ChosenRaceLeonin

        $HP = "0"
        $HP
        
        $SpeedTotal = "0"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = ""

        $RaceDescription = ""
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

        $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Satyr')
    {
        $ChosenRaceSatyr = $ChosenRaceSatyr.SelectedItem 
        $ChosenRaceSatyr
        
        $HP = "31"
        $HP
        
        $SpeedTotal = "40"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "+1"
        $DEX = "+3"
        $CON = "+0"
        $INT = "+1"
        $WIS = "+0"
        $CHA = "+2"

        $Skills = "Perception +2, Performance +6, Stealth +5"
        $Skills

        $Senses = "Passive Perception 12"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "Common, Elvish, Sylvan"

        $RaceDescription = "Unknown"
        $RaceDescription

        $RacialSpecialAbility = "Magic Resistance"
        $RacialSpecialAbility

        $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Fairy')
    {
        $ChosenRaceFairy = $ChosenRaceFairy.SelectedItem 
        $ChosenRaceFairy
        
        $HP = "0"
        $HP
        
        $SpeedTotal = "0"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "Unknown"

        $RaceDescription = "Unknown"
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

        $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Harengon')
    {
        $ChosenRaceHarengon = $ChosenRaceHarengon.SelectedItem 
        $ChosenRaceHarengon
        
        $HP = "0"
        $HP
        
        $SpeedTotal = "0"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "Unknown"

        $RaceDescription = "Unknown"
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

        $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Aarakocra')
    {
        $ChosenRaceAarakocra = $ChosenRaceAarakocra.SelectedItem 
        $ChosenRaceAarakocra

        $HP = "13"
        $HP
        
        $SpeedTotal = "25, 50 if flying"
        $SpeedTotal

        $RaceLifeTime = "30"
        $RaceLifeTime

        $PlayerSize = "100 Pounds, Medium"
        $PlayerSize

        $Playerheight = "5 Feet"
        $Playerheight

        #Attributes
        $STR = "+0"
        $DEX = "+2"
        $CON = "+0"
        $INT = "+0"
        $WIS = "+1"
        $CHA = "+0"

        $Skills = "Perception +5"
        $Skills

        $Senses = "Passive perception 15"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "You can speak, read, and write Common, Aarakocra, and Auran."

        $RaceDescription = "From below, aarakocra look much like large birds. Only when they descend to roost on a branch or walk across the ground does their humanoid appearance reveal itself. Standing upright, aarakocra might reach 5 feet tall, and they have long, narrow legs that taper to sharp talons.

        Feathers cover their bodies. Their plumage typically denotes membership in a tribe. Males are brightly colored, with feathers of red, orange, or yellow. Females have more subdued colors, usually brown or gray. Their heads complete the avian appearance, being something like a parrot or eagle with distinct tribal variations."
        $RaceDescription

        $RacialSpecialAbility = "Dive Attack"
        $RacialSpecialAbility

        $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Genasi')
    {
        $ChosenRaceGenasi = $ChosenRaceGenasi.SelectedItem 
        $ChosenRaceGenasi

        $HP = "0"
        $HP
        
        $SpeedTotal = "30"
        $SpeedTotal

        $RaceLifeTime = "120"
        $RaceLifeTime

        $PlayerSize = "Varies On Build, Medium"
        $PlayerSize

        $Playerheight = "6 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "You can speak, read, and write Common and Primordial. Primordial is a guttural language, filled with harsh syllables and hard consonants."

        $RaceDescription = "Those who think of other planes at all consider them remote, distant realms, but planar influence can be felt throughout the world. It sometimes manifests in beings who, through an accident of birth, carry the power of the planes in their blood. The genasi are one such people, the offspring of genies and mortals.

        The Elemental Planes are often inhospitable to natives of the Material Plane: crushing earth, searing flames, boundless skies, and endless seas make visiting these places dangerous for even a short time. The powerful genies, however, dont face such troubles when venturing into the mortal world. They adapt well to the mingled elements of the Material Plane, and they sometimes visit, whether of their own volition or compelled by magic. Some genies can adopt mortal guise and travel incognito.
        
        During these visits, a mortal might catch a genies eye. Friendship forms, romance blooms, and sometimes children result. These children are genasi, individuals with ties to two worlds, yet belonging to neither. Some genasi are born of mortal genie unions, others have two genasi as parents, and a rare few have a genie further up their family tree, manifesting an elemental heritage thats lain dormant for generations.
        
        Occasionally, genasi result from exposure to a surge of elemental power, through phenomena such as an eruption from the Inner Planes or a planar convergence. Elemental energy saturates any creatures in the area and might alter their nature enough that their offspring with other mortals are born as genasi."
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

        $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Goliath')
    {
        $ChosenRaceGoliath = $ChosenRaceGoliath.SelectedItem 
        $ChosenRaceGoliath

        $HP = "0"
        $HP
        
        $SpeedTotal = "30"
        $SpeedTotal

        $RaceLifeTime = "100"
        $RaceLifeTime

        $PlayerSize = "280-340 Pounds"
        $PlayerSize

        $Playerheight = "8 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "You can speak, read, and write Common and Giant."

        $RaceDescription = "At the highest mountain peaks, far above the slopes where trees grow and where the air is thin and the frigid winds howl dwell the reclusive goliaths. Few folk can claim to have seen a goliath, and fewer still can claim friendship with them. Goliaths wander a bleak realm of rock, wind, and cold. Their bodies look as if they are carved from mountain stone and give them great physical power. Their spirits take after the wandering wind, making them nomads who wander from peak to peak. Their hearts are infused with the cold regard of their frigid realm, leaving each goliath with the responsibility to earn a place in the tribe or die trying."
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

        $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Aasimar')
    {
        $ChosenRaceAasimar = $ChosenRaceAasimar.SelectedItem 
        $ChosenRaceAasimar
        
        $HP = "0"
        $HP
        
        $SpeedTotal = "0"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "Unknown"

        $RaceDescription = "Unknown"
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

        $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Bugbear')
    {
        $ChosenRaceBugbear = $ChosenRaceBugbear.SelectedItem 
        $ChosenRaceBugbear
        
        $HP = "27"
        $HP
        
        $SpeedTotal = "30"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "+2"
        $DEX = "+2"
        $CON = "-1"
        $INT = "-1"
        $WIS = "+0"
        $CHA = "-1"

        $Skills = "Stealth +6, Survival +2"
        $Skills

        $Senses = "Darkvision 60ft, passive perception 10"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "Common, Goblin"

        $RaceDescription = "Unknown"
        $RaceDescription

        $RacialSpecialAbility = "Brute, Surprise Attack"
        $RacialSpecialAbility

        $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Firbolg')
    {
        $ChosenRaceFirbolg = $ChosenRaceFirbolg.SelectedItem 
        $ChosenRaceFirbolg

        $HP = "0"
        $HP
        
        $SpeedTotal = "30"
        $SpeedTotal

        $RaceLifeTime = "500"
        $RaceLifeTime

        $PlayerSize = "240-300 Pounds"
        $PlayerSize

        $Playerheight = "6 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "You can speak, read and write Common, Elvish and giant"

        $RaceDescription = "Firbolgs are the fores-dwelling race native to the Greying Wildlands, particularly the mysterious Savlirwood. Their bodie are covered with thick fur ranging from tones of earthen brown and ruddy red to cool grays and blues , and even to wild hues of pink and green. Their bodies are bovine or camelid in appearance with floppy, pointed ears and broad, pink noses, but they are bipdal and have hands that manipulate weapons and objects
        Most Firbolgs live in extended family units, and it is unusual to find one living alone. However, they are introverted to the point where they seldom engage with other firbolgs outside the family unit, and firbolgs rarely form their own cities, villages or even large tribes. Despite this, many firbolgs enjoy visiting other nations and settlements for a short time for trade, signseeing, and to visit friends."
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

        $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Goblin')
    {
        $ChosenRaceGoblin = $ChosenRaceGoblin.SelectedItem 
        $ChosenRaceGoblin

        $HP = "0"
        $HP
        
        $SpeedTotal = "0"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls


        $SpokenLanguages = ""

        $RaceDescription = ""
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

        $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Hobgoblin')
    {
        $ChosenRaceHobGoblin = $ChosenRaceHobGoblin.SelectedItem 
        $ChosenRaceHobGoblin
        
        $HP = "11"
        $HP
        
        $SpeedTotal = "30"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "+1"
        $DEX = "+1"
        $CON = "+1"
        $INT = "+0"
        $WIS = "+0"
        $CHA = "-1"

        $Skills = "Unknown"
        $Skills

        $Senses = "Darkvision 60ft, Passive perception 10"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "Common, Goblin"

        $RaceDescription = "Unknown"
        $RaceDescription

        $RacialSpecialAbility = "Martial Advantage"
        $RacialSpecialAbility

        $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Kenku')
    {
        $ChosenRaceKenku = $ChosenRaceKenku.SelectedItem 
        $ChosenRaceKenku
        
        $HP = "13"
        $HP
        
        $SpeedTotal = "30"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "+0"
        $DEX = "+3"
        $CON = "+0"
        $INT = "+0"
        $WIS = "+0"
        $CHA = "+0"

        $Skills = "Deception +4, Perception +2, Stealth +5"
        $Skills

        $Senses = "Passive Perception 12"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "Common, Auran (only using mimicry)"

        $RaceDescription = "Unknown"
        $RaceDescription

        $RacialSpecialAbility = "Ambusher, Mimicry"
        $RacialSpecialAbility

        $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Kobold')
    {
        #Race Stats
        $ChosenRaceKobold = $ChosenRaceKobold.SelectedItem 
        $ChosenRaceKobold

        $HP = "5"
        $HP
        
        $SpeedTotal = "30"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "-2"
        $DEX = "+2"
        $CON = "-1"
        $INT = "-1"
        $WIS = "-2"
        $CHA = "-1"

        $Skills = "Unknown"
        $Skills

        $Senses = "Darkvision 60ft, Passive perception 8"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "Unknown"

        $RaceDescription = "Unknown"
        $RaceDescription

        $RacialSpecialAbility = "Sunlight Sensitivity"
        $RacialSpecialAbility

        $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws
    }
    if ($ChosenRace.SelectedItem -match 'Lizardfolk')
    {
        $ChosenRaceLizardfolk = $ChosenRaceLizardfolk.SelectedItem 
        $ChosenRaceLizardfolk
        
        $HP = "22"
        $HP
        
        $SpeedTotal = "30"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "+2"
        $DEX = "+0"
        $CON = "+1"
        $INT = "-2"
        $WIS = "+1"
        $CHA = "-2"

        $Skills = "Perception +3, Stealth +4, Survival +5"
        $Skills

        $Senses = "Passive perception 13"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "Common, Draconic"

        $RaceDescription = "Unknown"
        $RaceDescription

        $RacialSpecialAbility = "Hold Breath"
        $RacialSpecialAbility

        $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Tabaxi')
    {
        $ChosenRaceTabaxi = $ChosenRaceTabaxi.SelectedItem 
        $ChosenRaceTabaxi
        
        $HP = "0"
        $HP
        
        $SpeedTotal = "0"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "Unknown"

        $RaceDescription = "Unknown"
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

        $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Triton')
    {
        $ChosenRaceTriton = $ChosenRaceTriton.SelectedItem 
        $ChosenRaceTriton
        
        $HP = "0"
        $HP
        
        $SpeedTotal = "0"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "Unknown"

        $RaceDescription = "Unknown"
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

        $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Yuan-ti Pureblood')
    {
        $ChosenRaceYuan_Ti_Pureblood = $ChosenRaceYuan_Ti_Pureblood.SelectedItem 
        $ChosenRaceYuan_Ti_Pureblood
        
        $HP = "0"
        $HP
        
        $SpeedTotal = "0"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "Unknown"

        $RaceDescription = "Unknown"
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

        $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Feral Tiefling')
    {
        $ChosenRaceFeral_Tiefling = $ChosenRaceFeral_Tiefling.SelectedItem 
        $ChosenRaceFeral_Tiefling
        
        $HP = "0"
        $HP
        
        $SpeedTotal = "0"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "Unknown"

        $RaceDescription = "Unknown"
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

        $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Tortle')
    {
        $ChosenRaceTortle = $ChosenRaceTortle.SelectedItem 
        $ChosenRaceTortle
        
        $HP = "0"
        $HP
        
        $SpeedTotal = "0"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "Unknown"

        $RaceDescription = "Unknown"
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

        $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Changling')
    {
        $ChosenRaceChangling = $ChosenRaceChangling.SelectedItem 
        $ChosenRaceChangling
        
        $HP = "0"
        $HP
        
        $SpeedTotal = "0"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "Unknown"

        $RaceDescription = "Unknown"
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

        $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Kalashtar')
    {
        $ChosenRaceKalashtar = $ChosenRaceKalashtar.SelectedItem 
        $ChosenRaceKalashtar
        
        $HP = "0"
        $HP
        
        $SpeedTotal = "0"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "Unknown"

        $RaceDescription = "Unknown"
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

        $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws
    }
    if ($ChosenRace.SelectedItem -match 'Shifter')
    {
        $ChosenRaceShifter = $ChosenRaceShifter.SelectedItem 
        $ChosenRaceShifter
        
        $HP = "0"
        $HP
        
        $SpeedTotal = "0"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "Unknown"

        $RaceDescription = "Unknown"
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

        $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Warforged')
    {
        $ChosenRaceWarforged = $ChosenRaceWarforged.SelectedItem 
        $ChosenRaceWarforged
        
        $HP = "0"
        $HP
        
        $SpeedTotal = "0"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "Unknown"

        $RaceDescription = "Unknown"
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

        $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Gith')
    {
        $ChosenRaceGith = $ChosenRaceGith.SelectedItem 
        $ChosenRaceGith
        
        $HP = "0"
        $HP
        
        $SpeedTotal = "0"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "Unknown"

        $RaceDescription = "Unknown"
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

                $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Centaur')
    {
        $ChosenRaceCentaur = $ChosenRaceCentaur.SelectedItem 
        $ChosenRaceCentaur
        
        $HP = "0"
        $HP
        
        $SpeedTotal = "0"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "Unknown"

        $RaceDescription = "Unknown"
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

                $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Loxodon')
    {
        $ChosenRaceLoxodon = $ChosenRaceLoxodon.SelectedItem 
        $ChosenRaceLoxodon
        
        $HP = "0"
        $HP
        
        $SpeedTotal = "0"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "Unknown"

        $RaceDescription = "Unknown"
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

                $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Minotaur')
    {
        $ChosenRaceMinotaur = $ChosenRaceMinotaur.SelectedItem 
        $ChosenRaceMinotaur
        
        $HP = "0"
        $HP
        
        $SpeedTotal = "0"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "Unknown"

        $RaceDescription = "Unknown"
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

                $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Simic Hybrid')
    {
        $ChosenRaceSimic_Hybrid = $ChosenRaceSimic_Hybridr.SelectedItem 
        $ChosenRaceSimic_Hybrid
        
        $HP = "0"
        $HP
        
        $SpeedTotal = "0"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "Unknown"

        $RaceDescription = "Unknown"
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

                $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Vedalken')
    {
        $ChosenRaceSimic_Hybrid = $ChosenRaceSimic_Hybrid.SelectedItem 
        $ChosenRaceSimic_Hybrid
        
        $HP = "0"
        $HP
        
        $SpeedTotal = "0"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "Unknown"

        $RaceDescription = "Unknown"
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

                $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Verdan')
    {
        $ChosenRaceVerdan = $ChosenRaceVerdan.SelectedItem 
        $ChosenRaceVerdan
        
        $HP = "0"
        $HP
        
        $SpeedTotal = "0"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "Unknown"

        $RaceDescription = "Unknown"
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

                $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Locathah')
    {
        $ChosenRaceLocathah = $ChosenRaceLocathah.SelectedItem 
        $ChosenRaceLocathah
        
        $HP = "0"
        $HP
        
        $SpeedTotal = "0"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "Unknown"

        $RaceDescription = "Unknown"
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

                $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Grung')
    {
        $ChosenRaceGrung = $ChosenRaceGrung.SelectedItem 
        $ChosenRaceGrung
        
        $HP = "0"
        $HP
        
        $SpeedTotal = "0"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "Unknown"

        $RaceDescription = "Unknown"
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

                $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Lycanth')
    {
        $ChosenRaceLycanth = $ChosenRaceLycanth.SelectedItem 
        $ChosenRaceLycanth
        
        $HP = "0"
        $HP
        
        $SpeedTotal = "0"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "Unknown"

        $RaceDescription = "Unknown"
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

                $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Troll')
    {
        $ChosenRaceTroll = $ChosenRaceTroll.SelectedItem 
        $ChosenRaceTroll
        
        $HP = "84"
        $HP
        
        $SpeedTotal = "30"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "+4"
        $DEX = "+1"
        $CON = "+5"
        $INT = "-2"
        $WIS = "-1"
        $CHA = "-2"

        $Skills = "Perception +2"
        $Skills

        $Senses = "Darkvision 60ft, passive perception 12"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "Giant"

        $RaceDescription = "Unknown"
        $RaceDescription

        $RacialSpecialAbility = "Keen smell, Regeneration"
        $RacialSpecialAbility

                $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Ogre')
    {
        $ChosenRaceOrge = $ChosenRaceOrge.SelectedItem 
        $ChosenRaceOrge
        
        $HP = "59"
        $HP
        
        $SpeedTotal = "0"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "Unknown"

        $RaceDescription = "Unknown"
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

                $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Feral Wolf')
    {
        $ChosenRaceFera_Wolf = $ChosenRaceFera_Wolf.SelectedItem 
        $ChosenRaceFera_Wolf
        
        $HP = "0"
        $HP
        
        $SpeedTotal = "0"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "0"
        $DEX = "0"
        $CON = "0"
        $INT = "0"
        $WIS = "0"
        $CHA = "0"

        $Skills = "Unknown"
        $Skills

        $Senses = "Unknown"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "Unknown"

        $RaceDescription = "Unknown"
        $RaceDescription

        $RacialSpecialAbility = "Unknown"
        $RacialSpecialAbility

                $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
    if ($ChosenRace.SelectedItem -match 'Wolf')
    {
        $ChosenRaceWolf = $ChosenRaceWolf.SelectedItem 
        $ChosenRaceWolf
        
        $HP = "15"
        $HP
        
        $SpeedTotal = "40"
        $SpeedTotal

        $RaceLifeTime = "0"
        $RaceLifeTime

        $PlayerSize = "0 Pounds"
        $PlayerSize

        $Playerheight = "0 Feet"
        $Playerheight

        #Attributes
        $STR = "+1"
        $DEX = "+2"
        $CON = "+1"
        $INT = "-4"
        $WIS = "+1"
        $CHA = "-2"

        $Skills = "Perception +3, Stealth +4"
        $Skills

        $Senses = "Passive Perception 13"
        $Senses

        $Damage_Immunities = "Unknown"
        $Damage_Immunities

        $Condition_Immunities = "Unknown"
        $Condition_Immunities

        $Racesavingrolls = "0"
        $Racesavingrolls

        $SpokenLanguages = "Unknown"

        $RaceDescription = "Unknown"
        $RaceDescription

        $RacialSpecialAbility = "Keen Hearing and Smell"
        $RacialSpecialAbility

                $PersonalityTraits = "Unknown"
        $PersonalityTraits

        $Ideals = "Unknown"
        $Ideals

        $Bonds = "Unknown"
        $Bonds

        $Flaws = "Unknown"
        $Flaws

    }
#End of details

Write-Output $RaceDescription

#If adding a new race, please use the code below as an example:
    #if ($ChosenRace.SelectedItem -match 'Dragonborn')
    #{
        #Race Stats
    #   $ChosenRaceDragonborn = $ChosenRaceDragonborn.SelectedItem 
    #   $ChosenRaceDragonborn

        #$HP = "0"
        #$HP
        
        #$SpeedTotal = "0"
        #$SpeedTotal

        #$RaceLifeTime = "0"
        #$RaceLifeTime

        #$PlayerSize = "0 Pounds"
        #$PlayerSize

        #$Playerheight = "0 Feet"
        #$Playerheight

        #Attributes
        #$STR = "0"
        #$DEX = "0"
        #$CON = "0"
        #$INT = "0"
        #$WIS = "0"
        #$CHA = "0"

        #$Skills = "Unknown"
        #$Skills

        #$Senses = "Unknown"
        #$Senses

        #$Damage_Immunities = "Unknown"
        #$Damage_Immunities

        #$Condition_Immunities = "Unknown"
        #$Condition_Immunities

        #$Racesavingrolls = "0"
        #$Racesavingrolls

        #$SpokenLanguages = "Unknown"

        #$RaceDescription = "Unknown"
        #$RaceDescription

        #$RacialSpecialAbility = "Unknown"
        #$RacialSpecialAbility
        
    #}

    #Please finish adding - IF you select a race a picture appears to the rightside
    #of the form, along with a description below that in a larger box
    #make is scrollable

    #New weapon selection compared to the old one, 3 weapon scroll panels
    #All 3 must be a duplicate of the previous, but weapon stats need to be carried.
#New Weapon selection
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Sparks D&D Character Creator'
    $form.Size = New-Object System.Drawing.Size(400,300)
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
    $okButton.Text = 'OK'
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

    $selectweapon1label = New-Object System.Windows.Forms.Label
    $selectweapon1label.Location = New-Object System.Drawing.Point(10,20)
    $selectweapon1label.Size = New-Object System.Drawing.Size(140,18)
    $selectweapon1label.Text = 'Select Weapon 1:'
    $form.Controls.Add($selectweapon1label)

    $selectweapon2label = New-Object System.Windows.Forms.Label
    $selectweapon2label.Location = New-Object System.Drawing.Point(160,20)
    $selectweapon2label.Size = New-Object System.Drawing.Size(140,18)
    $selectweapon2label.Text = 'Select Weapon 2:'
    $form.Controls.Add($selectweapon2label)

    $selectweapon3label = New-Object System.Windows.Forms.Label
    $selectweapon3label.Location = New-Object System.Drawing.Point(310,20)
    $selectweapon3label.Size = New-Object System.Drawing.Size(140,18)
    $selectweapon3label.Text = 'Select Weapon 3:'
    $form.Controls.Add($selectweapon3label)

    $selectweapon1panel = New-Object System.Windows.Forms.ListBox
    $selectweapon1panel.Location = New-Object System.Drawing.Point(10,40)
    $selectweapon1panel.Size = New-Object System.Drawing.Size(140,18)
    $selectweapon1panel.Height = 230

    $selectweapon2panel = New-Object System.Windows.Forms.ListBox
    $selectweapon2panel.Location = New-Object System.Drawing.Point(160,40)
    $selectweapon2panel.Size = New-Object System.Drawing.Size(140,18)
    $selectweapon2panel.Height = 230

    $selectweapon3panel = New-Object System.Windows.Forms.ListBox
    $selectweapon3panel.Location = New-Object System.Drawing.Point(310,40)
    $selectweapon3panel.Size = New-Object System.Drawing.Size(140,18)
    $selectweapon3panel.Height = 230

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
 
    $form.Controls.Add($selectweapon1panel)
    $form.Controls.Add($selectweapon2panel)
    $form.Controls.Add($selectweapon3panel)
    $form.Topmost = $true

    if ($selectedweapons -eq [System.Windows.Forms.DialogResult]::OK)
    {
        $selectedweapon1 = $selectweapon1panel.SelectedItem
        $selectedweapon1

        $selectedweapon2 = $selectweapon2panel.SelectedItem
        $selectedweapon2

        $selectedweapon3 = $selectweapon3panel.SelectedItem
        $selectedweapon3
    }
    if ($selectedweapons -eq [System.Windows.Forms.DialogResult]::Ignore)
    {
        $selectedweapon1 = "Non-Selected"
        $selectedweapon2 = "Non-Selected"
        $selectedweapon3 = "Non-Selected"
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

#Input a Damage, weight and properties into sup categories for the export
#This also is for inventory purposes and types of character builds

#splitting up each inventory weapons with name, cost, damage, weight and properties
#Add descriptions to all weapons with the attributes when chosen

#Remember to add a second weapon and third weapon choice, also gold count (affected by class)

#Attack Bonuses According to weapon choice

#If added custom to the weapon list, make sure to add the correct listed item to the weapon selection below
#Make sure to split all sup parts of weapon stats up so when making files
#it can be done via value's 

#Currently adding weapon damage types to each weapon, finish this please
    #Weapon 1 Choice
    if ($selectweapon1panel.SelectedItem -match 'Iron Dagger')
    {
        $WPN1ATK_Bonus = "+4"

        $WeaponDamageSimpleMelee = "1d4 Piercing"
        $WeaponDamageSimpleMelee

        $Totalweaponweight = "1lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "Finesse, Light, thrown (range 20/60)"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon1panel.SelectedItem -match 'Steel Dagger')
    {
        $WPN1ATK_Bonus = "+4"

        $WeaponDamageSimpleMelee = "1d4 Piercing"
        $WeaponDamageSimpleMelee

        $Totalweaponweight = "2lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "Finesse, Light, thrown (range 20/60)"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon1panel.SelectedItem -match 'Club')
    {
        $WPN1ATK_Bonus = "+4"

        $WeaponDamageSimpleMelee = "1d4 Bludgeoning"
        $WeaponDamageSimpleMelee

        $Totalweaponweight = "2lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "Light"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon1panel.SelectedItem -match 'Great Club')
    {
        $WPN1ATK_Bonus = "+4"

        $WeaponDamageSimpleMelee = "1d8 Bludgeoning"
        $WeaponDamageSimpleMelee
        
        $Totalweaponweight = "10lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "Two-Handed"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon1panel.SelectedItem -match 'HandAxe')
    {
        $WPN1ATK_Bonus = "+4"

        $WeaponDamageSimpleMelee = "1d6 slashing"
        $WeaponDamageSimpleMelee

        $Totalweaponweight = "2lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "Light, Thrown (range 20/60)"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon1panel.SelectedItem -match 'Javelin')
    {
        $WPN1ATK_Bonus = "+4"

        $WeaponDamageSimpleMelee = "1d6 piercing"
        $WeaponDamageSimpleMelee

        $Totalweaponweight = "2lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "Thrown (range 30/120"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon1panel.SelectedItem -match 'Light Hammer')
    {
        $WPN1ATK_Bonus = "+4"

        $WeaponDamageSimpleMelee = "1d4 Bludgeoning"
        $WeaponDamageSimpleMelee

        $Totalweaponweight = "2lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "Light, Thrown (range 20/60)"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon1panel.SelectedItem -match 'Mace')
    {
        $WPN1ATK_Bonus = "+4"

        $WeaponDamageSimpleMelee = "1d6 Bludgeoning"
        $WeaponDamageSimpleMelee

        $Totalweaponweight = "4lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "One-Handed"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon1panel.SelectedItem -match 'QuarterStaff')
    {
        $WPN1ATK_Bonus = "+4"

        $WeaponDamageSimpleMelee = "1d6 Bludgeoning"
        $WeaponDamageSimpleMelee

        $Totalweaponweight = "4lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "Versatile (1d8)"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon1panel.SelectedItem -match 'Spear')
    {
        $WPN1ATK_Bonus = "+4"

        $WeaponDamageSimpleMelee = "1d6 Piercing"
        $WeaponDamageSimpleMelee

        $Totalweaponweight = "3lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "Thrown (range 20/60, versatile (qd8)"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon1panel.SelectedItem -match 'Nunchucks')
    {
        $WPN1ATK_Bonus = "+4"

        $WeaponDamageSimpleMelee = "1d4 Bludgeoning"
        $WeaponDamageSimpleMelee

        $Totalweaponweight = "5lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "Two-Handed, Thrown (range 20/30)"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon1panel.SelectedItem -match 'Iron Sword')
    {
        $WPN1ATK_Bonus = "+4"

        $WeaponDamageSimpleMelee = "1d6 Piercing"
        $WeaponDamageSimpleMelee

        $Totalweaponweight = "6lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "One-Handed"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon1panel.SelectedItem -match 'Iron Short Sword')
    {
        $WPN1ATK_Bonus = "+4"

        $WeaponDamageSimpleMelee = "1d4 Piercing"
        $WeaponDamageSimpleMelee
        
        $Totalweaponweight = "3lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "One-Handed"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon1panel.SelectedItem -match 'Crossbow - Light')
    {
        $WPN1ATK_Bonus = "+4"

        $WeapongDamageSimpleRanged = "1d8 Piercing"
        $WeapongDamageSimpleRanged

        $Totalweaponweight = "5lb"
        $Totalweaponweight
        
        $WeaponPropertiessimpleranged = "Ammunition (range 80/320), Loading, Two-Handed"
        $WeaponPropertiessimpleranged
    }
    if ($selectweapon1panel.SelectedItem -match 'Shortbow')
    {
        $WPN1ATK_Bonus = "+4"

        $WeapongDamageSimpleRanged = "1d6 Piercing"
        $WeapongDamageSimpleRanged

        $Totalweaponweight = "2lb"
        $Totalweaponweight

        $WeaponPropertiessimpleranged = "Ammunition (range 80/320), Two-Handed"
        $WeaponPropertiessimpleranged
    }
    if ($selectweapon1panel.SelectedItem -match 'Sling')
    {
        $WPN1ATK_Bonus = "+4"

        $WeapongDamageSimpleRanged = "1d4 Bludgeoning"
        $WeapongDamageSimpleRanged

        $Totalweaponweight = "0lb"
        $Totalweaponweight

        $WeaponPropertiessimpleranged = "Ammunition (range 30/120)"
        $WeaponPropertiessimpleranged
    }
    if ($selectweapon1panel.SelectedItem -match 'Dart')
    {
        $WPN1ATK_Bonus = "+4"

        $WeapongDamageSimpleRanged = "1d4 Piercing"
        $WeapongDamageSimpleRanged

        $Totalweaponweight = "1/4lb"
        $Totalweaponweight

        $WeaponPropertiessimpleranged = "Finesse, thrown (range 20/60)"
        $WeaponPropertiessimpleranged
    }
    if ($selectweapon1panel.SelectedItem -match 'BattleAxe')
    {
        $WPN1ATK_Bonus = "+4"

        $WeaponDamageMartialMelee = "1d8 Slashing"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "4lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Versatile (1d10)"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon1panel.SelectedItem -match 'Flail')
    {
        $WPN1ATK_Bonus = "+4"

        $WeaponDamageMartialMelee = "1d8 Bludgeoning"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "2lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "One-Handed"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon1panel.SelectedItem -match 'Great Axe')
    {
        $WPN1ATK_Bonus = "+4"

        $WeaponDamageMartialMelee = "1d12 Slashing"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "7lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Heavy, Two-Handed"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon1panel.SelectedItem -match 'Great Sword')
    {
        $WPN1ATK_Bonus = "+4"

        $WeaponDamageMartialMelee = "2d6 Slashing"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "6lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Heavy, Two-Handed"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon1panel.SelectedItem -match 'Halberd')
    {
        $WPN1ATK_Bonus = "+4"

        $WeaponDamageMartialMelee = "1d10 Slashing"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "6lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Heavy, Reach, Two-Handed"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon1panel.SelectedItem -match 'Longsword')
    {
        $WPN1ATK_Bonus = "+4"

        $WeaponDamageMartialMelee = "1d8 Slashing"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "3lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Versatile (1d10)"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon1panel.SelectedItem -match 'Maul')
    {
        $WPN1ATK_Bonus = "+4"

        $WeaponDamageMartialMelee = "2d6 Bludgeoning"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "10lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Heavy, Two-Handed"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon1panel.SelectedItem -match 'MorningStar')
    {
        $WPN1ATK_Bonus = "+4"

        $WeaponDamageMartialMelee = "1d8 Piercing"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "4lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Two-Handed"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon1panel.SelectedItem -match 'Rapier')
    {
        $WPN1ATK_Bonus = "+4"

        $WeaponDamageMartialMelee = "1d8 Piercing"
        $WeapoWeaponDamageMartialMeleenDamage

        $Totalweaponweight = "2lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Finesse"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon1panel.SelectedItem -match 'Sicimitar')
    {
        $WPN1ATK_Bonus = "+4"

        $WeaponDamageMartialMelee = "1d6 Slashing"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "3lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Finesse, Light"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon1panel.SelectedItem -match 'ShortSword')
    {
        $WPN1ATK_Bonus = "+4"

        $WeaponDamageMartialMelee = "1d6 Piercing"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "2lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Finesse, Light"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon1panel.SelectedItem -match 'Trident')
    {
        $WPN1ATK_Bonus = "+4"

        $WeaponDamageMartialMelee = "1d6 Piercing"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "4lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Thrown (range 20/60), Versatile (1d8)"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon1panel.SelectedItem -match 'Warhammer')
    {
        $WPN1ATK_Bonus = "+4"

        $WeaponDamageMartialMelee = "1d8 Bludgeoning"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "2lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Versatile (1d10)"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon1panel.SelectedItem -match 'DoomHammer')
    {
        $WPN1ATK_Bonus = "+4"

        $WeaponDamageMartialMelee = "1d12 Bludgeoning"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "10lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Heavy, Two-Handed"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon1panel.SelectedItem -match 'Dual-Wield Staff')
    {
        $WPN1ATK_Bonus = "+4"

        $WeaponDamageMartialMelee = "1d8 Budgeoning"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "7lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Two-Handed, Light"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon1panel.SelectedItem -match 'Broadsword')
    {
        $WPN1ATK_Bonus = "+4"

        $WeaponDamageMartialMelee = "1d8 Piercing"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "8lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Heavy, Two-Handed"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon1panel.SelectedItem -match 'Steel Sword')
    {
        $WPN1ATK_Bonus = "+4"

        $WeaponDamageMartialMelee = "1d8 Piercing"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "8lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "One-Handed"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon1panel.SelectedItem -match 'Crossbow - Heavy')
    {
        $WPN1ATK_Bonus = "+4"

        $WeaponDamageMartialRanged = "1d10 Piercing"
        $WeaponDamageMartialRanged

        $Totalweaponweight = "18lb"
        $Totalweaponweight

        $WeaponPropertiessmartialranged = "Ammunition (range 30/120), light, loading"
        $WeaponPropertiessmartialranged
    }
    if ($selectweapon1panel.SelectedItem -match 'Crossbow - Hand')
    {
        $WPN1ATK_Bonus = "+4"

        $WeaponDamageMartialRanged = "1d6 Piercing"
        $WeaponDamageMartialRanged

        $Totalweaponweight = "3lb"
        $Totalweaponweight

        $WeaponPropertiessmartialranged = "Ammunition (range 100/400), Heavy, Loading, Two-Handed"
        $WeaponPropertiessmartialranged
    }
    if ($selectweapon1panel.SelectedItem -match 'Longbow')
    {
        $WPN1ATK_Bonus = "+4"

        $WeaponDamageMartialRanged = "1d8 Piercing"
        $WeaponWeaponDamageMartialRangedDamage

        $Totalweaponweight = "2lb"
        $Totalweaponweight

        $WeaponPropertiessmartialranged = "Ammunition (range 150/600), Heavy, Two-Handed"
        $WeaponPropertiessmartialranged
    }
    #Weapon 2 Choice
    if ($selectweapon2panel.SelectedItem -match 'Iron Dagger')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageSimpleMelee = "1d4 Piercing"
        $WeaponDamageSimpleMelee

        $Totalweaponweight = "1lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "Finesse, Light, thrown (range 20/60)"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon2panel.SelectedItem -match 'Steel Dagger')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageSimpleMelee = "1d4 Piercing"
        $WeaponDamageSimpleMelee

        $Totalweaponweight = "2lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "Finesse, Light, thrown (range 20/60)"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon2panel.SelectedItem -match 'Club')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageSimpleMelee = "1d4 Bludgeoning"
        $WeaponDamageSimpleMelee

        $Totalweaponweight = "2lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "Light"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon2panel.SelectedItem -match 'Great Club')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageSimpleMelee = "1d8 Bludgeoning"
        $WeaponDamageSimpleMelee
        
        $Totalweaponweight = "10lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "Two-Handed"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon2panel.SelectedItem -match 'HandAxe')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageSimpleMelee = "1d6 slashing"
        $WeaponDamageSimpleMelee

        $Totalweaponweight = "2lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "Light, Thrown (range 20/60)"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon2panel.SelectedItem -match 'Javelin')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageSimpleMelee = "1d6 piercing"
        $WeaponDamageSimpleMelee

        $Totalweaponweight = "2lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "Thrown (range 30/120"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon2panel.SelectedItem -match 'Light Hammer')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageSimpleMelee = "1d4 Bludgeoning"
        $WeaponDamageSimpleMelee

        $Totalweaponweight = "2lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "Light, Thrown (range 20/60)"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon2panel.SelectedItem -match 'Mace')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageSimpleMelee = "1d6 Bludgeoning"
        $WeaponDamageSimpleMelee

        $Totalweaponweight = "4lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "One-Handed"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon2panel.SelectedItem -match 'QuarterStaff')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageSimpleMelee = "1d6 Bludgeoning"
        $WeaponDamageSimpleMelee

        $Totalweaponweight = "4lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "Versatile (1d8)"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon2panel.SelectedItem -match 'Spear')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageSimpleMelee = "1d6 Piercing"
        $WeaponDamageSimpleMelee

        $Totalweaponweight = "3lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "Thrown (range 20/60, versatile (qd8)"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon2panel.SelectedItem -match 'Nunchucks')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageSimpleMelee = "1d4 Bludgeoning"
        $WeaponDamageSimpleMelee

        $Totalweaponweight = "5lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "Two-Handed, Thrown (range 20/30)"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon2panel.SelectedItem -match 'Iron Sword')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageSimpleMelee = "1d6 Piercing"
        $WeaponDamageSimpleMelee

        $Totalweaponweight = "6lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "One-Handed"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon2panel.SelectedItem -match 'Iron Short Sword')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageSimpleMelee = "1d4 Piercing"
        $WeaponDamageSimpleMelee
        
        $Totalweaponweight = "3lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "One-Handed"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon2panel.SelectedItem -match 'Crossbow - Light')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeapongDamageSimpleRanged = "1d8 Piercing"
        $WeapongDamageSimpleRanged

        $Totalweaponweight = "5lb"
        $Totalweaponweight
        
        $WeaponPropertiessimpleranged = "Ammunition (range 80/320), Loading, Two-Handed"
        $WeaponPropertiessimpleranged
    }
    if ($selectweapon2panel.SelectedItem -match 'Shortbow')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeapongDamageSimpleRanged = "1d6 Piercing"
        $WeapongDamageSimpleRanged

        $Totalweaponweight = "2lb"
        $Totalweaponweight

        $WeaponPropertiessimpleranged = "Ammunition (range 80/320), Two-Handed"
        $WeaponPropertiessimpleranged
    }
    if ($selectweapon2panel.SelectedItem -match 'Sling')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeapongDamageSimpleRanged = "1d4 Bludgeoning"
        $WeapongDamageSimpleRanged

        $Totalweaponweight = "0lb"
        $Totalweaponweight

        $WeaponPropertiessimpleranged = "Ammunition (range 30/120)"
        $WeaponPropertiessimpleranged
    }
    if ($selectweapon2panel.SelectedItem -match 'Dart')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeapongDamageSimpleRanged = "1d4 Piercing"
        $WeapongDamageSimpleRanged

        $Totalweaponweight = "1/4lb"
        $Totalweaponweight

        $WeaponPropertiessimpleranged = "Finesse, thrown (range 20/60)"
        $WeaponPropertiessimpleranged
    }
    if ($selectweapon2panel.SelectedItem -match 'BattleAxe')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "1d8 Slashing"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "4lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Versatile (1d10)"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon2panel.SelectedItem -match 'Flail')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "1d8 Bludgeoning"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "2lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "One-Handed"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon2panel.SelectedItem -match 'Great Axe')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "1d12 Slashing"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "7lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Heavy, Two-Handed"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon2panel.SelectedItem -match 'Great Sword')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "2d6 Slashing"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "6lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Heavy, Two-Handed"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon2panel.SelectedItem -match 'Halberd')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "1d10 Slashing"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "6lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Heavy, Reach, Two-Handed"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon2panel.SelectedItem -match 'Longsword')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "1d8 Slashing"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "3lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Versatile (1d10)"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon2panel.SelectedItem -match 'Maul')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "2d6 Bludgeoning"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "10lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Heavy, Two-Handed"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon2panel.SelectedItem -match 'MorningStar')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "1d8 Piercing"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "4lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Two-Handed"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon2panel.SelectedItem -match 'Rapier')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "1d8 Piercing"
        $WeapoWeaponDamageMartialMeleenDamage

        $Totalweaponweight = "2lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Finesse"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon2panel.SelectedItem -match 'Sicimitar')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "1d6 Slashing"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "3lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Finesse, Light"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon2panel.SelectedItem -match 'ShortSword')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "1d6 Piercing"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "2lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Finesse, Light"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon2panel.SelectedItem -match 'Trident')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "1d6 Piercing"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "4lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Thrown (range 20/60), Versatile (1d8)"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon2panel.SelectedItem -match 'Warhammer')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "1d8 Bludgeoning"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "2lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Versatile (1d10)"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon2panel.SelectedItem -match 'DoomHammer')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "1d12 Bludgeoning"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "10lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Heavy, Two-Handed"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon2panel.SelectedItem -match 'Dual-Wield Staff')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "1d8 Budgeoning"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "7lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Two-Handed, Light"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon2panel.SelectedItem -match 'Broadsword')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "1d8 Piercing"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "8lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Heavy, Two-Handed"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon2panel.SelectedItem -match 'Steel Sword')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "1d8 Piercing"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "8lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "One-Handed"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon2panel.SelectedItem -match 'Crossbow - Heavy')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialRanged = "1d10 Piercing"
        $WeaponDamageMartialRanged

        $Totalweaponweight = "18lb"
        $Totalweaponweight

        $WeaponPropertiessmartialranged = "Ammunition (range 30/120), light, loading"
        $WeaponPropertiessmartialranged
    }
    if ($selectweapon2panel.SelectedItem -match 'Crossbow - Hand')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialRanged = "1d6 Piercing"
        $WeaponDamageMartialRanged

        $Totalweaponweight = "3lb"
        $Totalweaponweight

        $WeaponPropertiessmartialranged = "Ammunition (range 100/400), Heavy, Loading, Two-Handed"
        $WeaponPropertiessmartialranged
    }
    if ($selectweapon2panel.SelectedItem -match 'Longbow')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialRanged = "1d8 Piercing"
        $WeaponWeaponDamageMartialRangedDamage

        $Totalweaponweight = "2lb"
        $Totalweaponweight

        $WeaponPropertiessmartialranged = "Ammunition (range 150/600), Heavy, Two-Handed"
        $WeaponPropertiessmartialranged
    }
    #Weapon 3 Choice
    if ($selectweapon3panel.SelectedItem -match 'Iron Dagger')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageSimpleMelee = "1d4 Piercing"
        $WeaponDamageSimpleMelee

        $Totalweaponweight = "1lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "Finesse, Light, thrown (range 20/60)"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon3panel.SelectedItem -match 'Steel Dagger')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageSimpleMelee = "1d4 Piercing"
        $WeaponDamageSimpleMelee

        $Totalweaponweight = "2lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "Finesse, Light, thrown (range 20/60)"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon3panel.SelectedItem -match 'Club')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageSimpleMelee = "1d4 Bludgeoning"
        $WeaponDamageSimpleMelee

        $Totalweaponweight = "2lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "Light"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon3panel.SelectedItem -match 'Great Club')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageSimpleMelee = "1d8 Bludgeoning"
        $WeaponDamageSimpleMelee
        
        $Totalweaponweight = "10lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "Two-Handed"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon3panel.SelectedItem -match 'HandAxe')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageSimpleMelee = "1d6 slashing"
        $WeaponDamageSimpleMelee

        $Totalweaponweight = "2lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "Light, Thrown (range 20/60)"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon3panel.SelectedItem -match 'Javelin')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageSimpleMelee = "1d6 piercing"
        $WeaponDamageSimpleMelee

        $Totalweaponweight = "2lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "Thrown (range 30/120"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon3panel.SelectedItem -match 'Light Hammer')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageSimpleMelee = "1d4 Bludgeoning"
        $WeaponDamageSimpleMelee

        $Totalweaponweight = "2lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "Light, Thrown (range 20/60)"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon3panel.SelectedItem -match 'Mace')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageSimpleMelee = "1d6 Bludgeoning"
        $WeaponDamageSimpleMelee

        $Totalweaponweight = "4lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "One-Handed"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon3panel.SelectedItem -match 'QuarterStaff')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageSimpleMelee = "1d6 Bludgeoning"
        $WeaponDamageSimpleMelee

        $Totalweaponweight = "4lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "Versatile (1d8)"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon3panel.SelectedItem -match 'Spear')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageSimpleMelee = "1d6 Piercing"
        $WeaponDamageSimpleMelee

        $Totalweaponweight = "3lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "Thrown (range 20/60, versatile (qd8)"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon3panel.SelectedItem -match 'Nunchucks')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageSimpleMelee = "1d4 Bludgeoning"
        $WeaponDamageSimpleMelee

        $Totalweaponweight = "5lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "Two-Handed, Thrown (range 20/30)"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon3panel.SelectedItem -match 'Iron Sword')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageSimpleMelee = "1d6 Piercing"
        $WeaponDamageSimpleMelee

        $Totalweaponweight = "6lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "One-Handed"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon3panel.SelectedItem -match 'Iron Short Sword')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageSimpleMelee = "1d4 Piercing"
        $WeaponDamageSimpleMelee
        
        $Totalweaponweight = "3lb"
        $Totalweaponweight

        $WeaponPropertiessimplemelee = "One-Handed"
        $WeaponPropertiessimplemelee
    }
    if ($selectweapon3panel.SelectedItem -match 'Crossbow - Light')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeapongDamageSimpleRanged = "1d8 Piercing"
        $WeapongDamageSimpleRanged

        $Totalweaponweight = "5lb"
        $Totalweaponweight
        
        $WeaponPropertiessimpleranged = "Ammunition (range 80/320), Loading, Two-Handed"
        $WeaponPropertiessimpleranged
    }
    if ($selectweapon3panel.SelectedItem -match 'Shortbow')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeapongDamageSimpleRanged = "1d6 Piercing"
        $WeapongDamageSimpleRanged

        $Totalweaponweight = "2lb"
        $Totalweaponweight

        $WeaponPropertiessimpleranged = "Ammunition (range 80/320), Two-Handed"
        $WeaponPropertiessimpleranged
    }
    if ($selectweapon3panel.SelectedItem -match 'Sling')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeapongDamageSimpleRanged = "1d4 Bludgeoning"
        $WeapongDamageSimpleRanged

        $Totalweaponweight = "0lb"
        $Totalweaponweight

        $WeaponPropertiessimpleranged = "Ammunition (range 30/120)"
        $WeaponPropertiessimpleranged
    }
    if ($selectweapon3panel.SelectedItem -match 'Dart')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeapongDamageSimpleRanged = "1d4 Piercing"
        $WeapongDamageSimpleRanged

        $Totalweaponweight = "1/4lb"
        $Totalweaponweight

        $WeaponPropertiessimpleranged = "Finesse, thrown (range 20/60)"
        $WeaponPropertiessimpleranged
    }
    if ($selectweapon3panel.SelectedItem -match 'BattleAxe')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "1d8 Slashing"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "4lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Versatile (1d10)"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon3panel.SelectedItem -match 'Flail')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "1d8 Bludgeoning"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "2lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "One-Handed"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon3panel.SelectedItem -match 'Great Axe')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "1d12 Slashing"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "7lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Heavy, Two-Handed"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon3panel.SelectedItem -match 'Great Sword')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "2d6 Slashing"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "6lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Heavy, Two-Handed"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon3panel.SelectedItem -match 'Halberd')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "1d10 Slashing"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "6lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Heavy, Reach, Two-Handed"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon3panel.SelectedItem -match 'Longsword')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "1d8 Slashing"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "3lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Versatile (1d10)"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon3panel.SelectedItem -match 'Maul')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "2d6 Bludgeoning"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "10lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Heavy, Two-Handed"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon3panel.SelectedItem -match 'MorningStar')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "1d8 Piercing"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "4lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Two-Handed"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon3panel.SelectedItem -match 'Rapier')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "1d8 Piercing"
        $WeapoWeaponDamageMartialMeleenDamage

        $Totalweaponweight = "2lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Finesse"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon3panel.SelectedItem -match 'Sicimitar')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "1d6 Slashing"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "3lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Finesse, Light"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon3panel.SelectedItem -match 'ShortSword')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "1d6 Piercing"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "2lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Finesse, Light"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon3panel.SelectedItem -match 'Trident')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "1d6 Piercing"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "4lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Thrown (range 20/60), Versatile (1d8)"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon3panel.SelectedItem -match 'Warhammer')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "1d8 Bludgeoning"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "2lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Versatile (1d10)"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon3panel.SelectedItem -match 'DoomHammer')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "1d12 Bludgeoning"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "10lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Heavy, Two-Handed"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon3panel.SelectedItem -match 'Dual-Wield Staff')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "1d8 Budgeoning"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "7lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Two-Handed, Light"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon3panel.SelectedItem -match 'Broadsword')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "1d8 Piercing"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "8lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "Heavy, Two-Handed"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon3panel.SelectedItem -match 'Steel Sword')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialMelee = "1d8 Piercing"
        $WeaponDamageMartialMelee

        $Totalweaponweight = "8lb"
        $Totalweaponweight

        $WeaponPropertiesmartialmelee = "One-Handed"
        $WeaponPropertiesmartialmelee
    }
    if ($selectweapon3panel.SelectedItem -match 'Crossbow - Heavy')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialRanged = "1d10 Piercing"
        $WeaponDamageMartialRanged

        $Totalweaponweight = "18lb"
        $Totalweaponweight

        $WeaponPropertiessmartialranged = "Ammunition (range 30/120), light, loading"
        $WeaponPropertiessmartialranged
    }
    if ($selectweapon3panel.SelectedItem -match 'Crossbow - Hand')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialRanged = "1d6 Piercing"
        $WeaponDamageMartialRanged

        $Totalweaponweight = "3lb"
        $Totalweaponweight

        $WeaponPropertiessmartialranged = "Ammunition (range 100/400), Heavy, Loading, Two-Handed"
        $WeaponPropertiessmartialranged
    }
    if ($selectweapon3panel.SelectedItem -match 'Longbow')
    {
        $ATK_Bonus = "+4"
        $ATK_Bonus

        $WeaponDamageMartialRanged = "1d8 Piercing"
        $WeaponWeaponDamageMartialRangedDamage

        $Totalweaponweight = "2lb"
        $Totalweaponweight

        $WeaponPropertiessmartialranged = "Ammunition (range 150/600), Heavy, Two-Handed"
        $WeaponPropertiessmartialranged
    }


#End of attack bonuses
#for a custom attack bonuse use:
#if ($chosenprimaryweapon.selectedItem -match 'Custom')
#{
#    $ATK_Bonus = +0
#    $ATK_Bonus

     #$WeapomDamageCHOICE = "0"
     #$WeaponDamageCHOICE

     #$Totalweaponweight ="0"
     #$Totalweaponweight

     #$weaponpropertiesCHOICE = ""
     #$weaponpropertiesCHOICE
#}

#Armour Class additions
$ArmourClass = 0

    if ($chosenArmour.SelectedItem -match 'Light Armour - Naked')
    {
      $ArmourClass = 0
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
#Damage per weapon is added to the index above
#This also should include weight and properties

#Custom Backstory
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

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
    $okButton.Text = 'OK'
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

    $backstorylabel = New-Object System.Windows.Forms.Label
    $backstorylabel.Location = New-Object System.Drawing.Point(10,20)
    $backstorylabel.Size = New-Object System.Drawing.Size(120,18)
    $backstorylabel.Text = 'Write your backstory:'
    $form.Controls.Add($backstorylabel)
    
    $characterbackstory = New-Object System.Windows.Forms.TextBox
    $characterbackstory.Location = New-Object System.Drawing.Point(10,40)
    $characterbackstory.Size = New-Object System.Drawing.Size(400,200)
    $characterbackstory.Multiline = 1
    $characterbackstory.ScrollBars = 2
    $characterbackstory.AcceptsReturn = 1
    $form.Controls.Add($characterbackstory)
    
    $form.Topmost = $true
    if ($characterbackstoryformdialog -eq [System.Windows.Forms.DialogResult]::OK)
    {
        $characterbackstory = $characterbackstory.Text
        $characterbackstory

    }
    if ($characterbackstoryformdialog -eq [System.Windows.Forms.DialogResult]::Ignore)
    {
        $characterbackstory = "N/A"
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

#Select Path for export
$SaveChooser = New-Object -Typename System.Windows.Forms.SaveFileDialog
    $SaveChooser.Title = "Save as"
    $SaveChooser.FileName = "D&D Avatar - ChangeMe"
    $SaveChooser.DefaultExt = ".pdf"
    $SaveChooser.Filter = 'PDF File (*.pdf)|*.pdf'
    $SaveResult = $SaveChooser.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }))
if($SaveResult){
    $PathSelected = $SaveChooser.FileName
    $PathSelected
}
#End of path selection

#PDF Values Import before save
#PLEASE LEAVE ALL "NULL" STATEMENTS ALONE AS THEY ARE MEANT TO BE LEFT NULL
$characterparameters = @{
    Fields = @{
        'ClassLevel' = $ClassLevel;
        'PlayerName' = $playername.Text;
        'CharacterName' = $charactername.Text;
        'Background' = $characterbackgroundselect.SelectedItem;
        'Race' = $ChosenRace.SelectedItem;
        'Alignment' = $ChosenAlignment.SelectedItem;
        'XP' = $XP;
        'Inspiration' = $Inspiration;
        'STR' = $STR;
        'ProfBonus' = $ProficencyBonus;
        'AC' = $ArmourClass;
        'Initiative' = $InitiativeTotal;
        'Speed' = $SpeedTotal;
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
        #'HD' =  ;
        'Flaws' = $Flaws;
        'INT' = $INT;
        'ST Dexterity' = $ST_DEX;
        'ST Constitution' = $ST_CON;
        'ST Intelligence' = $ST_INT;
        'ST Wisdom' = $ST_WIS;
        'ST Charisma' = $ST_CHA;
        #'Acrobatics' =  ;
        #'Animal' =  ;
        #'Athletics' =  ;
        #'Deception ' =  ;
        #'History ' =  ;
        'Wpn Name' = $selectweapon1panel.SelectedItem;
        'Wpn1 AtkBonus' = $WPN1ATK_Bonus;
        'Wpn1 Damage' = $WeaponDamageSimpleMelee.SelectedItem;
        #'Insight' =  ;
        #'Intimidation' =  ;
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
        'Wpn2 Damage' = $WeaponDamageMartialMelee.SelectedItem;
        #'Investigation ' =  ;
        'WIS' = $WIS;
        #'Arcana' =  ;
        #'Perception ' =  ;
        'WISmod' = $WISmod;
        'CHA' = $CHA;
        #'Nature' =  ;
        #'Performance' =  ;
        #'Medicine' =  ;
        #'Religion' =  ;
        #'Stealth ' =  ;
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
        #'Persuasion' =  ;
        'HPMax' = $HP;
        #'HPCurrent' = NULL;
        #'HPTemp' = NULL;
        'Wpn3 Damage ' = $WeapongDamageSimpleRanged.SelectedItem;
        #'SleightofHand' =  ;
        'CHamod' = $CHAmod;
        #'Survival' =  ;
        'AttacksSpellcasting' = $CombinedWeaponStats;
        #'Passive' =  ;
        #'CP' =  ;
        'ProficienciesLang' = $SpokenLanguages;
        #'SP' = ;
        #'EP' = ;
        #'GP' = ;
        #'PP' = ;
        #'Equipment' =  ;
        #'Features and Traits' =  ;
        'CharacterName 2' = $charactername.Text;
        'Age' = $age.Text;
        'Height' = $Playerheight;
        'Weight' = $PlayerSize;
        'Eyes' = $characterfeaturesselecteyes.SelectedItem;
        'Skin' = $characterfeaturesselectskin.SelectedItem;
        'Hair' = $characterfeaturesselecthair.SelectedItem;
        'CHARACTER IMAGE' = $CharacterImage;
        #'Faction Symbol Image' =  ;
        #'Allies' =  ;
        #'FactionName' =  ;
        'Backstory' = $characterbackstory.Text;
        #'Feat+Traits' =  ;
        'Treasure' = $Gold;
        #'Spellcasting Class 2' =  ;
        #'SpellcastingAbility 2' =  ;
        #'SpellSaveDC  2' =  ;
        #'SpellAtkBonus 2' =  ;
        #'SlotsTotal 19' =  ;
        #'SlotsRemaining 19' =  ;
        #'Spells 1014' =  ;
        #'Spells 1015' =  ;
        #'Spells 1016' =  ;
        #'Spells 1017' =  ;
        #'Spells 1018' =  ;
        #'Spells 1019' =  ;
        #'Spells 1020' =  ;
        #'Spells 1021' =  ;
        #'Spells 1022' =  ;
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
    InputPdfFilePath = ".\Assets\Empty_PDF\DnD_5E_CharacterSheet - Form Fillable.pdf"
    ITextSharpLibrary = '.\Assets\iText\itextsharp.dll'
    OutputPdfFilePath = $PathSelected
}
Save-PdfField @characterparameters

#'.\Exported_Characters\D&D Avatar - ChangeMe.pdf'

#End of character Creation Dialog box
Add-Type -AssemblyName PresentationCore,PresentationFramework
    $ButtonType = [System.Windows.MessageBoxButton]::Ok
    $MessageIcon = [System.Windows.MessageBoxImage]::Information
    $MessageBody = "Dungeons And Dragons Character Successfully Created!"
    $MessageTitle = "Spark's D&D Character Creator"
[System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)

#Script Created By (Sparks Skywere) - Christopher Masters
#END OF THE POWERSHELL SCRIPT