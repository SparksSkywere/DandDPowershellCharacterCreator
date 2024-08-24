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