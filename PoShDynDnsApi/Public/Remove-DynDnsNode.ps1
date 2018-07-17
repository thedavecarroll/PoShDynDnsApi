function Remove-DynDnsNode {
    [CmdLetBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact='High'
    )]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Zone,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Node,
        [switch]$Force
    )

    if ($Node) {
        if ($Node -match $Zone ) {
            $Fqdn = $Node
        } else {
            $Fqdn = $Node + '.' + $Zone
        }
    } else {
        $Fqdn = $Zone
    }

    if ($Fqdn -notmatch $Zone ) {
        Write-Warning -Message "The zone ($Zone) does not contain $Fqdn."
        return
    }

    if (-Not (Test-DynDnsSession)) {
        return
    }

    $ZoneRecords = Get-DynDnsRecord -Zone $Zone -Node $Node -RecordType All
    $HttpRedirects = Get-DynDnsHttpRedirect -Zone $Zone -Node $Node

    if ($ZoneRecords -or $HttpRedirects) {
        if (-Not $Force) {
            Write-Warning -Message "The node ($Fqdn) contains records or services. Use the -Force switch if you wish to proceed."
            return
        } else {
            $WarningMessage = "`n"
            $WarningMessage += "`n" + ('-' * 80) + "`n"
            $WarningMessage += 'PROCEEDING WILL DELETE ALL RECORDS AND SERVICES CONTAINED WITHIN THE NODE' + "`n"
            $WarningMessage += 'THIS INCLUDES ALL CHILD NODES' + "`n"
            $WarningMessage += '-' * 80 + "`n"

            if ($ZoneRecords) {
                $WarningMessage += "`n"
                $Header = "Zone records for ${Fqdn}:"
                $WarningMessage += "$Header`n"
                $WarningMessage += '-' * $Header.Length + "`n"
                $WarningMessage += ($ZoneRecords | Out-String).Trim()
                $WarningMessage += "`n"
            }
            if ($HttpRedirects) {
                $WarningMessage += "`n"
                $Header = "HTTP redirects for ${Fqdn}:"
                $WarningMessage += "$Header`n"
                $WarningMessage += '-' * $Header.Length + "`n"
                $WarningMessage += ($HttpRedirects | Out-String).Trim()
                $WarningMessage += "`n"
            }
            $WarningMessage += "`n" + ('-' * 80) + "`n"
            $WarningMessage += "`n"
            Write-Warning -Message $WarningMessage
        }
    }

    $InvokeRestParams = Get-DynDnsRestParams
    $InvokeRestParams.Add('Method','Delete')

    $Uri = "$DynDnsApiClient/REST/Node/$Zone/$Fqdn"

    if ($PSCmdlet.ShouldProcess("$Uri",'Delete node, child nodes, and all records')) {
        try {
            $RemoveNode = Invoke-RestMethod -Uri $Uri @InvokeRestParams
            Write-DynDnsOutput -RestResponse $RemoveNode
            Write-Output ''
        }
        catch {
            Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
        }
    }
}