function Get-DynDnsZoneNotes {
    [CmdLetBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Zone,
        [ValidateRange(1,1000)]
        [int]$Limit = 1000,
        [ValidateRange(0,1000)]
        [int]$Offset = 0
    )

    if (-Not (Test-DynDnsSession)) {
        return
    }

    $InvokeRestParams = Get-DynDnsRestParams
    $InvokeRestParams.Add('Method','Post')

    $JsonBody = @{
        zone = $Zone
        limit = $Limit
        offset = $Offset
    } | ConvertTo-Json

    $Uri = "$DynDnsApiClient/REST/ZoneNoteReport"
    Write-Verbose -Message "$DynDnsApiVersion : INFO  : $Uri"

    try {
        $ZoneNotes = Invoke-RestMethod -Uri $Uri @InvokeRestParams -Body $JsonBody
        Write-DynDnsOutput -RestResponse $ZoneNotes
    }
    catch {
        Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
        return
    }
}