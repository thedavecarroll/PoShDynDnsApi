function Get-DynDnsNodeList {
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
        $Uri = "/REST/NodeList/$Zone/$Fqdn/"
    } else {
        $Uri = "/REST/NodeList/$Zone/"
    }

    $NodeList = Invoke-DynDnsRequest -UriPath $Uri
    Write-DynDnsOutput -DynDnsResponse $NodeList
}