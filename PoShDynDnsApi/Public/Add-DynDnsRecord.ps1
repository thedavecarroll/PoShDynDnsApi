function Add-DynDnsRecord {
    [CmdLetBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter()]
        [string]$Zone = (Read-Host -Prompt 'Please provide a zone in which to create the new dns record'),
        [string]$Node,
        [Parameter(Mandatory=$true)]
        [hashtable]$DynDnsRecord
    )

    if ($DynDnsRecord.record_type -eq 'SOA') {
        Write-Warning -Message 'You cannot add a new SOA record with this command. Please use Update-DynDnsRecord.'
        return
    }

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

    $JsonBody = $DynDnsRecord | ConvertTo-Json

    $InvokeRestParams = Get-DynDnsRestParams
    $InvokeRestParams.Add('Method','Post')

    $Uri = "$DynDnsApiClient/REST/$($DynDnsRecord.record_type)Record/$Zone/$Fqdn/"

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