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
    Write-Log "Console visibility set to: $($Show.IsPresent)" -Level DEBUG
}

# Improved logging function with levels
function Write-Log {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [ValidateSet('INFO', 'DEBUG', 'ERROR', 'WARN')]
        [string]$Level = 'INFO'
    )
    if ($global:DebugLoggingEnabled -or $Level -ne 'DEBUG') {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Write-Host "[$timestamp] $Level - $Message"
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

# Invoke-AppExit: Hard-stop the app from any UI path (Exit button / ESC key).
function Invoke-AppExit {
    param(
        [int]$Code = 0,
        [string]$Reason = "User requested exit"
    )

    Write-Log "Exiting application: $Reason" -Level INFO

    # Close WinForms loops first, then terminate the host process.
    try { [System.Windows.Forms.Application]::ExitThread() } catch {}
    try { [System.Windows.Forms.Application]::Exit() } catch {}

    try {
        [System.Environment]::Exit($Code)
    } catch {
        Stop-Process -Id $PID -Force
    }
}

# Change the line below to show debugging information
Show-Console -Hide
Write-Log "Console shown [Debugging Enabled]" -Level DEBUG

# Detect system language and load corresponding localisation file
function Set-Localisation {
    # Get the current system culture (e.g., "en-US" or "es-ES")
    $currentCulture = [System.Globalization.CultureInfo]::CurrentCulture.Name
    $languageCode = $currentCulture.Split('-')[0]

    $localisationPath = Join-Path $PSScriptRoot "Assets\Localisation\localisation.$languageCode.json"
    if (Test-Path $localisationPath) {
        try {
            $global:Localisation = Get-Content -Path $localisationPath -Raw -Encoding UTF8 | ConvertFrom-Json
            Write-Log "Loaded localisation for language: $languageCode" -Level DEBUG
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
        Write-Log "Loaded default localisation (English)" -Level DEBUG
    } catch {
        throw "[Debug] Failed to load the default localisation file."
    }
}

# Load the localisation based on system language
Set-Localisation

# Type loader, forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationCore,PresentationFramework

# Imports Modules + Add Types
Import-Module -Name "$PSScriptRoot\Assets\iText\PDFForm" | Out-Null
Add-Type -Path "$PSScriptRoot\Assets\iText\itextsharp.dll"

# Shared UI style values for consistent readability across all dialogs.
$script:UIStyle = @{
    FormFont = New-Object System.Drawing.Font("Segoe UI", 10)
    LabelFont = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    InputFont = New-Object System.Drawing.Font("Segoe UI", 10)
    ButtonFont = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    FormBackColor = [System.Drawing.Color]::FromArgb(246, 240, 240)
    SurfaceColor = [System.Drawing.Color]::FromArgb(253, 249, 249)
    AccentColor = [System.Drawing.Color]::FromArgb(166, 24, 32)
    InputBackColor = [System.Drawing.Color]::FromArgb(255, 252, 252)
    AccentTextColor = [System.Drawing.Color]::FromArgb(108, 16, 22)
    PrimaryButtonForeColor = [System.Drawing.Color]::White
    SecondaryButtonBackColor = [System.Drawing.Color]::FromArgb(248, 240, 240)
    SecondaryButtonBorderColor = [System.Drawing.Color]::FromArgb(205, 176, 178)
    ExitButtonBackColor = [System.Drawing.Color]::FromArgb(250, 230, 231)
    ExitButtonBorderColor = [System.Drawing.Color]::FromArgb(196, 92, 98)
    DisabledButtonBackColor = [System.Drawing.Color]::FromArgb(236, 228, 228)
    DisabledButtonForeColor = [System.Drawing.Color]::FromArgb(151, 141, 141)
    ButtonWidth = 96
    ButtonHeight = 34
    ButtonSpacing = 12
    ButtonPanelHeight = 64
    LabelHeight = 24
    VerticalGap = 32
    FormPadding = 24
    ColumnGap = 28
    SectionGap = 26
}

# Set-ProgramButtonStyle: Applies a consistent visual hierarchy to wizard actions.
function Set-ProgramButtonStyle {
    param (
        [System.Windows.Forms.Button]$Button,
        [string]$Action,
        [switch]$Disabled
    )

    $Button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $Button.UseVisualStyleBackColor = $false
    $Button.FlatAppearance.BorderSize = 1
    $Button.FlatAppearance.MouseDownBackColor = $script:UIStyle.SecondaryButtonBackColor
    $Button.FlatAppearance.MouseOverBackColor = $script:UIStyle.SurfaceColor
    $Button.ForeColor = $script:UIStyle.AccentTextColor
    $Button.BackColor = $script:UIStyle.SecondaryButtonBackColor
    $Button.FlatAppearance.BorderColor = $script:UIStyle.SecondaryButtonBorderColor
    $Button.Cursor = [System.Windows.Forms.Cursors]::Hand

    switch ($Action) {
        'accept' {
            $Button.BackColor = $script:UIStyle.AccentColor
            $Button.ForeColor = $script:UIStyle.PrimaryButtonForeColor
            $Button.FlatAppearance.BorderColor = $script:UIStyle.AccentColor
            $Button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(188, 36, 45)
            $Button.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(138, 18, 26)
        }
        'exit' {
            $Button.BackColor = $script:UIStyle.ExitButtonBackColor
            $Button.ForeColor = $script:UIStyle.AccentTextColor
            $Button.FlatAppearance.BorderColor = $script:UIStyle.ExitButtonBorderColor
            $Button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(245, 216, 218)
            $Button.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(236, 201, 204)
        }
        default {
            $Button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(251, 244, 244)
            $Button.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(240, 229, 229)
        }
    }

    if ($Disabled) {
        $Button.BackColor = $script:UIStyle.DisabledButtonBackColor
        $Button.ForeColor = $script:UIStyle.DisabledButtonForeColor
        $Button.FlatAppearance.BorderColor = $script:UIStyle.SecondaryButtonBorderColor
        $Button.FlatAppearance.MouseOverBackColor = $script:UIStyle.DisabledButtonBackColor
        $Button.FlatAppearance.MouseDownBackColor = $script:UIStyle.DisabledButtonBackColor
        $Button.Cursor = [System.Windows.Forms.Cursors]::Default
    }
}

# Get-ScaledFormBounds: Fits a requested form size within the active monitor working area.
function Get-ScaledFormBounds {
    param (
        [int]$RequestedWidth,
        [int]$RequestedHeight
    )

    $screen = [System.Windows.Forms.Screen]::FromPoint([System.Windows.Forms.Cursor]::Position)
    $workingArea = $screen.WorkingArea
    $horizontalPadding = 40
    $verticalPadding = 40
    $availableWidth = [Math]::Max(480, $workingArea.Width - $horizontalPadding)
    $availableHeight = [Math]::Max(360, $workingArea.Height - $verticalPadding)
    $width = [Math]::Min($RequestedWidth, $availableWidth)
    $height = [Math]::Min($RequestedHeight, $availableHeight)
    $minimumWidth = [Math]::Min(640, $availableWidth)
    $minimumHeight = [Math]::Min(480, $availableHeight)

    return @{
        Size = New-Object System.Drawing.Size($width, $height)
        MinimumSize = New-Object System.Drawing.Size($minimumWidth, $minimumHeight)
        MaximumSize = New-Object System.Drawing.Size($availableWidth, $availableHeight)
    }
}

# Save-ResponsiveControlLayout: Captures original bounds and font data for proportional resizing.
function Save-ResponsiveControlLayout {
    param (
        [System.Windows.Forms.Control]$Parent,
        [hashtable]$LayoutState
    )

    foreach ($control in $Parent.Controls) {
        if ($control.Dock -ne [System.Windows.Forms.DockStyle]::None) {
            continue
        }

        $LayoutState.Controls[$control] = @{
            Bounds = New-Object System.Drawing.Rectangle($control.Left, $control.Top, $control.Width, $control.Height)
            FontFamily = $control.Font.FontFamily
            FontSize = $control.Font.Size
            FontStyle = $control.Font.Style
        }

        if ($control.Controls.Count -gt 0) {
            Save-ResponsiveControlLayout -Parent $control -LayoutState $LayoutState
        }
    }
}

# Update-ResponsiveControlLayout: Resizes controls proportionally from their captured baseline state.
function Update-ResponsiveControlLayout {
    param (
        [hashtable]$LayoutState,
        [int]$ClientWidth,
        [int]$ClientHeight
    )

    if (-not $LayoutState -or -not $LayoutState.BaselineSize -or $LayoutState.BaselineSize.Width -le 0 -or $LayoutState.BaselineSize.Height -le 0) {
        return
    }

    $scaleX = $ClientWidth / [double]$LayoutState.BaselineSize.Width
    $scaleY = $ClientHeight / [double]$LayoutState.BaselineSize.Height
    $fontScale = [Math]::Max(0.85, [Math]::Min(1.4, [Math]::Min($scaleX, $scaleY)))

    foreach ($entry in $LayoutState.Controls.GetEnumerator()) {
        $control = $entry.Key
        $metadata = $entry.Value

        if ($null -eq $control -or $control.IsDisposed) {
            continue
        }

        $originalBounds = $metadata.Bounds
        $newLeft = [int][Math]::Round($originalBounds.Left * $scaleX)
        $newTop = [int][Math]::Round($originalBounds.Top * $scaleY)
        $newWidth = [int][Math]::Round($originalBounds.Width * $scaleX)
        $newHeight = [int][Math]::Round($originalBounds.Height * $scaleY)

        $control.SetBounds(
            $newLeft,
            $newTop,
            [Math]::Max(48, $newWidth),
            [Math]::Max(22, $newHeight)
        )

        $newFontSize = [Math]::Max(8, [Math]::Round($metadata.FontSize * $fontScale, 1))
        $control.Font = New-Object System.Drawing.Font($metadata.FontFamily, $newFontSize, $metadata.FontStyle)
    }
}

# Register-ResponsiveFormLayout: Enables proportional resizing for controls added to shared dialog forms.
function Register-ResponsiveFormLayout {
    param (
        [System.Windows.Forms.Form]$Form
    )

    $responsiveForm = $Form
    $responsiveState = @{
        LayoutState = $null
        IsApplying = $false
    }

    $initializeLayoutHandler = {
        param($sender)

        if ($null -ne $responsiveState.LayoutState) {
            return
        }

        $layoutState = @{
            BaselineSize = New-Object System.Drawing.Size($sender.ClientSize.Width, $sender.ClientSize.Height)
            Controls = @{}
        }

        Save-ResponsiveControlLayout -Parent $sender -LayoutState $layoutState
        $responsiveState.LayoutState = $layoutState
    }.GetNewClosure()

    $shownHandler = {
        param($sender, $e)

        & $initializeLayoutHandler $sender
    }.GetNewClosure()

    $resizeHandler = {
        param($sender, $e)

        & $initializeLayoutHandler $sender

        if ($null -eq $responsiveState.LayoutState -or $responsiveState.IsApplying) {
            return
        }

        $responsiveState.IsApplying = $true
        try {
            Update-ResponsiveControlLayout -LayoutState $responsiveState.LayoutState -ClientWidth $sender.ClientSize.Width -ClientHeight $sender.ClientSize.Height
        } finally {
            $responsiveState.IsApplying = $false
        }
    }.GetNewClosure()

    $closedHandler = {
        param($sender, $e)

        $responsiveState.LayoutState = $null
        $responsiveState.IsApplying = $false
    }.GetNewClosure()

    $responsiveForm.Add_Shown($shownHandler)
    $responsiveForm.Add_Resize($resizeHandler)
    $responsiveForm.Add_FormClosed($closedHandler)
}

# New-ProgramForm: Creates a standard wizard-style form with explicit button actions.
function New-ProgramForm {
    param (
        [string]$Title,
        [int]$Width = 720,
        [int]$Height = 520,
        [string]$AcceptButtonText = "OK",
        [string]$SkipButtonText = "Skip",
        [string]$CancelButtonText = "Exit",
        [string]$BackButtonText = "Back",
        [switch]$ShowBackButton = $true,
        [switch]$DisableBackButton = $false
    )

    $formBounds = Get-ScaledFormBounds -RequestedWidth $Width -RequestedHeight $Height

    $form = New-Object System.Windows.Forms.Form
    $form.Text = $Title
    $form.Size = $formBounds.Size
    $form.MinimumSize = $formBounds.MinimumSize
    $form.MaximumSize = $formBounds.MaximumSize
    $form.StartPosition = 'CenterScreen'
    $form.Font = $script:UIStyle.FormFont
    $form.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::Dpi
    $form.AutoScroll = $true
    $form.MaximizeBox = $false
    $form.BackColor = $script:UIStyle.FormBackColor
    
    # Try to load the icon, but keep the form background color-driven so controls remain readable.
    try {
        $form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$PSScriptRoot\Assets\installer.ico")
    } catch {
        Write-Log "Could not load form icon: $_" -Level WARN
    }

    $headerStrip = New-Object System.Windows.Forms.Panel
    $headerStrip.Dock = [System.Windows.Forms.DockStyle]::Top
    $headerStrip.Height = 10
    $headerStrip.BackColor = $script:UIStyle.AccentColor
    SafeAddControl $form $headerStrip

    # Create button panel
    $buttonPanel = New-Object System.Windows.Forms.Panel
    $buttonPanel.Dock = [System.Windows.Forms.DockStyle]::Bottom
    $buttonPanel.Height = $script:UIStyle.ButtonPanelHeight
    $buttonPanel.BackColor = $script:UIStyle.SurfaceColor
    SafeAddControl $form $buttonPanel

    $baseClientSize = New-Object System.Drawing.Size($form.ClientSize.Width, $form.ClientSize.Height)
    $footerMetrics = @{
        PanelHeight = $script:UIStyle.ButtonPanelHeight
        ButtonWidth = $script:UIStyle.ButtonWidth
        ButtonHeight = $script:UIStyle.ButtonHeight
        ButtonSpacing = $script:UIStyle.ButtonSpacing
        PanelPadding = 10
        FontSize = $script:UIStyle.ButtonFont.Size
    }
    $baseButtonFont = $script:UIStyle.ButtonFont

    # Create buttons with explicit action identifiers
    $buttons = @()
    
    # Exit button first so it appears away from the primary Next/Accept action
    $buttons += @{
        Text = $CancelButtonText
        Action = 'exit'
    }
    
    # Skip button
    $buttons += @{
        Text = $SkipButtonText
        Action = 'skip'
    }
    
    # Back button (conditionally added)
    if ($ShowBackButton) {
        $buttons += @{
            Text = $BackButtonText
            Action = 'back'
        }
    }
    
    # Accept button last so it remains the right-most primary action
    $buttons += @{
        Text = $AcceptButtonText
        Action = 'accept'
    }

    # Calculate right-aligned button positions for a clearer wizard flow.
    $buttonCount = $buttons.Count

    $layoutButtons = {
        param($sender, $e)

        $targetPanel = if ($sender -is [System.Windows.Forms.Panel]) { $sender } else { $buttonPanel }
        if ($null -eq $targetPanel -or $targetPanel.IsDisposed) {
            return
        }

        $safeFontSize = [single]$script:UIStyle.ButtonFont.Size
        if ($footerMetrics -and $footerMetrics.ContainsKey('FontSize') -and $footerMetrics.FontSize) {
            $safeFontSize = [single]$footerMetrics.FontSize
        }
        if ($safeFontSize -le 0) {
            $safeFontSize = 8
        }

        $targetPanel.Height = $footerMetrics.PanelHeight
        $buttonY = [int](($targetPanel.Height - $footerMetrics.ButtonHeight) / 2)
        $localButtonX = $targetPanel.Width - (($footerMetrics.ButtonWidth + $footerMetrics.ButtonSpacing) * $buttonCount) - $footerMetrics.PanelPadding
        if ($localButtonX -lt $footerMetrics.PanelPadding) { $localButtonX = $footerMetrics.PanelPadding }
        foreach ($ctrl in $targetPanel.Controls) {
            if ($ctrl -is [System.Windows.Forms.Button]) {
                $ctrl.Font = New-Object System.Drawing.Font("Segoe UI", [single]$safeFontSize, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Point)
                $ctrl.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
                $ctrl.Location = New-Object System.Drawing.Point($localButtonX, $buttonY)
                $ctrl.Size = New-Object System.Drawing.Size($footerMetrics.ButtonWidth, $footerMetrics.ButtonHeight)
                $localButtonX += ($footerMetrics.ButtonWidth + $footerMetrics.ButtonSpacing)
            }
        }
    }.GetNewClosure()

    $updateFooterMetrics = {
        param($sender, $e)

        $targetForm = if ($sender -is [System.Windows.Forms.Form]) { $sender } else { $form }
        if ($null -eq $targetForm -or $targetForm.IsDisposed) {
            return
        }

        $currentClientWidth = [Math]::Max(1, $targetForm.ClientSize.Width)
        $currentClientHeight = [Math]::Max(1, $targetForm.ClientSize.Height)

        # Scale footer directly from current form dimensions so resizing is always visible.
        $footerMetrics.PanelHeight = [Math]::Max(54, [Math]::Min(140, [int][Math]::Round($currentClientHeight * 0.14)))
        $footerMetrics.ButtonSpacing = [Math]::Max(8, [Math]::Min(24, [int][Math]::Round($currentClientWidth * 0.012)))
        $footerMetrics.PanelPadding = [Math]::Max(8, [Math]::Min(36, [int][Math]::Round($currentClientWidth * 0.01)))

        $availableButtonRowWidth = [Math]::Max(200, $currentClientWidth - ($footerMetrics.PanelPadding * 2))
        $targetButtonWidth = [int][Math]::Floor(($availableButtonRowWidth - (($buttonCount - 1) * $footerMetrics.ButtonSpacing)) / [Math]::Max(1, $buttonCount))
        $footerMetrics.ButtonWidth = [Math]::Max(82, [Math]::Min(220, $targetButtonWidth))

        $footerMetrics.ButtonHeight = [Math]::Max(30, [Math]::Min(72, [int][Math]::Round($footerMetrics.PanelHeight * 0.58)))
        $footerMetrics.FontSize = [Math]::Max(8, [Math]::Min(16, [Math]::Round($footerMetrics.ButtonHeight * 0.34, 1)))
        & $layoutButtons $buttonPanel $null
    }.GetNewClosure()

    foreach ($buttonInfo in $buttons) {
        $button = New-Object System.Windows.Forms.Button
        $button.Location = New-Object System.Drawing.Point(0, 0)
        $button.Size = New-Object System.Drawing.Size($footerMetrics.ButtonWidth, $footerMetrics.ButtonHeight)
        $button.Text = $buttonInfo.Text
        $button.Font = $script:UIStyle.ButtonFont
        $button.UseCompatibleTextRendering = $true
        $button.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $button.Margin = New-Object System.Windows.Forms.Padding(6, 4, 6, 4)
        $button.Tag = $buttonInfo.Action
        Set-ProgramButtonStyle -Button $button -Action $buttonInfo.Action
        if ($buttonInfo.Action -eq 'back' -and $DisableBackButton) {
            # Keep a stable layout while making Back visibly unavailable on the first step.
            $button.Enabled = $false
            $button.TabStop = $false
            Set-ProgramButtonStyle -Button $button -Action $buttonInfo.Action -Disabled
        }
        $button.Add_Click({
            param($sender, $e)
            # Persist the clicked button action for Show-Form and close this dialog.
            $form.Tag = [string]$sender.Tag
            $form.Close()
        })
        SafeAddControl $buttonPanel $button
    }

    # Reflow button row when the form is resized (DPI / accessibility friendly).
    $buttonPanel.Add_Resize($layoutButtons)
    $form.Add_Resize($updateFooterMetrics)
    $form.Add_SizeChanged($updateFooterMetrics)
    $form.Add_Shown($updateFooterMetrics)
    & $layoutButtons $buttonPanel $null
    & $updateFooterMetrics $form $null

    Register-ResponsiveFormLayout -Form $form

    # Set keyboard shortcuts for navigation
    $form.KeyPreview = $true
    $form.Add_KeyDown({
        param($sender, $e)
        if ($e.KeyCode -eq 'Enter') {
            $form.Tag = 'accept'
            $form.Close()
        }
        elseif ($e.KeyCode -eq 'Escape') {
            # ESC maps to the same action as the Exit button
            $form.Tag = 'exit'
            $form.Close()
        }
    })

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
    $label.Size = New-Object System.Drawing.Size($Width, $script:UIStyle.LabelHeight)
    $label.Text = $LabelText
    $label.Font = $script:UIStyle.LabelFont
    $label.AutoEllipsis = $true
    $label.BackColor = [System.Drawing.Color]::Transparent

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Point([int]$X, [int]($Y + $script:UIStyle.VerticalGap))
    $textBox.Size = New-Object System.Drawing.Size($Width, $Height)
    $textBox.MaxLength = $MaxLength
    $textBox.Font = $script:UIStyle.InputFont
    $textBox.Margin = New-Object System.Windows.Forms.Padding(6, 4, 6, 4)
    $textBox.BackColor = $script:UIStyle.InputBackColor
    $textBox.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle

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
        [string]$DisplayMember = ""
    )
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point([int]$X, [int]$Y)
    $label.Size = New-Object System.Drawing.Size($Width, $script:UIStyle.LabelHeight)
    $label.Text = $LabelText
    $label.Font = $script:UIStyle.LabelFont
    $label.AutoEllipsis = $true
    $label.BackColor = [System.Drawing.Color]::Transparent

    $listBox = New-Object System.Windows.Forms.ListBox
    $listBox.Location = New-Object System.Drawing.Point([int]$X, [int]($Y + $script:UIStyle.VerticalGap))
    $listBox.Size = New-Object System.Drawing.Size($Width, $Height)
    $listBox.DataSource = [System.Collections.ArrayList]$DataSource
    if (-not [string]::IsNullOrWhiteSpace($DisplayMember)) {
        $listBox.DisplayMember = $DisplayMember
    }
    $listBox.Font = $script:UIStyle.InputFont
    $listBox.IntegralHeight = $false
    $listBox.BackColor = $script:UIStyle.InputBackColor
    $listBox.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle

    return @($label, $listBox)
}

# Get-SelectedListValue: Returns the selected list item as a string for both objects and plain text items.
function Get-SelectedListValue {
    param(
        [System.Windows.Forms.ListBox]$ListBox
    )

    if ($null -eq $ListBox -or $null -eq $ListBox.SelectedItem) {
        return $null
    }

    $selectedItem = $ListBox.SelectedItem

    if ($selectedItem -is [string]) {
        return $selectedItem
    }

    if ($selectedItem.PSObject.Properties['Name']) {
        return [string]$selectedItem.Name
    }

    return [string]$selectedItem
}

# Show-Form: Displays a form and routes by explicit action tag (accept/skip/back/exit).
function Show-Form {
    param (
        [System.Windows.Forms.Form]$form,
        [ScriptBlock]$onOK,
        [ScriptBlock]$onIgnore,
        [ScriptBlock]$onBack,
        [ScriptBlock]$onCancel
    )

    $form.Topmost = $true
    $form.Add_Shown({$form.Activate()})

    Write-Log "Showing form: $($form.Text)" -Level DEBUG

    # Reset action and show the dialog.
    $form.Tag = $null
    [void]$form.ShowDialog()

    switch ($form.Tag) {
        'accept' {
            # User clicked Next/Accept - run the acceptance handler and move forward
            $script:NavDirection = 1
            & $onOK
        }
        'skip' {
            # User clicked Skip - treat as forward without saving data
            $script:NavDirection = 1
            if ($onIgnore) { & $onIgnore }
        }
        'back' {
            # Back button action
            Write-Log "Back button clicked" -Level DEBUG
            $script:NavDirection = -1
            # Call the explicit back handler if one was provided
            if ($onBack) { & $onBack }
        }
        'exit' {
            # Exit pressed - close the app immediately
            Write-Log "Character creation cancelled by user" -Level INFO
            $script:NavDirection = 0
            # Force termination from here so all forms behave consistently.
            Invoke-AppExit -Code 0 -Reason "Exit button pressed"
        }
        default {
            # Closed window by title-bar X or other non-button route: treat as exit.
            Write-Log "Form closed without explicit action; exiting" -Level WARN
            $script:NavDirection = 0
            Invoke-AppExit -Code 0 -Reason "Form closed without explicit action"
        }
    }
}

# Optimize JSON loading with caching
$script:JsonCache = @{}
function Get-JsonData {
    param (
        [string]$path
    )
    if ($script:JsonCache.ContainsKey($path)) {
        return $script:JsonCache[$path]
    }
    
    try {
        $jsonFiles = Get-ChildItem -Path $path -Filter *.json -ErrorAction Stop
        $data = @()
        foreach ($file in $jsonFiles) {
            $content = Get-Content -Path $file.FullName -Raw -ErrorAction Stop
            $jsonData = $content | ConvertFrom-Json -ErrorAction Stop
            $data += $jsonData
        }
        $script:JsonCache[$path] = $data
        return $data
    } catch {
        Write-Log "Failed to load JSON from path: $path. Error: $($_.Exception.Message)" -Level ERROR
        throw
    }
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
$global:CharacterImage = [string]$defaultJSON.PlayerIcon
$global:ImageSelected = $false
if (-not [string]::IsNullOrWhiteSpace($global:CharacterImage)) {
    $resolvedDefaultIconPath = $global:CharacterImage
    if (-not [System.IO.Path]::IsPathRooted($resolvedDefaultIconPath)) {
        $resolvedDefaultIconPath = Join-Path $PSScriptRoot $resolvedDefaultIconPath
    }

    if (Test-Path -LiteralPath $resolvedDefaultIconPath) {
        $global:CharacterImage = $resolvedDefaultIconPath
        $global:ImageSelected = $true
    } else {
        Write-Log "Default PlayerIcon path not found: $resolvedDefaultIconPath" -Level WARN
        $global:CharacterImage = $null
    }
}
$global:PersonalityTraits = $defaultJSON.PersonalityTraits
$global:ProficencyBonus = $defaultJSON.ProficencyBonus
$global:Class = $defaultJSON.ClassLevel
$global:HP = $defaultJSON.HP
$global:HD = $defaultJSON.HD
$global:Speed = $defaultJSON.SpeedTotal
$global:STR = $defaultJSON.STR
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
Write-Log "Loaded Defaults" -Level DEBUG

# Initialize default class and race objects to prevent errors
$global:SelectedClass = @{
    SavingThrows = @()
    InitiativeBonus = 0
    SkillProficiencies = @()
    HitDice = 8
    SpellCastingClass = ""
    SpellCastingAbility = ""
    SpellCastingSaveDC = 0
}
$global:SelectedRace = @{
    Name = "Human"
    image = "Human.png"
}

# Initialize other variables that might be needed
$global:Weapon1Weight = 0
$global:Weapon2Weight = 0 
$global:Weapon3Weight = 0
$global:GearWeight = 0
$global:ArmourWeight = 0

# Function to calculate ability modifiers and other derived stats
function CharacterStats {
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
        $global:ProficiencyBonus = 2
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
    Write-Log "Initiative = $global:InitiativeTotal" -Level DEBUG

    # Calculate passive perception
    $global:Passive = 10 + $global:WISMod
    if ($global:SelectedClass.SkillProficiencies -contains 'Perception') {
        $global:Passive += $global:ProficiencyBonus
    }

    # Calculate hit points
    $global:HPMax = ($global:HD * $level) + ($global:CONMod * $level)
    Write-Log "Total HP = $global:HPMax" -Level DEBUG

    # Calculate encumbrance
    $global:TotalWeightCarried = ($global:Weapon1Weight + $global:Weapon2Weight + $global:Weapon3Weight + $global:GearWeight + $global:ArmourWeight)
    $global:EncumbranceThreshold = $global:STR * 15 
    if ($global:TotalWeightCarried -gt $global:EncumbranceThreshold) {
        $global:Speed = [math]::Max(0, $global:Speed - 10)
        Write-Log "Character is over-encumbered. Speed reduced to $global:Speed." -Level DEBUG
    } else {
        Write-Log "Character is not over-encumbered. Speed remains at $global:Speed." -Level DEBUG
    }

    # Calculate spell slots
    if ($global:SpellCastingClass) {
        $global:SpellSlots = Get-SpellSlots -class $global:SpellCastingClass -level $level
        Write-Log "SpellSlots = $global:SpellSlots" -Level DEBUG
    }

        # Calculate SpellCastingAttackBonus
        switch ($global:SpellCastingAbility) {
            'INT' { $spellCastingAbilityMod = $global:INTMod }
            'WIS' { $spellCastingAbilityMod = $global:WISMod }
            'CHA' { $spellCastingAbilityMod = $global:CHAMod }
            default { $spellCastingAbilityMod = 0 }
        }
        
        $global:SpellCastingAttackBonus = $spellCastingAbilityMod + $global:ProficiencyBonus
        Write-Log "SpellCastingAttackBonus = $global:SpellCastingAttackBonus" -Level DEBUG
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

# Function to roll 4d6 and drop the lowest
function Roll-Stat {
    $rolls = @()
    for ($i = 0; $i -lt 4; $i++) {
        $rolls += Get-Random -Minimum 1 -Maximum 7
    }
    $rolls = $rolls | Sort-Object -Descending
    $total = ($rolls[0] + $rolls[1] + $rolls[2])
    Write-Log "Rolled 4d6: $($rolls -join ',') - Total: $total" -Level DEBUG
    return $total
}

# Form state management - tracks navigation history and current position
$script:FormState = @{
    CurrentForm = $null
    PreviousForm = $null
    FormData = @{}
    History = @()
    CurrentFormIndex = -1
}
# Shared navigation direction flag: 1 = forward, -1 = back, 0 = cancel
$script:NavDirection = 1

# New-DndForm: Wrapper around ProgramForm that accepts a hashtable of controls and
# wires up the Accept/Back/Cancel script blocks via Show-Form automatically.
function New-DndForm {
    param (
        [string]$Title,
        [hashtable]$Controls,
        [scriptblock]$OnAccept,
        [scriptblock]$OnCancel,
        [scriptblock]$OnBack,  # Optional - called when Back is pressed (overrides NavDirection default)
        [switch]$HideBackButton
    )
    
    $form = New-ProgramForm -Title $Title -Width 720 -Height 520 `
        -AcceptButtonText $global:Localisation.AcceptButtonText `
        -SkipButtonText $global:Localisation.SkipButtonText `
        -CancelButtonText "Exit" `
        -BackButtonText $(if ([string]::IsNullOrWhiteSpace([string]$global:Localisation.BackButtonText)) { "Back" } else { [string]$global:Localisation.BackButtonText }) `
        -ShowBackButton $true `
        -DisableBackButton $HideBackButton

    if ($null -eq $form) {
        throw "Failed to create form '$Title'."
    }

    # Modified to handle array of controls properly
    foreach ($control in $Controls.GetEnumerator()) {
        if ($control.Value -is [Array]) {
            foreach ($ctrl in $control.Value) {
                SafeAddControl $form $ctrl
            }
        } else {
            SafeAddControl $form $control.Value
        }
    }

    $form.Add_Shown({ $form.Activate() })
    $script:FormState.CurrentForm = $form
    
    Show-Form -form $form -onOK $OnAccept -onBack $OnBack -onCancel $OnCancel
}

# Test-RequiredFields: Returns $false and logs an error if any named field in the hashtable is blank.
function Test-RequiredFields {
    param (
        [hashtable]$Fields,
        [string[]]$Required
    )
    
    foreach ($field in $Required) {
        if ([string]::IsNullOrWhiteSpace($Fields[$field])) {
            Write-Log "Required field '$field' is empty" -Level ERROR
            return $false
        }
    }
    return $true
}

# Character state management
$script:CharacterState = @{
    BasicInfo = @{}
    Stats = @{}
    Equipment = @{}
    Skills = @{}
}

# Show-BasicInfoForm: First step in the wizard - collects character name, player name, and age.
# The Back button is hidden here because there is no previous step.
function Show-BasicInfoForm {
    Write-Log "Displaying Basic Info Form" -Level DEBUG
    
    $controls = @{
        CharacterName = Set-TextBox -LabelText $global:Localisation.CharacterNameLabel -X 24 -Y 24 -Width 300 -Height 28 -MaxLength 30
        Age = Set-TextBox -LabelText "Age:" -X 24 -Y 108 -Width 96 -Height 28 -MaxLength 3
        PlayerName = Set-TextBox -LabelText $global:Localisation.PlayerNameLabel -X 24 -Y 192 -Width 300 -Height 28 -MaxLength 30
        PlayerIcon = Set-TextBox -LabelText "Player Icon (optional):" -X 24 -Y 276 -Width 400 -Height 28 -MaxLength 1024
    }

    $controls.PlayerIcon[1].ReadOnly = $true

    $playerIconBrowseButton = New-Object System.Windows.Forms.Button
    $playerIconBrowseButton.Text = "Browse..."
    $playerIconBrowseButton.Location = New-Object System.Drawing.Point(436, 299)
    $playerIconBrowseButton.Size = New-Object System.Drawing.Size(92, 30)
    Set-ProgramButtonStyle -Button $playerIconBrowseButton -Role Secondary

    $playerIconClearButton = New-Object System.Windows.Forms.Button
    $playerIconClearButton.Text = "Clear"
    $playerIconClearButton.Location = New-Object System.Drawing.Point(538, 299)
    $playerIconClearButton.Size = New-Object System.Drawing.Size(74, 30)
    Set-ProgramButtonStyle -Button $playerIconClearButton -Role Ghost

    if ($global:ImageSelected -and -not [string]::IsNullOrWhiteSpace([string]$global:CharacterImage)) {
        $controls.PlayerIcon[1].Text = [string]$global:CharacterImage
    }

    $playerIconBrowseButton.Add_Click({
        $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $fileDialog.Title = "Select Player Icon"
        $fileDialog.Filter = "Image Files (*.png;*.jpg;*.jpeg;*.bmp;*.gif;*.webp)|*.png;*.jpg;*.jpeg;*.bmp;*.gif;*.webp|All Files (*.*)|*.*"
        $fileDialog.CheckFileExists = $true
        $fileDialog.Multiselect = $false

        if ($fileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $controls.PlayerIcon[1].Text = $fileDialog.FileName
        }
    })

    $playerIconClearButton.Add_Click({
        $controls.PlayerIcon[1].Text = ""
    })

    $controls.PlayerIconBrowse = $playerIconBrowseButton
    $controls.PlayerIconClear = $playerIconClearButton

    # Set tab order: CharacterName (0) -> Age (1) -> PlayerName (2) -> PlayerIcon (3) -> Browse/Clear
    $controls.CharacterName[1].TabIndex = 0
    $controls.Age[1].TabIndex = 1
    $controls.PlayerName[1].TabIndex = 2
    $controls.PlayerIcon[1].TabIndex = 3
    $playerIconBrowseButton.TabIndex = 4
    $playerIconClearButton.TabIndex = 5

    # Add KeyPress event handler to Age textbox to only allow numbers
    $controls.Age[1].Add_KeyPress({
        param($s, $e)
        if (-not [char]::IsDigit($e.KeyChar) -and $e.KeyChar -ne [char]8) {
            $e.Handled = $true
        }
    })
    
    New-DndForm -Title $global:Localisation.FormTitle -Controls $controls -HideBackButton -OnAccept {
        $selectedPlayerIconPath = [string]$controls.PlayerIcon[1].Text
        if (-not [string]::IsNullOrWhiteSpace($selectedPlayerIconPath)) {
            if (Test-Path -LiteralPath $selectedPlayerIconPath) {
                $global:CharacterImage = $selectedPlayerIconPath
                $global:ImageSelected = $true
                Write-Log "Custom player icon selected: $selectedPlayerIconPath" -Level DEBUG
            } else {
                [System.Windows.Forms.MessageBox]::Show("The selected player icon file cannot be found.", "Invalid Player Icon",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Warning)
                return
            }
        } else {
            $global:CharacterImage = $null
            $global:ImageSelected = $false
        }

        $script:CharacterState.BasicInfo = @{
            CharacterName = $controls.CharacterName[1].Text
            Age = $controls.Age[1].Text
            PlayerName = $controls.PlayerName[1].Text
        }
        
        # Additional validation for age
        if (-not [string]::IsNullOrEmpty($controls.Age[1].Text)) {
            try {
                $age = [int]$controls.Age[1].Text
                if ($age -lt 1 -or $age -gt 999) {
                    [System.Windows.Forms.MessageBox]::Show("Age must be between 1 and 999.", "Invalid Age", 
                        [System.Windows.Forms.MessageBoxButtons]::OK, 
                        [System.Windows.Forms.MessageBoxIcon]::Warning)
                    return
                }
            } catch {
                [System.Windows.Forms.MessageBox]::Show("Age must be a valid number.", "Invalid Age", 
                    [System.Windows.Forms.MessageBoxButtons]::OK, 
                    [System.Windows.Forms.MessageBoxIcon]::Warning)
                return
            }
        }
        
        if (-not (Test-RequiredFields -Fields $script:CharacterState.BasicInfo -Required @('CharacterName', 'PlayerName'))) {
            return
        }
        
        Write-Log "Basic info captured successfully" -Level INFO
        $global:WrittenCharactername = $controls.CharacterName[1].Text
        $global:WrittenAge = $controls.Age[1].Text
        $global:WrittenPlayername = $controls.PlayerName[1].Text
        Write-Log "Age set to: $global:WrittenAge" -Level DEBUG
    } -OnCancel {
        exit
    }
}

# Show-RaceForm: Lets the user pick their character's race and background.
# Race data drives HP, speed, size, languages, and stat modifiers.
function Show-RaceForm {
    Write-Log "Displaying Race Form" -Level DEBUG
    $form = New-ProgramForm -Title 'Sparks D&D Character Creator' -Width 640 -Height 460 -AcceptButtonText 'Next' -SkipButtonText 'Skip' -CancelButtonText 'Exit'

    $backgroundControls = Set-ListBox -LabelText 'Select a Background:' -X 24 -Y 24 -Width 270 -Height 260 -DataSource $CharacterBackgroundJSON -DisplayMember 'name'
    $raceControls = Set-ListBox -LabelText 'Select a Race:' -X 322 -Y 24 -Width 270 -Height 260 -DataSource $RacesJSON -DisplayMember 'name'

    SafeAddRange $form $backgroundControls
    SafeAddRange $form $raceControls

    # Route through Show-Form - Back sets NavDirection = -1, returning to BasicInfo via Navigate-Forms
    Show-Form -form $form -onOK {
        $global:ExportBackground = $backgroundControls[1].SelectedItem.Name
        $global:SelectedRace = $raceControls[1].SelectedItem
        $global:ExportRace = $global:SelectedRace.Name
        # Race description populates the Features and Traits field on the sheet
        $global:Feature1TTraits1 = $global:SelectedRace.Description
        $global:HP = $global:SelectedRace.HP
        $global:Speed = $global:SelectedRace.Speed
        $global:Size = $global:SelectedRace.Size
        $global:Height = $global:SelectedRace.Height
        $global:SpokenLanguages = $global:SelectedRace.Languages
        $global:Special = $global:SelectedRace.Special
        # Racial ability score modifiers - applied on top of the point-buy values
        $global:STRMod = $global:SelectedRace.StrengthMod
        $global:DEXMod = $global:SelectedRace.DexterityMod
        $global:CONMod = $global:SelectedRace.ConstitutionMod
        $global:INTMod = $global:SelectedRace.IntelligenceMod
        $global:WISMod = $global:SelectedRace.WisdomMod
        $global:CHAMod = $global:SelectedRace.CharismaMod
        # Use the race's default art if the user has not chosen a custom image
        if (-not $global:ImageSelected) {
            $raceImageName = [string]$global:SelectedRace.image
            if (-not [string]::IsNullOrWhiteSpace($raceImageName)) {
                $raceImagePath = Join-Path $PSScriptRoot "Assets\Races\Images\$raceImageName"
                if (Test-Path -LiteralPath $raceImagePath) {
                    $global:CharacterImage = $raceImagePath
                    Write-Log "Default race image set: $($global:CharacterImage)" -Level DEBUG
                } else {
                    $global:CharacterImage = $null
                    Write-Log "Race image not found for '$($global:SelectedRace.Name)': $raceImagePath" -Level WARN
                }
            } else {
                $global:CharacterImage = $null
                Write-Log "No race image metadata found for '$($global:SelectedRace.Name)'" -Level WARN
            }
        }
        Write-Log "Background: $global:ExportBackground" -Level DEBUG
        Write-Log "Race: $($global:SelectedRace.Name)" -Level DEBUG
    } -onIgnore {
        # Skip - keep default race values
        Write-Log "Race and background selection skipped" -Level DEBUG
    } -onCancel {
        exit
    }
}

# Show-SubRaceForm: Lets the user pick a subrace for races that have them.
# Skipped automatically by Navigate-Forms if no subraces exist.
function Show-SubRaceForm {
    Write-Log "Displaying SubRace Form" -Level DEBUG
    $form = New-ProgramForm -Title 'Sparks D&D Character Creator' -Width 680 -Height 460 -AcceptButtonText 'Next' -SkipButtonText 'Skip' -CancelButtonText 'Exit'

    if ($global:SelectedRace.subraces -and $global:SelectedRace.subraces.Count -gt 0) {
        # Build the subrace list only when the selected race actually has subraces
        $subRaceControls = Set-ListBox -LabelText 'Select a SubRace:' -X 24 -Y 24 -Width 610 -Height 280 -DataSource $global:SelectedRace.subraces -DisplayMember 'name'
        SafeAddRange $form $subRaceControls

        # Route through Show-Form so Back and Cancel are handled consistently
        Show-Form -form $form -onOK {
            $global:SelectedSubRace = $subRaceControls[1].SelectedItem
            $global:ExportSubrace = $global:SelectedSubRace.Name
            Write-Log "SelectedSubRace: $($global:SelectedSubRace)" -Level DEBUG
            Write-Log "ExportSubrace: $($global:ExportSubrace)" -Level DEBUG
        } -onIgnore {
            # Skip pressed - leave subrace unset
            Write-Log "SubRace selection skipped" -Level DEBUG
        } -onCancel { exit }
    } else {
        # No subraces for this race - treat as a transparent forward step
        Write-Log "No subraces available for the selected race - skipping SubRace form" -Level DEBUG
    }
}

# Show-CharacterFeaturesForm: Lets the user choose physical appearance - eyes, hair, and skin.
function Show-CharacterFeaturesForm {
    Write-Log "Displaying Character Features Form" -Level DEBUG
    $form = New-ProgramForm -Title 'Sparks D&D Character Creator' -Width 680 -Height 460 -AcceptButtonText 'Next' -SkipButtonText 'Skip' -CancelButtonText 'Exit'

    # Three side-by-side list boxes for appearance options
    $eyesControls = Set-ListBox -LabelText 'Select Eyes:' -X 24 -Y 24 -Width 180 -Height 240 -DataSource $EyesJSON -DisplayMember 'name'
    $hairControls = Set-ListBox -LabelText 'Select Hair:' -X 230 -Y 24 -Width 180 -Height 240 -DataSource $HairJSON -DisplayMember 'name'
    $skinControls = Set-ListBox -LabelText 'Select Skin:' -X 436 -Y 24 -Width 180 -Height 240 -DataSource $SkinJSON -DisplayMember 'name'

    SafeAddRange $form $eyesControls
    SafeAddRange $form $hairControls
    SafeAddRange $form $skinControls

    # Route through Show-Form for consistent Back/Cancel handling
    Show-Form -form $form -onOK {
        $global:Eyes = $eyesControls[1].SelectedItem.Name
        $global:Hair = $hairControls[1].SelectedItem.Name
        $global:Skin = $skinControls[1].SelectedItem.Name
        Write-Log "Eyes: $($global:Eyes)" -Level DEBUG
        Write-Log "Hair: $($global:Hair)" -Level DEBUG
        Write-Log "Skin: $($global:Skin)" -Level DEBUG
    } -onIgnore {
        # Skip - keep default appearance values
        Write-Log "Character features selection skipped" -Level DEBUG
    } -onCancel { exit }
}

# Show-ClassAndAlignmentForm: Lets the user pick their primary class and moral alignment.
# Note: the Cantrip form is driven by Navigate-Forms based on CanCastCantrips; it is NOT called from here.
function Show-ClassAndAlignmentForm {
    Write-Log "Displaying Class and Alignment Form" -Level DEBUG
    $form = New-ProgramForm -Title 'Sparks D&D Character Creator' -Width 680 -Height 460 -AcceptButtonText 'Next' -SkipButtonText 'Skip' -CancelButtonText 'Exit'

    $classControls = Set-ListBox -LabelText 'Select a Primary Class:' -X 24 -Y 24 -Width 280 -Height 260 -DataSource $ClassesJSON -DisplayMember 'name'
    $alignmentControls = Set-ListBox -LabelText 'Select an Alignment:' -X 332 -Y 24 -Width 280 -Height 260 -DataSource $AlignmentJSON -DisplayMember 'name'

    SafeAddRange $form $classControls
    SafeAddRange $form $alignmentControls

    # Route through Show-Form for consistent Back/Cancel handling
    Show-Form -form $form -onOK {
        # Pull all class-specific values from the JSON data
        $global:SelectedClass = $classControls[1].SelectedItem
        $global:Class = $global:SelectedClass.Name
        $global:HD = $global:SelectedClass.HitDice
        $global:SpellCastingClass = $global:SelectedClass.spellcastingclass
        $global:SpellCastingAbility = $global:SelectedClass.SpellCastingAbility
        $global:SpellCastingSaveDC = $global:SelectedClass.SpellCastingSaveDC
        $global:SelectedPack = $global:SelectedClass.backpack
        $global:Alignment = $alignmentControls[1].SelectedItem.Name
        # Saving throw proficiency check boxes for the PDF
        $global:Check11 = $global:SelectedClass.Check11
        $global:Check18 = $global:SelectedClass.Check18
        $global:Check19 = $global:SelectedClass.Check19
        $global:Check20 = $global:SelectedClass.Check20
        $global:Check21 = $global:SelectedClass.Check21
        $global:Check22 = $global:SelectedClass.Check22
        # Convert CanCastCantrips to a boolean so the Cantrip step can be gated
        $global:CanCastCantrips = [bool]::Parse($global:SelectedClass.CanCastCantrips)
        Write-Log "SelectedClass: $($global:SelectedClass)" -Level DEBUG
        Write-Log "Class: $($global:Class)" -Level DEBUG
        Write-Log "Alignment: $($global:Alignment)" -Level DEBUG
        Write-Log "HD: $($global:HD)" -Level DEBUG
        Write-Log "SpellCastingClass: $($global:SpellCastingClass)" -Level DEBUG
        Write-Log "SpellCastingAbility: $($global:SpellCastingAbility)" -Level DEBUG
        Write-Log "SpellCastingSaveDC: $($global:SpellCastingSaveDC)" -Level DEBUG
        Write-Log "SelectedPack: $($global:SelectedPack)" -Level DEBUG
        Write-Log "CanCastCantrips: $($global:CanCastCantrips)" -Level DEBUG
        Write-Log "Strength check enabled: $global:Check11" -Level DEBUG
        Write-Log "Dexterity check enabled: $global:Check18" -Level DEBUG
        Write-Log "Constitution check enabled: $global:Check19" -Level DEBUG
        Write-Log "Intelligence check enabled: $global:Check20" -Level DEBUG
        Write-Log "Wisdom check enabled: $global:Check21" -Level DEBUG
        Write-Log "Charisma check enabled: $global:Check22" -Level DEBUG
    } -onIgnore {
        # Skip - keep default class values
        Write-Log "Class and alignment selection skipped" -Level DEBUG
    } -onCancel { exit }
}

# Show-SubClassForm: Lets the user pick a subclass when one is available for the selected class.
# Transparent forward step if the class has no subclasses.
function Show-SubClassForm {
    Write-Log "Displaying SubClass Form" -Level DEBUG
    $form = New-ProgramForm -Title 'Sparks D&D Character Creator' -Width 680 -Height 460 -AcceptButtonText 'Next' -SkipButtonText 'Skip' -CancelButtonText 'Exit'

    if ($global:SelectedClass.Subclasses -and $global:SelectedClass.Subclasses.Count -gt 0) {
        # Only show the list when subclasses actually exist
        $subClassControls = Set-ListBox -LabelText 'Select a SubClass:' -X 24 -Y 24 -Width 610 -Height 280 -DataSource $global:SelectedClass.Subclasses
        SafeAddRange $form $subClassControls

        # Route through Show-Form for consistent Back/Cancel handling
        Show-Form -form $form -onOK {
            if ($subClassControls[1].SelectedItem) {
                $global:SubClass = $subClassControls[1].SelectedItem
                # Store the combined class + subclass label used on the character sheet
                $global:ClassAndSubClass = "$($global:Class) - $($global:SubClass)"
                Write-Log "SubClass Selected: $($global:SubClass)" -Level DEBUG
                Write-Log "Final Selection: $($global:ClassAndSubClass)" -Level DEBUG
            }
        } -onIgnore {
            # Skip without selecting a subclass
            Write-Log "SubClass selection skipped" -Level DEBUG
        } -onCancel { exit }
    } else {
        # No subclasses for this class - move forward transparently
        Write-Log "No subclasses available for the selected class - skipping SubClass form" -Level DEBUG
    }
}

# Show-CantripForm: Lets spellcasting classes pick up to 3 cantrips filtered to their class.
# Navigate-Forms gates this step using $global:CanCastCantrips.
function Show-CantripForm {
    Write-Log "Displaying Cantrip Selection Form" -Level DEBUG

    # Only show cantrips that belong to the character's chosen class
    $filteredCantrips = $CantripsJSON | Where-Object { $_.classes -contains $global:Class }

    $form = New-ProgramForm -Title 'Select Cantrips' -Width 640 -Height 700 -AcceptButtonText 'Next' -SkipButtonText 'Skip' -CancelButtonText 'Exit'

    # Three stacked list boxes - one per cantrip slot
    $cantrip1Controls = Set-ListBox -LabelText 'Select Cantrip 1:' -X 24 -Y 24 -Width 560 -Height 140 -DataSource $filteredCantrips -DisplayMember 'name'
    $cantrip2Controls = Set-ListBox -LabelText 'Select Cantrip 2:' -X 24 -Y 212 -Width 560 -Height 140 -DataSource $filteredCantrips -DisplayMember 'name'
    $cantrip3Controls = Set-ListBox -LabelText 'Select Cantrip 3:' -X 24 -Y 400 -Width 560 -Height 140 -DataSource $filteredCantrips -DisplayMember 'name'

    SafeAddRange $form $cantrip1Controls
    SafeAddRange $form $cantrip2Controls
    SafeAddRange $form $cantrip3Controls

    # Route through Show-Form for consistent Back/Cancel handling
    Show-Form -form $form -onOK {
        # Store each selected cantrip in the matching PDF spell slot global
        $global:Cantrip01 = $cantrip1Controls[1].SelectedItem.name
        $global:Cantrip02 = $cantrip2Controls[1].SelectedItem.name
        $global:Cantrip03 = $cantrip3Controls[1].SelectedItem.name
        Write-Log "Selected Cantrip 1: $($global:Cantrip01)" -Level DEBUG
        Write-Log "Selected Cantrip 2: $($global:Cantrip02)" -Level DEBUG
        Write-Log "Selected Cantrip 3: $($global:Cantrip03)" -Level DEBUG
    } -onIgnore {
        # Skip - leave cantrip slots empty
        Write-Log "Cantrip selection skipped" -Level DEBUG
    } -onCancel { exit }
}

# Show-WeaponAndArmourForm: Lets the user pick up to 3 weapons, select armour, choose
# extra gear, and optionally add a shield (+2 AC).
function Show-WeaponAndArmourForm {
    Write-Log "Displaying Weapon and Armor Form" -Level DEBUG
    
    # Create the form
    $form = New-ProgramForm -Title 'Sparks D&D Character Creator' -Width 820 -Height 720 -AcceptButtonText 'Next' -SkipButtonText 'Skip' -CancelButtonText 'Exit'

    # Create individual ListBox controls for weapon selection
    $weapon1Controls = Set-ListBox -LabelText "Select Weapon 1" -X 24 -Y 24 -Width 220 -Height 250 -DataSource $WeaponJSON -DisplayMember 'name'
    $weapon2Controls = Set-ListBox -LabelText "Select Weapon 2" -X 290 -Y 24 -Width 220 -Height 250 -DataSource $WeaponJSON -DisplayMember 'name'
    $weapon3Controls = Set-ListBox -LabelText "Select Weapon 3" -X 556 -Y 24 -Width 220 -Height 250 -DataSource $WeaponJSON -DisplayMember 'name'
    
    # Add controls to the form
    SafeAddRange $form $weapon1Controls
    SafeAddRange $form $weapon2Controls
    SafeAddRange $form $weapon3Controls

    # Additional controls for armor and gear
    $gearControls = Set-ListBox -LabelText 'Select Extra Adventuring Gear:' -X 412 -Y 328 -Width 364 -Height 220 -DataSource $GearJSON -DisplayMember 'name'
    $armorControls = Set-ListBox -LabelText 'Select Armour:' -X 24 -Y 328 -Width 360 -Height 220 -DataSource $ArmourJSON -DisplayMember 'name'

    $checkboxShield = New-Object System.Windows.Forms.CheckBox
    $checkboxShield.Location = New-Object System.Drawing.Point(24, 588)
    $checkboxShield.Size = New-Object System.Drawing.Size(160, 32)
    $checkboxShield.Font = $script:UIStyle.InputFont
    $checkboxShield.Text = "Shield?"
    $checkboxShield.Checked = $false

    SafeAddRange $form $gearControls
    SafeAddRange $form $armorControls
    SafeAddControl $form $checkboxShield

    # Route through Show-Form for consistent Back/Cancel handling
    Show-Form -form $form -onOK {
        # Reset weapon collection before repopulating from the form
        $global:Weapons = @()
        Write-Log "Weapons Array initialised" -Level DEBUG
        $global:WeaponDescription = ""

        # Build the flat weapon description string used in the PDF AttacksSpellcasting field
        $global:WeaponDescription += WeaponSelection -selectedWeapon $weapon1Controls[1].SelectedItem -slotNumber 1
        $global:WeaponDescription += WeaponSelection -selectedWeapon $weapon2Controls[1].SelectedItem -slotNumber 2
        $global:WeaponDescription += WeaponSelection -selectedWeapon $weapon3Controls[1].SelectedItem -slotNumber 3
        # Remove any trailing separator left by the last weapon slot
        $global:WeaponDescription = $global:WeaponDescription.TrimEnd(", ")

        # Calculate armour class from the selected armour type and DEX modifier
        $selectedArmor = $armorControls[1].SelectedItem
        if ($selectedArmor) {
            $baseAC = [int]$selectedArmor.BaseAC
            $armorType = $selectedArmor.Type
            $maxDexBonus = [int]$selectedArmor.MaxDexBonus
            $dexModifier = [int]$global:DEXMod
            # Medium armour caps the DEX bonus contribution to AC
            if ($selectedArmor.DexModifierApplicable -and $armorType -eq 'Medium') {
                $dexModifier = [math]::Min($dexModifier, $maxDexBonus)
            }
            $global:ArmourClass = $baseAC + $dexModifier
            # A shield adds a flat +2 to AC
            if ($checkboxShield.Checked) {
                $global:ArmourClass += 2
            }
            $global:ArmourWeight = $selectedArmor.Weight
            $global:GearWeight = $gearControls[1].SelectedItem.Weight
            Write-Log "Selected Armor: $($selectedArmor.Name)" -Level DEBUG
            Write-Log "Armor Type: $armorType" -Level DEBUG
            Write-Log "Base AC: $baseAC" -Level DEBUG
            Write-Log "Dexterity Modifier: $dexModifier" -Level DEBUG
            Write-Log "Calculated ArmourClass: $($global:ArmourClass)" -Level DEBUG
            Write-Log "Total Armour Weight: $global:ArmourWeight" -Level DEBUG
            Write-Log "Total Gear Weight: $global:GearWeight" -Level DEBUG
        } else {
            Write-Log "No Armor Selected" -Level DEBUG
        }
        Write-Log "Combined Weapon Description: $($global:WeaponDescription)" -Level DEBUG
    } -onIgnore {
        # Skip - keep default weapon/armour values
        Write-Log "Weapon and armour selection skipped" -Level DEBUG
    } -onCancel { exit }
}

function WeaponSelection {
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
        $description = "$($selectedWeapon.Name) - $($selectedWeapon.Description); "
        Write-Log "Weapon$slotNumber Selected: $($selectedWeapon.Name)" -Level DEBUG

        return $description
    } else {
        Write-Log "No Weapon Selected for Weapon Slot $slotNumber" -Level DEBUG
        return ""
    }
}

# Helper functions to suppress output from control additions
function SafeAddControl {
    param([System.Windows.Forms.Control]$parent, [System.Windows.Forms.Control]$child)
    [void]$parent.Controls.Add($child)
}
function SafeAddRange {
    param([System.Windows.Forms.Control]$parent, [System.Windows.Forms.Control[]]$children)
    [void]$parent.Controls.AddRange($children)
}
function SafeItemsAdd {
    param($items, $item)
    [void]$items.Add($item)
}

# Show-ChooseSkillsForm: Lets the user pick up to 3 skill proficiencies from the class skill list.
# Selected skills are mapped to their PDF checkbox field names via SkillToCheckboxMap.
function Show-ChooseSkillsForm {
    Write-Log "Displaying Choose Skills Form" -Level DEBUG

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

    $skillOptions = @($global:SelectedClass.Skills | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) })
    Write-Log "Available class skills: $($skillOptions -join ', ')" -Level DEBUG
    
    # Create the form
    $form = New-ProgramForm -Title 'Select Skills' -Width 620 -Height 680 -AcceptButtonText 'Next' -SkipButtonText 'Skip' -CancelButtonText 'Exit'

    $instructionsLabel = New-Object System.Windows.Forms.Label
    $instructionsLabel.Location = New-Object System.Drawing.Point(24, 20)
    $instructionsLabel.Size = New-Object System.Drawing.Size(560, 42)
    $instructionsLabel.Text = 'Choose up to three class skill proficiencies. Duplicate picks are ignored when the character sheet is generated.'
    $instructionsLabel.Font = $script:UIStyle.FormFont
    $instructionsLabel.BackColor = [System.Drawing.Color]::Transparent
    SafeAddControl $form $instructionsLabel

    if ($skillOptions.Count -eq 0) {
        $emptyStateLabel = New-Object System.Windows.Forms.Label
        $emptyStateLabel.Location = New-Object System.Drawing.Point(48, 250)
        $emptyStateLabel.Size = New-Object System.Drawing.Size(512, 80)
        $emptyStateLabel.Text = 'No class skills were loaded for the selected class. Use Skip to continue or reselect the class.'
        $emptyStateLabel.Font = $script:UIStyle.LabelFont
        $emptyStateLabel.ForeColor = $script:UIStyle.AccentTextColor
        $emptyStateLabel.BackColor = [System.Drawing.Color]::Transparent
        $emptyStateLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        SafeAddControl $form $emptyStateLabel
    }

    $skill1Controls = $null
    $skill2Controls = $null
    $skill3Controls = $null

    if ($skillOptions.Count -gt 0) {
        # Create list box controls for selecting up to 3 skills
        $skill1Controls = Set-ListBox -LabelText 'Select Skill 1:' -X 24 -Y 86 -Width 560 -Height 140 -DataSource $skillOptions
        $skill2Controls = Set-ListBox -LabelText 'Select Skill 2:' -X 24 -Y 274 -Width 560 -Height 140 -DataSource $skillOptions
        $skill3Controls = Set-ListBox -LabelText 'Select Skill 3:' -X 24 -Y 462 -Width 560 -Height 100 -DataSource $skillOptions

        # Add controls to the form
        SafeAddRange $form $skill1Controls
        SafeAddRange $form $skill2Controls
        SafeAddRange $form $skill3Controls
    }

    # Route through Show-Form for consistent Back/Cancel handling
    Show-Form -form $form -onOK {
        # Collect up to three selected skill proficiencies
        $selectedSkillValues = @(
            if ($skill1Controls) { Get-SelectedListValue -ListBox $skill1Controls[1] }
            if ($skill2Controls) { Get-SelectedListValue -ListBox $skill2Controls[1] }
            if ($skill3Controls) { Get-SelectedListValue -ListBox $skill3Controls[1] }
        ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

        for ($index = 0; $index -lt $selectedSkillValues.Count; $index++) {
            Write-Log "Selected Skill $($index + 1): $($selectedSkillValues[$index])" -Level DEBUG
        }

        $global:SelectedSkills = @($selectedSkillValues | Select-Object -Unique)
        $global:SelectedClass.SkillProficiencies = @($global:SelectedSkills)
        Write-Log "Selected Skills: $($global:SelectedSkills -join ', ')" -Level DEBUG
        # Mark the corresponding PDF checkbox fields to 'Yes' for chosen skills
        foreach ($skill in $global:SelectedSkills) {
            if ($skill -and $global:SkillToCheckboxMap.ContainsKey($skill)) {
                $checkboxField = $global:SkillToCheckboxMap[$skill]
                if ($checkboxField) {
                    $global:CharacterParameters.Fields[$checkboxField] = "Yes"
                    Write-Log "Set checkbox '$checkboxField' = Yes for skill '$skill'" -Level DEBUG
                }
            }
        }
        # Explicitly mark unselected skills as 'off' so the PDF is clean
        foreach ($key in $global:SkillToCheckboxMap.Keys) {
            if (-not $global:SelectedSkills -contains $key) {
                $checkboxField = $global:SkillToCheckboxMap[$key]
                if ($checkboxField) {
                    $global:CharacterParameters.Fields[$checkboxField] = "off"
                    Write-Log "Set checkbox '$checkboxField' = off for skill '$key'" -Level DEBUG
                }
            }
        }
    } -onIgnore {
        # Skip - no skill proficiencies marked
        $global:SelectedSkills = @()
        $global:SelectedClass.SkillProficiencies = @()
        Write-Log "Skill selection skipped" -Level DEBUG
    } -onCancel { exit }
}

# Show-StatsChooserForm: Point-buy stat allocation form.
# Each stat starts at 8 and the player distributes 27 points using + / - buttons.
function Show-StatsChooserForm {
    Write-Log "Displaying Stats Chooser Form" -Level DEBUG

    $form = New-ProgramForm -Title 'Allocate Character Stats' -Width 620 -Height 500 -AcceptButtonText 'OK' -SkipButtonText 'Skip' -CancelButtonText 'Exit'
    $statOrder = @('STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA')
    
    $remainingPointsLabel = New-Object System.Windows.Forms.Label
    $remainingPointsLabel.Location = New-Object System.Drawing.Point(24, 20)
    $remainingPointsLabel.Size = New-Object System.Drawing.Size(260, 24)
    $remainingPointsLabel.Text = "Remaining Points: $($global:TotalPoints)"
    $remainingPointsLabel.Font = $script:UIStyle.LabelFont
    SafeAddControl $form $remainingPointsLabel

    $instructionsLabel = New-Object System.Windows.Forms.Label
    $instructionsLabel.Location = New-Object System.Drawing.Point(24, 50)
    $instructionsLabel.Size = New-Object System.Drawing.Size(540, 40)
    $instructionsLabel.Text = 'Use 27-point buy. Scores start at 8, can go to 15, and 14-15 cost 2 points each.'
    $instructionsLabel.Font = $script:UIStyle.FormFont
    SafeAddControl $form $instructionsLabel

    $resetButton = New-Object System.Windows.Forms.Button
    $resetButton.Location = New-Object System.Drawing.Point(470, 16)
    $resetButton.Size = New-Object System.Drawing.Size(90, 30)
    $resetButton.Text = 'Reset'
    $resetButton.Font = $script:UIStyle.ButtonFont
    $resetButton.Add_Click({
        $global:TotalPoints = 27
        $global:StatIncrements.Keys | ForEach-Object { $global:StatIncrements[$_] = 0 }
        UpdateFormControls -form $form -remainingPointsLabel $remainingPointsLabel
    })
    SafeAddControl $form $resetButton

    $statHeaderLabel = New-Object System.Windows.Forms.Label
    $statHeaderLabel.Location = New-Object System.Drawing.Point(24, 106)
    $statHeaderLabel.Size = New-Object System.Drawing.Size(90, 24)
    $statHeaderLabel.Text = 'Stat'
    $statHeaderLabel.Font = $script:UIStyle.LabelFont
    SafeAddControl $form $statHeaderLabel

    $adjustHeaderLabel = New-Object System.Windows.Forms.Label
    $adjustHeaderLabel.Location = New-Object System.Drawing.Point(180, 106)
    $adjustHeaderLabel.Size = New-Object System.Drawing.Size(120, 24)
    $adjustHeaderLabel.Text = 'Adjust'
    $adjustHeaderLabel.Font = $script:UIStyle.LabelFont
    SafeAddControl $form $adjustHeaderLabel

    $valueHeaderLabel = New-Object System.Windows.Forms.Label
    $valueHeaderLabel.Location = New-Object System.Drawing.Point(340, 106)
    $valueHeaderLabel.Size = New-Object System.Drawing.Size(90, 24)
    $valueHeaderLabel.Text = 'Score'
    $valueHeaderLabel.Font = $script:UIStyle.LabelFont
    SafeAddControl $form $valueHeaderLabel

    $costHeaderLabel = New-Object System.Windows.Forms.Label
    $costHeaderLabel.Location = New-Object System.Drawing.Point(440, 106)
    $costHeaderLabel.Size = New-Object System.Drawing.Size(100, 24)
    $costHeaderLabel.Text = 'Next Cost'
    $costHeaderLabel.Font = $script:UIStyle.LabelFont
    SafeAddControl $form $costHeaderLabel

    $yPosition = 138

    foreach ($stat in $statOrder) {
        Write-Log "[Debug] Creating controls for stat: $stat at yPosition: $yPosition" -Level DEBUG
        Add-StatControls -form $form -stat $stat -yPosition $yPosition -remainingPointsLabel $remainingPointsLabel
        $yPosition += 42
    }

    # Route through Show-Form for consistent Back/Cancel handling
    Show-Form -form $form -onOK {
        # Apply the point-buy increments on top of the base stat values
        foreach ($stat in $statOrder) {
            Set-Variable -Name $stat -Value ($global:BaseStats[$stat] + $global:StatIncrements[$stat]) -Scope Global
        }
        Write-Log "Stats allocated: STR=$($global:STR), DEX=$($global:DEX), CON=$($global:CON), INT=$($global:INT), WIS=$($global:WIS), CHA=$($global:CHA)" -Level DEBUG
    } -onIgnore {
        # Skip - keep current stat values
        Write-Log "Stats allocation skipped" -Level DEBUG
    } -onCancel { exit }
}

# Add-StatControls: Adds the controls for each stat
function Add-StatControls {
    param (
        [System.Windows.Forms.Form]$form,
        [string]$stat,
        [int]$yPosition,
        [System.Windows.Forms.Label]$remainingPointsLabel
    )

    $buttonYPosition = [int]($yPosition - 2)

    # Create a label for the stat name
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(24, $yPosition)
    $label.Size = New-Object System.Drawing.Size(110, 24)
    $label.Text = $stat
    $label.Font = $script:UIStyle.LabelFont
    SafeAddControl $form $label

    # Create the value label to display the current stat value
    $valueLabel = New-Object System.Windows.Forms.Label
    $valueLabel.Name = "StatValue_$stat"
    $valueLabel.Location = New-Object System.Drawing.Point(340, $yPosition)
    $valueLabel.Size = New-Object System.Drawing.Size(70, 24)
    $valueLabel.Text = ($global:BaseStats[$stat] + $global:StatIncrements[$stat]).ToString()
    $valueLabel.Font = $script:UIStyle.InputFont
    $valueLabel.Tag = $stat  # Tag the value label with the stat name
    $valueLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    SafeAddControl $form $valueLabel

    $costLabel = New-Object System.Windows.Forms.Label
    $costLabel.Name = "StatCost_$stat"
    $costLabel.Location = New-Object System.Drawing.Point(440, $yPosition)
    $costLabel.Size = New-Object System.Drawing.Size(100, 24)
    $costLabel.Font = $script:UIStyle.FormFont
    $costLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
    SafeAddControl $form $costLabel

    Write-Log "[Debug] Created valueLabel for stat: $stat at yPosition: $yPosition with initial value: $($valueLabel.Text)" -Level DEBUG

    # Create the "+" button and associate it with the correct stat
    $upButton = New-Object System.Windows.Forms.Button
    $upButton.Location = New-Object System.Drawing.Point(180, $buttonYPosition)
    $upButton.Size = New-Object System.Drawing.Size(48, 28)
    $upButton.Text = "+"
    $upButton.Font = $script:UIStyle.ButtonFont
    $upButton.Tag = $stat
    $upButton.Add_Click({
        $currentStat = [string]$this.Tag
        Write-Log "[Debug] Up button clicked for stat: $currentStat" -Level DEBUG
        HandleButtonClick -form $this.FindForm() -stat $currentStat -direction 'up' -remainingPointsLabel $remainingPointsLabel
    })
    SafeAddControl $form $upButton

    # Create the "-" button and associate it with the correct stat
    $downButton = New-Object System.Windows.Forms.Button
    $downButton.Location = New-Object System.Drawing.Point(236, $buttonYPosition)
    $downButton.Size = New-Object System.Drawing.Size(48, 28)
    $downButton.Text = "-"
    $downButton.Font = $script:UIStyle.ButtonFont
    $downButton.Tag = $stat
    $downButton.Add_Click({
        $currentStat = [string]$this.Tag
        Write-Log "[Debug] Down button clicked for stat: $currentStat" -Level DEBUG
        HandleButtonClick -form $this.FindForm() -stat $currentStat -direction 'down' -remainingPointsLabel $remainingPointsLabel
    })
    SafeAddControl $form $downButton

    UpdateStatRowDisplay -form $form -stat $stat
}

# Get-PointBuyIncrementCost: Returns the cost to increase a stat by one point.
function Get-PointBuyIncrementCost {
    param (
        [int]$currentValue
    )

    if ($currentValue -lt 8 -or $currentValue -ge 15) {
        return 0
    }

    if ($currentValue -ge 13) {
        return 2
    }

    return 1
}

# Get-PointBuyDecrementRefund: Returns the refunded cost when reducing a stat by one point.
function Get-PointBuyDecrementRefund {
    param (
        [int]$currentValue
    )

    if ($currentValue -le 8) {
        return 0
    }

    if ($currentValue -gt 13) {
        return 2
    }

    return 1
}

# UpdateStatRowDisplay: Refreshes the score and next-cost labels for a stat row.
function UpdateStatRowDisplay {
    param (
        [System.Windows.Forms.Form]$form,
        [string]$stat
    )

    $currentValue = $global:BaseStats[$stat] + $global:StatIncrements[$stat]
    $valueLabel = $form.Controls["StatValue_$stat"]
    $costLabel = $form.Controls["StatCost_$stat"]

    if ($null -ne $valueLabel) {
        $valueLabel.Text = $currentValue.ToString()
    }

    if ($null -ne $costLabel) {
        if ($currentValue -ge 15) {
            $costLabel.Text = 'Max'
        } else {
            $costLabel.Text = (Get-PointBuyIncrementCost -currentValue $currentValue).ToString()
        }
    }
}

# HandleButtonClick: Handles the increment and decrement of stats
function HandleButtonClick {
    param (
        [System.Windows.Forms.Form]$form,
        [string]$stat,
        [string]$direction,
        [System.Windows.Forms.Label]$remainingPointsLabel
    )

    # Validate that the stat and form are correct
    if (-not $stat) {
        Write-Log "[Error] The stat variable is empty or undefined." -Level ERROR
        return
    }

    if ($null -eq $form) {
        Write-Log "[Error] The stat form reference is null for stat: $stat." -Level ERROR
        return
    }

    # Debug log for tracking button clicks and their intended effect
    Write-Log "[Debug] Button Click Detected: Stat = $stat, Direction = $direction, Current Stat Increment = $($global:StatIncrements[$stat]), Remaining Points = $($global:TotalPoints)" -Level DEBUG

    $currentValue = $global:BaseStats[$stat] + $global:StatIncrements[$stat]

    # Update stat based on the button direction
    if ($direction -eq 'up') {
        $pointCost = Get-PointBuyIncrementCost -currentValue $currentValue
        if ($pointCost -gt 0 -and $global:TotalPoints -ge $pointCost) {
            $global:StatIncrements[$stat]++
            $global:TotalPoints -= $pointCost
            Write-Log "[Debug] Incremented $stat New Increment Value = $($global:StatIncrements[$stat]), Cost = $pointCost, Remaining Points = $($global:TotalPoints)" -Level DEBUG
        } else {
            Write-Log "[Debug] Cannot increment $stat Current Value = $currentValue, Cost = $pointCost, Remaining Points = $($global:TotalPoints)" -Level DEBUG
        }
    } elseif ($direction -eq 'down' -and $global:StatIncrements[$stat] -gt 0) {
        $refund = Get-PointBuyDecrementRefund -currentValue $currentValue
        $global:StatIncrements[$stat]--
        $global:TotalPoints += $refund
        Write-Log "[Debug] Decremented $stat New Increment Value = $($global:StatIncrements[$stat]), Refund = $refund, Remaining Points = $($global:TotalPoints)" -Level DEBUG
    } else {
        Write-Log "[Debug] No stat change applied: Direction = $direction, Stat = $stat, Current Stat Increment = $($global:StatIncrements[$stat])" -Level DEBUG
    }

    # Update and refresh labels to reflect changes
    UpdateStatRowDisplay -form $form -stat $stat
    $remainingPointsLabel.Text = "Remaining Points: $($global:TotalPoints)"
}

# Function to update form controls
function UpdateFormControls {
    param (
        [System.Windows.Forms.Form]$form,
        [System.Windows.Forms.Label]$remainingPointsLabel
    )

    $remainingPointsLabel.Text = "Remaining Points: $($global:TotalPoints)"
    foreach ($stat in @('STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA')) {
        UpdateStatRowDisplay -form $form -stat $stat
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

# Show-BackstoryForm: Captures the character's backstory, personality, ideals, bonds, and flaws.
function Show-BackstoryForm {
    Write-Log "Displaying Backstory Form" -Level DEBUG
    $form = New-ProgramForm -Title 'Sparks D&D Character Creator' -Width 980 -Height 760 -AcceptButtonText 'Next' -SkipButtonText 'Skip' -CancelButtonText 'Exit'

    $backstoryControls = Set-TextBox -LabelText 'Write your backstory:' -X 24 -Y 24 -Width 430 -Height 560 -MaxLength 0
    $backstoryControls[1].Multiline = $true
    $backstoryControls[1].ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical

    $personalityControls = Set-TextBox -LabelText 'Write your Personality Traits:' -X 490 -Y 24 -Width 430 -Height 96 -MaxLength 0
    $personalityControls[1].Multiline = $true
    $personalityControls[1].ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical

    $idealsControls = Set-TextBox -LabelText 'Write your Ideals:' -X 490 -Y 174 -Width 430 -Height 96 -MaxLength 0
    $idealsControls[1].Multiline = $true
    $idealsControls[1].ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical

    $bondsControls = Set-TextBox -LabelText 'Write About your Bonds:' -X 490 -Y 324 -Width 430 -Height 96 -MaxLength 0
    $bondsControls[1].Multiline = $true
    $bondsControls[1].ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical

    $flawsControls = Set-TextBox -LabelText 'Write your Flaws:' -X 490 -Y 474 -Width 430 -Height 96 -MaxLength 0
    $flawsControls[1].Multiline = $true
    $flawsControls[1].ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical

    SafeAddRange $form $backstoryControls
    SafeAddRange $form $personalityControls
    SafeAddRange $form $idealsControls
    SafeAddRange $form $bondsControls
    SafeAddRange $form $flawsControls

    # Route through Show-Form for consistent Back/Cancel handling
    Show-Form -form $form -onOK {
        # Capture all roleplay text fields into globals for the PDF
        $global:Characterbackstory = $backstoryControls[1].Text
        $global:PersonalityTraits  = $personalityControls[1].Text
        $global:Ideals             = $idealsControls[1].Text
        $global:Bonds              = $bondsControls[1].Text
        $global:Flaws              = $flawsControls[1].Text
        Write-Log "Characterbackstory: $($global:Characterbackstory)" -Level DEBUG
        Write-Log "PersonalityTraits: $($global:PersonalityTraits)" -Level DEBUG
        Write-Log "Ideals: $($global:Ideals)" -Level DEBUG
        Write-Log "Bonds: $($global:Bonds)" -Level DEBUG
        Write-Log "Flaws: $($global:Flaws)" -Level DEBUG
    } -onIgnore {
        # Skip - leave backstory fields at their default values
        Write-Log "Backstory skipped" -Level DEBUG
    } -onCancel { exit }
}

# Show-AdditionalDetailsForm: Captures allies, organisations, faction name, and additional traits.
function Show-AdditionalDetailsForm {
    Write-Log "Displaying Additional Details Form" -Level DEBUG
    $form = New-ProgramForm -Title 'Sparks D&D Character Creator' -Width 980 -Height 760 -AcceptButtonText 'Next' -SkipButtonText 'Skip' -CancelButtonText 'Exit'

    $alliesControls = Set-TextBox -LabelText 'Write about your Allies and Organisations:' -X 24 -Y 24 -Width 430 -Height 560 -MaxLength 0
    $alliesControls[1].Multiline = $true
    $alliesControls[1].ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical

    $featTraitsControls = Set-TextBox -LabelText 'Write your Additional features and traits:' -X 490 -Y 24 -Width 430 -Height 560 -MaxLength 0
    $featTraitsControls[1].Multiline = $true
    $featTraitsControls[1].ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical

    $factionNameControls = Set-TextBox -LabelText 'Faction Name:' -X 24 -Y 620 -Width 430 -Height 28 -MaxLength 0

    SafeAddRange $form $alliesControls
    SafeAddRange $form $featTraitsControls
    SafeAddRange $form $factionNameControls

    # Route through Show-Form for consistent Back/Cancel handling
    Show-Form -form $form -onOK {
        # Capture organisation, faction, and additional trait text for the PDF
        $global:Allies            = $alliesControls[1].Text
        $global:AddionalfeatTraits = $featTraitsControls[1].Text
        $global:factionname       = $factionNameControls[1].Text
        Write-Log "Allies: $($global:Allies)" -Level DEBUG
        Write-Log "AddionalfeatTraits: $($global:AddionalfeatTraits)" -Level DEBUG
        Write-Log "FactionName: $($global:factionname)" -Level DEBUG
    } -onIgnore {
        # Skip - leave additional details at their defaults
        Write-Log "Additional details skipped" -Level DEBUG
    } -onCancel { exit }
}

# Navigate-Forms: Drives the wizard-style form flow using an index.
# After each form, $script:NavDirection controls whether we advance (1), go back (-1), or exit (0).
# This allows the Back button to re-display the previous step correctly.
function Navigate-Forms {
    param (
        [string[]]$FormSequence,
        [hashtable]$FormHandlers
    )

    # Start at the first form
    $i = 0
    while ($i -ge 0 -and $i -lt $FormSequence.Count) {
        $formName = $FormSequence[$i]
        $handler = $FormHandlers[$formName]

        if ($handler) {
            Write-Log "Navigating to form: $formName (Step $($i+1) of $($FormSequence.Count))" -Level DEBUG
            # Reset direction to forward before each form; the form sets it via Show-Form
            $script:NavDirection = 1

            # Gate the Cantrip step: only show it for spellcasting classes
            if ($formName -eq 'Cantrip' -and -not $global:CanCastCantrips) {
                Write-Log "Skipping Cantrip form - class cannot cast cantrips" -Level DEBUG
                # NavDirection stays 1 so we skip forward automatically
            } else {
                & $handler
            }
        } else {
            Write-Log "No handler found for form: $formName" -Level WARN
            # Skip missing handlers by moving forward
            $script:NavDirection = 1
        }

        # Move forward or backward depending on what the user pressed
        if ($script:NavDirection -eq 0) {
            # Cancel was confirmed - exit the entire wizard
            Write-Log "Navigation cancelled at step: $formName" -Level INFO
            exit
        }
        $i += $script:NavDirection
        # Clamp to zero so going back from the first form stays at the first form
        if ($i -lt 0) { $i = 0 }
    }
}

# The ordered list of wizard steps - Navigate-Forms walks through these in sequence.
# Back button decrements the index; forward/skip increments it.
# 'Cantrip' is gated inside Navigate-Forms by $global:CanCastCantrips.
# 'SubRace' and 'SubClass' are transparent forwards when no options exist.
$formSequence = @(
    'BasicInfo',        # Character name, player name, age
    'Race',             # Race and background selection
    'SubRace',          # Subrace (skipped if race has none)
    'CharacterFeatures',# Eyes, hair, skin appearance
    'ClassAndAlignment',# Class and alignment
    'SubClass',         # Subclass (skipped if class has none)
    'Cantrip',          # Cantrip selection (gated by CanCastCantrips)
    'WeaponAndArmour',  # Weapons, armour, gear
    'ChooseSkills',     # Skill proficiency selection
    'StatsChooser',     # Point-buy stat allocation
    'Backstory',        # Backstory and personality fields
    'AdditionalDetails' # Allies, faction, additional traits
)

# Map each step name to the PowerShell function that shows its form
$formHandlers = @{
    'BasicInfo'         = { Show-BasicInfoForm }
    'Race'              = { Show-RaceForm }
    'SubRace'           = { Show-SubRaceForm }
    'CharacterFeatures' = { Show-CharacterFeaturesForm }
    'ClassAndAlignment' = { Show-ClassAndAlignmentForm }
    'SubClass'          = { Show-SubClassForm }
    'Cantrip'           = { Show-CantripForm }
    'WeaponAndArmour'   = { Show-WeaponAndArmourForm }
    'ChooseSkills'      = { Show-ChooseSkillsForm }
    'StatsChooser'      = { Show-StatsChooserForm }
    'Backstory'         = { Show-BackstoryForm }
    'AdditionalDetails' = { Show-AdditionalDetailsForm }
}

# Start form navigation sequence - no try/catch so exit in cancel handlers propagates correctly
Navigate-Forms -FormSequence $formSequence -FormHandlers $formHandlers

Write-Log "Calculating stats" -Level DEBUG
CharacterStats
Write-Log "All forms have been displayed, proceeding with Save" -Level DEBUG

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

# Ensure default values are set to avoid null array errors
if (-not $global:Weapons) {
    $global:Weapons = @(
        @{ Name = ""; Damage = ""; ATK_Bonus = ""; Weight = 0; Properties = "" },
        @{ Name = ""; Damage = ""; ATK_Bonus = ""; Weight = 0; Properties = "" },
        @{ Name = ""; Damage = ""; ATK_Bonus = ""; Weight = 0; Properties = "" }
    )
}

# PDF Values Import before save
$characterparameters = @{
    Fields = @{
        # Base character information
        'ClassLevel' = [string]$Class;
        'PlayerName' = [string]$WrittenPlayername;
        'CharacterName' = [string]$WrittenCharactername;
        'Background' = [string]$ExportBackground;
        'Race ' = [string]$ExportRace;
        'Alignment' = [string]$Alignment;
        'XP' = [string]$XP;
        'Inspiration' = [string]$Inspiration;
        'STR' = [string]$STR;
        'ProfBonus' = [string]$ProficencyBonus;
        'AC' = [string]$ArmourClass;
        'Initiative' = [string]$InitiativeTotal;
        'Speed' = [string]$Speed;
        'PersonalityTraits ' = [string]$PersonalityTraits;
        'STRmod' = [string]$STRMod;
        'ST Strength' = [string]$ST_STR;
        'DEX' = [string]$DEX;
        'Ideals' = [string]$Ideals;
        'DEXmod ' = [string]$DEXMod;
        'Bonds' = [string]$Bonds;
        'CON' = [string]$CON;
        'HDTotal' = [string]$HitDiceTotal;
        'Check Box 12' = if ($Check12) { "Yes" } else { "off" }; #first success button (from left)
        'Check Box 13' = if ($Check13) { "Yes" } else { "off" }; #second success button
        'Check Box 14' = if ($Check14) { "Yes" } else { "off" }; #last success button
        'CONmod' = [string]$CONMod;
        'Check Box 15' = if ($Check15) { "Yes" } else { "off" }; #first failure button (from left)
        'Check Box 16' = if ($Check16) { "Yes" } else { "off" }; #second failure button
        'Check Box 17' = if ($Check17) { "Yes" } else { "off" }; #last failure button
        'HD' = [string]$HD;
        'Flaws' = [string]$Flaws;
        'INT' = [string]$INT;
        'ST Dexterity' = [string]$ST_DEX;
        'ST Constitution' = [string]$ST_CON;
        'ST Intelligence' = [string]$ST_INT;
        'ST Wisdom' = [string]$ST_WIS;
        'ST Charisma' = [string]$ST_CHA;
        'Acrobatics' = [string]$Acrobatics;
        'Animal' = [string]$AnimalHandling;
        'Athletics' = [string]$Athletics;
        'Deception ' = [string]$Deception;
        'History ' = [string]$History;
        'Wpn Name' = [string]($global:Weapons[0].Name);
        'Wpn1 AtkBonus' = [string]($global:Weapons[0].ATK_Bonus);
        'Wpn1 Damage' = [string]($global:Weapons[0].Damage);
        'Insight' = [string]$Insight;
        'Intimidation' = [string]$Intimidation;
        'Wpn Name 2' = [string]($global:Weapons[1].Name);
        'Wpn2 AtkBonus ' = [string]($global:Weapons[1].ATK_Bonus);
        'Wpn Name 3' = [string]($global:Weapons[2].Name);
        'Wpn3 AtkBonus  ' = [string]($global:Weapons[2].ATK_Bonus);
        'Check Box 11' = if ($Check11) { "Yes" } else { "off" }; #Strength Button
        'Check Box 18' = if ($Check18) { "Yes" } else { "off" }; #Dexterity Button
        'Check Box 19' = if ($Check19) { "Yes" } else { "off" }; #Constitution Button
        'Check Box 20' = if ($Check20) { "Yes" } else { "off" }; #Intelligence Button
        'Check Box 21' = if ($Check21) { "Yes" } else { "off" }; #Wisdom Button
        'Check Box 22' = if ($Check22) { "Yes" } else { "off" }; #Charisma Button
        'INTmod' = [string]$INTMod;
        'Wpn2 Damage ' = [string]($global:Weapons[1].Damage);
        'Investigation ' = [string]$Investigation;
        'WIS' = [string]$WIS;
        'Arcana' = [string]$Arcana;
        'Perception ' = [string]$Perception;
        'WISmod' = [string]$WISMod;
        'CHA' = [string]$CHA;
        'Nature' = [string]$Nature;
        'Performance' = [string]$Performance;
        'Medicine' = [string]$Medicine;
        'Religion' = [string]$Religion;
        'Stealth ' = [string]$Stealth;
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
        'Persuasion' = [string]$Persuation;
        'HPMax' = [string]$HPMax;
        'HPCurrent' = [string]$HP;
        #'HPTemp' = ;
        'Wpn3 Damage ' = [string]($global:Weapons[2].Damage);
        'SleightofHand' = [string]$SleightOfHand;
        'CHamod' = [string]$CHAMod;
        'Survival' = [string]$Survival;
        'AttacksSpellcasting' = [string]$WeaponDescription;
        'Passive' = [string]$Passive;
        'CP' = [string]$CopperCP;
        'ProficienciesLang' = [string]$SpokenLanguages;
        'SP' = [string]$SilverSP;
        'EP' = [string]$ElectrumEP;
        'GP' = [string]$GoldGP;
        'PP' = [string]$PlatinumPP;
        'Equipment' = [string]$TotalEquiptment;
        'Features and Traits' = [string]$Feature1TTraits1;
        'CharacterName 2' = [string]$WrittenCharactername;
        'Age' = [string]$WrittenAge;
        'Height' = [string]$Height;
        'Weight' = [string]$Size;
        'Eyes' = [string]$Eyes;
        'Skin' = [string]$Skin;
        'Hair' = [string]$Hair;
        #'CHARACTER IMAGE' = $CharacterImage; # Do not uncomment this line
        'Faction Symbol Image' = [string]$FactionSymbol;
        'Allies' = [string]$Allies;
        'FactionName' = [string]$factionname;
        'Backstory' = [string]$Characterbackstory;
        'Feat+Traits' = [string]$AddionalfeatTraits;
        #'Treasure' = ;
        'Spellcasting Class 2' = [string]$SpellCastingClass;
        'SpellcastingAbility 2' = [string]$SpellCastingAbility;
        'SpellSaveDC  2' = [string]$SpellCastingSaveDC;
        'SpellAtkBonus 2' = [string]$SpellCastingAttackBonus;
        #'SlotsTotal 19' =  ;
        #'SlotsRemaining 19' =  ;
        'Spells 1014' = [string]$Cantrip01; #Cantrip 0 slot 1 (top)
        'Spells 1015' = [string]$Cantrip11; #Cantrip 1 slot 1 (top)
        'Spells 1016' = [string]$Cantrip02; #Cantrip 0 slot 2
        'Spells 1017' = [string]$Cantrip03; #Cantrip 0 slot 3
        'Spells 1018' = [string]$Cantrip04; #Cantrip 0 slot 4
        'Spells 1019' = [string]$Cantrip05; #Cantrip 0 slot 5
        'Spells 1020' = [string]$Cantrip06; #Cantrip 0 slot 6
        'Spells 1021' = [string]$Cantrip07; #Cantrip 0 slot 7
        'Spells 1022' = [string]$Cantrip08; #Cantrip 0 slot 8
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
}

# Only add ImageFields if the character image exists and is valid
if ($CharacterImage -and (Test-Path $CharacterImage)) {
    $characterparameters.ImageFields = @{
        'CHARACTER IMAGE' = $CharacterImage
    }
    Write-Log "Character image found and will be included: $CharacterImage" -Level DEBUG
} else {
    Write-Log "No character image found or invalid path, proceeding without image" -Level DEBUG
}

# Validate that the Fields are correctly cast to Hashtable
$characterparameters.Fields = [hashtable]$characterparameters.Fields
if ($characterparameters.ContainsKey('ImageFields')) {
    $characterparameters.ImageFields = [hashtable]$characterparameters.ImageFields
}

# Add error handling for PDF generation
try {
    Save-PdfField @characterparameters
    Write-Log "PDF generated successfully" -Level INFO
} catch {
    Write-Log "Failed to generate PDF: $($_.Exception.Message)" -Level ERROR
    [System.Windows.MessageBox]::Show(
        "Failed to create character sheet. Please check the logs.",
        "Error",
        [System.Windows.MessageBoxButton]::OK,
        [System.Windows.MessageBoxImage]::Error
    )
}

# End of character Creation Dialog box
$ButtonType = [System.Windows.MessageBoxButton]::Ok
$MessageIcon = [System.Windows.MessageBoxImage]::Information
$MessageBody = "Dungeons And Dragons Character Successfully Created!"
$MessageTitle = "Spark's D&D Character Creator"
[System.Windows.MessageBox]::Show($MessageBody, $MessageTitle, $ButtonType, $MessageIcon)
Write-Log "Character successfully created message displayed." -Level DEBUG
Exit