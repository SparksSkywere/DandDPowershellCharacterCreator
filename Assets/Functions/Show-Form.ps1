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