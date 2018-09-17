function Write-DynDnsOutput {
    [CmdLetBinding()]
    param(
        [PsObject]$DynDnsResponse
    )

    if ($DynDnsApiVersion) {
        $ApiVersion = 'API-' + $DynDnsApiVersion
    } else {
        $ApiVersion = $null
    }

    $Status = $JobId = $null
    if ($DynDnsResponse | Get-Member -Name 'Data') {
        if ($DynDnsResponse.Data | Get-Member -Name status) {
            if ($null -ne $DynDnsResponse.Data.status) {
                $Status = $DynDnsResponse.Data.status
            }
        }
        if ($DynDnsResponse.Data | Get-Member -Name job_id) {
            if ($null -ne $DynDnsResponse.Data.job_id) {
                $JobId = $DynDnsResponse.Data.job_id
            }
        }
    }

    $MyFunction = Get-PSCallStack | Where-Object {$_.Command -notmatch 'DynDnsRequest|DynDnsOutput|ScriptBlock'}
    if ($Uri -match 'Session') {
        $Command = $MyFunction.Command | Where-Object {$_ -match 'DynDnsSession'}
    } else {
        $MyFunction = $MyFunction | Select-Object -First 1
        $Command = $MyFunction.Command
        if ($MyFunction.Arguments) {
            $Arugments = $MyFunction.Arguments.Split(',') | ForEach-Object {
                if ($_ -match '\w+=\S+\w+') { $matches[0] } } | Where-Object {
                    $_ -notmatch 'Debug|Verbose|InformationAction|WarningAction|ErrorAction|Variable'
                }
            $Arugments = $Arugments | ForEach-Object { $_.Replace('\','\\') | ConvertFrom-StringData }
        }
    }

    $InformationOutput = [PsCustomObject][ordered]@{
        Command = $Command
        Status = $Status
        JobId = $JobId
        Method = $DynDnsResponse.Response.Method
        Uri = $DynDnsResponse.Response.Uri
        StatusCode = $DynDnsResponse.Response.StatusCode
        StatusDescription = $DynDnsResponse.Response.StatusDescription
        ElapsedTime = "{0:N3}" -f $DynDnsResponse.ElapsedTime
    }

    foreach ($Key in $Arugments.Keys) {
        Add-Member -InputObject $InformationOutput -MemberType NoteProperty -Name $Key -Value $Arugments.$Key -Force
    }

    Write-Information -MessageData $InformationOutput

    foreach ($Message in $DynDnsResponse.Data.msgs) {
        if ($Message.LVL -eq 'INFO') {
            Write-Verbose -Message ($ApiVersion,$Message.LVL,$Message.SOURCE,$Message.INFO -join ' : ')
        } else {
            if ($Message.ERR_CD -ne 'NOT_FOUND') {
                Write-Warning -Message ($ApiVersion,$Message.LVL,$Message.SOURCE,$Message.ERR_CD,$Message.INFO -join ' : ')
            } else {
                Write-Verbose -Message ($ApiVersion,$Message.LVL,$Message.SOURCE,$Message.ERR_CD,$Message.INFO -join ' : ')
            }
        }
    }

    foreach ($DataResponse in $DynDnsResponse.Data.data) {
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
                    [DynDnsRecord]::New($DataResponse)
                }
            }
        } elseif ($DataResponse.Data.task_id -and $DataResponse.Data.step_count) {
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

    if ($DynDnsResponse.Data.msgs.INFO -match 'get_node_list') {
        $DynDnsResponse.Data.data
    }

}