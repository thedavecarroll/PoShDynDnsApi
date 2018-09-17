# https://blogs.technet.microsoft.com/janesays/2017/04/25/compare-all-properties-of-two-objects-in-windows-powershell/
function Compare-ObjectProperties {
    [CmdLetBinding()]
    Param(
        [PSObject]$ReferenceObject,
        [PSObject]$DifferenceObject
    )
    $objprops = $ReferenceObject | Get-Member -MemberType Property,NoteProperty | ForEach-Object { $_.Name }
    $objprops += $DifferenceObject | Get-Member -MemberType Property,NoteProperty | ForEach-Object { $_.Name }
    $objprops = $objprops | Sort-Object | Select-Object -Unique
    $diffs = @()
    foreach ($objprop in $objprops) {
        $diff = Compare-Object $ReferenceObject $DifferenceObject -Property $objprop
        if ($diff) {
            $diffprops = @{
                PropertyName=$objprop
                RefValue=($diff | Where-Object {$_.SideIndicator -eq '<='} | ForEach-Object $($objprop) -WhatIf:$false)
                DiffValue=($diff | Where-Object {$_.SideIndicator -eq '=>'} | ForEach-Object $($objprop) -WhatIf:$false)
            }
            $diffs += New-Object PSObject -Property $diffprops
        }
    }
    if ($diffs) {return ($diffs | Select-Object PropertyName,RefValue,DiffValue)}
}