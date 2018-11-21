function Get-DynDnsZoneChanges {
    [CmdLetBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseSingularNouns', Justification='Retrieves all zone changes')]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Zone
    )

    $ZoneChanges = Invoke-DynDnsRequest -UriPath "/REST/ZoneChanges/$Zone"
    Write-DynDnsOutput -DynDnsResponse $ZoneChanges
}