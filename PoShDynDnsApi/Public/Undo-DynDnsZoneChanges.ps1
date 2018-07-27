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

    if ($PSCmdlet.ShouldProcess($Zone,"discard zone changes")) {
        $UndoZoneChanges = Invoke-DynDnsRequest -UriPath "/REST/ZoneChanges/$Zone" -Method Delete
        Write-DynDnsOutput -DynDnsResponse $UndoZoneChanges
    } else {
        Write-Verbose 'Whatif : Discarded zone changes'
    }
}