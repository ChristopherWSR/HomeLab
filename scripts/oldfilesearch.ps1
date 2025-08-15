$folderTree = 'DRIVELETTER:\'
$refDate = (Get-Date).AddDays(-730).Date
$batchSize = 1000  # Adjust as needed
$counter = 0
$batch = @()

Get-ChildItem -Path $folderTree -Filter * -File -Recurse | 
    Where-Object { $_.LastWriteTime -lt $refDate } | 
    ForEach-Object {
        # Create a custom string with the desired properties
        $batch += "{0}`t{1}`t{2}" -f $_.Length, $_.LastWriteTime, $_.FullName
        $counter++

        # If the batch size is reached, process the batch
        if ($counter -ge $batchSize) {
            $batch | Format-Table -AutoSize | Out-File -FilePath C:\filepath\oldfiles.txt -Append
            $batch.Clear()  # Clear the batch for the next set of files
            $counter = 0    # Reset the counter
        }
    }

# Process any remaining files in the batch
if ($batch.Count -gt 0) {
    $batch | Format-Table -AutoSize | Out-File -FilePath C:\filepath\oldfiles.txt -Append
}
