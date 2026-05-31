function New-PTUser {
    <#
    .SYNOPSIS
        Creates a new staff user.
    .PARAMETER FirstName
        User first name.
    .PARAMETER LastName
        User last name.
    .PARAMETER Email
        User email address.
    .PARAMETER Type
        Access level. 0 = standard, 2 = admin (check API docs for full list).
    .PARAMETER DevelopmentIds
        Array of building IDs the user should have access to.
    .EXAMPLE
        New-PTUser -FirstName 'Bob' -LastName 'Jones' -Email 'bob@example.com' -Type 0 -DevelopmentIds 42,43
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$FirstName,
        [Parameter(Mandatory)][string]$LastName,
        [Parameter(Mandatory)][string]$Email,
        [Parameter(Mandatory)][int]$Type,
        [Parameter(Mandatory)][int[]]$DevelopmentIds
    )

    $body = @{
        firstName      = $FirstName
        lastName       = $LastName
        email          = $Email
        type           = $Type
        developmentIds = $DevelopmentIds
    }
    Invoke-PTRequest -Method POST -Path '/api/public/users' -Body $body
}
