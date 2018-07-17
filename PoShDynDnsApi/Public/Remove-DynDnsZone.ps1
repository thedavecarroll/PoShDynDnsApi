
function Remove-DynDnsZone {
    [CmdLetBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact='High'
    )]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Zone
    )

    if (-Not (Test-DynDnsSession)) {
        return
    }

    $InvokeRestParams = Get-DynDnsRestParams
    $InvokeRestParams.Add('Method','Delete')

    $Uri = "https://api.dynect.net/REST/Zone/$Zone"

    if ($PSCmdlet.ShouldProcess("$Uri",'Delete DNS zone')) {
        try {
            $DeleteZone = Invoke-RestMethod -Uri $Uri  @InvokeRestParams
            Write-DynDnsOutput -RestResponse $DeleteZone
        }
        catch {
            Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
            return
        }
    }
    Write-Output ''
}