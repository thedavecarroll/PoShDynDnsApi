function Get-DynDnsRecord {
    [CmdLetBinding()]
    param(
        [Parameter()]
        [string]$Zone = (Read-Host -Prompt 'Please provide a zone to check for unpublished changes'),
        [ValidateSet('SOA','NS','MX','TXT','SRV','CNAME','PTR','A','All')]
        [string]$RecordType,
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
    } else {
        $Fqdn = $Zone
    }

    if ($RecordType -ne 'All') {
        $RecordType = $RecordType.ToUpper()
    } elseif ($RecordType -eq 'All') {
        $RecordType = 'All'
    }

    $InvokeRestParams = Get-DynDnsRestParams
    $InvokeRestParams.Add('Method','Get')

    try {
        $Records = Invoke-RestMethod -Uri "$DynDnsApiClient/REST/$($RecordType)Record/$Zone/$Fqdn/" @InvokeRestParams
        Write-DynDnsOutput -RestResponse $Records
    }
    catch {
        Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
        return
    }

    foreach ($Record in $Records.data) {
        try {
            $RecordData = Invoke-RestMethod -Uri "$DynDnsApiClient$Record" @InvokeRestParams
            Write-DynDnsOutput -RestResponse $RecordData
        }
        catch {
            Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
        }
    }
}