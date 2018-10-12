#region discover module name
$ScriptPath = Split-Path $MyInvocation.MyCommand.Path
$ModuleName = Split-Path $ScriptPath -Leaf
$PSModule = $ExecutionContext.SessionState.Module

#endregion discover module name
write-Verbose $PSModule

#region load module variables
Write-Verbose "Creating modules variables"
$DynDnsSession = [ordered]@{
    ClientUrl           = 'https://api.dynect.net'
    User                = $null
    Customer            = $null
    ApiVersion          = $null
    AuthToken           = $null
    StartTime           = $null
    ElapsedTime         = $null
    LastCommand         = $null
    LastCommandTime     = $null
    LastCommandResults  = $null
    RefreshTime         = $null
}
New-Variable -Name DynDnsSession -Value $DynDnsSession -Scope Script -Force
#endregion load module variables

#region load functions
Try {
    foreach ($Scope in 'Public','Private') {
        Get-ChildItem "$ScriptPath\$Scope" -Filter *.ps1 | ForEach-Object {
            $Function = $_.FullName.BaseName
            . $_.FullName
        }
    }
} Catch {
    Write-Warning ("{0}: {1}" -f $Function,$_.Exception.Message)
    Continue
}
#endregion load functions

#region Format and Type Data
#try {
#    Update-FormatData "$ScriptPath\TypeData\$ModuleName.Format.ps1xml" -ErrorAction Stop
#}
#catch {}
#try {
#    Update-TypeData "$ScriptPath\TypeData\$ModuleName.Types.ps1xml" -ErrorAction Stop
#}
#catch {}
#endregion Format and Type Data

#region load classes
#if (Test-Path -Path "$ScriptPath\Classes\$ModuleName.Class.ps1") {
    . "$ScriptPath\Classes\$ModuleName.Class.ps1"
#}

#region Aliases
#New-Alias -Name short -Value Get-LongCommand -Force
#endregion Aliases

#region Handle Module Removal
$OnRemoveScript = {
    Remove-Variable -Name DynDnsSession -Scope Script -Force
}
$ExecutionContext.SessionState.Module.OnRemove += $OnRemoveScript
Register-EngineEvent -SourceIdentifier ([System.Management.Automation.PsEngineEvent]::Exiting) -Action $OnRemoveScript
#endregion Handle Module Removal

#region export module members
#$ExportModule = @{
#    #Alias = @()
#    #Function = @()
#    #Variable = @()
#}
#Export-ModuleMember @ExportModule
#endregion export module members
