function Undo-DynDnsZoneChanges {
    [CmdLetBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact='High'
    )]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Zone,
        [switch]$Force
    )

    if (-Not (Test-DynDnsSession)) {
        return
    }

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

    $InvokeRestParams = Get-DynDnsRestParams
    $InvokeRestParams.Add('Method','Delete')

    $Uri = "$DynDnsApiClient/REST/ZoneChanges/$Zone"

    if ($PSCmdlet.ShouldProcess($Uri,"discard zone changes")) {
        try {
            $UndoZoneChanges = Invoke-RestMethod -Uri $Uri @InvokeRestParams
            Write-DynDnsOutput -RestResponse $UndoZoneChanges
        }
        catch {
            Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
            continue
        }
    } else {
        Write-Verbose 'Whatif : Discarded zone changes'
    }
}