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
        [SecureString]$Password = (Read-Host -AsSecureString -Prompt 'Enter your Dyn API user password'),
        [switch]$Force
    )

    if (Test-DynDnsSession -WarningAction SilentlyContinue) {
        if ($Force) {
            try {
                Disconnect-DynDnsSession
            }
            catch {
                Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
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

    $InvokeRestParams = Get-DynDnsRestParams -NoAuthToken
    $InvokeRestParams.Add('Uri',"$DynDnsApiClient/REST/Session/")
    $InvokeRestParams.Add('Method','Post')
    $InvokeRestParams.Add('Body',$JsonBody)

    try {
        $Session = Invoke-RestMethod @InvokeRestParams
        Write-DynDnsOutput -RestResponse $Session
        Set-Variable -Name DynDnsAuthToken -Value $Session.data.token -Scope global
        Set-Variable -Name DynDnsApiVersion -Value "API-$($Session.data.version)" -Scope global
        Write-DynDnsOutput -RestResponse $Session
    }
    catch {
        Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
        return
    }
}