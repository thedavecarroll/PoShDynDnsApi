#region discover module name
$ScriptPath = Split-Path $MyInvocation.MyCommand.Path
$ModuleName = Split-Path $ScriptPath -Leaf
$PSModule = $ExecutionContext.SessionState.Module
$PSModuleRoot = $PSModule.ModuleBase
#endregion discover module name
write-Verbose $PSModule

#region load module variables
Write-Verbose "Creating modules variables"
New-Variable -Name DynDnsApiClient -Value 'https://api.dynect.net' -Scope Global -Option ReadOnly -Force
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
Try {
    Update-FormatData "$ScriptPath\TypeData\$ModuleName.Format.ps1xml" -ErrorAction Stop
}
Catch {}
Try {
    Update-TypeData "$ScriptPath\TypeData\$ModuleName.Types.ps1xml" -ErrorAction Stop
}
Catch {}
#endregion Format and Type Data

#region load classes
. "$ScriptPath\Classes\$ModuleName.Class.ps1"

#region Aliases
#New-Alias -Name short -Value Get-LongCommand -Force
#endregion Aliases

#region Handle Module Removal
$OnRemoveScript = {
    Remove-Variable -Name DynDnsApiClient -Scope Global -Force
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
