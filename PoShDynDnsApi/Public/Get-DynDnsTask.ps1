function Get-DynDnsTask {
    [CmdLetBinding()]
    param(
        [int]$TaskId
    )

    if (-Not (Test-DynDnsSession)) {
        Write-Warning -Message "No active session to Dyn."
        return
    }

    $InvokeRestParams = Get-DynDnsRestParams
    $InvokeRestParams.Add('Method','Get')

    if ($TaskId) {
        $Uri = "$DynDnsApiClient/REST/Task/$($TaskId.ToString())"
    } else {
        $Uri = "$DynDnsApiClient/REST/Task/"
    }

    try {
        $TaskData = Invoke-RestMethod -Uri $Uri @InvokeRestParams
        Write-DynDnsOutput -RestResponse $TaskData
    }
    catch {
        Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
        return
    }
}