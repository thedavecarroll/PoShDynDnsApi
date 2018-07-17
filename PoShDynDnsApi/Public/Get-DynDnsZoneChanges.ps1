function Get-DynDnsZoneChanges {
    [CmdLetBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Zone
    )

    if (-Not (Test-DynDnsSession)) {
        return
    }

    $InvokeRestParams = Get-DynDnsRestParams
    $InvokeRestParams.Add('Method','Get')

    $Uri = "$DynDnsApiClient/REST/ZoneChanges/$Zone"
    Write-Verbose -Message "$DynDnsApiVersion : INFO  : $Uri"

    try {
        $ZoneChanges = Invoke-RestMethod -Uri $Uri @InvokeRestParams
        Write-DynDnsOutput -RestResponse $ZoneChanges
    }
    catch {
        Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
        return
    }

}