function Import-PTConfig {
    <#
    .SYNOPSIS
        Loads a saved ParcelTracker connection from the config file.
    .DESCRIPTION
        Reads $env:APPDATA\PSParcelTracker\config.json and restores the API key and
        development ID saved by Export-PTConfig. The API key is decrypted using
        Windows DPAPI — it can only be decrypted by the same user on the same machine.
    .EXAMPLE
        Import-PTConfig
    #>
    [CmdletBinding()]
    param()

    $configPath = Join-Path $env:APPDATA 'PSParcelTracker\config.json'

    if (-not (Test-Path $configPath)) {
        throw "No config file found at '$configPath'. Run Connect-ParcelTracker then Export-PTConfig first."
    }

    $config = Get-Content -Path $configPath -Raw | ConvertFrom-Json

    $secure              = $config.ApiKey | ConvertTo-SecureString
    $bstr                = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    $script:PTApiKey     = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    $script:PTDevelopmentId = $config.DevelopmentId
    $script:PTBaseUrl       = $config.BaseUrl
    $script:PTImportPath    = $config.ImportPath
    $script:PTMappingPath   = $config.MappingPath

    # Re-load the mapping from the registered file if it still exists
    if ($script:PTMappingPath -and (Test-Path $script:PTMappingPath)) {
        $script:PTMapping = & $script:PTMappingPath
        Write-Verbose "Mapping loaded from '$script:PTMappingPath'"
    }

    Write-Verbose "Connected to $script:PTBaseUrl (DevelopmentId: $script:PTDevelopmentId)"
}
