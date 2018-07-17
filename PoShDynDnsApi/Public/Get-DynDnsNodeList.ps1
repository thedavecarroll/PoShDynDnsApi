function Get-DynDnsNodeList {
    [CmdLetBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Zone,
        [string]$Node
    )

    if (-Not (Test-DynDnsSession)) {
        return
    }

    $InvokeRestParams = Get-DynDnsRestParams
    $InvokeRestParams.Add('Method','Get')

    if ($Node) {
        if ($Node -match $Zone ) {
            $Fqdn = $Node
        } else {
            $Fqdn = $Node + '.' + $Zone
        }
        $Uri = "$DynDnsApiClient/REST/NodeList/$Zone/$Fqdn/"
    } else {
        $Uri = "$DynDnsApiClient/REST/NodeList/$Zone/"
    }

    try {
        $NodeList = Invoke-RestMethod -Uri $Uri @InvokeRestParams
        Write-DynDnsOutput -RestResponse $NodeList
    }
    catch {
        Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
        return
    }

}