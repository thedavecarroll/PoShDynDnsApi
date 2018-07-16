function Get-DynDnsHttpRedirect {
    [CmdLetBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Zone = (Read-Host -Prompt 'Please provide a zone to check for unpublished changes'),
        [string]$Node
    )

    if (-Not (Test-DynDnsSession)) {
        return
    }

    if ($Node) {
        if ($Node -match $Zone ) {
            $Fqdn = $Node
        } else {
            $Fqdn = $Node + '.' + $Zone
        }
        $Uri = "$DynDnsApiClient/REST/HTTPRedirect/$Zone/$Fqdn"
    } else {
        $Uri = "$DynDnsApiClient/REST/HTTPRedirect/$Zone"
    }

    $InvokeRestParams = Get-DynDnsRestParams
    $InvokeRestParams.Add('Method','Get')

    try {
        $HttpRedirects = Invoke-RestMethod -Uri $Uri @InvokeRestParams
    }
    catch {
        Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
        return
    }

    if ($Node) {
        Write-DynDnsOutput -RestResponse $HttpRedirects
    } else {
        Write-DynDnsOutput -RestResponse $HttpRedirects
        foreach ($Redirects in $HttpRedirects.data) {
            try {
                $RedirectData = Invoke-RestMethod -Uri "$DynDnsApiClient$Redirects" @InvokeRestParams
                Write-DynDnsOutput -RestResponse $RedirectData
            }
            catch {
                Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
            }
        }
    }
}