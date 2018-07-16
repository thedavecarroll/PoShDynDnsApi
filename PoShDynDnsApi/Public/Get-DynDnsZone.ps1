function Get-DynDnsZone {
    [CmdLetBinding()]
    param(
        [string]$Zone
    )

    if (-Not (Test-DynDnsSession)) {
        return
    }

    $InvokeRestParams = Get-DynDnsRestParams
    $InvokeRestParams.Add('Method','Get')

    if ($Zone) {
        $Uri = "$DynDnsApiClient/REST/Zone/$Zone"
    } else {
        $Uri = "$DynDnsApiClient/REST/Zone/"
    }

    try {
        $Zones = Invoke-RestMethod -Uri $Uri @InvokeRestParams
    }
    catch {
        Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
        return
    }

    if ($Zone) {
        Write-DynDnsOutput -RestResponse $Zones
    } else {
        Write-DynDnsOutput -RestResponse $Zones
        foreach ($ZoneRecord in $Zones.data) {
            try {
                $ZoneData = Invoke-RestMethod -Uri "$DynDnsApiClient$ZoneRecord" @InvokeRestParams
                Write-DynDnsOutput -RestResponse $ZoneData
            }
            catch {
                Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
            }
        }
    }
}