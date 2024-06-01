function CheckForWindowsUpdates {
    param(
        [string]$windowTitle,
        [string]$updateSearchQuery,
        [string]$noUpdatesMessage
    )

    #Create our Update Session and Update Searcher
    $updateSession = new-object -com "Microsoft.Update.Session"
    $updateSearcher = $updateSession.CreateupdateSearcher()
    $searchResult = $updateSearcher.Search($updateSearchQuery)

    if ($searchResult.Updates.Count -eq 0) {
        #If no updates are found, show a popup
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.popup($noUpdatesMessage, 0, $windowTitle, 64)
    }
    else {
        #Check if admin mode is enabled. Depending on the result, run the appropriate command
        if ($adminmode -eq $true) {
            #If yes, install updates
            $wshell = New-Object -ComObject Wscript.Shell
            if ($wshell.Popup("Do you want to continue and download updates?", 0, "Update Confirm", 0x00000004) -eq 6) {
                #Check the status to see if we need to download or just install updates
                $downloadReq = $false
                foreach ($update in $searchResult.Updates) {
                    if ($update.IsDownloaded -eq $false) {
                        $downloadReq = $true
                    }
                }

                #If we need to download updates, we do that here.
                if ($downloadReq) {
                    $updatesToDownload = new-object -com "Microsoft.Update.UpdateColl"
                    foreach ($update in $searchResult.Updates) {
                        $updatesToDownload.Add($update) | out-null
                    }
                    $downloader = $updateSession.CreateUpdateDownloader() 
                    $downloader.Updates = $updatesToDownload
                    $downloader.Download()
                }

                $updatesToInstall = new-object -com "Microsoft.Update.UpdateColl"
                foreach ($update in $searchResult.Updates) {
                    if ( $update.IsDownloaded ) {
                        $updatesToInstall.Add($update) | out-null
                    }
                }
                if ( $updatesToInstall.Count -eq 0 ) {
                    #Not ready for install.
                }
                else {
                    $wshell = New-Object -ComObject Wscript.Shell
                    $installer = $updateSession.CreateUpdateInstaller()
                    $installer.Updates = $updatesToInstall
                    $installationResult = $installer.Install()
                    if ( $installationResult.ResultCode -eq 2 ) {
                        $wshell.popup("Updates installed successfully.", 0, $windowTitle, 64)
                    }
                    else {
                        $wshell.popup("Some updates could not installed.", 0, $windowTitle, 64)
                    }
                    if ( $installationResult.RebootRequired ) {
                        $wshell.popup("One or more updates are requiring reboot.", 0, $windowTitle, 64)
                    }
                    else {
                        $wshell.popup("Finished. Reboot are not required.", 0, $windowTitle, 64)
                    }
                }
            }
            else {
                #Do nothing
            }
        }
        else {
            #If no, show a popup that updates are available, but admin mode needs to be run
            $wshell = New-Object -ComObject Wscript.Shell
            $wshell.popup("Updates found. Please run ETT in admin mode to install updates.", 0, $windowTitle, 64)
        }
    }
}

function ClearLastLogin{
    param(
        [Parameter(Position=0,mandatory=$true)]
        $adminmode, 
        [Parameter(Position=1,mandatory=$true)]
        $ToastStack
    )
    #Check if admin mode is enabled. Depending on the result, run the appropriate command    
    if ($adminmode -eq $true) {
        #With admin mode enabled, run the commands without UAC
        New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI' -Name LastLoggedOnSAMUser -Value "" -Force
        New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI' -Name LastLoggedOnUser -Value ""  -Force
        New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI' -Name LastLoggedOnUserSID -Value "" -Force
    }
    elseif ($adminmode -eq $false) {
        #Without admin mode enabled, run the commands with UAC, in a sub-process shell
        Start-Process powershell.exe -Verb runAs -ArgumentList '-Command', 'New-ItemProperty -Path ''HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI'' -Name LastLoggedOnSAMUser -Value "" -Force; New-ItemProperty -Path ''HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI'' -Name LastLoggedOnUser -Value ""  -Force; New-ItemProperty -Path ''HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI'' -Name LastLoggedOnUserSID -Value "" -Force' -Wait
    }

    #Display a notification that the last login has been cleared
    $ToastStack.BalloonTipText = "Last Login Cleared!"
    $ToastStack.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
    $ToastStack.BalloonTipTitle = "Login Status"
    $ToastStack.ShowBalloonTip(5000)
    $ToastStack.Visible = $true
}

function Get-WindowsActivationKey{
    $HardwareKey = (Get-WmiObject -query 'select * from SoftwareLicensingService' | Select-Object OA3xOriginalProductKey).OA3xOriginalProductKey
        
    #Verify that the key is not null
    if ($HardwareKey -eq $null -or $HardwareKey -eq "") {
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("No Windows Activation Key found in WMI." + "`n`nThis could be the result of running in a VM, or not stored in BIOS", 0, "Windows Activation", 64)
    }
    else {
        #Key is not null, so display it in a popup
        $HardwareKey | Set-Clipboard
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("Windows Activation Key: " + $HardwareKey + "`n`nKey Copied to Clipboard.", 0, "Windows Activation Key", 64)
    }
}
function Get-HostsFileIntegrity{
    $hostsHash = (Get-FileHash "C:\Windows\System32\Drivers\etc\hosts").Hash
    $hostsCompliant = $true
    $hostsText = "Host File Integrity: Unmodified"
    if ($hostsHash -ne "2D6BDFB341BE3A6234B24742377F93AA7C7CFB0D9FD64EFA9282C87852E57085") {
        $hostsCompliant = $false
        $hostsText = "Host File Integrity: Modified"
    return $hostsText
}
}

function Get-WindowsActivationType{
    slmgr.vbs /dli
}

function Start-WingetAppUpdates{
    #Upgrade applications on the machine

    #Main try-catch test to verify newest version of WPM (winget) is installed
    try {
        winget.exe
    }
    catch {
        #IF winget is not installed, open the store and close the script
        { 1: $wshell = New-Object -ComObject Wscript.Shell
            $wshell.Popup("Error: Winget not Installed.", 0, "Winget Issue", 32)
            Start-Process ms-windows-store:
            Exit-PSSession }
    }
    
    #If winget is installed, run an upgrade on all apps in new administator powershell window.
    Start-Process powershell.exe -ArgumentList "-command winget upgrade --all"
}

function Start-PolicyPatch{
    Start-Process powershell.exe -ArgumentList "-command gpupdate /force"
}
function Start-DriverUpdateCLI{
    param(
        [Parameter(Position=0,mandatory=$true)]
        $manufacturer
    )
    #Launch Driver Updater
    if (($manufacturer -eq "Dell Inc.") -and (Test-Path -Path "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe")) {
        #Uses Dell Command Update CLI to update drivers
        Start-Process -Filepath "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe" -ArgumentList "/applyUpdates -outputLog=C:\Temp\dellUpdateOutput.log" -WorkingDirectory "C:\Program Files (x86)\Dell\CommandUpdate" -PassThru -Verb RunAs
    }
    elseif (($manufacturer -eq "LENOVO") -and (Test-Path -Path "C:\Program Files (x86)\Lenovo\System Update\tvsu.exe")) {
        #Uses Lenovo System Update CLI trigger to update drivers
        Start-Process "C:\Program Files (x86)\Lenovo\System Update\tvsu.exe" -ArgumentList "/CM -search C -action INSTALL -includerebootpackages 1,3,4 -noreboot" -WorkingDirectory "C:\Program Files (x86)\Lenovo\System Update" -PassThru -Verb RunAs
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("Lenovo Updates Completed!", 0, "Driver Updater", 64)
    }
    else {
        #Open MS Settings - Windows Update deeplink
        Start-Process ms-settings:windowsupdate-action
        Start-Process ms-settings:windowsupdate-optionalupdates
    }
}

function Start-DriverUpdateGUI{
    param(
        [Parameter(Position=0,mandatory=$true)]
        $manufacturer
    )
    #Launch Driver Updater
    if (($manufacturer -eq "Dell Inc.") -and (Test-Path -Path "C:\Program Files\Dell\CommandUpdate\DellCommandUpdate.exe")) {
        Start-Process "C:\Program Files\Dell\CommandUpdate\DellCommandUpdate.exe"
    }
    elseif (($manufacturer -eq "LENOVO") -and (Test-Path -Path "C:\Program Files (x86)\Lenovo\System Update\tvsu.exe")) {
        Start-Process "C:\Program Files (x86)\Lenovo\System Update\tvsu.exe"
    }
    else {
        #Open MS Settings - Windows Update deeplink and 1 second popup to notify user
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("Driver Updater not found. Opening Windows Update.", 0, "Driver Updater", 64)
        Start-Process ms-settings:windowsupdate-action
        Start-Process ms-settings:windowsupdate-optionalupdates
    }
}

function Start-SFCScan{
    #SFC Scan
    Start-Process powershell.exe -ArgumentList "-command sfc /scannow" -PassThru -Verb RunAs
}

function Start-SuspendBitlockerAction{
    param(
        [Parameter(Position=0,mandatory=$true)]
        $adminmode
    )
    #Check if adminmode is enabled
    if ($adminmode -eq "True") {
        #Check if BitLocker is enabled
        if ((Get-BitLockerVolume -MountPoint C:).ProtectionStatus -eq "On") {
            #Suspend BitLocker
            Suspend-BitLocker -MountPoint "C:" -RebootCount 1
            $wshell = New-Object -ComObject Wscript.Shell
            $wshell.Popup("BitLocker suspended for one reboot.", 0, "BitLocker", 64)
        }
        else {
            #BitLocker is not enabled
            $wshell = New-Object -ComObject Wscript.Shell
            $wshell.Popup("BitLocker is not enabled on this computer.", 0, "BitLocker", 64)
        }
    }
    else {
        #Admin mode is not enabled
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("Admin mode is not enabled. Please enable adminmode flag and reboot script. If compiled, this requires a version of the application with adminmode flag turned on.", 0, "BitLocker", 64)     
    }
}

function Start-NetworkTest{
    #Test Network
    Start-Process powershell.exe -ArgumentList "-command Test-NetConnection -ComputerName google.com; pause" -PassThru -Wait
}

function Start-WiFiDiagnostics{
    param(
        [Parameter(Position=0,mandatory=$true)]
        $adminmode
    )
    #Test Wi-Fi
    if ($adminmode -eq "True") {
        Start-Process cmd.exe -ArgumentList "/K netsh wlan show wlanreport" -PassThru -Wait
        Start-Process "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -ArgumentList "C:\ProgramData\Microsoft\Windows\WlanReport\wlan-report-latest.html" -WindowStyle maximized
    }
    else {
        #Admin mode is not enabled, run in a sub-process shell, but catch if UAC is not accepted and do nothing
        try {
            Start-Process powershell.exe -Verb runAs -ArgumentList "-command netsh wlan show wlanreport" -PassThru -Wait
            Start-Process "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -ArgumentList "C:\ProgramData\Microsoft\Windows\WlanReport\wlan-report-latest.html" -WindowStyle maximized
        }
        catch {
            #Do nothing...
        }
    }
}

function Start-BatteryDiagnostics{
    param(
        [Parameter(Position=0,mandatory=$true)]
        $adminmode
    )
    #Test Battery, first check if device is a laptop
    if ($systemType -eq "Mobile" -or $systemType -eq "Appliance PC" -or $systemType -eq "Slate") {
        #Device is a laptop, now check if adminmode is enabled
        if ($adminmode -eq "True") {
            #Check to see if C:\Temp\ exists, if not, create it
            if ((Test-Path -path "C:\Temp\") -eq $false) {
                New-Item -Path 'C:\Temp\' -ItemType Directory
            }

            #Adminmode is enabled, so run the battery report
            Start-Process powershell.exe -ArgumentList "-command powercfg /batteryreport /output C:\Temp\Battery.html" -PassThru -Wait
            Start-Process "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -ArgumentList "C:\Temp\Battery.html" -WindowStyle maximized
        }
        else {
            #Adminmode is not enabled, so run the battery report in a sub-process shell, but catch if UAC is not accepted and do nothing
            try {
                #Check to see if C:\Temp\ exists, if not, create it
                if ((Test-Path -path "C:\Temp\") -eq $false) {
                    New-Item -Path 'C:\Temp\' -ItemType Directory
                }

                Start-Process powershell.exe -ArgumentList "-command powercfg /batteryreport /output C:\Temp\Battery.html" -PassThru -Verb RunAs -Wait
                Start-Process "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -ArgumentList "C:\Temp\Battery.html" -WindowStyle maximized
            }
            catch {
                #Do nothing...
            }
        }
    }
    else {
        #Device is not a laptop, so display a popup
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("This device is not a laptop. No battery report available.", 0, "Battery Diagnostic", 64)
    }
}

function Start-SCCMClientFunction {
    param (
        $TriggerScheduleGUID,
        $TriggerScheduleName
    )
    Invoke-CimMethod -Namespace 'root\CCM' -ClassName SMS_Client -MethodName TriggerSchedule -Arguments @{sScheduleID = $TriggerScheduleGUID }
    $wshell = New-Object -ComObject Wscript.Shell
    $wshell.Popup("SCCM Client Task $TriggerScheduleName Triggered. The selected task will run and might take several minutes to finish.", 0, "SCCM Client Task", 64)
}

function QuickReboot{
    #First, confirm reboot
    $wshell = New-Object -ComObject Wscript.Shell
    if ($wshell.Popup("Are you sure you want to reboot? Make sure everything is saved before proceeding.", 0, "Reboot", 4 + 32) -eq 6) {
        #Reboot
        Start-Process shutdown -argumentlist "-r -t 0" -PassThru
    }
}