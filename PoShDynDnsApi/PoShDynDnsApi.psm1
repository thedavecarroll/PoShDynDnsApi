#Requires -Version 5.1

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

#Set-StrictMode -Version Latest
Add-Type -AssemblyName System.Net.Http

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

# dot source public and private function definition files, export publich functions
try {
    foreach ($Scope in 'Public','Private') {
        Get-ChildItem "$ScriptPath\$Scope" -Filter *.ps1 | ForEach-Object {
            . $_.FullName
            if ($Scope -eq 'Public') {
                Export-ModuleMember -Function $_.BaseName -ErrorAction Stop
            }
        }
    }
}
catch {
    Write-Error ("{0}: {1}" -f $_.BaseName,$_.Exception.Message)
    exit 1
}

#region PSEdition detection
if ($PSEdition -eq 'Core') {
    Set-Alias -Name 'Invoke-DynDnsRequest' -Value 'Invoke-DynDnsRequestCore'
} else {
    Set-Alias -Name 'Invoke-DynDnsRequest' -Value 'Invoke-DynDnsRequestDesktop'
}
#endregion

#region load classes
if (Test-Path -Path "$ScriptPath\Classes\$ModuleName.Class.ps1") {
    . "$ScriptPath\Classes\$ModuleName.Class.ps1"
}
#endregion
