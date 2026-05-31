function Get-PTParcelByTenant {
    <#
    .SYNOPSIS
        Retrieves parcels for a specific tenant using the legacy v1 endpoint.
    .DESCRIPTION
        Uses the v1 API endpoint which queries by tenant ID. For new integrations,
        prefer Get-PTParcel which uses the v2 endpoint and supports richer filtering.
    .PARAMETER TenantId
        The ID of the tenant whose parcels to retrieve.
    .PARAMETER IncludeSignature
        Include signature data in the response.
    .PARAMETER IncludePhoto
        Include photo data in the response.
    .PARAMETER All
        Fetch all pages of results automatically.
    .PARAMETER Filter
        A scriptblock to filter results client-side, like Where-Object.
    .PARAMETER Page
        Page number. Defaults to 1.
    .PARAMETER PageSize
        Results per page. Defaults to 200.
    .EXAMPLE
        Get-PTParcelByTenant -TenantId 'abc-123'
    .EXAMPLE
        Get-PTParcelByTenant -TenantId 'abc-123' -IncludePhoto
    .EXAMPLE
        Get-PTParcelByTenant -TenantId 'abc-123' -All -Filter { $_.Courier -eq 'FedEx' }
    #>
    [CmdletBinding()]
    [Alias('Get-PTParcelByRecipient')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('RecipientId', 'Id', 'TenantId')]
        [string]$TenantId,
        [switch]$IncludeSignature,
        [switch]$IncludePhoto,
        [switch]$All,
        [scriptblock]$Filter,
        [int]$Page     = 1,
        [int]$PageSize = 200
    )

    process {
        $PageSize = Assert-PTPageSize -PageSize $PageSize

        $query = @{
            tenant_id         = $TenantId
            page              = $Page
            page_size         = $PageSize
            include_signature = $IncludeSignature.IsPresent.ToString().ToLower()
            include_photo     = $IncludePhoto.IsPresent.ToString().ToLower()
        }
        Invoke-PTPagedRequest -Path '/api/public/parcels' -Query $query -All:$All -Filter $Filter -TypeName 'ParcelTracker.Parcel'
    }
}
