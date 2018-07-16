function Add-DynDnsZone {
    [CmdLetBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact='High'
    )]
    param(
        [Parameter(Mandatory=$true,ParameterSetName='Zone')]
        [Parameter(Mandatory=$true,ParameterSetName='ZoneFile')]
        [string]$Zone = (Read-Host -Prompt 'Please provide the name of the new zone'),

        [Parameter(Mandatory=$true,ParameterSetName='Zone')]
        [string]$ResponsibilePerson,

        [Parameter(ParameterSetName='Zone')]
        [ValidateSet('increment','epoch','day','minute')]
        [string]$SerialStyle = 'day',

        [Parameter(ParameterSetName='Zone')]
        [int]$TTL = 3600,

        [Parameter(ParameterSetName='ZoneFile')]
        [ValidateScript({Test-Path $_})]
        [string]$ZoneFile
    )

    if (-Not (Test-DynDnsSession)) {
        return
    }

    $InvokeRestParams = Get-DynDnsRestParams
    $InvokeRestParams.Add('Method','Post')

    switch ($PsCmdlet.ParameterSetName) {
        'Zone' {
            $Uri = "https://api.dynect.net/REST/Zone/$Zone"
            $JsonBody = @{
                rname = $ResponsibilePerson.Replace('@','.')
                serial_style = $SerialStyle
                ttl = $TTL.ToString()
            } | ConvertTo-Json
        }
        'ZoneFile' {
            $Uri = "https://api.dynect.net/REST/ZoneFile/$Zone"
            $JsonBody = @{
                file = "$(Get-Content -Path $ZoneFile -Raw)"
            } | ConvertTo-Json
        }
    }

    if ($PSCmdlet.ShouldProcess("$Zone",'Create DNS zone')) {
        try {
            $NewZone = Invoke-RestMethod -Uri $Uri -Body $JsonBody @InvokeRestParams
            Write-DynDnsOutput -RestResponse $NewZone
        }
        catch {
            Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
            return
        }
    } else {
        Write-Verbose 'Whatif : Created new zone'
    }
}