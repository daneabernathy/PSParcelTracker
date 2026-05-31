function Get-PTParcel {
    <#
    .SYNOPSIS
        Retrieves parcels using the v2 endpoint. Recommended for all new integrations.
    .PARAMETER DevelopmentId
        Filter by development/building ID. Defaults to the value set in Connect-ParcelTracker.
    .PARAMETER LoggedInSince
        Return parcels logged in since this date (ISO 8601).
    .PARAMETER UpdatedSince
        Return parcels updated since this date (ISO 8601).
    .PARAMETER RecipientExternalId
        Filter by recipient external ID.
    .PARAMETER RecipientEmail
        Filter by recipient email address.
    .PARAMETER All
        Fetch all pages of results automatically.
    .PARAMETER Filter
        A scriptblock to filter results client-side, like Where-Object.
    .PARAMETER Page
        Page number. Defaults to 1.
    .PARAMETER PageSize
        Results per page. Defaults to 200.
    .EXAMPLE
        Get-PTParcel
    .EXAMPLE
        Get-PTParcel -All -Filter { $_.Courier -eq 'UPS' }
    .EXAMPLE
        Get-PTParcel -All -UpdatedSince '2024-01-01' -Filter { $_.Size -eq 'Large' }
    #>
    [CmdletBinding()]
    param(
        [string]$DevelopmentId = $script:PTDevelopmentId,
        [string]$LoggedInSince,
        [string]$UpdatedSince,
        [string]$RecipientExternalId,
        [string]$RecipientEmail,
        [switch]$All,
        [scriptblock]$Filter,
        [int]$Page     = 1,
        [int]$PageSize = 200
    )

    $PageSize = Assert-PTPageSize -PageSize $PageSize

    $query = @{
        development_id        = $DevelopmentId
        logged_in_since       = $LoggedInSince
        updated_since         = $UpdatedSince
        recipient_external_id = $RecipientExternalId
        recipient_email       = $RecipientEmail
        page                  = $Page
        page_size             = $PageSize
    }
    Invoke-PTPagedRequest -Path '/api/v2/public/parcels' -Query $query -All:$All -Filter $Filter -TypeName 'ParcelTracker.Parcel'
}
