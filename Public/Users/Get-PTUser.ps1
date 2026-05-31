function Get-PTUser {
    <#
    .SYNOPSIS
        Lists users, optionally filtered by building.
    .PARAMETER DevelopmentId
        Filter by development/building ID. Defaults to the value set in Connect-ParcelTracker.
    .PARAMETER All
        Fetch all pages of results automatically.
    .PARAMETER Filter
        A scriptblock to filter results client-side, like Where-Object.
    .PARAMETER Page
        Page number. Defaults to 1.
    .PARAMETER PageSize
        Results per page. Defaults to 200.
    .EXAMPLE
        Get-PTUser
    .EXAMPLE
        Get-PTUser -All -Filter { $_.Email -like '*@example.com' }
    #>
    [CmdletBinding()]
    param(
        [string]$DevelopmentId = $script:PTDevelopmentId,
        [switch]$All,
        [scriptblock]$Filter,
        [int]$Page     = 1,
        [int]$PageSize = 200
    )

    $PageSize = Assert-PTPageSize -PageSize $PageSize

    $query = @{
        development_id = $DevelopmentId
        page           = $Page
        page_size      = $PageSize
    }
    Invoke-PTPagedRequest -Path '/api/public/users' -Query $query -All:$All -Filter $Filter -TypeName 'ParcelTracker.User'
}
