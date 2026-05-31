function Invoke-PTPagedRequest {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][hashtable]$Query,
        [switch]$All,
        [scriptblock]$Filter,
        [string]$TypeName
    )

    $currentPage = $Query.page ?? 1

    do {
        $Query.page = $currentPage
        $response   = Invoke-PTRequest -Method GET -Path $Path -Query $Query
        $elements   = $response.Elements
        $totalPages = $response.TotalPages

        if ($TypeName) {
            foreach ($element in $elements) {
                $element.PSObject.TypeNames.Insert(0, $TypeName)
            }
        }

        if ($Filter) {
            $elements | Where-Object $Filter
        } else {
            $elements
        }

        $currentPage++
    } while ($All -and $currentPage -le $totalPages)
}
