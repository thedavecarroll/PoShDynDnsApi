function Disconnect-DynDnsSession {
    [CmdLetBinding()]
    param()

    $Session = Invoke-DynDnsRequest -SessionAction 'Disconnect'
    if ($Session.Data.status -eq 'success') {
        Write-DynDnsOutput -DynDnsResponse $Session
    } else {
        Write-DynDnsOutput -DynDnsResponse $Session -WarningAction Continue
    }
    Remove-Variable -Name DynDnsAuthToken -Scope global -ErrorAction SilentlyContinue
    Remove-Variable -Name DynDnsApiVersion -Scope global -ErrorAction SilentlyContinue
}