function Add-DynDnsRecord {
    [CmdLetBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact='High'
    )]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Zone,
        [string]$Node,
        [Parameter(Mandatory=$true)]
        [DynDnsRecord]$DynDnsRecord
    )

    if ($DynDnsRecord.record_type -eq 'SOA') {
        Write-Warning -Message 'You cannot add a new SOA record with this command. Please use Update-DynDnsRecord.'
        return
    }

    if ($Node) {
        if ($Node -match $Zone ) {
            $Fqdn = $Node
        } else {
            $Fqdn = $Node + '.' + $Zone
        }
    } else {
        $Fqdn = $Zone
    }

    $Uri = "$DynDnsApiClient/REST/$($DynDnsRecord.Type)Record/$Zone/$Fqdn/"

    $JsonBody = $DynDnsRecord.RawData | ConvertTo-Json

    if ($PSCmdlet.ShouldProcess("$($DynDnsRecord.Type) - $Fqdn","Adding DNS record")) {
        $NewHttpRedirect = Invoke-DynDnsRequest -UriPath $Uri -Method Post -Body $JsonBody
        Write-DynDnsOutput -DynDnsResponse $NewHttpRedirect
    } else {
        Write-Verbose 'Whatif : Added DNS record'
    }
}