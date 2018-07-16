function Write-DynDnsOutput {
    [CmdLetBinding()]
    param($RestResponse)

    if ($RestResponse -is [string] ) {
        try {
            $RestResponse = $RestResponse | ConvertFrom-Json -ErrorAction Stop
        }
        catch {
            $CleanResponse = $RestResponse.Split("`n").Trim() | Where-Object { $_ -match '\S' } | Select-Object -Skip 1
            $Response = $CleanResponse[0..($CleanResponse.IndexOf('msgs:') -1)]
            $Messages = $CleanResponse[($CleanResponse.IndexOf('msgs:') +1)..($CleanResponse.Length)]
            if ($Response[3] -ne 'None') { $data = $Response[3] } else { $data = $null }
            if ($Response[5] -ne 'None') { $job_id = $Response[5] } else { $job_id = $null }
            $FormattedResponse = [ordered]@{
                status = $Response[1]
                data = $data
                job_id = $job_id
                msgs = @{
                    INFO = $Messages[1]
                    SOURCE = $Messages[3]
                    ERR_CD = $Messages[5]
                    LVL = $Messages[7]
                }
            }
            $RestResponse = New-Object PsCustomObject -Property $FormattedResponse
        }
    }

    if ($RestResponse.status -or $RestResponse.job_id) {
        Write-Information -MessageData ('-'*40)
        if ($RestResponse.status) {
            Write-Information -MessageData ('Status : ' + $RestResponse.status)
        }
        if ($RestResponse.job_id) {
            Write-Information -MessageData ('JobId  : ' + $RestResponse.job_id)
        }
        Write-Information -MessageData ('-'*40)
    }

    if ($DynDnsApiVersion) {
        $ApiVersion = $DynDnsApiVersion + ' : '
    } else {
        $ApiVersion = $null
    }
    foreach ($Message in $RestResponse.msgs) {
        if ($Message.LVL -eq 'ERROR') {
            Write-Warning -Message ($ApiVersion + $Message.LVL + ' : ' + $Message.ERR_CD)
            Write-Warning -Message ($ApiVersion + $Message.LVL + ' : ' + $Message.INFO)
        } else {
            Write-Verbose -Message ($ApiVersion + $Message.LVL + ' : ' + $Message.INFO)
        }
    }

    foreach ($DataResponse in $RestResponse.data) {
        if ($DataResponse.record_type) {
            switch ($DataResponse.record_type) {
                'A'     { [DynDnsRecord_A]::New($DataResponse) }
                'TXT'   { [DynDnsRecord_TXT]::New($DataResponse) }
                'CNAME' { [DynDnsRecord_CNAME]::New($DataResponse) }
                'MX'    { [DynDnsRecord_MX]::New($DataResponse) }
                'SRV'   { [DynDnsRecord_SRV]::New($DataResponse) }
                'NS'    { [DynDnsRecord_NS]::New($DataResponse) }
                'PTR'   { [DynDnsRecord_PTR]::New($DataResponse) }
                'SOA'   { [DynDnsRecord_SOA]::New($DataResponse) }
                default {
                    $DataResponse
                }
            }
        } elseif ($DataResponse.task_id -and $DataResponse.step_count) {
            [DynDnsTask]::New($DataResponse)
        } elseif ($DataResponse.note)  {
            [DynDnsZoneNote]::New($DataResponse)
        } elseif ($DataResponse.zone_type)  {
            [DynDnsZone]::New($DataResponse)
        } elseif ($DataResponse.url -and $DataResponse.keep_uri) {
            [DynDnsHttpRedirect]::New($DataResponse)
        } elseif ($DataResponse.user_name -and $DataResponse.group_name) {
            [DynDnsUser]::New($DataResponse)
        } elseif ($DataResponse.rdata_type) {
            $DataResponse
        }
   }
}