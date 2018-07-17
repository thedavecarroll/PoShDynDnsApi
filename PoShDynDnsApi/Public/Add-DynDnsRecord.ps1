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

    if (-Not (Test-DynDnsSession)) {
        return
    }

    $InvokeRestParams = Get-DynDnsRestParams
    $InvokeRestParams.Add('Method','Post')

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

    if ($PSCmdlet.ShouldProcess("$Uri","Adding DNS record")) {
        try {
            $AddRecord = Invoke-RestMethod -Uri $Uri -Body $JsonBody @InvokeRestParams
            Write-DynDnsOutput -RestResponse $AddRecord
        }
        catch {
            Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
            continue
        }
    } else {
        Write-Verbose 'Whatif : Add dns record'
    }
}