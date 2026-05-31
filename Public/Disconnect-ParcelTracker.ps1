function Disconnect-ParcelTracker {
    <#
    .SYNOPSIS
        Clears the current ParcelTracker session.
    .PARAMETER RemoveConfig
        Also deletes the saved config file from $env:APPDATA\ParcelTracker\config.json.
    .EXAMPLE
        Disconnect-ParcelTracker
    .EXAMPLE
        Disconnect-ParcelTracker -RemoveConfig
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [switch]$RemoveConfig
    )

    $script:PTApiKey        = $null
    $script:PTDevelopmentId = $null
    $script:PTBaseUrl       = 'https://api.parceltracker.com'

    if ($RemoveConfig) {
        $configPath = Join-Path $env:APPDATA 'ParcelTracker\config.json'
        if (Test-Path $configPath) {
            if ($PSCmdlet.ShouldProcess($configPath, 'Delete saved config')) {
                Remove-Item $configPath -Force
                Write-Verbose "Config file removed."
            }
        } else {
            Write-Verbose "No config file found at '$configPath'."
        }
    }

    Write-Verbose "Disconnected from ParcelTracker."
}
