function Unlock-DynDnsZone {
    [CmdLetBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact='High'
    )]
    param(
        [Parameter()]
        [string]$Zone = (Read-Host -Prompt 'Please provide a zone to publish changes')
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
    if ($PSCmdlet.ShouldProcess($Zone,"thaw zone")) {
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