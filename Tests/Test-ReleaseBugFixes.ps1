$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent -Path $PSScriptRoot
. (Join-Path -Path $repositoryRoot -ChildPath 'PSAssets\ToolboxFunctions.ps1')

function Assert-Equal {
    param($Expected, $Actual, [string]$Message)
    if ($Expected -ne $Actual) {
        throw "$Message Expected '$Expected', but received '$Actual'."
    }
}

function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) {
        throw $Message
    }
}

function Get-State {
    param(
        [bool]$Drive = $false,
        [AllowNull()][Nullable[double]]$Free,
        [bool]$RAM = $false,
        [double]$RAMValue = 8,
        [bool]$Defender = $false,
        [bool]$DefenderValue = $true
    )
    Get-ETTComplianceState `
        -RAMCheckActive $RAM -RAMCheck $RAMValue -RAMMinimum 8 `
        -DriveSpaceCheckActive $Drive -FreeDriveSpaceGB $Free -DriveSpaceMinimum 20 `
        -WinVersionCheckActive $false -WinVersion '' -WinVersionTarget '' `
        -DefenderEnrollCheckActive $Defender -DefenderEnrollStatus $DefenderValue
}

Assert-Equal -Expected 'Non-Compliant' -Actual (Get-State -Drive:$true -Free 9).Status -Message '9 GB incorrectly passed the disk check.'
Assert-Equal -Expected 'Non-Compliant' -Actual (Get-State -Drive:$true -Free 19.999).Status -Message 'Free space rounded to the threshold passed.'
Assert-Equal -Expected 'Compliant' -Actual (Get-State -Drive:$true -Free 20).Status -Message 'Free space at the threshold failed.'
Assert-Equal -Expected 'Compliant' -Actual (Get-State -Drive:$true -Free 21).Status -Message 'Free space above the threshold failed.'
$warning = $null
Assert-Equal -Expected 'Non-Compliant' -Actual ((Get-State -Drive:$true -Free $null) 3>&1 | Tee-Object -Variable warning | Select-Object -Last 1).Status -Message 'Missing C: telemetry did not fail.'
Assert-True -Condition (@($warning -match 'unavailable').Count -gt 0) -Message 'Missing C: telemetry did not produce a warning.'
Assert-Equal -Expected 'Non-Compliant' -Actual (Get-State -RAM:$true -RAMValue 7 -Defender:$true -DefenderValue $true).Status -Message 'A passing Defender check hid failed RAM.'
Assert-Equal -Expected 'Non-Compliant' -Actual (Get-State -RAM:$true -RAMValue 8 -Defender:$true -DefenderValue $false).Status -Message 'A passing RAM check hid failed Defender enrollment.'
Assert-Equal -Expected 'Compliant' -Actual (Get-State -RAM:$true -RAMValue 8 -Defender:$true -DefenderValue $true).Status -Message 'All passing checks were not compliant.'
$noChecks = Get-State
Assert-Equal -Expected $null -Actual $noChecks.Status -Message 'No enabled checks should have a blank status.'
Assert-Equal -Expected $false -Actual $noChecks.Flag -Message 'No enabled checks should not trigger a compliance notification.'

$script:popupMessages = @()
$script:popupResponse = 6
$script:wingetAvailable = $false
$script:startedProcesses = @()
$script:scans = @()
$script:openedPaths = @()
$script:registryWrites = @()
$script:registryWriteFails = $false
$script:toastMessages = @()
$script:batteryDialogPath = "C:\My Reports\Joe's & Team\Battery.html"
$script:batteryDialogResult = 'OK'
$script:batteryExitCode = 0
$global:stopFails = $false
$global:cleanupFails = $false
$global:restartFails = $false
$global:stopCalls = 0
$global:startServiceCalls = 0

function New-Object {
    param(
        [Parameter(Position = 0)]$TypeName,
        $ComObject
    )
    if ($ComObject -eq 'Wscript.Shell') {
        $shell = [pscustomobject]@{}
        $shell | Add-Member -MemberType ScriptMethod -Name Popup -Value {
            param($Message, $Wait, $Title, $Type)
            $script:popupMessages += "$Title|$Message|$Type"
            return $script:popupResponse
        }
        return $shell
    }
    if ($TypeName -eq 'System.Windows.Forms.SaveFileDialog') {
        $dialog = [pscustomobject]@{
            Filter = ''
            Title = ''
            InitialDirectory = ''
            FileName = ''
        }
        $dialog | Add-Member -MemberType ScriptMethod -Name ShowDialog -Value {
            $script:lastDialog = $this
            $this.FileName = $script:batteryDialogPath
            return $script:batteryDialogResult
        }
        return $dialog
    }
    throw "Unexpected New-Object call: $TypeName $ComObject"
}

function Get-Command {
    param($Name, $CommandType, $ErrorAction)
    if ($script:wingetAvailable) {
        return [pscustomobject]@{ Name = $Name }
    }
    return $null
}

function Start-Process {
    param($FilePath, $ArgumentList, [switch]$PassThru, [switch]$Wait, $Verb, $WorkingDirectory, $ErrorAction)
    $script:startedProcesses += [pscustomobject]@{
        FilePath = $FilePath
        ArgumentList = $ArgumentList
        Verb = $Verb
        WorkingDirectory = $WorkingDirectory
    }
    if ($PassThru) {
        return [pscustomobject]@{ ExitCode = $script:batteryExitCode }
    }
}

function Invoke-Item {
    param($LiteralPath, $ErrorAction)
    $script:openedPaths += $LiteralPath
}

function Test-Path {
    param($Path, $LiteralPath, $PathType)
    return $true
}

function Start-MpScan {
    param($ScanType, $ErrorAction)
    $script:scans += $ScanType
}

function New-ItemProperty {
    param($Path, $Name, $Value, [switch]$Force, $ErrorAction)
    if ($script:registryWriteFails) {
        throw 'registry failure'
    }
    $script:registryWrites += [pscustomobject]@{ Path = $Path; Name = $Name; Value = $Value }
}

# Admin-mode elevation helper
$script:startedProcesses = @()
$started = Start-ETTElevated -ConfiguredAdminMode $true -CurrentlyElevated $false -ScriptPath 'C:\Tools\ETT.ps1' -ExecutablePath $null -WorkingDirectory 'C:\Tools'
Assert-True -Condition $started -Message 'Configured admin mode did not request relaunch.'
Assert-True -Condition ($script:startedProcesses.Count -eq 1) -Message 'Configured admin mode did not start exactly one elevated process.'
Assert-Equal -Expected 'RunAs' -Actual ([string]$script:startedProcesses[0].Verb) -Message 'ETT relaunch did not use RunAs.'
Assert-Equal -Expected "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" -Actual ([string]$script:startedProcesses[0].FilePath) -Message 'Script relaunch did not use Windows PowerShell.'

$script:startedProcesses = @()
$started = Start-ETTElevated -ConfiguredAdminMode $true -CurrentlyElevated $true -ScriptPath 'C:\Tools\ETT.ps1' -ExecutablePath $null -WorkingDirectory 'C:\Tools'
Assert-Equal -Expected $false -Actual $started -Message 'An elevated process was incorrectly relaunch-requested.'
Assert-Equal -Expected 0 -Actual $script:startedProcesses.Count -Message 'An elevated process started another elevated process.'

function Create-ToastNotification {
    param($Icon, $Title, $Message, $Duration)
    $script:toastMessages += "$Title|$Message"
}

function Stop-Service {
    param($Name, [switch]$Force, $ErrorAction)
    $global:stopCalls++
    if ($global:stopFails) {
        throw 'stop failure'
    }
}

function Start-Service {
    param($Name, $ErrorAction)
    $global:startServiceCalls++
    if ($global:restartFails) {
        throw 'restart failure'
    }
}

function Remove-Item {
    param($Path, [switch]$Recurse, [switch]$Force, $ErrorAction)
    if ($global:cleanupFails) {
        throw 'cleanup failure'
    }
}

$before = $script:startedProcesses.Count
Start-WingetAppUpdates
Assert-Equal -Expected $before -Actual $script:startedProcesses.Count -Message 'Missing winget started a child process.'
Assert-True -Condition ($script:popupMessages[-1] -match 'App Installer') -Message 'Missing winget did not show install guidance.'
$script:wingetAvailable = $true
Start-WingetAppUpdates
Assert-Equal -Expected 1 -Actual ($script:startedProcesses.Count - $before) -Message 'Available winget was not launched once.'

$systemType = 'Mobile'
Start-BatteryDiagnostics -adminmode $true
Assert-True -Condition ($script:startedProcesses[-1].ArgumentList -eq "/batteryreport /output `"$script:batteryDialogPath`"") -Message 'Battery report path was not passed intact and quoted.'
Assert-Equal -Expected $script:batteryDialogPath -Actual $script:openedPaths[-1] -Message 'The selected battery report was not opened.'
Start-BatteryDiagnostics -adminmode $false
Assert-Equal -Expected 'RunAs' -Actual $script:startedProcesses[-1].Verb -Message 'An unelevated battery report did not retain its UAC path.'
$processCount = $script:startedProcesses.Count
$script:batteryDialogResult = 'Cancel'
Start-BatteryDiagnostics -adminmode $true
Assert-Equal -Expected $processCount -Actual $script:startedProcesses.Count -Message 'A canceled battery dialog generated a report.'
$script:batteryDialogResult = 'OK'
$script:batteryExitCode = 1
$openedBeforeFailure = $script:openedPaths.Count
Start-BatteryDiagnostics -adminmode $true
Assert-Equal -Expected $openedBeforeFailure -Actual $script:openedPaths.Count -Message 'A failed battery report opened an old or stale file.'
$script:batteryExitCode = 0

foreach ($action in @(
    @{ Name = 'Restore-OldOutlook'; Property = 'UseNewOutlook' }
    @{ Name = 'Disable-AutomaticNewOutlookMigration'; Property = 'NewOutlookMigrationUserSetting' }
)) {
    $adminmode = $false
    $script:popupResponse = 7
    $before = $script:registryWrites.Count
    $popupCount = $script:popupMessages.Count
    & $action.Name | Out-Null
    Assert-Equal -Expected ($before + 1) -Actual $script:registryWrites.Count -Message "$($action.Name) did not run unelevated."
    Assert-Equal -Expected ($popupCount + 1) -Actual $script:popupMessages.Count -Message "$($action.Name) showed a profile warning unelevated."
    Assert-Equal -Expected $action.Property -Actual $script:registryWrites[-1].Name -Message "$($action.Name) wrote the wrong setting."
    Assert-True -Condition ($script:registryWrites[-1].Path -like 'HKCU:\*') -Message "$($action.Name) did not target the current profile."

    $adminmode = $true
    $before = $script:registryWrites.Count
    & $action.Name | Out-Null
    Assert-Equal -Expected $before -Actual $script:registryWrites.Count -Message "$($action.Name) wrote after the profile warning was declined."
    Assert-True -Condition ($script:popupMessages[-1] -match 'profile.*Administrator Protection') -Message "$($action.Name) did not warn about the elevated profile."

    $script:popupResponse = 6
    & $action.Name | Out-Null
    Assert-Equal -Expected ($before + 1) -Actual $script:registryWrites.Count -Message "$($action.Name) did not run after confirmation."

    $script:registryWriteFails = $true
    $toastCount = $script:toastMessages.Count
    & $action.Name | Out-Null
    Assert-Equal -Expected ($toastCount + 1) -Actual $script:toastMessages.Count -Message "$($action.Name) did not report a registry failure."
    $script:registryWriteFails = $false
}

$script:popupResponse = 7
$scanCount = $script:scans.Count
Start-DefenderQuickScan
Assert-Equal -Expected $scanCount -Actual $script:scans.Count -Message 'Declining a Defender prompt still started a scan.'
$script:popupResponse = 6
Start-DefenderFullScan
Start-DefenderQuickScan
Assert-Equal -Expected 'FullScan' -Actual $script:scans[0] -Message 'Full Defender scan was not selected.'
Assert-Equal -Expected 'QuickScan' -Actual $script:scans[1] -Message 'Quick Defender scan was not selected.'

$adminmode = $true
$global:cleanupFails = $true
$popupStart = $script:popupMessages.Count
Clear-GroupPolicyCache
if ((Get-Command -Name Start-Service -CommandType Function).Count -eq 0) {
    throw 'Start-Service mock was not registered.'
}
if ($global:startServiceCalls -eq 0) {
    throw "GPO path did not call Start-Service. adminmode=$adminmode popups=$($script:popupMessages[$popupStart..($script:popupMessages.Count - 1)] -join ';')"
}
Assert-Equal -Expected 1 -Actual $global:startServiceCalls -Message 'gpsvc restart was not attempted after cleanup failure.'
Assert-True -Condition (($script:popupMessages[$popupStart..($script:popupMessages.Count - 1)] -join "`n") -match 'cleanup failed') -Message 'Cleanup failure was not reported.'
$global:cleanupFails = $false
$global:restartFails = $true
$popupStart = $script:popupMessages.Count
Clear-GroupPolicyCache
Assert-True -Condition (($script:popupMessages[$popupStart..($script:popupMessages.Count - 1)] -join "`n") -match 'could not be restarted') -Message 'Service restart failure was not reported.'
$global:restartFails = $false
$global:stopFails = $true
$startsBefore = $global:startServiceCalls
Clear-GroupPolicyCache
Assert-Equal -Expected $startsBefore -Actual $global:startServiceCalls -Message 'gpsvc restart was attempted after the stop itself failed.'

$lapsSource = Get-Content -LiteralPath (Join-Path -Path $repositoryRoot -ChildPath 'MiniClients\LAPSToolV2.ps1') -Raw
$bitLockerSource = Get-Content -LiteralPath (Join-Path -Path $repositoryRoot -ChildPath 'MiniClients\BitLockerToolV2.ps1') -Raw
$settingsSource = Get-Content -LiteralPath (Join-Path -Path $repositoryRoot -ChildPath 'MiniClients\SettingsMenu.ps1') -Raw
Assert-True -Condition ($lapsSource -match [regex]::Escape('TenantId $azureADTenantId')) -Message 'LAPS did not use the configured tenant.'
Assert-True -Condition ($bitLockerSource -match [regex]::Escape('Scopes Device.Read.All, BitlockerKey.Read.All')) -Message 'BitLocker proxy scopes are incorrect.'
Assert-True -Condition ($lapsSource -notmatch '\$tenantID') -Message 'A recovery tool still references the undefined tenantID variable.'
Assert-True -Condition ($lapsSource -match [regex]::Escape('DecryptionCredential $alternateCredential -Domain $ADDomainNameTextBox.Text -AsPlainText).Password')) -Message 'Alternate-credential LAPS did not select Password.'
Assert-True -Condition ($settingsSource -match [regex]::Escape('$defenderEnrollCheckActiveCheckBox.Checked = $DefenderEnrollCheck')) -Message 'The Settings checkbox does not read the saved Defender value.'
Assert-True -Condition ($settingsSource -match [regex]::Escape('elseif ($settings.ETTSettingsGUI -eq $false)')) -Message 'The Settings disabled branch does not use ETTSettingsGUI.'
Assert-True -Condition ($settingsSource -notmatch 'Set-Content -Path "\.\\ETTConfig\.json"') -Message 'Settings still writes directly to the live config.'
Assert-Equal -Expected 0 -Actual @(Get-ChildItem -LiteralPath (Join-Path -Path $repositoryRoot -ChildPath 'MiniClients\DeprecatedClients') -File).Count -Message 'Obsolete clients remain in the maintained tree.'
$entryPoint = Get-Content -LiteralPath (Join-Path -Path $repositoryRoot -ChildPath 'ETT.ps1') -Raw
Assert-True -Condition ($entryPoint -notmatch 'Create-ToastNotification -Icon \[System\.Windows\.Forms\.ToolTipIcon\]::Error') -Message 'The PS2EXE compliance toast still passes an enum expression as an argument.'

# Evaluate the startup assignments without starting the GUI.
$ast = [System.Management.Automation.Language.Parser]::ParseInput($entryPoint, [ref]$null, [ref]$null)
$ternary = $ast.Find({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $n.Name -eq 'Invoke-Ternary' }, $false)
. ([scriptblock]::Create($ternary.Extent.Text))
Set-Alias '?:' Invoke-Ternary
$flags = $ast.FindAll({ param($n)
    $n -is [System.Management.Automation.Language.AssignmentStatementAst] -and
    $n.Left.Extent.Text -in '$AutoUpdateCheckerEnabled', '$customTools'
}, $false)
Assert-Equal 2 $flags.Count 'Expected both startup assignments.'
foreach ($case in @(
    @{ Json = '{}'; Update = $true; Tools = $true }
    @{ Json = '{"AutoUpdateCheckerEnabled":null,"EnableCustomTools":null}'; Update = $true; Tools = $true }
    @{ Json = '{"AutoUpdateCheckerEnabled":false,"EnableCustomTools":true}'; Update = $false; Tools = $true }
    @{ Json = '{"AutoUpdateCheckerEnabled":true,"EnableCustomTools":false}'; Update = $true; Tools = $false }
)) {
    $jsonConfig = ConvertFrom-Json $case.Json
    foreach ($flag in $flags) { . ([scriptblock]::Create($flag.Extent.Text)) }
    Assert-Equal $case.Update $AutoUpdateCheckerEnabled "Update flag for $($case.Json)."
    Assert-Equal $case.Tools $customTools "Custom tools flag for $($case.Json)."
}

Write-Output 'All release bug regression assertions passed.'
