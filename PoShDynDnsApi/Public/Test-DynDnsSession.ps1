function Test-DynDnsSession {
    [CmdLetBinding()]
    param()

    $Session = Invoke-DynDnsRequest -SessionAction 'Test' -WarningAction SilentlyContinue
    Write-DynDnsOutput -DynDnsResponse $Session
    if ($Session.Data.status -eq 'success') {
        $true
    } else {
        $false
    }
}