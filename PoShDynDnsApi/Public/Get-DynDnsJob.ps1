function Get-DynDnsJob {
    [CmdLetBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$JobId
    )

    $JobData = Invoke-DynDnsRequest -UriPath "/REST/Job/$JobId"
    Write-DynDnsOutput -DynDnsResponse $JobData
}