
function Remove-DynDnsZone {
    [CmdLetBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact='High'
    )]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Zone
    )

    if ($PSCmdlet.ShouldProcess("$Zone",'Delete DNS zone')) {
        $DeleteZone = Invoke-DynDnsRequest -UriPath "https://api.dynect.net/REST/Zone/$Zone" -Method Delete
        Write-DynDnsOutput -DynDnsResponse $DeleteZone
    } else {
        Write-Verbose 'Whatif : Deleted DNZ zone'
    }
    Write-Output ''
}