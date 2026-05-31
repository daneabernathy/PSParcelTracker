function Remove-PTUser {
    <#
    .SYNOPSIS
        Permanently deletes a staff user.
    .PARAMETER UserId
        The ID of the user to delete.
    .EXAMPLE
        Remove-PTUser -UserId 'abc-123'
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [string]$UserId
    )

    process {
        if ($PSCmdlet.ShouldProcess($UserId, 'Delete user')) {
            Invoke-PTRequest -Method DELETE -Path "/api/public/users/$UserId"
        }
    }
}
