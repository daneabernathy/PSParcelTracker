function Set-PTSyncConfig {
    <#
    .SYNOPSIS
        Stores the default import CSV path and mapping file for Sync-PTRecipient.
    .DESCRIPTION
        Registers a default CSV path and a mapping .ps1 file so that Sync-PTRecipient
        can be called without specifying -Path and -Mapping every time.

        The mapping file should be a .ps1 script that returns a hashtable, e.g.:

            @{
                ExternalId = 'ObjectId'
                FirstName  = 'GivenName'
                LastName   = 'Surname'
                Email      = 'Mail'
                Alias      = 'EmployeeId'
                Phone      = { $_.MobilePhone ?? $_.BusinessPhone }
            }

        Call Export-PTConfig after this to persist the settings.
    .PARAMETER ImportPath
        Path to the default CSV file to use with Sync-PTRecipient.
    .PARAMETER MappingPath
        Path to a .ps1 file that returns the field mapping hashtable.
    .EXAMPLE
        Set-PTSyncConfig -ImportPath 'C:\exports\users.csv' -MappingPath 'C:\ParcelTracker\mapping.ps1'
        Export-PTConfig
    #>
    [CmdletBinding()]
    param(
        [string]$ImportPath,
        [string]$MappingPath
    )

    if ($PSBoundParameters.ContainsKey('ImportPath')) {
        if ($ImportPath -and -not (Test-Path $ImportPath)) {
            Write-Warning "Import file not found at '$ImportPath'. Path saved but file does not currently exist."
        }
        $script:PTImportPath = $ImportPath
    }

    if ($PSBoundParameters.ContainsKey('MappingPath')) {
        if (-not (Test-Path $MappingPath)) {
            throw "Mapping file not found at '$MappingPath'."
        }
        $script:PTMappingPath = $MappingPath
        $script:PTMapping     = & $MappingPath
        Write-Verbose "Mapping loaded from '$MappingPath' — keys: $($script:PTMapping.Keys -join ', ')"
    }

    Write-Verbose "Sync config updated. Run Export-PTConfig to persist."
}
