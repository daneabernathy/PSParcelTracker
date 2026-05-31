function Get-PTConnection {
    <#
    .SYNOPSIS
        Shows the current ParcelTracker connection status.
    .EXAMPLE
        Get-PTConnection
    #>
    [CmdletBinding()]
    param()

    [PSCustomObject]@{
        Connected     = $null -ne $script:PTApiKey
        BaseUrl       = $script:PTBaseUrl
        DevelopmentId = $script:PTDevelopmentId
        ApiKey        = if ($script:PTApiKey) { '*' * 8 + $script:PTApiKey.Substring([Math]::Max(0, $script:PTApiKey.Length - 4)) } else { $null }
        ImportPath    = $script:PTImportPath
        MappingPath   = $script:PTMappingPath
        MappingLoaded = $null -ne $script:PTMapping
    }
}
