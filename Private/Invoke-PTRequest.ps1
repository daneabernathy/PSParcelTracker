function Invoke-PTRequest {
    param(
        [Parameter(Mandatory)][string]$Method,
        [Parameter(Mandatory)][string]$Path,
        [hashtable]$Query,
        [object]$Body
    )

    if (-not $script:PTApiKey) {
        $PSCmdlet.ThrowTerminatingError([System.Management.Automation.ErrorRecord]::new(
            [System.InvalidOperationException]::new('Not connected. Run Connect-ParcelTracker first.'),
            'PT.NotConnected',
            [System.Management.Automation.ErrorCategory]::ConnectionError,
            $null
        ))
    }

    $uri = $script:PTBaseUrl + $Path

    if ($Query -and $Query.Count -gt 0) {
        $qs = $Query.GetEnumerator() |
            Where-Object { $null -ne $_.Value -and $_.Value -ne '' } |
            ForEach-Object { "$($_.Key)=$([uri]::EscapeDataString($_.Value.ToString()))" }
        if ($qs) { $uri += '?' + ($qs -join '&') }
    }

    $params = @{
        Method      = $Method
        Uri         = $uri
        Headers     = @{ Authorization = "ApiKey $script:PTApiKey" }
        ContentType = 'application/json'
        ErrorAction = 'Stop'
    }

    if ($Body) {
        $params.Body = $Body | ConvertTo-Json -Depth 10
    }

    try {
        Invoke-RestMethod @params
    } catch [System.Net.Http.HttpRequestException] {
        $statusCode = [int]$_.Exception.StatusCode

        $detail  = $_.ErrorDetails.Message
        $parsed  = $detail | ConvertFrom-Json -ErrorAction SilentlyContinue
        $message = if ($parsed.message) { $parsed.message }
                   elseif ($parsed.error) { $parsed.error }
                   elseif ($detail)       { $detail }
                   else                   { $_.Exception.Message }

        $category = switch ($statusCode) {
            400 { [System.Management.Automation.ErrorCategory]::InvalidArgument }
            401 { [System.Management.Automation.ErrorCategory]::AuthenticationError }
            403 { [System.Management.Automation.ErrorCategory]::PermissionDenied }
            404 { [System.Management.Automation.ErrorCategory]::ObjectNotFound }
            409 { [System.Management.Automation.ErrorCategory]::ResourceExists }
            429 { [System.Management.Automation.ErrorCategory]::LimitsExceeded }
            default { [System.Management.Automation.ErrorCategory]::NotSpecified }
        }

        $errorId = "PT.Http$statusCode"
        $exception = [System.Exception]::new("[$statusCode] $message")

        $PSCmdlet.ThrowTerminatingError([System.Management.Automation.ErrorRecord]::new(
            $exception,
            $errorId,
            $category,
            $uri
        ))
    }
}
