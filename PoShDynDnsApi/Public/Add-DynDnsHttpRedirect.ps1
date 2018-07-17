function Add-DynDnsHttpRedirect {
    [CmdLetBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact='High'
    )]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Zone,

        [string]$Node,

        [Parameter(Mandatory=$true)]
        [string]$Url,

        [ValidateSet('301','302')]
        [string]$ResponseCode = '301',

        [ValidateSet('Y','N')]
        [string]$IncludeUri = 'N'
    )

    if (-Not (Test-DynDnsSession)) {
        return
    }

    $InvokeRestParams = Get-DynDnsRestParams
    $InvokeRestParams.Add('Method','Post')

    if ($Node) {
        if ($Node -match $Zone ) {
            $Fqdn = $Node
        } else {
            $Fqdn = $Node + '.' + $Zone
        }
    } else {
        $Fqdn = $Zone
    }

    $Uri = "$DynDnsApiClient/REST/HTTPRedirect/$Zone/$Fqdn"

    $JsonBody = @{
        code = $ResponseCode
        keep_uri = $IncludeUri
        url = $Url
    } | ConvertTo-Json

    Write-Warning -Message 'This will autopublish the HTTP redirect to the zone.'

    if ($PSCmdlet.ShouldProcess("$Uri","Create HTTP redirect to $Url")) {
        try {
            $NewHttpRedirect = Invoke-RestMethod -Uri $Uri -Body $JsonBody @InvokeRestParams
            Write-DynDnsOutput -RestResponse $NewHttpRedirect
        }
        catch {
            Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
            return
        }
    } else {
        Write-Verbose 'Whatif : Created new HTTP redirect'
    }
}