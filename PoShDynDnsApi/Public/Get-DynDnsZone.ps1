function Get-DynDnsZone {
    [CmdLetBinding()]
    param(
        [string]$Zone
    )

    if ($Zone) {
        $UriPath = "/REST/Zone/$Zone"
    } else {
        $UriPath = "/REST/Zone/"
    }

    $Zones = Invoke-DynDnsRequest -UriPath $UriPath
    if ($Zones.Data.status -eq 'failure') {
        Write-DynDnsOutput -DynDnsResponse $Zones
        return
    }

    if ($Zone) {
        Write-DynDnsOutput -DynDnsResponse $Zones
    } else {
        Write-DynDnsOutput -DynDnsResponse $Zones
        foreach ($UriPath in $Zones.Data.data) {
            $ZoneData = Invoke-DynDnsRequest -UriPath $UriPath -SkipSessionCheck
            Write-DynDnsOutput -DynDnsResponse $ZoneData
        }
    }
}