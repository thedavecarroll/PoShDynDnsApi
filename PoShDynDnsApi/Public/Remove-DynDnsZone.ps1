
function Remove-DynDnsZone {
    [CmdLetBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact='High'
    )]
    param(
        [Parameter()]
        [string]$Zone = (Read-Host -Prompt 'Please provide the name of the new zone')
    )

    if (-Not (Test-DynDnsSession)) {
        return
    }

    $InvokeRestParams = Get-DynDnsRestParams
    $InvokeRestParams.Add('Method','Delete')

    $Uri = "https://api.dynect.net/REST/Zone/$Zone"

    if ($PSCmdlet.ShouldProcess("$Zone",'Delete DNS zone')) {
        try {
            $DeleteZone = Invoke-RestMethod -Uri $Uri  @InvokeRestParams
            Write-DynDnsOutput -RestResponse $DeleteZone
        }
        catch {
            Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
            return
        }
    } else {
        Write-Verbose 'Whatif : Deleted dns zone'
    }
}