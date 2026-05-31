function Invoke-PTParcelCheckout {
    <#
    .SYNOPSIS
        Marks one or more parcels as checked out (collected).
    .PARAMETER ParcelId
        One or more parcel IDs to check out.
    .PARAMETER CollectionNotes
        Optional notes to attach to the collection record.
    .PARAMETER SendNotifications
        Send collection notifications to recipients. Defaults to $true.
    .EXAMPLE
        Invoke-PTParcelCheckout -ParcelId 'abc-123','def-456'
    .EXAMPLE
        Get-PTParcel -TenantId 'xyz' | Select-Object -ExpandProperty Id | Invoke-PTParcelCheckout
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [string[]]$ParcelId,
        [string]$CollectionNotes,
        [bool]$SendNotifications = $true
    )

    begin   { $ids = [System.Collections.Generic.List[string]]::new() }
    process { $ids.AddRange($ParcelId) }
    end {
        $body = @{
            ParcelIds         = $ids.ToArray()
            SendNotifications = $SendNotifications
        }
        if ($PSBoundParameters.ContainsKey('CollectionNotes')) {
            $body.CollectionNotes = $CollectionNotes
        }
        Invoke-PTRequest -Method POST -Path '/api/v2/public/parcels/collect' -Body $body
    }
}
