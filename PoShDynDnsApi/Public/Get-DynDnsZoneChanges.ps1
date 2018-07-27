function Get-DynDnsZoneChanges {
    [CmdLetBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Zone
    )

    $ZoneChanges = Invoke-DynDnsRequest -UriPath "/REST/ZoneChanges/$Zone"
    Write-DynDnsOutput -DynDnsResponse $ZoneChanges
}