function Unlock-DynDnsZone {
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
    $InvokeRestParams.Add('Method','Put')

    $JsonBody = @{
        thaw = $true
    } | ConvertTo-Json

    $Uri = "$DynDnsApiClient/REST/Zone/$Zone"

    if ($PSCmdlet.ShouldProcess($Uri,"thaw zone")) {
        try {
            $UnlockZone = Invoke-RestMethod -Uri $Uri -Body $JsonBody @InvokeRestParams
            Write-DynDnsOutput -RestResponse $UnlockZone
        }
        catch {
            Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
            continue
        }
    } else {
        Write-Verbose 'Whatif : Zone thawed'
    }
}