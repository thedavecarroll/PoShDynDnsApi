function Get-DynDnsZoneChanges {
    [CmdLetBinding()]
    param(
        [Parameter()]
        [string]$Zone = (Read-Host -Prompt 'Please provide a zone to check for unpublished changes')
    )

    if (-Not (Test-DynDnsSession)) {
        return
    }

    $InvokeRestParams = Get-DynDnsRestParams
    $InvokeRestParams.Add('Method','Get')

    try {
        $ZoneChanges = Invoke-RestMethod -Uri "$DynDnsApiClient/REST/ZoneChanges/$Zone" @InvokeRestParams
        Write-DynDnsOutput -RestResponse $ZoneChanges
    }
    catch {
        Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
        return
    }

}