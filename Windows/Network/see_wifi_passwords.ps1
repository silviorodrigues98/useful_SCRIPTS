try {
    $Profiles = netsh wlan show profiles | Select-String -Pattern 'All User Profile\s+:\s(.+)' | ForEach-Object { $_.Matches.Groups[1].Value }
    $Profiles | ForEach-Object {
        $Index = [array]::IndexOf($Profiles, $_) + 1
        $Profile = $_
        Write-Output "[$Index] $Profile"
    }
    $SelectedIndex = Read-Host -Prompt 'Enter the index number of the profile you want to see the password for'
    $SelectedProfile = $Profiles[$SelectedIndex - 1]
    $Password = (netsh wlan show profile name=$SelectedProfile key=clear | Select-String -Pattern 'Key Content\s+:\s(.+)').Matches.Groups[1].Value
    Set-Clipboard -Value $Password
    Write-Output "The password for $SelectedProfile has been copied to the clipboard."
}
catch {
    Write-Output "An error occurred: $_"
}
finally {
    Start-Sleep -Seconds 5
}
