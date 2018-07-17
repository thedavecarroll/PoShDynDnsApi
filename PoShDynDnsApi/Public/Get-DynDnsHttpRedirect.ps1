function Get-DynDnsHttpRedirect {
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
        $Uri = "$DynDnsApiClient/REST/HTTPRedirect/$Zone/$Fqdn"
    } else {
        $Uri = "$DynDnsApiClient/REST/HTTPRedirect/$Zone"
    }

    Write-Verbose -Message "$DynDnsApiVersion : INFO  : $Uri"

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
            $Uri = "$DynDnsApiClient$Redirects"
            Write-Verbose -Message "$DynDnsApiVersion : INFO  : $Uri"
            try {
                $RedirectData = Invoke-RestMethod -Uri $Uri @InvokeRestParams
                Write-DynDnsOutput -RestResponse $RedirectData
            }
            catch {
                Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
            }
        }
    }
}