function Disconnect-DynDnsSession {
    [CmdLetBinding()]
    param()

    if (-Not (Test-DynDnsSession)) {
        return
    }

    $InvokeRestParams = Get-DynDnsRestParams
    $InvokeRestParams.Add('Uri',"$DynDnsApiClient/REST/Session/")
    $InvokeRestParams.Add('Method','Delete')

    try {
        $Session =  Invoke-RestMethod @InvokeRestParams
        Write-DynDnsOutput -RestResponse $Session
        Remove-Variable -Name DynDnsAuthToken -Scope global -ErrorAction SilentlyContinue
        Remove-Variable -Name DynDnsApiVersion -Scope global -ErrorAction SilentlyContinue
    }
    catch {
        Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
    }
}