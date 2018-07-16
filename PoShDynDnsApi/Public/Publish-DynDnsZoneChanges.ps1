function Publish-DynDnsZoneChanges {
    [CmdLetBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact='High'
    )]
    param(
        [Parameter()]
        [string]$Zone = (Read-Host -Prompt 'Please provide a zone to publish changes'),
        [string]$Notes
    )

    if (-Not (Test-DynDnsSession)) {
        return
    }

    $PendingZoneChanges = Get-DynDnsZoneChanges -Zone $Zone
    if ($PendingZoneChanges) {
        Write-Output $PendingZoneChanges
    }

    if ($Notes) {
        $BodyNotes = "REST-Api-PoSh: $Notes"
    } else {
        $BodyNotes = 'REST-Api-PoSh'
    }

    $JsonBody = @{
        publish = $true
        notes = $BodyNotes
    } | ConvertTo-Json

    $InvokeRestParams = Get-DynDnsRestParams
    $InvokeRestParams.Add('Method','Put')

    $Uri = "$DynDnsApiClient/REST/Zone/$Zone"

    if ($PSCmdlet.ShouldProcess($Zone,"publish zone changes")) {
        try {
            $PublishZoneChanges = Invoke-RestMethod -Uri $Uri -Body $JsonBody @InvokeRestParams
            Write-DynDnsOutput -RestResponse $PublishZoneChanges
        }
        catch {
            Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
            continue
        }
    } else {
        Write-Verbose 'Whatif : Published zone changes'
    }
}