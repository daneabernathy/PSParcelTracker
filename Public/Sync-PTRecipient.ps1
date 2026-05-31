function Sync-PTRecipient {
    <#
    .SYNOPSIS
        Syncs recipients into ParcelTracker from a CSV file or piped objects using a field mapping.
    .DESCRIPTION
        For each source record, applies the mapping and either creates a new recipient or updates
        an existing one matched by ExternalId (Id2 in ParcelTracker).

        Use -ExportRemovals to identify recipients in ParcelTracker that are not present in the
        source data. These are exported to a CSV for review. After editing the CSV, pipe it to
        Remove-PTRecipient to perform deletions.
    .PARAMETER Path
        Path to a CSV file to import.
    .PARAMETER InputObject
        Source objects piped in (e.g. from Get-MgUser or Get-ADUser).
    .PARAMETER Mapping
        A hashtable mapping ParcelTracker field names to source column names (string) or
        transformation scriptblocks (scriptblock receiving the row as $_).

        Required key: ExternalId — must map to the source field containing the Entra Object ID.

        Supported PT fields: FirstName, LastName, Email, Phone, Room, Alias,
                             ExternalId, DevelopmentId, NotificationOptions, DateOfBirth
    .PARAMETER DevelopmentId
        Building ID for new recipients. Defaults to the value set in Connect-ParcelTracker.
    .PARAMETER ExportRemovals
        Identifies PT recipients not present in the source data and exports them to a CSV.
        No recipients are deleted. The exported file can be reviewed, edited, and piped to
        Remove-PTRecipient.
    .PARAMETER ExportPath
        Path for the removals export CSV. Defaults to .\PTRemovals_<timestamp>.csv
    .EXAMPLE
        $mapping = @{
            ExternalId = 'ObjectId'
            FirstName  = 'GivenName'
            LastName   = 'Surname'
            Email      = 'Mail'
            Alias      = 'EmployeeId'
            Room       = { ($_.Building, $_.Room | Where-Object { $_ }) -join ' - ' }
        }
        Sync-PTRecipient -Path 'C:\exports\users.csv' -Mapping $mapping
    .EXAMPLE
        Sync-PTRecipient -Path 'C:\exports\users.csv' -Mapping $mapping -ExportRemovals -WhatIf
    .EXAMPLE
        Import-Csv 'PTRemovals_2024-01-01.csv' | Remove-PTRecipient
    #>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Path')]
    param(
        [Parameter(ParameterSetName = 'Path')][string]$Path = $script:PTImportPath,
        [Parameter(Mandatory, ParameterSetName = 'InputObject', ValueFromPipeline)][object[]]$InputObject,
        [hashtable]$Mapping = $script:PTMapping,
        [string]$DevelopmentId = $script:PTDevelopmentId,
        [switch]$ExportRemovals,
        [string]$ExportPath
    )

    begin {
        if (-not $Mapping) {
            throw "No mapping provided and no default mapping configured. Run Set-PTSyncConfig -MappingPath first, or pass -Mapping explicitly."
        }

        if ($PSCmdlet.ParameterSetName -eq 'Path' -and -not $Path) {
            throw "No import path provided and no default path configured. Run Set-PTSyncConfig -ImportPath first, or pass -Path explicitly."
        }

        # Validate mapping has ExternalId
        if (-not $Mapping.ContainsKey('ExternalId')) {
            throw "Mapping must include an 'ExternalId' key that maps to the source field containing the Entra Object ID."
        }

        # Validate mandatory PT fields are mappable
        foreach ($required in @('FirstName', 'LastName', 'Email')) {
            if (-not $Mapping.ContainsKey($required)) {
                throw "Mapping must include '$required'."
            }
        }

        # Load CSV if using Path parameter set
        $sourceRows = if ($PSCmdlet.ParameterSetName -eq 'Path') {
            if (-not (Test-Path $Path)) { throw "File not found: '$Path'" }
            Import-Csv -Path $Path
        } else {
            [System.Collections.Generic.List[object]]::new()
        }

        # Fetch all current PT recipients (keyed by Id2 for fast lookup)
        Write-Verbose "Fetching all current recipients from ParcelTracker..."
        $currentRecipients = @{}
        Get-PTTenant -All | ForEach-Object {
            if ($_.Id2) { $currentRecipients[$_.Id2] = $_ }
        }
        Write-Verbose "Found $($currentRecipients.Count) existing recipients."

        $stats = @{ Created = 0; Updated = 0; Skipped = 0; Unchanged = 0 }
        $sourceExternalIds = [System.Collections.Generic.HashSet[string]]::new()
    }

    process {
        # Accumulate piped objects
        if ($PSCmdlet.ParameterSetName -eq 'InputObject') {
            $sourceRows += $InputObject
        }
    }

    end {
        foreach ($row in $sourceRows) {
            $mapped = Resolve-PTMapping -Row $row -Mapping $Mapping

            $externalId = $mapped['ExternalId']
            if ([string]::IsNullOrWhiteSpace($externalId)) {
                Write-Warning "Skipping row — ExternalId resolved to empty. Row: $($row | ConvertTo-Json -Compress -Depth 1)"
                $stats.Skipped++
                continue
            }

            [void]$sourceExternalIds.Add($externalId)

            $devId = if ($mapped.ContainsKey('DevelopmentId') -and $mapped['DevelopmentId']) {
                $mapped['DevelopmentId']
            } else {
                $DevelopmentId
            }

            if ($currentRecipients.ContainsKey($externalId)) {
                # --- UPDATE ---
                $existing = $currentRecipients[$externalId]
                $changes  = @{}

                $updateFields = @('FirstName','LastName','Email','Phone','Room','Alias','NotificationOptions')
                foreach ($field in $updateFields) {
                    if (-not $mapped.ContainsKey($field)) { continue }
                    $newVal = $mapped[$field]
                    $curVal = $existing.$field
                    if ("$newVal" -ne "$curVal" -and -not [string]::IsNullOrWhiteSpace($newVal)) {
                        $changes[$field] = $newVal
                    }
                }

                if ($changes.Count -eq 0) {
                    Write-Verbose "Unchanged: $($existing.FirstName) $($existing.LastName) ($externalId)"
                    $stats.Unchanged++
                    continue
                }

                $desc = "Update recipient $($existing.FirstName) $($existing.LastName) [$($existing.Id)] — changed: $($changes.Keys -join ', ')"
                if ($PSCmdlet.ShouldProcess($desc)) {
                    $params = @{ TenantId = $existing.Id }
                    $changes.GetEnumerator() | ForEach-Object { $params[$_.Key] = $_.Value }
                    Set-PTTenant @params
                    $stats.Updated++
                }

            } else {
                # --- CREATE ---
                $desc = "Create recipient $($mapped['FirstName']) $($mapped['LastName']) (ExternalId: $externalId)"
                if ($PSCmdlet.ShouldProcess($desc)) {
                    $params = @{
                        FirstName     = $mapped['FirstName']
                        LastName      = $mapped['LastName']
                        Email         = $mapped['Email']
                        DevelopmentId = $devId
                        ExternalId    = $externalId
                    }
                    if ($mapped['Phone'])               { $params.Phone               = $mapped['Phone'] }
                    if ($mapped['Room'])                { $params.Room                = $mapped['Room'] }
                    if ($mapped['Alias'])               { $params.Alias               = $mapped['Alias'] }
                    if ($mapped['DateOfBirth'])         { $params.DateOfBirth         = $mapped['DateOfBirth'] }
                    if ($mapped['NotificationOptions']) { $params.NotificationOptions = $mapped['NotificationOptions'] }

                    New-PTTenant @params
                    $stats.Created++
                }
            }
        }

        # --- EXPORT REMOVALS ---
        if ($ExportRemovals) {
            $removals = $currentRecipients.Values | Where-Object {
                $_.Id2 -and -not $sourceExternalIds.Contains($_.Id2)
            }

            if ($removals.Count -eq 0) {
                Write-Host "No removals found — all PT recipients exist in the source data." -ForegroundColor Green
            } else {
                if (-not $ExportPath) {
                    $timestamp  = Get-Date -Format 'yyyy-MM-dd_HHmmss'
                    $ExportPath = Join-Path (Get-Location) "PTRemovals_$timestamp.csv"
                }

                $removals | Select-Object Id, Id2, FirstName, LastName, Alias, Email, Phone, Room, DevelopmentId |
                    Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8

                Write-Host "$($removals.Count) recipient(s) not in source data exported to:" -ForegroundColor Yellow
                Write-Host "  $ExportPath" -ForegroundColor Yellow
                Write-Host "Review the file, remove any rows that should NOT be deleted, then run:" -ForegroundColor Yellow
                Write-Host "  Import-Csv '$ExportPath' | Remove-PTRecipient" -ForegroundColor Cyan
            }
        }

        # --- SUMMARY ---
        Write-Host "`nSync complete:" -ForegroundColor Green
        Write-Host "  Created:   $($stats.Created)"
        Write-Host "  Updated:   $($stats.Updated)"
        Write-Host "  Unchanged: $($stats.Unchanged)"
        Write-Host "  Skipped:   $($stats.Skipped)"
    }
}
