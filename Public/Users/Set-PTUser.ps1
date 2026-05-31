function Set-PTUser {
    <#
    .SYNOPSIS
        Updates an existing staff user.
    .PARAMETER UserId
        The ID of the user to update.
    .PARAMETER FirstName
        Updated first name.
    .PARAMETER LastName
        Updated last name.
    .PARAMETER Email
        Updated email address.
    .PARAMETER Type
        Updated access level.
    .PARAMETER DevelopmentIds
        Updated array of building IDs.
    .EXAMPLE
        Set-PTUser -UserId '123' -DevelopmentIds 42,43,44
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('Id')]
        [string]$UserId,
        [string]$FirstName,
        [string]$LastName,
        [string]$Email,
        [int]$Type,
        [int[]]$DevelopmentIds
    )

    process {
        $body = @{}
        if ($PSBoundParameters.ContainsKey('FirstName'))      { $body.firstName      = $FirstName }
        if ($PSBoundParameters.ContainsKey('LastName'))       { $body.lastName       = $LastName }
        if ($PSBoundParameters.ContainsKey('Email'))          { $body.email          = $Email }
        if ($PSBoundParameters.ContainsKey('Type'))           { $body.type           = $Type }
        if ($PSBoundParameters.ContainsKey('DevelopmentIds')) { $body.developmentIds = $DevelopmentIds }

        Invoke-PTRequest -Method PUT -Path "/api/public/users/$UserId" -Body $body
    }
}
