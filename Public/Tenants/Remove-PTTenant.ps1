function Remove-PTTenant {
    <#
    .SYNOPSIS
        Permanently deletes a tenant. This action cannot be undone.
    .PARAMETER TenantId
        The ID of the tenant to delete.
    .EXAMPLE
        Remove-PTTenant -TenantId 'abc-123'
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [Alias('Remove-PTRecipient')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('RecipientId', 'Id')]
        [string]$TenantId
    )

    process {
        if ($PSCmdlet.ShouldProcess($TenantId, 'Delete tenant')) {
            Invoke-PTRequest -Method DELETE -Path "/api/public/tenants/$TenantId"
        }
    }
}
