function New-PTExternalSender {
    <#
    .SYNOPSIS
        Creates an external sender record. Name is required; all other fields are optional.
        Duplicate names will result in a 409 Conflict error.
    .PARAMETER Name
        Sender name (must be unique).
    .PARAMETER Email
        Sender email address.
    .PARAMETER AddressLine1
        Address line 1.
    .PARAMETER AddressLine2
        Address line 2.
    .PARAMETER City
        City.
    .PARAMETER State
        State or province.
    .PARAMETER Postcode
        Postcode or zip code.
    .PARAMETER Country
        Country.
    .EXAMPLE
        New-PTExternalSender -Name 'Amazon' -Email 'noreply@amazon.com'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Name,
        [string]$Email,
        [string]$AddressLine1,
        [string]$AddressLine2,
        [string]$City,
        [string]$State,
        [string]$Postcode,
        [string]$Country
    )

    $body = @{ Name = $Name }
    if ($PSBoundParameters.ContainsKey('Email'))        { $body.Email        = $Email }
    if ($PSBoundParameters.ContainsKey('AddressLine1')) { $body.AddressLine1 = $AddressLine1 }
    if ($PSBoundParameters.ContainsKey('AddressLine2')) { $body.AddressLine2 = $AddressLine2 }
    if ($PSBoundParameters.ContainsKey('City'))         { $body.City         = $City }
    if ($PSBoundParameters.ContainsKey('State'))        { $body.State        = $State }
    if ($PSBoundParameters.ContainsKey('Postcode'))     { $body.Postcode     = $Postcode }
    if ($PSBoundParameters.ContainsKey('Country'))      { $body.Country      = $Country }

    Invoke-PTRequest -Method POST -Path '/api/public/external-senders' -Body $body
}
