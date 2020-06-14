
Describe -Name 'Test-DynDnsSession' -Tag 'Unit','Public' {

    Set-BuildEnvironment -Force
    Import-Module $env:BHPSModuleManifest

    InModuleScope 'PoShDynDnsApi' {

        #Mock -CommandName Invoke-DynDnsRequestDesktop -MockWith { $true }
        #Mock -CommandName Invoke-DynDnsRequestCore -MockWith { $true }
        Mock -CommandName Invoke-DynDnsRequest -MockWith { $true } -ParameterFilter {
            $SessionAction = 'Test'
        }
        Mock -CommandName Write-DynDnsOutput -MockWith {}

        It 'Returns $true if existing authentication token is valid' {
            Test-DynDnsSession | Should be $true
        }

    }

}

    <#
    [OutputType('System.Boolean')]
    param()

    $Session = Invoke-DynDnsRequest -SessionAction 'Test' -WarningAction SilentlyContinue
    Write-DynDnsOutput -DynDnsResponse $Session -WarningAction SilentlyContinue
    if ($Session.Data.status -eq 'success') {
        $true
    } else {
        $false
    }
    #>