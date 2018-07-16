function Undo-DynDnsZoneChanges {
    [CmdLetBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact='High'
    )]
    param(
        [Parameter()]
        [string]$Zone = (Read-Host -Prompt 'Please provide a zone to check for unpublished changes')
    )

    if (-Not (Test-DynDnsSession)) {
        return
    }

    $PendingZoneChanges = Get-DynDnsZoneChanges -Zone $Zone
    if ($PendingZoneChanges) {
        Write-Output $PendingZoneChanges
    } else {
        Write-Warning -Message 'There are no pending zone changes.'
        return
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