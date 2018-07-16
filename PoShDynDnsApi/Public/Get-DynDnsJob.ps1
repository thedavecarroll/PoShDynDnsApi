function Get-DynDnsJob {
    [CmdLetBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$JobId
    )

    if (-Not (Test-DynDnsSession)) {
        return
    }

    $InvokeRestParams = Get-DynDnsRestParams
    $InvokeRestParams.Add('Method','Get')

    $Uri = "$DynDnsApiClient/REST/Job/$JobId"
    try {
        $JobData = Invoke-RestMethod -Uri $Uri @InvokeRestParams
        Write-DynDnsOutput -RestResponse $JobData
    }
    catch {
        Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
        return
    }
}