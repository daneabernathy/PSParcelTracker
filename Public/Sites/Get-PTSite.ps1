function Get-PTSite {
    <#
    .SYNOPSIS
        Returns all sites configured in ParcelTracker.
    .EXAMPLE
        Get-PTSite
    #>
    [CmdletBinding()]
    param()

    $results = Invoke-PTRequest -Method GET -Path '/api/public/sites'
    foreach ($site in $results) {
        $site.PSObject.TypeNames.Insert(0, 'ParcelTracker.Site')
    }
    $results
}
