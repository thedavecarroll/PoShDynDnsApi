function Get-DynDnsRestParams {
    param([switch]$NoAuthToken)
    $DynDnsRestParams = @{
        ContentType = 'application/json'
        ErrorAction = 'Stop'
        Verbose = $false
    }
    if (-Not $NoAuthToken) {
        $DynDnsRestParams.Add('Headers',@{'Auth-Token' = "$DynDnsAuthToken"})
    }
    $DynDnsRestParams
}