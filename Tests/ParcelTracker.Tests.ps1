BeforeAll {
    $modulePath = Join-Path $PSScriptRoot '..\ParcelTracker.psd1'
    Import-Module $modulePath -Force

    # Fake a connected session so tests don't prompt for credentials
    InModuleScope ParcelTracker {
        $script:PTApiKey        = 'test-api-key'
        $script:PTDevelopmentId = '9999'
        $script:PTBaseUrl       = 'https://api.parceltracker.com'
    }
}

AfterAll {
    Remove-Module ParcelTracker -ErrorAction SilentlyContinue
}

# ---------------------------------------------------------------------------
# Connect / Disconnect
# ---------------------------------------------------------------------------
Describe 'Connect-ParcelTracker' {
    It 'Sets session variables' {
        Connect-ParcelTracker -ApiKey 'abc123' -DevelopmentId '42'
        InModuleScope ParcelTracker {
            $script:PTApiKey        | Should -Be 'abc123'
            $script:PTDevelopmentId | Should -Be '42'
            $script:PTBaseUrl       | Should -Be 'https://api.parceltracker.com'
        }
    }

    It 'Accepts a custom BaseUrl' {
        Connect-ParcelTracker -ApiKey 'abc123' -DevelopmentId '42' -BaseUrl 'https://staging.parceltracker.com/'
        InModuleScope ParcelTracker {
            $script:PTBaseUrl | Should -Be 'https://staging.parceltracker.com'
        }
    }
}

Describe 'Disconnect-ParcelTracker' {
    It 'Clears session variables' {
        Connect-ParcelTracker -ApiKey 'abc123' -DevelopmentId '42'
        Disconnect-ParcelTracker
        InModuleScope ParcelTracker {
            $script:PTApiKey        | Should -BeNullOrEmpty
            $script:PTDevelopmentId | Should -BeNullOrEmpty
        }
    }
}

# ---------------------------------------------------------------------------
# Get-PTConnection
# ---------------------------------------------------------------------------
Describe 'Get-PTConnection' {
    BeforeEach {
        Connect-ParcelTracker -ApiKey 'mykey123' -DevelopmentId '99'
    }

    It 'Returns Connected = true when connected' {
        $result = Get-PTConnection
        $result.Connected | Should -Be $true
    }

    It 'Masks the API key' {
        $result = Get-PTConnection
        $result.ApiKey | Should -Not -Be 'mykey123'
        $result.ApiKey | Should -Match '^\*+'
    }

    It 'Returns Connected = false after disconnect' {
        Disconnect-ParcelTracker
        $result = Get-PTConnection
        $result.Connected | Should -Be $false
    }
}

# ---------------------------------------------------------------------------
# Assert-PTPageSize
# ---------------------------------------------------------------------------
Describe 'Assert-PTPageSize' {
    It 'Returns the value when within range' {
        InModuleScope ParcelTracker {
            Assert-PTPageSize -PageSize 100 | Should -Be 100
        }
    }

    It 'Clamps to 200 and warns when over limit' {
        InModuleScope ParcelTracker {
            $result = Assert-PTPageSize -PageSize 500 -WarningVariable warn 3>$null
            $result | Should -Be 200
        }
    }

    It 'Throws when PageSize is less than 1' {
        InModuleScope ParcelTracker {
            { Assert-PTPageSize -PageSize 0 } | Should -Throw
        }
    }
}

# ---------------------------------------------------------------------------
# Get-PTTenant / Get-PTRecipient
# ---------------------------------------------------------------------------
Describe 'Get-PTTenant' {
    BeforeAll {
        Connect-ParcelTracker -ApiKey 'test' -DevelopmentId '99'

        # Mock at the HTTP level so real Invoke-PTPagedRequest (and its filter) runs
        Mock -ModuleName ParcelTracker Invoke-PTRequest {
            [PSCustomObject]@{
                Page         = 1
                PageSize     = 200
                TotalPages   = 1
                TotalResults = 2
                Elements     = @(
                    [PSCustomObject]@{ Id = 'tenant-1'; FirstName = 'Jane'; LastName = 'Doe'; Room = '101'; Alias = 'A001'; Email = 'jane@example.com' },
                    [PSCustomObject]@{ Id = 'tenant-2'; FirstName = 'John'; LastName = 'Smith'; Room = '102'; Alias = 'A002'; Email = 'john@example.com' }
                )
            }
        } -ParameterFilter { $Method -eq 'GET' -and $Path -eq '/api/public/tenants' }

        Mock -ModuleName ParcelTracker Invoke-PTRequest {
            [PSCustomObject]@{ Id = 'tenant-1'; FirstName = 'Jane'; LastName = 'Doe'; Room = '101' }
        } -ParameterFilter { $Method -eq 'GET' -and $Path -like '/api/public/tenants/*' }
    }

    It 'Calls Invoke-PTRequest for list' {
        Get-PTTenant
        Should -Invoke Invoke-PTRequest -ModuleName ParcelTracker -Times 1
    }

    It 'Calls Invoke-PTRequest for single tenant' {
        Get-PTTenant -TenantId 'tenant-1'
        Should -Invoke Invoke-PTRequest -ModuleName ParcelTracker -Times 1
    }

    It 'Returns results' {
        $results = Get-PTTenant
        $results.Count | Should -Be 2
    }

    It 'Filters results with -Filter' {
        $results = Get-PTTenant -Filter { $_.Room -eq '101' }
        $results.Count | Should -Be 1
        $results[0].FirstName | Should -Be 'Jane'
    }

    It 'Is accessible via Get-PTRecipient alias' {
        Get-PTRecipient
        Should -Invoke Invoke-PTRequest -ModuleName ParcelTracker -Times 1
    }
}

# ---------------------------------------------------------------------------
# Get-PTUser
# ---------------------------------------------------------------------------
Describe 'Get-PTUser' {
    BeforeAll {
        Connect-ParcelTracker -ApiKey 'test' -DevelopmentId '99'

        Mock -ModuleName ParcelTracker Invoke-PTPagedRequest {
            [PSCustomObject]@{ Id = 'user-1'; FirstName = 'Admin'; LastName = 'User'; Email = 'admin@example.com'; Type = 2 }
        }
    }

    It 'Calls Invoke-PTPagedRequest' {
        Get-PTUser
        Should -Invoke Invoke-PTPagedRequest -ModuleName ParcelTracker -Times 1
    }

    It 'Returns results' {
        $results = Get-PTUser
        $results.Count | Should -Be 1
        $results[0].Email | Should -Be 'admin@example.com'
    }
}

# ---------------------------------------------------------------------------
# Get-PTParcel
# ---------------------------------------------------------------------------
Describe 'Get-PTParcel' {
    BeforeAll {
        Connect-ParcelTracker -ApiKey 'test' -DevelopmentId '99'

        Mock -ModuleName ParcelTracker Invoke-PTRequest {
            [PSCustomObject]@{
                Page         = 1
                PageSize     = 200
                TotalPages   = 1
                TotalResults = 2
                Elements     = @(
                    [PSCustomObject]@{ Id = 'parcel-1'; Courier = 'UPS';   TrackingNumber = '1Z001' },
                    [PSCustomObject]@{ Id = 'parcel-2'; Courier = 'FedEx'; TrackingNumber = '1Z002' }
                )
            }
        }
    }

    It 'Calls Invoke-PTRequest' {
        Get-PTParcel
        Should -Invoke Invoke-PTRequest -ModuleName ParcelTracker -Times 1
    }

    It 'Filters by courier with -Filter' {
        $results = Get-PTParcel -Filter { $_.Courier -eq 'UPS' }
        $results.Count | Should -Be 1
        $results[0].TrackingNumber | Should -Be '1Z001'
    }
}

# ---------------------------------------------------------------------------
# Get-PTSite
# ---------------------------------------------------------------------------
Describe 'Get-PTSite' {
    BeforeAll {
        Mock -ModuleName ParcelTracker Invoke-PTRequest {
            @(
                [PSCustomObject]@{ Id = 1000; BuildingName = 'Test Building'; City = 'Test City' }
            )
        }
    }

    It 'Calls Invoke-PTRequest' {
        Get-PTSite
        Should -Invoke Invoke-PTRequest -ModuleName ParcelTracker -Times 1
    }

    It 'Returns site data' {
        $result = Get-PTSite
        $result.BuildingName | Should -Be 'Test Building'
    }
}

# ---------------------------------------------------------------------------
# Module structure
# ---------------------------------------------------------------------------
Describe 'Module structure' {
    It 'Exports all expected functions' {
        $exported = (Get-Module ParcelTracker).ExportedFunctions.Keys | Sort-Object
        $exported | Should -Contain 'Connect-ParcelTracker'
        $exported | Should -Contain 'Disconnect-ParcelTracker'
        $exported | Should -Contain 'Get-PTConnection'
        $exported | Should -Contain 'Get-PTParcel'
        $exported | Should -Contain 'Get-PTParcelByTenant'
        $exported | Should -Contain 'Get-PTTenant'
        $exported | Should -Contain 'Get-PTUser'
        $exported | Should -Contain 'Get-PTSite'
        $exported | Should -Contain 'New-PTParcel'
        $exported | Should -Contain 'New-PTTenant'
        $exported | Should -Contain 'New-PTUser'
        $exported | Should -Contain 'Remove-PTParcel'
        $exported | Should -Contain 'Remove-PTTenant'
        $exported | Should -Contain 'Remove-PTUser'
        $exported | Should -Contain 'Set-PTTenant'
        $exported | Should -Contain 'Set-PTUser'
        $exported | Should -Contain 'Import-PTConfig'
        $exported | Should -Contain 'Export-PTConfig'
    }

    It 'Exports all expected aliases' {
        $exported = (Get-Module ParcelTracker).ExportedAliases.Keys | Sort-Object
        $exported | Should -Contain 'Get-PTRecipient'
        $exported | Should -Contain 'New-PTRecipient'
        $exported | Should -Contain 'Set-PTRecipient'
        $exported | Should -Contain 'Remove-PTRecipient'
        $exported | Should -Contain 'Get-PTParcelByRecipient'
    }
}
