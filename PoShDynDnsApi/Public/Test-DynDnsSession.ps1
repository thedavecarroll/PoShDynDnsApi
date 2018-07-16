function Test-DynDnsSession {
    [CmdLetBinding()]
    param()

    $InvokeRestParams = Get-DynDnsRestParams
    $InvokeRestParams.Add('Uri',"$DynDnsApiClient/REST/Session/")
    $InvokeRestParams.Add('Method','Get')

    try {
        $Session = Invoke-RestMethod  @InvokeRestParams
        Write-DynDnsOutput -RestResponse $Session
        return $true
    }
    catch {
        Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
        if ($DynDnsApiVersion) {
            Write-Warning -Message ($DynDnsApiVersion + ' : ERROR : No active DynDns session found')
        } else {
            Write-Warning -Message 'ERROR : No active DynDns session found'
        }
        return $false
    }

}