#region info
<#
The following members are exported via the module's data file (.psd1)
    Functions
    TypeData
    FormatData
#>
#endregion info

#region discover module name
$ScriptPath = Split-Path $MyInvocation.MyCommand.Path
$ModuleName = $ExecutionContext.SessionState.Module
Write-Verbose -Message "Loading module $ModuleName"
#endregion discover module name

#region load module variables
Write-Verbose -Message "Creating modules variables"
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$DynDnsSession = [ordered]@{
    ClientUrl           = 'https://api.dynect.net'
    User                = $null
    Customer            = $null
    ApiVersion          = $null
    AuthToken           = $null
    StartTime           = $null
    ElapsedTime         = $null
    RefreshTime         = $null
}

[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
$DynDnsHistory = New-Object System.Collections.ArrayList
#endregion load module variables

#region Handle Module Removal
$OnRemoveScript = {
#    Remove-Variable -Name DynDnsSession -Scope Script -Force
}
$ExecutionContext.SessionState.Module.OnRemove += $OnRemoveScript
Register-EngineEvent -SourceIdentifier ([System.Management.Automation.PsEngineEvent]::Exiting) -Action $OnRemoveScript
#endregion Handle Module Removal

#region load classes
if (Test-Path -Path "$ScriptPath\Classes\$ModuleName.Class.ps1") {
    . "$ScriptPath\Classes\$ModuleName.Class.ps1"
}
#endregion
