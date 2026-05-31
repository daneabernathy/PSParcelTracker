function Remove-PTParcel {
    <#
    .SYNOPSIS
        Permanently deletes a parcel. This action cannot be undone.
    .PARAMETER ParcelId
        The ID of the parcel to delete.
    .EXAMPLE
        Remove-PTParcel -ParcelId 'abc-123'
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [string]$ParcelId
    )

    process {
        if ($PSCmdlet.ShouldProcess($ParcelId, 'Delete parcel')) {
            Invoke-PTRequest -Method DELETE -Path "/api/public/parcels/$ParcelId"
        }
    }
}
