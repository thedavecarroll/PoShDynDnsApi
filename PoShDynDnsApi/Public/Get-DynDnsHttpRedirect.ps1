function Get-DynDnsHttpRedirect {
    [CmdLetBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Zone,
        [string]$Node
    )

    if ($Node) {
        if ($Node -match $Zone ) {
            $Fqdn = $Node
        } else {
            $Fqdn = $Node + '.' + $Zone
        }
        $Uri = "/REST/HTTPRedirect/$Zone/$Fqdn"
    } else {
        $Uri = "/REST/HTTPRedirect/$Zone"
    }

    $HttpRedirects = Invoke-DynDnsRequest -UriPath $Uri
    if ($HttpRedirects.Data.status -eq 'failure') {
        Write-DynDnsOutput -DynDnsResponse $HttpRedirects
        return
    }

    if ($Node) {
        Write-DynDnsOutput -DynDnsResponse $HttpRedirects
    } else {
        Write-DynDnsOutput -DynDnsResponse $HttpRedirects
        foreach ($UriPath in $HttpRedirects.Data.data) {
            $RedirectData = Invoke-DynDnsRequest -UriPath $UriPath -SkipSessionCheck
            Write-DynDnsOutput -DynDnsResponse $RedirectData
        }
    }
}