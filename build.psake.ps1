Properties {
    $ProjectRoot = $env:BHProjectPath
    if(-not $ProjectRoot) {
        $ProjectRoot = $PSScriptRoot
    }

    $Timestamp = Get-date -UFormat "%Y%m%d-%H%M%S"
    $PSVersion = $PSVersionTable.PSVersion.Major

    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $TestResultsName = "TestResults_PS$PSVersion`_$TimeStamp.xml"

    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $Line = "`n" + ('-' * 70)

    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $ModulePath = $env:BHModulePath
    $BuildOutput = $env:BHBuildOutput

    $Manifest = Import-PowerShellDataFile -Path $env:BHPSModuleManifest
    $psd1 = $env:BHPSModuleManifest

    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $VersionFolder = Join-Path -Path $BuildOutput -ChildPath $Manifest.ModuleVersion

    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $Tests = Join-Path -Path $ProjectRoot -ChildPath 'Tests'

    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $PrivateFunctionsPath = Join-Path -Path $ModulePath -ChildPath 'Private'

    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $PublicFunctionsPath = Join-Path -Path $ModulePath -ChildPath 'Public'

    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $ClassPath = Join-Path -Path $ModulePath -ChildPath 'Classes'

    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $ExternalHelpPath = Join-Path -Path $ModulePath -ChildPath 'en-US'

    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $PathSeparator = [IO.Path]::DirectorySeparatorChar

    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $DotNetFramework = 'netstandard2.0'
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssigments', '')]
    $Release = 'Release'
}

Task Default -Depends Test

Task Init -Description 'Initialize build environment' {
    "STATUS: Testing with PowerShell $PSVersion"
    ''
    "Build System Details:"
    Get-Item ENV:BH*
    ''
    "Version Folder:".PadRight(20) + $VersionFolder
    ''
    "Loading modules:"
    'Pester', 'platyPS', 'PSScriptAnalyzer' | Foreach-Object {
        "    $_"
        if (-not (Get-Module -Name $_ -ListAvailable -Verbose:$false -ErrorAction SilentlyContinue)) {
            Install-Module -Name $_ -Repository PSGallery -Scope CurrentUser -AllowClobber -Confirm:$false -ErrorAction Stop
        }
        Import-Module -Name $_ -Verbose:$false -Force -ErrorAction Stop
    }
    $Line
}

Task Clean -Depends Init -Description 'Cleans module output directory' {
    Remove-Module -Name $env:BHProjectName -Force -ErrorAction SilentlyContinue

    if (Test-Path -Path $BuildOutput) {
        Get-ChildItem -Path $BuildOutput -Recurse | Remove-Item -Force -Recurse
    } else {
        $null = New-Item -Path $BuildOutput -ItemType Directory
    }

    "    Cleaned previous output directory [$BuildOutput]"
    $Line
}

Task Compile -Depends Clean -Description 'Compiles module from source' {

    # create module output directory
    $null = New-Item -Path $VersionFolder -ItemType Directory

    # append items to psm1
    Write-Verbose -Message 'Creating psm1...'
    $psm1 = Copy-Item -Path (Join-Path -Path $ModulePath -ChildPath "$env:BHProjectName.psm1") -Destination (Join-Path -Path $VersionFolder -ChildPath "$($ENV:BHProjectName).psm1") -PassThru

    # append psm1
    '#region classes' | Add-Content -Path $psm1 -Encoding UTF8
    'Classes'| Foreach-Object {
        Write-Verbose -Message "Appending folder $_ to psm1..."
        Get-ChildItem -Path (Join-Path -Path $ModulePath -ChildPath $_) -Recurse -File |
            Get-Content -Raw | Add-Content -Path $psm1 -Encoding UTF8
    }
    '#endregion classes' | Add-Content -Path $psm1 -Encoding UTF8

    # copy private and public functions to build output version folder
    'Private','Public' | ForEach-Object {
        Write-Verbose -Message "Copying folder $_ to BuildOutput..."
        $BuildFolderPath = Join-Path -Path $VersionFolder -ChildPath $_
        $FolderPath = Join-Path -Path $ModulePath -ChildPath $_
        $HasFiles = Get-ChildItem -Path $FolderPath -File
        if ($HasFiles) {
            $null = New-Item -Path $BuildFolderPath -ItemType Directory
            $HasFiles | ForEach-Object { Copy-Item -Path $_.FullName -Destination $BuildFolderPath }
        }
    }

    # copy psd1 to build version output folder
    Copy-Item -Path $psd1 -Destination $VersionFolder
    $BuildManifest = Get-ChildItem -Path $VersionFolder -Include *.psd1 -Recurse | Select-Object -First 1 -ExpandProperty FullName

    # copy classes to build version output folder
    $NestedModules = @()
    if (Test-Path -Path $ClassPath) {
        $BuildClassPath = Join-Path -Path $VersionFolder -ChildPath 'Classes'
        $HasClasses = Get-ChildItem -Path $ClassPath -File
        if ($HasClasses) {
            $null = New-Item -Path $BuildClassPath -ItemType Directory
            $HasClasses | ForEach-Object {
                Copy-Item -Path $_.FullName -Destination $BuildClassPath
                $BuildRelativePath = Join-Path -Path '.' -ChildPath 'Classes'
                $NestedModules += Join-Path -Path $BuildRelativePath -ChildPath $_.Name.ToString()
            }
        }
    }

    # copy external help to build version output folder
    if (Test-Path -Path $ExternalHelpPath) {
        $BuildExternalHelpPath = Join-Path -Path $VersionFolder -ChildPath 'en-US'
        $HasExternalHelp = Get-ChildItem -Path $ExternalHelpPath -File
        if ($HasExternalHelp) {
            $null = New-Item -Path $BuildExternalHelpPath -ItemType Directory
            $HasExternalHelp | ForEach-Object { Copy-Item -Path $_.FullName -Destination $BuildExternalHelpPath }
        }
    }

    $Files = Get-ChildItem -Path $ModulePath -Recurse -Exclude '.gitignore' -File
    $FileList = $Files.FullName | ForEach-Object { $_.Replace("$ModulePath$PathSeparator",'')}

    $FunctionsToExport =  (Get-ChildItem -Path (Join-Path -Path $ModulePath -ChildPath 'Public') -Recurse -File | ForEach-Object { $_.BaseName })

    $Formats = Join-Path -Path $ModulePath -ChildPath 'TypeData' | Join-Path -ChildPath "$ModuleName.Format.ps1xml"
    if (Test-Path -Path $Formats) {
        $FormatsToProcess = $Formats.Replace("$ModulePath$PathSeparator",'')
    }

    $TypeData = Join-Path -Path $ModulePath -ChildPath 'TypeData' | Join-Path -ChildPath "$ModuleName.Types.ps1xml"
    if (Test-Path -Path $TypeData) {
        $TypesToProcess = $TypeData.Replace("$ModulePath$PathSeparator",'')
    }

    $UpdateManifestParams = @{}
    if ($FileList)          { $UpdateManifestParams['FileList'] = $FileList }
    if ($FunctionsToExport) { $UpdateManifestParams['FunctionsToExport'] = $FunctionsToExport }
    if ($FormatsToProcess)  { $UpdateManifestParams['FormatsToProcess'] = $FormatsToProcess }
    if ($TypesToProcess)    { $UpdateManifestParams['TypesToProcess'] = $TypesToProcess }
    if ($NestedModules)     { $UpdateManifestParams['NestedModules'] = $NestedModules }

    ''
    '    Adding the following to module manifest:'
    $UpdateManifestParams.Keys | ForEach-Object { "        $_"}
    Update-ModuleManifest -Path $BuildManifest @UpdateManifestParams

    ''
    "    Created compiled module at [$VersionFolder]"
    $Line
}

Task Test -Depends Init, Analyze, Pester -Description 'Run test suite'

Task Analyze -Description 'Run PSScriptAnalyzer' -Depends Compile {
    $Analysis = Invoke-ScriptAnalyzer -Path $VersionFolder -Verbose:$false
    $AnalyzeErrors = $Analysis | Where-Object {$_.Severity -eq 'Error'}
    $AnalyzeWarnings = $Analysis | Where-Object {$_.Severity -eq 'Warning'}

    '    PSScriptAnalyzer results:'
    ($Analysis | Group-Object -Property Severity,RuleName | Select-Object -Property Count,Name | Out-String).Trim().Split("`n") | Foreach-Object { (' ' * 8) + $_ }
    ''

    if (($AnalyzeErrors.Count -eq 0) -and ($AnalyzeWarnings.Count -eq 0)) {
        '    PSScriptAnalyzer passed without errors or warnings'
    }

    if (@($AnalyzeErrors).Count -gt 0) {
        Write-Error -Message 'One or more Script Analyzer errors were found. Build cannot continue!'
        $AnalyzeErrors | Format-Table
    }

    if (@($AnalyzeWarnings).Count -gt 0) {
        Write-Warning -Message 'One or more Script Analyzer warnings were found. These should be corrected.'
        $AnalyzeWarnings | Format-Table
    }
    $Line
}

Task Pester -Description 'Run Pester tests' -Depends Analyze {
    Push-Location
    Set-Location -Path $VersionFolder
    if(-not $ENV:BHProjectPath) {
        Set-BuildEnvironment -Path (Join-Path -Path $PSScriptRoot -ChildPath '..') -Passthru
    }

    $origModulePath = $env:PSModulePath
    if ( $env:PSModulePath.split($pathSeperator) -notcontains $BuildOutput ) {
        $env:PSModulePath = ($BuildOutput + $pathSeperator + $origModulePath)
    }

    Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue -Verbose:$false
    Import-Module (Join-Path -Path $VersionFolder -ChildPath "${env:BHProjectName}.psd1") -Force -Verbose:$false
    $TestResultsXml = Join-Path -Path $BuildOutput -ChildPath $TestResultsName
    $TestResults = Invoke-Pester -Path $Tests -PassThru -OutputFile $TestResultsXml -OutputFormat NUnitXml

    <#
    # Upload test artifacts to AppVeyor
    if ($env:APPVEYOR_JOB_ID) {
        $wc = New-Object 'System.Net.WebClient'
        $wc.UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", $testResultsXml)
    }
    #>

    if ($TestResults.FailedCount -gt 0) {
        $TestResults | Format-List
        Write-Error -Message 'One or more Pester tests failed. Build cannot continue!'
    }
    Pop-Location
    $env:PSModulePath = $origModulePath

    ''
    $Line
}


Task Build -Depends Compile, CreateMarkdownHelp, CreateExternalHelp {
    # External help
    $helpXml = New-ExternalHelp "$projectRoot\docs\reference\functions" -OutputPath (Join-Path -Path $VersionFolder -ChildPath 'en-US') -Force
    "    Module XML help created at [$helpXml]"
}
