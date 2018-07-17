function Publish-DynDnsZoneChanges {
    [CmdLetBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact='High'
    )]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Zone,
        [string]$Notes,
        [switch]$Force
    )

    if (-Not (Test-DynDnsSession)) {
        return
    }

    $InvokeRestParams = Get-DynDnsRestParams
    $InvokeRestParams.Add('Method','Put')

    $PendingZoneChanges = Get-DynDnsZoneChanges -Zone $Zone
    if ($PendingZoneChanges) {
        Write-Output $PendingZoneChanges
    } else {
        Write-Warning -Message 'There are no pending zone changes.'
        if (-Not $Force) {
            return
        } else {
            Write-Verbose -Message '-Force switch used.'
        }
    }

    if ($Notes) {
        $BodyNotes = "REST-Api-PoSh: $Notes"
    } else {
        $BodyNotes = 'REST-Api-PoSh'
    }

    $Uri = "$DynDnsApiClient/REST/Zone/$Zone"

    $JsonBody = @{
        publish = $true
        notes = $BodyNotes
    } | ConvertTo-Json

    if ($PSCmdlet.ShouldProcess($Uri,"publish zone changes")) {
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