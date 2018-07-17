function Remove-DynDnsRecord {
    [CmdLetBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact='High'
    )]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [DynDnsRecord[]]$DynDnsRecord
    )

    begin {

        if (-Not (Test-DynDnsSession)) {
            return
        }

        $InvokeRestParams = Get-DynDnsRestParams
        $InvokeRestParams.Add('Method','Delete')
    }

    process {

        foreach ($Record in $DynDnsRecord) {

            $Fqdn = $Record.RawData.fqdn
            $Zone = $Record.RawData.zone
            $RecordType = $Record.RawData.record_type
            $RecordId = $Record.RecordId

            $Uri = "$DynDnsApiClient/REST/$($RecordType)Record/$Zone/$Fqdn/$RecordId"

            Write-Output $Record

            if ($PSCmdlet.ShouldProcess("$Uri",'Delete DNS record')) {
                try {
                    $RemoveRecord = Invoke-RestMethod -Uri $Uri @InvokeRestParams
                    Write-DynDnsOutput -RestResponse $RemoveRecord
                }
                catch {
                    Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
                    continue
                }
            } else {
                Write-Verbose 'Whatif : Deleted dns record'
            }
            Write-Output ''
        }
    }

    end {

    }

}