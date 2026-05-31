function Assert-PTPageSize {
    param(
        [Parameter(Mandatory)][int]$PageSize
    )

    if ($PageSize -lt 1) {
        throw "PageSize must be at least 1."
    }

    if ($PageSize -gt 200) {
        Write-Warning "PageSize '$PageSize' exceeds the API maximum of 200. Clamping to 200."
        return 200
    }

    return $PageSize
}
