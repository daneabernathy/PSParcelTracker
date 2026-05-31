function Connect-ParcelTracker {
    <#
    .SYNOPSIS
        Stores your ParcelTracker API key and development ID for use by all PT cmdlets.
    .PARAMETER ApiKey
        Your ParcelTracker API key.
    .PARAMETER DevelopmentId
        Your building/development ID. Used as the default for all commands that accept -DevelopmentId.
    .PARAMETER BaseUrl
        Override the default API base URL. Defaults to https://api.parceltracker.com
    .EXAMPLE
        Connect-ParcelTracker -ApiKey 'abc123' -DevelopmentId '1234'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$ApiKey,
        [Parameter(Mandatory)][string]$DevelopmentId,
        [string]$BaseUrl = 'https://api.parceltracker.com'
    )
    $script:PTApiKey        = $ApiKey
    $script:PTDevelopmentId = $DevelopmentId
    $script:PTBaseUrl       = $BaseUrl.TrimEnd('/')
    Write-Verbose "Connected to $script:PTBaseUrl (DevelopmentId: $DevelopmentId)"
}
