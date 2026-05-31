function Get-PTParcelTag {
    <#
    .SYNOPSIS
        Returns all configured parcel tags.
    .EXAMPLE
        Get-PTParcelTag
    #>
    [CmdletBinding()]
    param()

    Invoke-PTRequest -Method GET -Path '/api/public/parcel-tags'
}
