function Add-DynDnsZone {
    [CmdLetBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact='High'
    )]
    param(
        [Parameter(Mandatory=$true,ParameterSetName='Zone')]
        [Parameter(Mandatory=$true,ParameterSetName='ZoneFile')]
        [string]$Zone,

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

    switch ($PsCmdlet.ParameterSetName) {
        'Zone' {
            $Uri = "/REST/Zone/$Zone"
            $JsonBody = @{
                rname = $ResponsibilePerson.Replace('@','.')
                serial_style = $SerialStyle
                ttl = $TTL.ToString()
            } | ConvertTo-Json
        }
        'ZoneFile' {
            $Uri = "/REST/ZoneFile/$Zone"
            $JsonBody = @{
                file = "$(Get-Content -Path $ZoneFile -Raw)"
            } | ConvertTo-Json
        }
    }

    if ($PSCmdlet.ShouldProcess("$Zone",'Create DNS zone')) {
        $NewZone = Invoke-DynDnsRequest -UriPath $Uri -Method Post -Body $JsonBody
        Write-DynDnsOutput -DynDnsResponse $NewZone
    } else {
        Write-Verbose 'Whatif : Created new zone'
    }
}