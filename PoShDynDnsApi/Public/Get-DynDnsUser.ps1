function Get-DynDnsUser {
    [CmdLetBinding()]
    param(
        [string]$UserName
    )

    if (-Not (Test-DynDnsSession)) {
        return
    }

    $InvokeRestParams = Get-DynDnsRestParams
    $InvokeRestParams.Add('Method','Get')

    if ($UserName) {
        $Uri = "$DynDnsApiClient/REST/User/$UserName"
    } else {
        $Uri = "$DynDnsApiClient/REST/User/"
    }

    try {
        $Users = Invoke-RestMethod -Uri $Uri @InvokeRestParams
    }
    catch {
        Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
        return
    }

    if ($UserName) {
        Write-DynDnsOutput -RestResponse $Users
    } else {
        Write-DynDnsOutput -RestResponse $Users
        foreach ($UserRecord in $Users.data) {
            try {
                $UserData = Invoke-RestMethod -Uri "$DynDnsApiClient$UserRecord" @InvokeRestParams
                Write-DynDnsOutput -RestResponse $UserData
            }
            catch {
                Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
            }
        }
    }
}