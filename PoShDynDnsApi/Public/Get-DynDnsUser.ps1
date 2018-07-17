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

    Write-Verbose -Message "$DynDnsApiVersion : INFO  : $Uri"

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
            $Uri = "$DynDnsApiClient$UserRecord"
            Write-Verbose -Message "$DynDnsApiVersion : INFO  : $Uri"
            try {
                $UserData = Invoke-RestMethod -Uri $Uri @InvokeRestParams
                Write-DynDnsOutput -RestResponse $UserData
            }
            catch {
                Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
            }
        }
    }
}