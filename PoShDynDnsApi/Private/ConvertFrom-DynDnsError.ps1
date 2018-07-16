function ConvertFrom-DynDnsError {
    param([object]$Response)

    try {
        $streamReader = [System.IO.StreamReader]::new($Response.Exception.Response.GetResponseStream())
        $ErrorResponse = $streamReader.ReadToEnd() | ConvertFrom-Json
        $streamReader.Close()
    }
    catch {
        Write-Warning -Message 'Unable to convert error.'
        $ErrorResponse = $null
    }
    finally {
        $ErrorResponse
    }
}