function Send-DynDnsSession {
    [CmdLetBinding()]
    param()

    $Session = Invoke-DynDnsRequest -SessionAction 'Send'
    Write-DynDnsOutput -DynDnsResponse $Session
    if ($Session.Data.status -eq 'success') {
        $DynDnsSession.RefreshTime = [System.DateTime]::Now
    }
}