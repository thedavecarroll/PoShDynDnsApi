function Send-DynDnsSession {
    [CmdLetBinding()]
    param()

    $Session = Invoke-DynDnsRequest -SessionAction 'Send'
    Write-DynDnsOutput -DynDnsResponse $Session
}