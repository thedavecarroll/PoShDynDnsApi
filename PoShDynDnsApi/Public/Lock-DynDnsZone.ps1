function Lock-DynDnsZone {
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

    $Uri = "$DynDnsApiClient/REST/Zone/$Zone"

    $JsonBody = @{
        freeze = $true
    } | ConvertTo-Json

    if ($PSCmdlet.ShouldProcess($Uri,"freeze zone")) {
        try {
            $LockZone = Invoke-RestMethod -Uri $Uri -Body $JsonBody @InvokeRestParams
            Write-DynDnsOutput -RestResponse $LockZone
        }
        catch {
            Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
            continue
        }
    } else {
        Write-Verbose 'Whatif : Zone frozen'
    }
}