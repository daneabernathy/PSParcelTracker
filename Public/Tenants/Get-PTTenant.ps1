function Get-PTTenant {
    <#
    .SYNOPSIS
        Retrieves one tenant by ID, or lists tenants with optional filters.
    .PARAMETER TenantId
        Return a single tenant by ID.
    .PARAMETER DevelopmentId
        Filter by development/building ID.
    .PARAMETER UpdatedSince
        Return tenants updated since this date (ISO 8601).
    .PARAMETER All
        Fetch all pages of results automatically.
    .PARAMETER Filter
        A scriptblock to filter results client-side, like Where-Object.
    .PARAMETER Page
        Page number. Defaults to 1.
    .PARAMETER PageSize
        Results per page. Defaults to 200.
    .EXAMPLE
        Get-PTTenant
    .EXAMPLE
        Get-PTTenant -TenantId 'abc-123'
    .EXAMPLE
        Get-PTTenant -All -Filter { $_.Alias -eq 'A000000000' }
    .EXAMPLE
        Get-PTTenant -All -Filter { $_.Room -like '1*' }
    #>
    [CmdletBinding(DefaultParameterSetName = 'List')]
    [Alias('Get-PTRecipient')]
    param(
        [Parameter(Mandatory, ParameterSetName = 'Single', ValueFromPipelineByPropertyName)]
        [Alias('RecipientId', 'Id')]
        [string]$TenantId,

        [Parameter(ParameterSetName = 'List')][string]$DevelopmentId = $script:PTDevelopmentId,
        [Parameter(ParameterSetName = 'List')][string]$UpdatedSince,
        [Parameter(ParameterSetName = 'List')][switch]$All,
        [Parameter(ParameterSetName = 'List')][scriptblock]$Filter,
        [Parameter(ParameterSetName = 'List')][int]$Page     = 1,
        [Parameter(ParameterSetName = 'List')][int]$PageSize = 200
    )

    process {
        if ($PSCmdlet.ParameterSetName -eq 'Single') {
            Invoke-PTRequest -Method GET -Path "/api/public/tenants/$TenantId"
        } else {
            $PageSize = Assert-PTPageSize -PageSize $PageSize

            $query = @{
                development_id = $DevelopmentId
                updated_since  = $UpdatedSince
                page           = $Page
                page_size      = $PageSize
            }
            Invoke-PTPagedRequest -Path '/api/public/tenants' -Query $query -All:$All -Filter $Filter -TypeName 'ParcelTracker.Tenant'
        }
    }
}
