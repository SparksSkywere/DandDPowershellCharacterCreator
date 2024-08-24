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