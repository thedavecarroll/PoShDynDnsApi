function Connect-DynDnsSession {
    [CmdLetBinding()]
    param(
        [Parameter(Mandatory = $true, HelpMessage = 'The Dyn API user (not DynID')]
        [Alias('ApiUserName','UserName')]
        [string]$User,
        [Parameter(Mandatory = $true, HelpMessage = "The customer name for the Dyn API user")]
        [Alias('CustomerName')]
        [string]$Customer,
        [Parameter(Mandatory = $true, HelpMessage = 'The Dyn API user password')]
        [Alias('pwd','pass')]
        [SecureString]$Password,
        [switch]$Force
    )

    if (Test-DynDnsSession) {
        if ($Force) {
            $Disconnect = Disconnect-DynDnsSession
            Write-DynDnsOutput -DynDnsResponse $Session
            if ($Disconnect.Data.status -eq 'failure') {
                return
            }
        } else {
            Write-Warning -Message "There is a valid active session. Use the -Force parameter to logoff and create a new session."
            return
        }
    }

    $JsonBody = @{
        customer_name = "$Customer"
        user_name = "$User"
        password = ([pscredential]::new('user',$Password).GetNetworkCredential().Password)
    }  | ConvertTo-Json

    $Session = Invoke-DynDnsRequest -SessionAction 'Connect' -Body $JsonBody
    if ($Session.Data.status -eq 'success') {
        Set-Variable -Name DynDnsAuthToken -Value $Session.Data.data.token -Scope global
        Set-Variable -Name DynDnsApiVersion -Value $Session.Data.data.version -Scope global
        Write-DynDnsOutput -DynDnsResponse $Session
    } else {
        Write-DynDnsOutput -DynDnsResponse $Session
    }
}