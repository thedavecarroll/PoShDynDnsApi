function Get-DynDnsRecord {
    [CmdLetBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Zone,
        [ValidateSet('SOA','NS','MX','TXT','SRV','CNAME','PTR','A','All')]
        [string]$RecordType,
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
    } else {
        $Fqdn = $Zone
    }

    # record type is case sensitive
    if ($RecordType -ne 'All') {
        $RecordType = $RecordType.ToUpper()
    } elseif ($RecordType -eq 'All') {
        $RecordType = 'All'
    }

    $Uri = "$DynDnsApiClient/REST/$($RecordType)Record/$Zone/$Fqdn/"
    Write-Verbose -Message "$DynDnsApiVersion : INFO  : $Uri"

    try {
        $Records = Invoke-RestMethod -Uri $Uri @InvokeRestParams
        Write-DynDnsOutput -RestResponse $Records
    }
    catch {
        Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
        return
    }

    foreach ($Record in $Records.data) {
        $Uri = "$DynDnsApiClient$Record"
        Write-Verbose -Message "$DynDnsApiVersion : INFO  : $Uri"
        try {
            $RecordData = Invoke-RestMethod -Uri $Uri @InvokeRestParams
            Write-DynDnsOutput -RestResponse $RecordData
        }
        catch {
            Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
        }
    }
}