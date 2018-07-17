function Update-DynDnsRecord {
    [CmdLetBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact='High'
    )]
    param(
        [Parameter(Mandatory=$true)]
        [DynDnsRecord]$DynDnsRecord,
        [Parameter(Mandatory=$true)]
        [DynDnsRecord]$UpdatedDynDnsRecord
    )

    if ($DynDnsRecord.GetType() -ne $UpdatedDynDnsRecord.GetType()) {
        Write-Warning -Message "The original record type does not match the updated record type."
        return
    } else {
        Write-Verbose -Message "The original record type matches the updated record type."
    }

    if (-Not (Test-DynDnsSession)) {
        return
    }

    $Fqdn = $DynDnsRecord.Name
    $Zone = $DynDnsRecord.Zone
    $RecordType = $DynDnsRecord.Type
    $RecordId = $DynDnsRecord.RecordId

    $JsonBody = $UpdatedDynDnsRecord.RawData  | ConvertTo-Json | ConvertFrom-Json | Select-Object * -ExcludeProperty record_type | ConvertTo-Json

    $InvokeRestParams = Get-DynDnsRestParams
    $InvokeRestParams.Add('Method','Put')

    $Uri = "$DynDnsApiClient/REST/$($RecordType)Record/$Zone/$Fqdn/$RecordId"
    Write-Verbose -Message "$DynDnsApiVersion : INFO  : $Uri"

    if ($PSCmdlet.ShouldProcess("$Fqdn",'Update DNS record')) {
        try {
            $UpdateRecord = Invoke-RestMethod -Uri $Uri -Body $JsonBody @InvokeRestParams
            Write-DynDnsOutput -RestResponse $UpdateRecord
        }
        catch {
            Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
        }
    } else {
        Write-Verbose 'Whatif : Updated dns record'
    }
}