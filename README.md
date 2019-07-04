# PoShDynDnsApi

**PoShDynDnsApi** is an unofficial PowerShell module used to interact with Dyn Managed DNS REST API.

For online help, please visit the [module help site](https://powershell.anovelidea.org/modulehelp/PoShDynDnsApi/).

## Session Commands

Use the following commands to create, extend, test, or remove a session. Additionally, you can view the current session
information or view the current session history.

### Connect-DynDnsSession

The `Connect-DynDnsSession` command creates a new session.

### Send-DynDnsSession

The `Send-DynDnsSession` command extends the current session.

### Test-DynDnsSession

The `Test-DynDnsSession` command verifies that a session is still active.

### Disconnect-DynDnsSession

The `Disconnect-DynDnsSession` command terminates an existing, valid session.

### Get-DynDnsSession

The `Get-DynDnsSession` command retrieves information about the current session.

### Get-DynDnsHistory

The `Get-DynDnsHistory` command shows the history of commands that have been sent in the current session.

## Zone Commands

Use the following commands to create a zone by providing required parameters or by providing a zone file, and you can
view the zone record. You can also remove a zone. You can view pending changes and publish them or discard them. And
you can view the publish notes. Additionally, you can freeze or thaw the zone.

### Get-DynDnsZone

The `Get-DynDnsZone` command will return all zones associated with the customer, or the specified zone.

### Add-DynDnsZone

The `Add-DynDnsZone` command creates a primary DNS zone in the customer's Dyn DNS Managed account.

### Remove-DynDnsZone

The `Remove-DynDnsZone` command immediately deletes the primary DNS zone from the customer's Dyn DNS Managed account.

### Get-DynDnsZoneNotes

The `Get-DynDnsZoneNotes` command generates a report containing the Zone Notes for the specified zone.

### Get-DynDnsZoneChanges

The `Get-DynDnsZoneChanges` command will retrieve all unpublished changes for the current session for the specified zone.

### Publish-DynDnsZoneChanges

The `Publish-DynDnsZoneChanges` command publishes pending zone changes.

### Undo-DynDnsZoneChanges

The `Undo-DynDnsZoneChanges` deletes changes to the specified zone that have been created during the current session,
but not yet published to the zone.

### Lock-DynDnsZone

The `Lock-DynDnsZone` command prevents other users from making changes to the zone.

### Unlock-DynDnsZone

The `Unlock-DynDnsZone` command removes the restriction that prevents other users from making changes to the zone.

## Record Commands

Use the follow commands to view, add, update, or remove DNS records of the following types: A, TXT, CNAME, MX, SRV,
or PTR. There is a command to create a new record object that can be used to add or update a record.

### Get-DynDnsRecord

The `Get-DynDnsRecord` command retrieves one or all records of the specified type from a specified zone/node.

### New-DynDnsRecord

The `New-DynDnsRecord` command creates DNS record object of the specified type.

### Add-DynDnsRecord

The `Add-DynDnsRecord` command creates a new DNS record of the specified type at the indicated zone/node level.

### Update-DynDnsRecord

The `Update-DynDnsRecord` command updates an existing DNS record in the specified zone.

### Remove-DynDnsRecord

The `Remove-DynDnsRecord` command deletes one or all records of the specified type from a specified zone/node.

## HttpRedirect Commands

Use the following commands to view, create, or delete an HTTP redirect service.

### Get-DynDnsHttpRedirect

The `Get-DynDnsHttpRedirect` command retrieves one or all HTTP Redirect services on the zone/node indicated.

### Add-DynDnsHttpRedirect

The `Add-DynDnsHttpRedirect` command creates a new HTTP Redirect service on the zone/node indicated.

### Remove-DynDnsHttpRedirect

The `Remove-DynDnsHttpRedirect` command deletes one or more existing HTTP Redirect services from the zone/node indicated.

## Node Commands

Use the following commands to list nodes and remove a node.

### Get-DynDnsNodeList

The `Get-DynDnsNodeList` command retrieves a list of all node names at or below the given zone node.

### Remove-DynDnsNode

The `Remove-DynDnsNode` command removes the indicated node, any records within the node, and any nodes underneath the node.

## Miscellaneous Commands

These commands will allow you to view users, jobs, or tasks.

### Get-DynDnsUser

The `Get-DynDnsUser` command retrieves information on a specified user or for all users.

### Get-DynDnsTask

The `Get-DynDnsTask` command retrieves a list of all current DNS API tasks or a single pending API task based on the task ID.

### Get-DynDnsJob

The `Get-DynDnsJob` command retrieves the result from a previous job.

## More Information

Please check out the following links for more information on the Dyn Managed DNS REST API.

* [Managed DNS Master Topics List](https://help.dyn.com/managed-dns-master-topics-list/)
* [Dyn Community Traffic Management Forum](https://www.dyncommunity.com/spaces/41/traffic-management.html)
* [DNS API Quick-Start Guide](https://help.dyn.com/dns-api-guide/)
* [Understanding How The API Works](https://help.dyn.com/understanding-works-api/)
* [REST Resources](https://help.dyn.com/rest-resources/)
* [RESTful API Interface](https://help.dyn.com/rest/)
