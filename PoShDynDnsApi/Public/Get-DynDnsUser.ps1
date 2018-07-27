function Get-DynDnsUser {
    [CmdLetBinding()]
    param(
        [Alias('ApiUserName','UserName')]
        [string]$User
    )

    if ($User) {
        $UriPath = "/REST/User/$User"
    } else {
        $UriPath = "/REST/User/"
    }

    $Users = Invoke-DynDnsRequest -UriPath $UriPath
    if ($Users.Data.status -eq 'failure') {
        Write-DynDnsOutput -DynDnsResponse $Users
        return
    }

    if ($User) {
        Write-DynDnsOutput -DynDnsResponse $Users
    } else {
        Write-DynDnsOutput -DynDnsResponse $Users
        foreach ($UriPath in $Users.Data.data) {
            $UserData = Invoke-DynDnsRequest -UriPath $UriPath -SkipSessionCheck
            Write-DynDnsOutput -DynDnsResponse $UserData
        }
    }
}