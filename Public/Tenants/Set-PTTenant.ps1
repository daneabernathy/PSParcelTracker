function Set-PTTenant {
    <#
    .SYNOPSIS
        Updates an existing tenant's details.
    .PARAMETER TenantId
        The ID of the tenant to update.
    .PARAMETER FirstName
        Updated first name.
    .PARAMETER LastName
        Updated last name.
    .PARAMETER Email
        Updated email address.
    .PARAMETER DevelopmentId
        Updated building ID.
    .PARAMETER Room
        Updated room or unit number.
    .PARAMETER Phone
        Updated phone number.
    .PARAMETER Alias
        Updated alias/nickname.
    .PARAMETER NotificationOptions
        Updated notification preference bitmask.
    .EXAMPLE
        Set-PTTenant -TenantId 'abc-123' -Room '202' -Phone '555-1234'
    #>
    [CmdletBinding()]
    [Alias('Set-PTRecipient')]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('RecipientId', 'Id')]
        [string]$TenantId,
        [string]$FirstName,
        [string]$LastName,
        [string]$Email,
        [string]$DevelopmentId,
        [string]$Room,
        [string]$Phone,
        [string]$Alias,
        [int]$NotificationOptions
    )

    process {
        $body = @{}
        if ($PSBoundParameters.ContainsKey('FirstName'))           { $body.firstName           = $FirstName }
        if ($PSBoundParameters.ContainsKey('LastName'))            { $body.lastName            = $LastName }
        if ($PSBoundParameters.ContainsKey('Email'))               { $body.email               = $Email }
        if ($PSBoundParameters.ContainsKey('DevelopmentId'))       { $body.developmentId       = $DevelopmentId }
        if ($PSBoundParameters.ContainsKey('Room'))                { $body.room                = $Room }
        if ($PSBoundParameters.ContainsKey('Phone'))               { $body.phone               = $Phone }
        if ($PSBoundParameters.ContainsKey('Alias'))               { $body.alias               = $Alias }
        if ($PSBoundParameters.ContainsKey('NotificationOptions')) { $body.notificationOptions = $NotificationOptions }

        Invoke-PTRequest -Method PUT -Path "/api/public/tenants/$TenantId" -Body $body
    }
}
