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