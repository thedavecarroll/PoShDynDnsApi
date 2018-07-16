function Send-DynDnsSession {
    [CmdLetBinding()]
    param()

    if (-Not (Test-DynDnsSession)) {
        return
    }

    $InvokeRestParams = Get-DynDnsRestParams
    $InvokeRestParams.Add('Uri',"$DynDnsApiClient/REST/Session/")
    $InvokeRestParams.Add('Method','Put')

    try {
        $Session =  Invoke-RestMethod @InvokeRestParams
        Write-DynDnsOutput -RestResponse $Session
    }
    catch {
        Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
        return
    }

}