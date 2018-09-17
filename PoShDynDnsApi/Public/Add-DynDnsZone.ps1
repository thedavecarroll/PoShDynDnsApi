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

    $EmailRegex = '^([\w-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([\w-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$'

    switch ($PsCmdlet.ParameterSetName) {
        'Zone' {
            if ($ResponsibilePerson -notmatch $EmailRegex) {
                Write-Warning -Message 'The value provided for ResponsibilePerson does not appear to be a valid email. Please try again.'
                return
            }
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

    if ($PSCmdlet.ShouldProcess("$Zone","Create DNS zone by $($PsCmdlet.ParameterSetName) method")) {
        $NewZone = Invoke-DynDnsRequest -UriPath $Uri -Method Post -Body $JsonBody
        Write-DynDnsOutput -DynDnsResponse $NewZone
        if ($NewZone.Data.Status -eq 'success') {
            Write-Output 'Be sure to use the function Publish-DynDnsZoneChanges in order publish the domain.'
        }
    } else {
        Write-Verbose 'Whatif : Created new zone'
    }
}