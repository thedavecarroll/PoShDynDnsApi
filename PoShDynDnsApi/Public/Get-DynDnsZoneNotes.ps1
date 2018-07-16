function Get-DynDnsZoneNotes {
    [CmdLetBinding()]
    param(
        [Parameter()]
        [string]$Zone = (Read-Host -Prompt 'Please provide a zone to check for unpublished changes'),
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

    try {
        $ZoneNotes = Invoke-RestMethod -Uri "$DynDnsApiClient/REST/ZoneNoteReport" @InvokeRestParams -Body $JsonBody
        Write-DynDnsOutput -RestResponse $ZoneNotes
    }
    catch {
        Write-DynDnsOutput -RestResponse (ConvertFrom-DynDnsError -Response $_)
        return
    }
}