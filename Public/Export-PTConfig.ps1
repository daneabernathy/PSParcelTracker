function Export-PTConfig {
    <#
    .SYNOPSIS
        Saves the current ParcelTracker connection to a config file.
    .DESCRIPTION
        Persists the API key (encrypted via Windows DPAPI) and development ID to
        $env:APPDATA\ParcelTracker\config.json. Load it in future sessions with Import-PTConfig.
    .EXAMPLE
        Export-PTConfig
    #>
    [CmdletBinding()]
    param()

    if (-not $script:PTApiKey) {
        throw 'Not connected. Run Connect-ParcelTracker first.'
    }

    $configDir = Join-Path $env:APPDATA 'ParcelTracker'
    if (-not (Test-Path $configDir)) {
        New-Item -ItemType Directory -Path $configDir | Out-Null
    }

    $encryptedKey = $script:PTApiKey |
        ConvertTo-SecureString -AsPlainText -Force |
        ConvertFrom-SecureString

    $config = @{
        ApiKey        = $encryptedKey
        DevelopmentId = $script:PTDevelopmentId
        BaseUrl       = $script:PTBaseUrl
        ImportPath    = $script:PTImportPath
        MappingPath   = $script:PTMappingPath
    }

    $config | ConvertTo-Json | Set-Content -Path (Join-Path $configDir 'config.json') -Encoding UTF8
    Write-Verbose "Config saved to $configDir\config.json"
}
