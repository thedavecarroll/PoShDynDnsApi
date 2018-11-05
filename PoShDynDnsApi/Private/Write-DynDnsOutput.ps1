function Write-DynDnsOutput {
    [CmdLetBinding()]
    param(
        [PsObject]$DynDnsResponse,
        [switch]$SkipSuccess
    )

    if ($DynDnsSession.ApiVersion) {
        $ApiVersion = 'API-' + $DynDnsSession.ApiVersion
    } else {
        $ApiVersion = $null
    }

    $Status = $JobId = $null
    if ($DynDnsResponse | Get-Member -Name 'Data' -ErrorAction SilentlyContinue) {
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
            $Arguments = $MyFunction.Arguments.Split(',') | ForEach-Object {
                if ($_ -match '\w+=\S+\w+') { $matches[0] } } | Where-Object {
                    $_ -notmatch 'Debug|Verbose|InformationAction|WarningAction|ErrorAction|Variable'
                }
            $Arguments = $Arguments | ForEach-Object { $_.Replace('\','\\') | ConvertFrom-StringData }
        }
    }

    $FilteredArguments = @{}
    foreach ($Key in $Arguments.Keys) {
        if ($Key -notmatch 'User|Customer|Password') {
            $FilteredArguments.Add($Key,$Arguments.$Key)
        }
    }

    $InformationOutput = [DynDnsHistory]::New(@{
        Command = $Command
        Status = $Status
        JobId = $JobId
        Method = $DynDnsResponse.Response.Method
        Uri = $DynDnsResponse.Response.Uri
        StatusCode = $DynDnsResponse.Response.StatusCode
        StatusDescription = $DynDnsResponse.Response.StatusDescription
        ElapsedTime = "{0:N3}" -f $DynDnsResponse.ElapsedTime
        Arguments = $FilteredArguments
    })

    [void]$DynDnsHistory.Add($InformationOutput)
    Write-Information -MessageData $InformationOutput

    switch ($Command) {
        'Add-DynDnsZone' {
            foreach ($Info in $Message.INFO) {
                Write-Output ($Info -Split (':',2))[1].Trim()
            }
        }
        'Publish-DynDnsZoneChanges' {
            if ($DynDnsResponse.Data.msgs.INFO -match 'Missing SOA record' ) {
                Write-Output "The attempt to import $($DynDnsResponse.Response.Uri.Split('/')[-1]) has failed. Please delete the zone and reattempt the import after fixing errors."
            }
        }
    }

    foreach ($Message in $DynDnsResponse.Data.msgs) {
        $VerboseMessage = ($ApiVersion,$Message.LVL,$Message.SOURCE,$Message.INFO -join ' : ')
        $ErrorMessage = ($ApiVersion,$Message.LVL,$Message.SOURCE,$Message.ERR_CD,$Message.INFO -join ' : ')
        switch ($Message.LVL) {
            'INFO' {
                Write-Verbose -Message $VerboseMessage
            }
            'ERROR' {
                if ($Message.ERR_CD -eq 'NOT_FOUND' -and $Message.INFO -notmatch 'No such zone') {
                    Write-Verbose -Message $ErrorMessage
                } else {
                    Write-Warning -Message $ErrorMessage
                }
            }
            default {
                Write-Warning -Message $ErrorMessage
            }
        }
    }

    if ($SkipSuccess) {
        return
    }

    if ($Status -eq 'success') {
        foreach ($DataResponse in $DynDnsResponse.Data.data) {
            switch ($Command.Split('-')[1]) {
                'DynDnsRecord' {
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
                }
                'DynDnsZone' {
                    [DynDnsZone]::New($DataResponse)
                }
                'DynDnsTask' {
                    [DynDnsTask]::New($DataResponse)
                }
                'DynDnsZoneNotes' {
                    [DynDnsZoneNote]::New($DataResponse)
                }
                'DynDnsHttpRedirect' {
                    [DynDnsHttpRedirect]::New($DataResponse)
                }
                'DynDnsUser' {
                    [DynDnsUser]::New($DataResponse)
                }
                'DynDnsZoneChanges' {
                    [DynDnsZoneChanges]::New($DataResponse)
                }
                'DynDnsNodeList' {
                    $DataResponse
                }
            }
        }
    }
}