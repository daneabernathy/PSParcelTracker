function Get-PTParcelDimension {
    <#
    .SYNOPSIS
        Returns all configured parcel dimension/size options.
    .EXAMPLE
        Get-PTParcelDimension
    #>
    [CmdletBinding()]
    param()

    Invoke-PTRequest -Method GET -Path '/api/public/parcel-dimensions'
}
