function New-PTParcel {
    <#
    .SYNOPSIS
        Creates a new parcel record.
    .PARAMETER RecipientId
        The ParcelTracker ID of the recipient tenant.
    .PARAMETER RecipientExternalId
        The external/integration ID of the recipient tenant. Use this or -RecipientId.
    .PARAMETER Barcode
        The parcel barcode.
    .PARAMETER TrackingNumber
        Courier tracking number.
    .PARAMETER Courier
        Courier name.
    .PARAMETER Size
        Parcel size descriptor.
    .PARAMETER Notes
        Notes to attach to the parcel.
    .PARAMETER Tags
        Array of tag strings.
    .PARAMETER Expected
        Mark the parcel as expected (pre-advised).
    .PARAMETER SiteId
        ID of the site where the parcel was received.
    .PARAMETER MailroomLocation
        Mailroom location label.
    .PARAMETER DocId
        Document ID.
    .PARAMETER Quantity
        Quantity.
    .PARAMETER ExternalSenderId
        ID of an external sender record.
    .EXAMPLE
        New-PTParcel -RecipientExternalId 'RES001' -TrackingNumber '1Z999' -Courier 'UPS'
    #>
    [CmdletBinding()]
    param(
        [string]$RecipientId,
        [string]$RecipientExternalId,
        [string]$Barcode,
        [string]$TrackingNumber,
        [string]$Courier,
        [string]$Size,
        [string]$Notes,
        [string[]]$Tags,
        [switch]$Expected,
        [string]$SiteId,
        [string]$MailroomLocation,
        [string]$DocId,
        [double]$Quantity,
        [string]$ExternalSenderId
    )

    $recipient = @{}
    if ($RecipientId)         { $recipient.Id         = $RecipientId }
    if ($RecipientExternalId) { $recipient.ExternalId = $RecipientExternalId }

    $body = @{ Recipient = $recipient }
    if ($PSBoundParameters.ContainsKey('Barcode'))          { $body.Barcode          = $Barcode }
    if ($PSBoundParameters.ContainsKey('TrackingNumber'))   { $body.TrackingNumber   = $TrackingNumber }
    if ($PSBoundParameters.ContainsKey('Courier'))          { $body.Courier          = $Courier }
    if ($PSBoundParameters.ContainsKey('Size'))             { $body.Size             = $Size }
    if ($PSBoundParameters.ContainsKey('Notes'))            { $body.Notes            = $Notes }
    if ($PSBoundParameters.ContainsKey('Tags'))             { $body.Tags             = $Tags }
    if ($PSBoundParameters.ContainsKey('Expected'))         { $body.Expected         = $Expected.IsPresent }
    if ($PSBoundParameters.ContainsKey('SiteId'))           { $body.SiteId           = $SiteId }
    if ($PSBoundParameters.ContainsKey('MailroomLocation')) { $body.MailroomLocation = $MailroomLocation }
    if ($PSBoundParameters.ContainsKey('DocId'))            { $body.DocId            = $DocId }
    if ($PSBoundParameters.ContainsKey('Quantity'))         { $body.Quantity         = $Quantity }
    if ($PSBoundParameters.ContainsKey('ExternalSenderId')) { $body.ExternalSenderId = $ExternalSenderId }

    Invoke-PTRequest -Method POST -Path '/api/public/parcels' -Body $body
}
