$script:PTApiKey        = $null
$script:PTDevelopmentId = $null
$script:PTBaseUrl       = 'https://api.parceltracker.com'
$script:PTImportPath    = $null
$script:PTMappingPath   = $null
$script:PTMapping       = $null

foreach ($file in Get-ChildItem -Path "$PSScriptRoot\Private" -Filter '*.ps1') {
    . $file.FullName
}

foreach ($file in Get-ChildItem -Path "$PSScriptRoot\Public" -Filter '*.ps1' -Recurse) {
    . $file.FullName
}

$_configPath = Join-Path $env:APPDATA 'PSParcelTracker\config.json'
if (Test-Path $_configPath) {
    Import-PTConfig -ErrorAction SilentlyContinue
} else {
    try {
        Write-Host 'PSParcelTracker: No saved config found.' -ForegroundColor Yellow
        $apiKey        = Read-Host 'Enter your API key'
        $developmentId = Read-Host 'Enter your Development ID'
        Connect-ParcelTracker -ApiKey $apiKey -DevelopmentId $developmentId
        $save = Read-Host 'Save config for future sessions? (Y/N)'
        if ($save -match '^[Yy]') {
            Export-PTConfig
            Write-Host 'Config saved.' -ForegroundColor Green
        }
    } catch {
        Write-Verbose 'PSParcelTracker: Non-interactive session — run Connect-ParcelTracker to authenticate.'
    }
}
Remove-Variable _configPath

Export-ModuleMember -Function (
    Get-ChildItem -Path "$PSScriptRoot\Public" -Filter '*.ps1' -Recurse |
        ForEach-Object { $_.BaseName }
) -Alias 'Get-PTRecipient', 'New-PTRecipient', 'Set-PTRecipient', 'Remove-PTRecipient', 'Get-PTParcelByRecipient'
