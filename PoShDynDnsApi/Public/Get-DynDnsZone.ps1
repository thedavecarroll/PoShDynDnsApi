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

    Write-Verbose -Message "$DynDnsApiVersion : INFO  : $Uri"

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
            $Uri = "$DynDnsApiClient$ZoneRecord"
            Write-Verbose -Message "$DynDnsApiVersion : INFO  : $Uri"
            try {
                $ZoneData = Invoke-RestMethod -Uri $Uri @InvokeRestParams
                Write-DynDnsOutput -RestResponse $ZoneData
            }
            catch {
                Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
            }
        }
    }
}