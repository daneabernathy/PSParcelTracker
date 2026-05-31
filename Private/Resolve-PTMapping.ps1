function Resolve-PTMapping {
    <#
        Applies a mapping hashtable to a source row, returning a hashtable of
        PT field names to resolved values. Mapping values can be either a string
        (source property name) or a scriptblock (receives the row as $_).
    #>
    param(
        [Parameter(Mandatory)][object]$Row,
        [Parameter(Mandatory)][hashtable]$Mapping
    )

    $result = @{}
    foreach ($ptField in $Mapping.Keys) {
        $def = $Mapping[$ptField]
        $result[$ptField] = if ($def -is [scriptblock]) {
            $Row | ForEach-Object $def
        } else {
            $Row.$def
        }
    }
    return $result
}
