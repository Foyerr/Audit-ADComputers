# Active Directory Computer Object Management Toolkit

This toolkit consists of PowerShell scripts designed to help system administrators audit, update, and clean up computer objects in Active Directory. The toolkit aims to enhance the efficiency and accuracy of managing computer accounts, especially those that are outdated, no longer in use, or need updates to their AD attributes.

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