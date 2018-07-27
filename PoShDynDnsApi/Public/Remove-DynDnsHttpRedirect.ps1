function Remove-DynDnsHttpRedirect {
    [CmdLetBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact='High'
    )]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [DynDnsHttpRedirect[]]$DynDnsHttpRedirect,

        [ValidateSet('Y','N')]
        [string]$Publish = 'N'
    )

    begin {

    }

    process {

        foreach ($Redirect in $DynDnsHttpRedirect) {

            $Fqdn = $Redirect.RawData.fqdn
            $Zone = $Redirect.RawData.zone
            $Url = $Redirect.RawData.url

            Write-Output $Redirect

            if ($Publish -eq 'Y') {
                Write-Warning -Message 'This will autopublish the HTTP redirect deletion to the zone.'
            }

            if ($PSCmdlet.ShouldProcess("$Url",'Delete HTTP redirect')) {
                $RemoveRedirect = Invoke-DynDnsRequest -UriPath "/REST/HTTPRedirect/$Zone/$Fqdn" -Method Delete
                Write-DynDnsOutput -DynDnsResponse $RemoveRedirect
            } else {
                Write-Verbose 'Whatif : Removed HTTP redirect'
            }
            Write-Output ''
        }
    }

    end {

    }

}