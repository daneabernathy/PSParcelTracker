# PSParcelTracker

A PowerShell module for interacting with the [Parcel Tracker](https://parceltracker.com) API. Covers the full public API surface — parcels, recipients/tenants, users, sites, tags, dimensions, and external senders — with support for filtering, auto-pagination, recipient syncing from CSV, and persistent connection configuration.

---

## Attribution and Disclaimer

This module is an independent, community-built integration and is **not affiliated with, endorsed by, or maintained by [Deepfinity LTD](https://parceltracker.com)** [@deepfinity](https://github.com/deepfinity) the company behind Parcel Tracker.

- **Parcel Tracker** is a product of Deepfinity LTD, registered in England and Wales (Company No. 10341207).
- **Parcel Tracker website:** https://parceltracker.com
- **Parcel Tracker developer / API documentation:** https://developer.parceltracker.com

All API design, endpoints, field names, and authentication methods belong to Deepfinity LTD. This module simply provides a PowerShell-native interface to their published public API.

---

## Credits

Authored by **Dane Abernathy**.

Built with the assistance of [Claude](https://claude.ai) by [Anthropic](https://anthropic.com).

---

## License

This project is licensed under the [MIT License](LICENSE). It is free to use, modify, and distribute for any purpose, personal or commercial.

---

## Requirements

- PowerShell 7.0 or later
- A Parcel Tracker API key (contact your Parcel Tracker account representative)
- Your Parcel Tracker Development/Building ID

---

## Installation

Clone the repository and import the module directly:

```powershell
git clone https://github.com/daneabernathy/PSParcelTracker.git
Import-Module ./PSParcelTracker/PSParcelTracker.psd1
```

---

## Getting Started

### Connecting

On first import, if no saved config is found, the module will prompt for your API key and Development ID. You can also connect manually at any time:

```powershell
Connect-ParcelTracker -ApiKey 'your-api-key' -DevelopmentId 'your-development-id'
```

### Saving your connection

Once connected, save your credentials for future sessions. The API key is encrypted using Windows DPAPI and stored in `$env:APPDATA\PSParcelTracker\config.json` — it is tied to your Windows user account and cannot be decrypted by anyone else or on another machine.

```powershell
Export-PTConfig
```

After saving, future imports will connect automatically without prompting.

### Checking connection status

```powershell
Get-PTConnection
```

### Disconnecting

```powershell
Disconnect-ParcelTracker

# Also remove the saved config file
Disconnect-ParcelTracker -RemoveConfig
```

---

## Commands

### Parcels

| Command | Description |
|---|---|
| `Get-PTParcel` | List parcels using the v2 endpoint (recommended). Supports `-All` and `-Filter`. |
| `Get-PTParcelByTenant` | List parcels for a specific recipient using the legacy v1 endpoint. Supports `-All` and `-Filter`. |
| `New-PTParcel` | Log a new incoming parcel. |
| `Remove-PTParcel` | Permanently delete a parcel. Prompts for confirmation. |
| `Invoke-PTParcelCheckout` | Mark one or more parcels as collected. Accepts pipeline input. |

### Recipients / Tenants

Parcel Tracker uses the term "tenant" in their v1 API and "recipient" in v2. All commands support both names interchangeably — `Get-PTTenant` and `Get-PTRecipient` are the same command, as are their `New-`, `Set-`, and `Remove-` equivalents.

| Command | Alias | Description |
|---|---|---|
| `Get-PTTenant` | `Get-PTRecipient` | Get a single recipient by ID, or list recipients. Supports `-All` and `-Filter`. |
| `New-PTTenant` | `New-PTRecipient` | Create a new recipient. |
| `Set-PTTenant` | `Set-PTRecipient` | Update an existing recipient. |
| `Remove-PTTenant` | `Remove-PTRecipient` | Permanently delete a recipient. Prompts for confirmation. |

### Users

| Command | Description |
|---|---|
| `Get-PTUser` | List staff users. Supports `-All` and `-Filter`. |
| `New-PTUser` | Create a new staff user. |
| `Set-PTUser` | Update an existing staff user. |
| `Remove-PTUser` | Permanently delete a staff user. Prompts for confirmation. |

### Reference Data

| Command | Description |
|---|---|
| `Get-PTSite` | List all configured sites/buildings. |
| `Get-PTParcelDimension` | List configured parcel size options. |
| `Get-PTParcelTag` | List configured parcel tags. |
| `New-PTExternalSender` | Create an external sender record. |

### Configuration

| Command | Description |
|---|---|
| `Connect-ParcelTracker` | Set your API key and Development ID for the session. |
| `Disconnect-ParcelTracker` | Clear the session. Optionally removes the saved config. |
| `Export-PTConfig` | Save the current connection (and sync config) to disk. |
| `Import-PTConfig` | Load a previously saved config. Called automatically on import. |
| `Get-PTConnection` | Show current connection status, including sync config. |
| `Set-PTSyncConfig` | Register a default import CSV path and mapping file for `Sync-PTRecipient`. |

---

## Filtering and Pagination

All list commands support client-side filtering via a `-Filter` scriptblock and automatic pagination via `-All`.

```powershell
# Return the first page only (default)
Get-PTRecipient

# Fetch all pages and filter results
Get-PTRecipient -All -Filter { $_.Room -eq '101' }
Get-PTParcel -All -Filter { $_.Courier -eq 'UPS' }

# Combine API-side and client-side filtering
Get-PTParcel -UpdatedSince '2024-01-01' -All -Filter { $_.Size -eq 'Large' }
```

The `-Filter` scriptblock works identically to `Where-Object` — any PowerShell comparison operator is valid.

> **Note:** `Get-PTParcel` can return 150,000+ records. Always use `-UpdatedSince`, `-RecipientEmail`, or other API-side filters alongside `-All` where possible.

---

## Recipient Sync

`Sync-PTRecipient` imports recipients from a CSV file or piped objects and creates or updates them in Parcel Tracker. Matching is done on `ExternalId` (stored as `Id2` in Parcel Tracker, corresponding to the Entra Object ID or equivalent external identifier).

### Defining a mapping file

Create a `.ps1` file that returns a hashtable mapping Parcel Tracker field names to source column names. Values can be a plain string (column name) or a scriptblock for transformations:

```powershell
# mapping.ps1
@{
    ExternalId = 'ObjectId'
    FirstName  = 'GivenName'
    LastName   = 'Surname'
    Email      = 'Mail'
    Alias      = 'EmployeeId'
    Room       = 'Department'
    Phone      = { $_.MobilePhone ?? $_.BusinessPhone }
}
```

### Registering the sync config

```powershell
Set-PTSyncConfig -ImportPath 'C:\exports\users.csv' -MappingPath 'C:\config\mapping.ps1'
Export-PTConfig
```

Once saved, `Sync-PTRecipient` can be called with no arguments.

### Running a sync

```powershell
# Dry run — see what would be created or updated without making changes
Sync-PTRecipient -WhatIf

# Live sync
Sync-PTRecipient

# Override the default file
Sync-PTRecipient -Path 'C:\exports\users_today.csv'

# Pipe objects directly (e.g. from Get-MgUser or Get-ADUser)
Get-MgUser -All | Sync-PTRecipient -Mapping $mapping
```

### Identifying removals

`Sync-PTRecipient` never deletes recipients by default. Use `-ExportRemovals` to identify recipients in Parcel Tracker that are not present in the source data:

```powershell
Sync-PTRecipient -ExportRemovals
```

This exports a CSV of unmatched recipients for review. After removing any rows that should be kept, pass the file to `Remove-PTRecipient`:

```powershell
Import-Csv 'PTRemovals_2026-05-31.csv' | Remove-PTRecipient
```

---

## Pipeline Support

Commands are designed to work together in the pipeline. Objects returned from one command bind naturally to the next:

```powershell
# Get all parcels for a recipient
Get-PTRecipient -Filter { $_.Alias -eq 'A12345' } | Get-PTParcelByRecipient

# Check out all uncollected parcels for a recipient
Get-PTParcelByRecipient -RecipientId 'abc-123' -All | Invoke-PTParcelCheckout
```

---

## Running Tests

The module includes a [Pester](https://pester.dev) test suite. Tests are fully mocked and do not make live API calls.

```powershell
Install-Module Pester -MinimumVersion 5.0 -Scope CurrentUser
Invoke-Pester ./Tests/PSParcelTracker.Tests.ps1
```
