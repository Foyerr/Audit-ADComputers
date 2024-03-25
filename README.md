# Active Directory Computer Object Audit

## Components

- **Audit-ADComputers.ps1**: Audits old computer objects based on their last login timestamp and other criteria.
- **Remove-DormantComputerObject.ps1**: Removes or disables dormant computer objects identified by the audit script.
- **Update-ADObjectHelper.ps1**: Provides functionalities to update computer objects in Active Directory, including renaming, moving, and appending messages to objects.

## Purpose

This toolkit helps maintain an organized and secure Active Directory environment by providing system administrators with the tools to:

- Identify computer objects that have not authenticated against AD for a specified number of days.
- Perform bulk updates to computer objects, including disabling, moving, and renaming.
- Log actions performed on AD objects for auditing and rollback purposes.

## Prerequisites

- PowerShell 5.1 or higher.
- Active Directory module for PowerShell.
- Appropriate permissions to view and modify computer objects in Active Directory.

## Usage

### Audit-ADComputers.ps1

**Parameters:**

Parameter | Explanation
--------- | -----------
`-daysSinceLogin` | Specifies the number of days since last login to identify old computer objects.
`-ping` | Optional switch to check if the computer responds to ping.
`-excludeOU` | Specifies OUs to exclude from the audit.
`-filter` | Custom LDAP filter to refine the search.
`-computerGroups` | Specifies groups to include in the audit.

**Example:**

```powershell
.\Audit-ADComputers.ps1 -daysSinceLogin 180 -ping -excludeOU "OU=TestOU,DC=example,DC=com"
```

### Update-ADObjectHelper.ps1

**Parameters:**

Parameter | Explanation
--------- | -----------
`-Identity` | Specifies the identity of the AD object to update. This is mandatory.
`-NewName` | Specifies the new name for the AD object. Optional.
`-AdMessage` | Appends a message to the 'info' attribute of the AD object. Optional.
`-TargetPath` | Specifies the OU to move the AD object to. This should be in 'OU=example,DC=domain,DC=com' format. Optional.
`-remove` | If specified, removes the AD object. This is a switch parameter and is optional.
`-disable` | If specified, disables the AD object. This is a switch parameter and is optional.
`-errorLogPath` | Specifies the path to the error log file where errors will be logged if they occur. Optional.

**Example:**

```powershell
.\Update-ADObjectHelper.ps1 -Identity "CN=OldComputer01,OU=OldComputers,DC=example,DC=com" -NewName "NewComputer01" -TargetPath "OU=Computers,DC=example,DC=com" -AdMessage "Moved to new OU" -errorLogPath "C:\Logs\UpdateErrors.log"

