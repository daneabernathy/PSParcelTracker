function New-PTTenant {
    <#
    .SYNOPSIS
        Creates a new tenant (resident) in a building.
    .PARAMETER FirstName
        Tenant first name.
    .PARAMETER LastName
        Tenant last name.
    .PARAMETER Email
        Tenant email address.
    .PARAMETER DevelopmentId
        ID of the building to add the tenant to.
    .PARAMETER Room
        Room or unit number.
    .PARAMETER Phone
        Tenant phone number.
    .PARAMETER Alias
        Nickname used by the OCR algorithm for matching.
    .PARAMETER NotificationOptions
        Notification preference bitmask.
    .PARAMETER ExternalId
        External system ID for the recipient (e.g. Entra Object ID). Stored as Id2 in ParcelTracker.
    .PARAMETER DateOfBirth
        Date of birth in YYYY-MM-DD format.
    .EXAMPLE
        New-PTTenant -FirstName 'Jane' -LastName 'Smith' -Email 'jane@example.com' -DevelopmentId '42' -Room '101'
    .EXAMPLE
        New-PTTenant -FirstName 'Jane' -LastName 'Smith' -Email 'jane@example.com' -DevelopmentId '42' -ExternalId 'entra-object-id'
    #>
    [CmdletBinding()]
    [Alias('New-PTRecipient')]
    param(
        [Parameter(Mandatory)][string]$FirstName,
        [Parameter(Mandatory)][string]$LastName,
        [Parameter(Mandatory)][string]$Email,
        [Parameter(Mandatory)][string]$DevelopmentId,
        [string]$ExternalId,
        [string]$Room,
        [string]$Phone,
        [string]$Alias,
        [int]$NotificationOptions,
        [string]$DateOfBirth
    )

    $body = @{
        firstName     = $FirstName
        lastName      = $LastName
        email         = $Email
        developmentId = $DevelopmentId
    }
    if ($PSBoundParameters.ContainsKey('ExternalId'))          { $body.externalId          = $ExternalId }
    if ($PSBoundParameters.ContainsKey('Room'))                { $body.room                = $Room }
    if ($PSBoundParameters.ContainsKey('Phone'))               { $body.phone               = $Phone }
    if ($PSBoundParameters.ContainsKey('Alias'))               { $body.alias               = $Alias }
    if ($PSBoundParameters.ContainsKey('NotificationOptions')) { $body.notificationOptions = $NotificationOptions }
    if ($PSBoundParameters.ContainsKey('DateOfBirth'))         { $body.dateOfBirth         = $DateOfBirth }

    Invoke-PTRequest -Method POST -Path '/api/public/tenants' -Body $body
}
