function Update-DynDnsRecord {
    [CmdLetBinding(
        SupportsShouldProcess=$true,
        ConfirmImpact='High'
    )]
    param(
        [Parameter(Mandatory=$true)]
        [DynDnsRecord]$DynDnsRecord,
        [Parameter(Mandatory=$true)]
        [DynDnsRecord]$UpdatedDynDnsRecord
    )

    if ($DynDnsRecord.GetType() -ne $UpdatedDynDnsRecord.GetType()) {
        Write-Warning -Message "The original record type does not match the updated record type."
        return
    } else {
        Write-Verbose -Message "The original record type matches the updated record type."
    }

    $Fqdn = $DynDnsRecord.Name
    $Zone = $DynDnsRecord.Zone
    $RecordType = $DynDnsRecord.Type
    $RecordId = $DynDnsRecord.RecordId

    if ($RecordType -eq 'SOA') {
        $Body = $UpdatedDynDnsRecord.RawData | ConvertTo-Json | ConvertFrom-Json
        Add-Member -InputObject $Body -MemberType NoteProperty -Name serial_style -Value $DynDnsRecord.RawData.serial_style -Force
        $JsonBody = $Body | Select-Object * -ExcludeProperty record_type | ConvertTo-Json
    } else {
        $JsonBody = $UpdatedDynDnsRecord.RawData | ConvertTo-Json | ConvertFrom-Json | Select-Object * -ExcludeProperty record_type | ConvertTo-Json
    }

    $UpdatedAttributes = Compare-ObjectProperties -ReferenceObject $DynDnsRecord -DifferenceObject $UpdatedDynDnsRecord | ForEach-Object {
        if ($_.DiffValue.length -gt 0 -and $_.DiffValue -ne 0) { $_ }
    }
    $UpdatedAttributes = $UpdatedAttributes | Select-Object @{label='Attribute';expression={$_.PropertyName}},
        @{label='Original';expression={$_.RefValue}},@{label='Updated';expression={$_.DiffValue}} | Out-String

    Write-Output ''
    Write-Output ('-' * 80)
    Write-Output 'Original DNS Record:'
    Write-Output ''
    Write-Output ($DynDnsRecord | Out-String).Trim()
    Write-Output ''
    Write-Output ('-' * 80)
    Write-Output 'Update DNS Record Attributes:'
    Write-Output ''
    Write-Output $UpdatedAttributes.Trim()
    Write-Output ''

    if ($PSCmdlet.ShouldProcess("$Fqdn","Update $RecordType DNS record")) {
        $UpdateDnsRecord = Invoke-DynDnsRequest -UriPath "/REST/$($RecordType)Record/$Zone/$Fqdn/$RecordId" -Method Put -Body $JsonBody
        Write-DynDnsOutput -DynDnsResponse $UpdateDnsRecord
    } else {
        Write-Verbose 'Whatif : Updated DNS record'
    }
}