function Get-DynDnsTask {
    [CmdLetBinding()]
    param(
        [int]$TaskId
    )

    if ($TaskId) {
        $UriPath = "/REST/Task/$($TaskId.ToString())"
    } else {
        $UriPath = "/REST/Task/"
    }

    $TaskData = Invoke-DynDnsRequest -UriPath $UriPath
    Write-DynDnsOutput -DynDnsResponse $TaskData
}