function Get-DynDnsRecord {
    [CmdLetBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Zone,
        [ValidateSet('SOA','NS','MX','TXT','SRV','CNAME','PTR','A','All',IgnoreCase=$false)]
        [string]$RecordType = 'All',
        [string]$Node
    )

    if ($Node) {
        if ($Node -match $Zone ) {
            $Fqdn = $Node
        } else {
            $Fqdn = $Node + '.' + $Zone
        }
    } else {
        $Fqdn = $Zone
    }

    $Records = Invoke-DynDnsRequest -UriPath "/REST/$($RecordType)Record/$Zone/$Fqdn/"
    Write-DynDnsOutput -DynDnsResponse $Records -SkipSuccess
    if ($Records.Data.status -eq 'failure') {
        return
    }

    foreach ($UriPath in $Records.Data.data) {
        $RecordData = Invoke-DynDnsRequest -UriPath $UriPath -SkipSessionCheck
        Write-DynDnsOutput -DynDnsResponse $RecordData
    }
}