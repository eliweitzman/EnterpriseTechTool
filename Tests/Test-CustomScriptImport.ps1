$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent -Path $PSScriptRoot
. (Join-Path -Path $repositoryRoot -ChildPath 'MiniClients\SettingsMenu.ps1')

$testDirectory = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ('ETT-CustomScriptImport-' + [guid]::NewGuid().ToString())
$utf8WithoutBom = New-Object System.Text.UTF8Encoding($false)

function Assert-Equal {
    param(
        [AllowNull()]
        $Expected,

        [AllowNull()]
        $Actual,

        [string]$Message
    )

    if ($Expected -ne $Actual) {
        throw "$Message Expected '$Expected', but received '$Actual'."
    }
}

function Assert-True {
    param(
        [bool]$Condition,
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Assert-Throws {
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock]$Action,

        [Parameter(Mandatory = $true)]
        [string]$ExpectedMessage
    )

    $exceptionMessage = $null
    try {
        & $Action
    }
    catch {
        $exceptionMessage = $_.Exception.Message
    }

    if ($null -eq $exceptionMessage) {
        throw "Expected an exception containing '$ExpectedMessage', but no exception was thrown."
    }
    if ($exceptionMessage -notlike "*$ExpectedMessage*") {
        throw "Expected an exception containing '$ExpectedMessage', but received '$exceptionMessage'."
    }
}

function Write-TestConfig {
    param(
        [string]$Path,
        [hashtable]$Config
    )

    [System.IO.File]::WriteAllText($Path, ($Config | ConvertTo-Json -Depth 10), $utf8WithoutBom)
}

function Get-ConfigSnapshot {
    param([string]$Path)

    return [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($Path))
}

try {
    [void](New-Item -ItemType Directory -Path $testDirectory -Force)

    $configPath = Join-Path -Path $testDirectory -ChildPath 'ETTConfig.json'
    $scriptPath = Join-Path -Path $testDirectory -ChildPath 'Imported Tool.ps1'
    $scriptContent = @'
# Imported script comment
$message = 'Hello, "ETT"!'

Write-Output $message
'@
    [System.IO.File]::WriteAllText($scriptPath, $scriptContent, $utf8WithoutBom)

    $parsedContent = Read-ETTCustomScript -Path $scriptPath
    Assert-Equal -Expected $scriptContent -Actual $parsedContent -Message 'The parsed script content was changed.'

    $providerQualifiedScriptPath = "Microsoft.PowerShell.Core\FileSystem::$scriptPath"
    $providerParsedContent = Read-ETTCustomScript -Path $providerQualifiedScriptPath
    Assert-Equal -Expected $scriptContent -Actual $providerParsedContent -Message 'A provider-qualified script path was not normalized.'

    Write-TestConfig -Path $configPath -Config @{
        EnableCustomScriptUpload = $false
        BrandColor = '#123456'
        CustomFunctions = @(
            @{
                displayName = 'Existing Tool'
                description = 'Keep this entry'
                tab = ''
                requireAdmin = $false
                codeBlock = 'Write-Output "existing"'
            }
        )
    }

    Add-ETTCustomFunction -ConfigPath $configPath -CodeBlock $parsedContent -DisplayName 'Imported Tool' -Description 'Imported test' -RequireAdmin $true -AdminMode $true -EnableCustomScriptUpload $true
    $savedConfig = Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
    Assert-Equal -Expected '#123456' -Actual $savedConfig.BrandColor -Message 'An existing config value was not preserved.'
    Assert-Equal -Expected 2 -Actual @($savedConfig.CustomFunctions).Count -Message 'The custom function was not appended.'
    Assert-Equal -Expected 'Existing Tool' -Actual $savedConfig.CustomFunctions[0].displayName -Message 'The existing custom function was not preserved.'
    Assert-Equal -Expected $scriptContent -Actual $savedConfig.CustomFunctions[1].codeBlock -Message 'The saved script content was changed.'
    Assert-Equal -Expected $true -Actual $savedConfig.EnableCustomScriptUpload -Message 'Successful import did not enable the setting.'
    Assert-Equal -Expected $true -Actual $savedConfig.CustomFunctions[1].requireAdmin -Message 'The admin metadata was not preserved.'
    Assert-Equal -Expected 'Custom' -Actual $savedConfig.CustomFunctions[1].tab -Message 'The custom tool was not routed to the Custom tab.'

    $beforeDuplicate = Get-ConfigSnapshot -Path $configPath
    Assert-Throws -Action {
        Add-ETTCustomFunction -ConfigPath $configPath -CodeBlock 'Write-Output "duplicate"' -DisplayName 'imported tool' -Description '' -RequireAdmin $false -AdminMode $true -EnableCustomScriptUpload $true
    } -ExpectedMessage 'already exists'
    Assert-Equal -Expected $beforeDuplicate -Actual (Get-ConfigSnapshot -Path $configPath) -Message 'A duplicate import changed the config.'

    $beforeNonAdmin = Get-ConfigSnapshot -Path $configPath
    Assert-Throws -Action {
        Add-ETTCustomFunction -ConfigPath $configPath -CodeBlock 'Write-Output "blocked"' -DisplayName 'Blocked Non-Admin' -Description '' -RequireAdmin $false -AdminMode $false -EnableCustomScriptUpload $true
    } -ExpectedMessage 'Admin elevation is required'
    Assert-Equal -Expected $beforeNonAdmin -Actual (Get-ConfigSnapshot -Path $configPath) -Message 'A non-admin import changed the config.'

    Assert-Throws -Action {
        Add-ETTCustomFunction -ConfigPath $configPath -CodeBlock 'Write-Output "blocked"' -DisplayName 'Blocked Setting' -Description '' -RequireAdmin $false -AdminMode $true -EnableCustomScriptUpload $false
    } -ExpectedMessage 'disabled in Settings'
    Assert-Equal -Expected $beforeNonAdmin -Actual (Get-ConfigSnapshot -Path $configPath) -Message 'An import with uploads disabled changed the config.'

    $invalidScriptPath = Join-Path -Path $testDirectory -ChildPath 'Invalid.ps1'
    [System.IO.File]::WriteAllText($invalidScriptPath, 'if ($true) {', $utf8WithoutBom)
    $beforeInvalid = Get-ConfigSnapshot -Path $configPath
    Assert-Throws -Action {
        Read-ETTCustomScript -Path $invalidScriptPath
    } -ExpectedMessage 'syntax validation failed'
    Assert-Equal -Expected $beforeInvalid -Actual (Get-ConfigSnapshot -Path $configPath) -Message 'Syntax validation changed the config.'

    $emptyScriptPath = Join-Path -Path $testDirectory -ChildPath 'Empty.ps1'
    [System.IO.File]::WriteAllText($emptyScriptPath, " `r`n", $utf8WithoutBom)
    Assert-Throws -Action {
        Read-ETTCustomScript -Path $emptyScriptPath
    } -ExpectedMessage 'empty'

    $wrongExtensionPath = Join-Path -Path $testDirectory -ChildPath 'Script.txt'
    [System.IO.File]::WriteAllText($wrongExtensionPath, 'Write-Output "not PowerShell"', $utf8WithoutBom)
    Assert-Throws -Action {
        Read-ETTCustomScript -Path $wrongExtensionPath
    } -ExpectedMessage 'Only .ps1'

    $minimalConfigPath = Join-Path -Path $testDirectory -ChildPath 'MinimalConfig.json'
    Write-TestConfig -Path $minimalConfigPath -Config @{
        BrandColor = '#654321'
    }
    Add-ETTCustomFunction -ConfigPath $minimalConfigPath -CodeBlock 'Write-Output "first"' -DisplayName 'First Tool' -Description '' -RequireAdmin $false -AdminMode $true -EnableCustomScriptUpload $true
    $minimalConfig = Get-Content -LiteralPath $minimalConfigPath -Raw | ConvertFrom-Json
    Assert-Equal -Expected 1 -Actual @($minimalConfig.CustomFunctions).Count -Message 'A missing CustomFunctions array was not initialized.'
    Assert-Equal -Expected '#654321' -Actual $minimalConfig.BrandColor -Message 'A config value was lost while initializing CustomFunctions.'
    Assert-Equal -Expected $true -Actual $minimalConfig.EnableCustomScriptUpload -Message 'A missing upload setting was not initialized.'

    $atomicConfig = Get-Content -LiteralPath $minimalConfigPath -Raw | ConvertFrom-Json
    $atomicConfig | Add-Member -MemberType NoteProperty -Name 'ExtraSetting' -Value @{
        lines = @('one', 'two')
    }
    Save-ETTConfigAtomically -ConfigPath $minimalConfigPath -Config $atomicConfig
    $savedAtomicConfig = Get-Content -LiteralPath $minimalConfigPath -Raw | ConvertFrom-Json
    Assert-Equal -Expected 2 -Actual @($savedAtomicConfig.ExtraSetting.lines).Count -Message 'Atomic settings save lost nested data.'

    $beforeLockedSave = Get-ConfigSnapshot -Path $minimalConfigPath
    $lockedStream = [System.IO.File]::Open(
        $minimalConfigPath,
        [System.IO.FileMode]::Open,
        [System.IO.FileAccess]::ReadWrite,
        [System.IO.FileShare]::None
    )
    try {
        Assert-Throws -Action {
            Save-ETTConfigAtomically -ConfigPath $minimalConfigPath -Config $savedAtomicConfig
        } -ExpectedMessage 'Unable to save ETT configuration'
    }
    finally {
        $lockedStream.Dispose()
    }
    Assert-Equal -Expected $beforeLockedSave -Actual (Get-ConfigSnapshot -Path $minimalConfigPath) -Message 'A failed atomic replacement changed the original config.'
    Assert-True -Condition (@(Get-ChildItem -LiteralPath $testDirectory -Force -Filter '.ETTConfig.*').Count -eq 0) -Message 'A failed atomic replacement left temporary or backup files.'

    $metadataDefaults = New-ETTCustomFunctionMetadata -ScriptPath $scriptPath
    Assert-Equal -Expected 'Imported Tool' -Actual $metadataDefaults.displayName -Message 'The display-name default was incorrect.'
    Assert-Equal -Expected 'Imported from Imported Tool.ps1' -Actual $metadataDefaults.description -Message 'The description default was incorrect.'
    Assert-Equal -Expected $false -Actual $metadataDefaults.requireAdmin -Message 'The admin default was not false.'

    Assert-True -Condition $true -Message 'The custom script import assertions did not complete.'
    Write-Output 'All custom script import tests passed.'
}
finally {
    if (Test-Path -LiteralPath $testDirectory) {
        Remove-Item -LiteralPath $testDirectory -Recurse -Force
    }
}
