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

        if (-Not (Test-DynDnsSession)) {
            return
        }

        $InvokeRestParams = Get-DynDnsRestParams
        $InvokeRestParams.Add('Method','Delete')
    }

    process {

        foreach ($Redirect in $DynDnsHttpRedirect) {

            $Fqdn = $Redirect.RawData.fqdn
            $Zone = $Redirect.RawData.zone
            $Url = $Redirect.RawData.url

            $Uri = "$DynDnsApiClient/REST/HTTPRedirect/$Zone/$Fqdn"

            Write-Output $Redirect

            if ($Publish -eq 'Y') {
                Write-Warning -Message 'This will autopublish the HTTP redirect deletion to the zone.'
            }

            if ($PSCmdlet.ShouldProcess("$Url",'Delete HTTP redirect')) {
                try {
                    $RemoveRedirect = Invoke-RestMethod -Uri $Uri @InvokeRestParams
                    Write-DynDnsOutput -RestResponse $RemoveRedirect
                }
                catch {
                    Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
                    continue
                }
            } else {
                Write-Verbose 'Whatif : Deleted HTTP redirect'
            }
        }
    }

    end {

    }

}