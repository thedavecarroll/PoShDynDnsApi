function Invoke-DynDnsRequest {
    [CmdLetBinding()]
    param(
        [Parameter(ParameterSetName='Default')]
        [ValidateSet('Get','Post','Put','Delete')]
        [String]$Method='Get',

        [Parameter(ParameterSetName='Default')]
        [ValidateScript({$_ -match '^/REST/'})]
        [String]$UriPath,

        [Parameter(ParameterSetName='Default')]
        [Parameter(ParameterSetName='Session')]
        [Alias('JsonBody','Json')]
        [ValidateScript({$_ | ConvertFrom-Json})]
        [AllowNull()]
        $Body,

        [Parameter(ParameterSetName='Default')]
        [Switch]$SkipSessionCheck,

        [Parameter(ParameterSetName='Session')]
        [ValidateSet('Connect','Disconnect','Test','Send')]
        [string]$SessionAction
    )

    $RestParams = @{
        ContentType = 'application/json'
        ErrorAction = 'Stop'
        Verbose = $false
    }

    $DynDnsApiClient = 'https://api.dynect.net'
    if ($PsCmdlet.ParameterSetName -eq 'Session') {
        $RestParams.Add('Uri',"$DynDnsApiClient/REST/Session/")
        switch ($SessionAction) {
            'Connect'       {
                $RestParams.Add('Method','Post')
                if ($DynDnsAuthToken) {
                    Write-Warning -Message 'Existing authentication token found. Please use Disconnect-DynDnsSession if you want to start a new session. All unpublished changes will be discarded.'
                    return
                }
                if ($Body) {
                    $RestParams.Add('Body',$Body)
                } else {
                    Write-Warning -Message 'No login credentials provided.'
                    return
                }
            }
            'Disconnect'    {
                $RestParams.Add('Method','Delete')
                if ($DynDnsAuthToken) {
                    $RestParams.Add('Headers',@{'Auth-Token' = "$DynDnsAuthToken"})
                } else {
                    Write-Warning -Message 'No authentication token found. Please use Connect-DynDnsSession to obtain a new token.'
                    return
                }
            }
            'Send'          {
                $RestParams.Add('Method','Put')
                if ($DynDnsAuthToken) {
                    $RestParams.Add('Headers',@{'Auth-Token' = "$DynDnsAuthToken"})
                } else {
                    Write-Warning -Message 'No authentication token found. Please use Connect-DynDnsSession to obtain a new token.'
                    return
                }
            }
            'Test'          {
                if ($DynDnsAuthToken) {
                    $RestParams.Add('Method','Get')
                    $RestParams.Add('WarningAction','SilentlyContinue')
                    $RestParams.Add('Headers',@{'Auth-Token' = "$DynDnsAuthToken"})
                } else {
                    Write-Verbose -Message 'No authentication token found.'
                    return $false
                }
            }
        }
    } else {
        if ($DynDnsAuthToken) {
            $RestParams.Add('Headers',@{'Auth-Token' = "$DynDnsAuthToken"})
        } else {
            Write-Warning -Message 'No authentication token found. Please use Connect-DynDnsSession to obtain a new token.'
            return
        }
        if (-Not $SkipSessionCheck) {
            if (-Not (Test-DynDnsSession)) {
                return
            }
        }
        $RestParams.Add('Uri',"$DynDnsApiClient$UriPath")
        $RestParams.Add('Method',$Method)
        if ($Body -and $Method -match 'Post|Put') {
            $RestParams.Add('Body',$Body)
        }
    }

    $StopWatch = [System.Diagnostics.Stopwatch]::StartNew()
    $OriginalProgressPreference = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'
    try {
        $DynDnsResponse = Invoke-WebRequest @RestParams -ErrorVariable ErrorResponse
        $Content = $DynDnsResponse.Content
    }
    catch {
        $DynDnsResponse = $ErrorResponse.ErrorRecord.Exception.Response
        $ResponseReader = [System.IO.StreamReader]::new($DynDnsResponse.GetResponseStream())
        $Content = $ResponseReader.ReadToEnd()
        $ResponseReader.Close()
    }
    $ElapsedTime = $StopWatch.Elapsed.TotalSeconds
    $StopWatch.Stop()
    $ProgressPreference = $OriginalProgressPreference

    try {
        $Data = $Content | ConvertFrom-Json
    }
    catch {
        $Data = $null
    }

    if (-Not $DynDnsResponse.Method) {
        Add-Member -InputObject $DynDnsResponse -MemberType NoteProperty -Name Method -Value $RestParams.Method.ToUpper() -Force
    }
    if (-Not $DynDnsResponse.ResponseUri) {
        Add-Member -InputObject $DynDnsResponse -MemberType NoteProperty -Name ResponseUri -Value $RestParams.Uri -Force
    }

    [DynDnsRestResponse]::New(
        [PsCustomObject]@{
            Response = $DynDnsResponse | Select-Object Method,ResponseUri,StatusCode,StatusDescription
            Data = $Data
            ElapsedTime = $ElapsedTime
        }
    )
}