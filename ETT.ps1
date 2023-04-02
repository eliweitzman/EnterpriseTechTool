<# 
.NAME
    Enterprise Tech Tool
.SYNOPSIS
    A tool designed to assist in simplifying common tasks for IT professionals.
.DESCRIPTION
        - System-aware Dark Mode!
        - Auto-elevate to admin
        - Clear last Windows login
        - Check for app updates thru WinGet
        - Retreive Local Admin Passwords thru LAPS
        - Windows Policy Update Function (Runs GPUpdate and Intune Sync [Intune not quite fixed yet])
        - Mini-Functions
        
.AUTHOR
    Eli Weitzman
.NOTES
    Version:        1.0
    Creation Date:  12-26-22
    Last Updated:   3-28-23
    Purpose/Change: Updates, and trickledown feature integration
#>

<#
# Self-elevate the script to administrative rights (Remove comment if you want this)

if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        $Command = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -FilePath PowerShell.exe -Verb RunAs -ArgumentList $Command
        Exit
 }
}
#>

#Capture Machine Info
$username = whoami.exe
$hostname = HOSTNAME.EXE
$winver = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").DisplayVersion
$manufacturer = Get-WmiObject -Class Win32_ComputerSystemProduct | Select-Object -ExpandProperty Vendor
$model = Get-WmiObject -Class Win32_ComputerSystem -Property Model | Select-Object -ExpandProperty Model
$domain = Get-WmiObject -Class Win32_ComputerSystem -Property Domain | Select-Object -ExpandProperty Domain
$drivespace = Get-WmiObject -ComputerName localhost -Class win32_logicaldisk | Where-Object caption -eq "C:" | foreach-object { Write-Output " $($_.caption) $('{0:N2}' -f ($_.Size/1gb)) GB total, $('{0:N2}' -f ($_.FreeSpace/1gb)) GB free " }
$ramCheck = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum / 1gb
$cpuCheck = Get-WmiObject -Class Win32_Processor | Select-Object -ExpandProperty Name
$drivetype =  Get-PhysicalDisk | Where-Object DeviceID -eq 0 | Select-Object -ExpandProperty MediaType

#Create Device Info Dump
$deviceInfo = @"
Compliance Status: $complianceStatus
Username: $username
Hostname: $hostname
Windows Version: $winver
Manufacturer: $manufacturer
Model: $model
RAM: $ramCheck GB
CPU: $cpuCheck
Domain: $domain
Storage: $drivespace
Storage Type: $drivetype
"@

#Determine Dark/Light Mode
# Get the current theme
$theme = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize").AppsUseLightTheme

#Dark/Light Parameters
# If the theme is 0, it is dark mode
if ($theme -eq 0) {
    #DARK MODE
    $BGcolor = 'Black'
    $TextColor = 'White'
    $BoxColor = 'SlateGray'
}
else {
    #LIGHT MODE
    $BGcolor = 'WhiteSmoke'
    $TextColor = 'Black'
    $BoxColor = 'White'
}

#Import Winforms API for GUI
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

#Create main frame (REMEMBER TO ITERATE VERSION NUMBER ON BUILD CHANGES)
$Form = New-Object System.Windows.Forms.Form
$Form.ClientSize = New-Object System.Drawing.Point(519, 330)
$Form.text = "Eli's Enterprise Tech Tool V1.0"
$Form.StartPosition = 'CenterScreen'
$Form.MaximizeBox = $false
$Form.MaximumSize = $Form.Size
$Form.MinimumSize = $Form.Size
$Form.TopMost = $false
$Form.BackColor = $BGcolor

#Import and load in logo icon
$Logo = New-Object system.Windows.Forms.PictureBox
$Logo.width = 126
$Logo.height = 73
$Logo.location = New-Object System.Drawing.Point(377, 29)
$Logo.imageLocation = "https://github.com/eliweitzman/EliEnterpriseKit/blob/main/Eli's%20Enterprise%20(1).png?raw=true"
$Logo.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::zoom

$Heading = New-Object system.Windows.Forms.Label
$Heading.text = "Enterprise Tech Tool"
$Heading.AutoSize = $true
$Heading.width = 25
$Heading.height = 10
$Heading.location = New-Object System.Drawing.Point(40, 47)
$Heading.Font = New-Object System.Drawing.Font('Segoe UI', 25, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
$Heading.ForeColor = $TextColor

#Create Toast Notification Stack
$ToastStack = New-Object System.Windows.Forms.NotifyIcon
$Path = (Get-Process -id $pid).Path
$ToastStack.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$ToastStack.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
$ToastStack.BalloonTipTitle = "Eli's Enterprise Tech Tool"
$ToastStack.BalloonTipText = "Welcome to Eli's Enterprise Tech Tool!"
$ToastStack.Visible = $true
$ToastStack.ShowBalloonTip(5000)

#Button placeholder for clearing last login
$ClearLastLogin = New-Object system.Windows.Forms.Button
$ClearLastLogin.text = "Clear Last Login"
$ClearLastLogin.width = 237
$ClearLastLogin.height = 89
$ClearLastLogin.location = New-Object System.Drawing.Point(13, 117)
$ClearLastLogin.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
$ClearLastLogin.ForeColor = $TextColor
$ClearLastLogin.BackColor = $BoxColor

$ClearLastLogin_Action = {
    
    Start-Process powershell.exe -Verb runAs -ArgumentList '-Command', 'New-ItemProperty -Path ''HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI'' -Name LastLoggedOnSAMUser -Value "" -Force; New-ItemProperty -Path ''HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI'' -Name LastLoggedOnUser -Value ""  -Force; New-ItemProperty -Path ''HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI'' -Name LastLoggedOnUserSID -Value "" -Force' -Wait
    $ToastStack.BalloonTipText = "Last Login Cleared!"
    $ToastStack.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
    $ToastStack.BalloonTipTitle = "Login Status"
    $ToastStack.ShowBalloonTip(5000)
    $ToastStack.Visible = $true

}
$ClearLastLogin.Add_Click($ClearLastLogin_Action)

#LAPS button
$Lapspw = New-Object system.Windows.Forms.Button
$Lapspw.text = "Get LAPS Password"
$Lapspw.width = 237
$Lapspw.height = 89
$Lapspw.Anchor = 'top'
$Lapspw.location = New-Object System.Drawing.Point(267, 117)
$Lapspw.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
$Lapspw.ForeColor = $TextColor
$Lapspw.BackColor = $BoxColor

#A seperate GUI applet for LAPS openable when the function is selected
$Lapspw_Action = {
    
    ##FIRST SECTION INPUT FIELD
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()
    
    #Create box
    $LapsForm = New-Object system.Windows.Forms.Form
    $LapsForm.ClientSize = New-Object System.Drawing.Point(500, 301)
    $LapsForm.text = "LAPS GUI"
    $LapsForm.TopMost = $true
    $LapsForm.BackColor = $BGcolor
    
    #Title for box
    $titleTag = New-Object system.Windows.Forms.Label
    $titleTag.text = "LAPS GUI"
    $titleTag.AutoSize = $true
    $titleTag.width = 25
    $titleTag.height = 10
    $titleTag.location = New-Object System.Drawing.Point(88, 45)
    $titleTag.Font = New-Object System.Drawing.Font('Segoe UI', 16, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
    $titleTag.ForeColor = $TextColor
    
    #Logo sourced from choccolatey gal
    $Lapslogo = New-Object system.Windows.Forms.PictureBox
    $Lapslogo.width = 106
    $Lapslogo.height = 72
    $Lapslogo.location = New-Object System.Drawing.Point(313, 17)
    $Lapslogo.imageLocation = "https://community.chocolatey.org/content/packageimages/laps.6.2.0.20210403.png"
    $Lapslogo.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::zoom
    
    #Label for domain info
    $domainLabel = New-Object system.Windows.Forms.Label
    $domainLabel.text = "Domain:"
    $domainLabel.AutoSize = $true
    $domainLabel.width = 25
    $domainLabel.height = 10
    $domainLabel.location = New-Object System.Drawing.Point(16, 116)
    $domainLabel.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
    $domainLabel.ForeColor = $TextColor
    
    #Domain input box
    $domainInput = New-Object system.Windows.Forms.TextBox
    $domainInput.multiline = $false
    $domainInput.width = 184
    $domainInput.height = 20
    $domainInput.Anchor = 'top'
    $domainInput.location = New-Object System.Drawing.Point(239, 114)
    $domainInput.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)
    
    #Hostname information label
    $hostnameLabel = New-Object system.Windows.Forms.Label
    $hostnameLabel.text = "Machine Hostname"
    $hostnameLabel.AutoSize = $true
    $hostnameLabel.width = 25
    $hostnameLabel.height = 10
    $hostnameLabel.location = New-Object System.Drawing.Point(16, 152)
    $hostnameLabel.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
    $hostnameLabel.ForeColor = $TextColor
    
    #Input field for hostname
    $hostnameInput = New-Object system.Windows.Forms.TextBox
    $hostnameInput.multiline = $false
    $hostnameInput.width = 269
    $hostnameInput.height = 20
    $hostnameInput.location = New-Object System.Drawing.Point(154, 152)
    $hostnameInput.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)
    
    #Username information label
    $usernameInfo = New-Object system.Windows.Forms.Label
    $usernameInfo.text = "Your Username with Domain prefix (DOMAIN\username)"
    $usernameInfo.AutoSize = $true
    $usernameInfo.width = 25
    $usernameInfo.height = 10
    $usernameInfo.location = New-Object System.Drawing.Point(16, 189)
    $usernameInfo.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
    $usernameInfo.ForeColor = $TextColor
    
    #Username input box
    $usernameInput = New-Object system.Windows.Forms.TextBox
    $usernameInput.multiline = $false
    $usernameInput.width = 406
    $usernameInput.height = 20
    $usernameInput.location = New-Object System.Drawing.Point(17, 216)
    $usernameInput.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)
    
    #Start button that closes window to run
    $lapsStart = New-Object system.Windows.Forms.Button
    $lapsStart.text = "Start"
    $lapsStart.width = 125
    $lapsStart.height = 30
    $lapsStart.location = New-Object System.Drawing.Point(154, 251)
    $lapsStart.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
    $lapsStart.BackColor = $BoxColor
    $lapsStart.Add_Click({ $form.Add_FormClosing({ $_.Cancel = $false }); $Lapsform.Close() })
    
    #Print the above GUI applets in the box
    $LapsForm.controls.AddRange(@($Lapslogo, $domainInput, $domainLabel, $titleTag, $hostnameLabel, $hostnameInput, $usernameInfo, $usernameInput, $lapsStart))
    
    #region Logic 
    
    #endregion
    
    #SHOW ME THE MONEY
    [void]$LapsForm.ShowDialog()
    
    #RUN LAPS OPERATION
    
    #Converting input from prior box into a LAPS run
    $hostname = $hostnameInput.Text
    $domain = $domainInput.Text
    $username = $usernameInput.Text

    #Run LAPS in new powershell window
    $output = Get-ADComputer $hostname -Properties * -Server $domain -Credential $username | Select-Object -ExpandProperty ms-Mcs-AdmPwd

    #Add password to the clipboard
    Set-Clipboard -Value $output
    
    $wshell = New-Object -ComObject Wscript.Shell
    $wshell.Popup("Password: " + $output + "`r`n(Result has as well been copied to clipboard)", 0, "LAPS Result", 64)
}

#Enable clicking to run the action above
$Lapspw.Add_Click($Lapspw_Action)

#Button to run a winget upgrade sequence
$appUpdate = New-Object system.Windows.Forms.Button
$appUpdate.text = "Update Apps (Winget)"
$appUpdate.width = 237
$appUpdate.height = 89
$appUpdate.Anchor = 'bottom,left'
$appUpdate.location = New-Object System.Drawing.Point(13, 219)
$appUpdate.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
$appUpdate.ForeColor = $TextColor
$appUpdate.BackColor = $BoxColor

#Winget upgrading function
$appUpdate_onClick = {
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

#Assign function to the button
$appUpdate.Add_Click($appUpdate_onClick)

#A button to run a policy update (GPUpdate and Intune Sync)
$PolicyPatch = New-Object system.Windows.Forms.Button
$PolicyPatch.text = "Windows Policy Update"
$PolicyPatch.width = 237
$PolicyPatch.height = 89
$PolicyPatch.location = New-Object System.Drawing.Point(266, 219)
$PolicyPatch.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
$PolicyPatch.ForeColor = $TextColor
$PolicyPatch.BackColor = $BoxColor

#BATCH MENU = Policy Update!

$PolicyPatch_OnClick = {
    #First, run GPUpdate
    Start-Process powershell.exe -ArgumentList "-command gpupdate /force"

    #Any additional commands can be added here, depending on policy and compliance needs

}

#Make button do stuff
$PolicyPatch.Add_Click($PolicyPatch_OnClick)

#TAB MENU

$menu = New-Object System.Windows.Forms.MenuStrip
$menu.ForeColor = $TextColor
$menu.BackColor = $BGcolor

<#TEMPLATE FOR TABS

$tabvarname = New-Object System.Windows.Forms.ToolStripMenuItem

AND 

$tabvarname.Text = "Tab Name"
$tabvarname.Add_Click({
    #Code to run when tab is clicked
})
$menu.Items.Add($tabvarname) FOR TOP LEVEL TABS

$tabName.DropDownItems.Add($tabvarname) FOR SUB TABS
#>

#Info Tab
$menuInfo = New-Object System.Windows.Forms.ToolStripMenuItem
$menuWhoami = New-Object System.Windows.Forms.ToolStripMenuItem
$menuHostname = New-Object System.Windows.Forms.ToolStripMenuItem
$windowsVersion = New-Object System.Windows.Forms.ToolStripMenuItem
$manufacturerInfo = New-Object System.Windows.Forms.ToolStripMenuItem
$modelInfo = New-Object System.Windows.Forms.ToolStripMenuItem
$domainInfo = New-Object System.Windows.Forms.ToolStripMenuItem
$storageInfo = New-Object System.Windows.Forms.ToolStripMenuItem
$ramInfo = New-Object System.Windows.Forms.ToolStripMenuItem
$cpuInfo = New-Object System.Windows.Forms.ToolStripMenuItem
$deviceInfoPrint = New-Object System.Windows.Forms.ToolStripMenuItem
$deviceInfoClipboard = New-Object System.Windows.Forms.ToolStripMenuItem

#HELP TAB
$menuHelp = New-Object System.Windows.Forms.ToolStripMenuItem
$menuAbout = New-Object System.Windows.Forms.ToolStripMenuItem
$menuBugReport = New-Object System.Windows.Forms.ToolStripMenuItem
$menuLicenses = New-Object System.Windows.Forms.ToolStripMenuItem

#FUNCTIONS TAB
$menuFunctions = New-Object System.Windows.Forms.ToolStripMenuItem
$launchDriverUpdater = New-Object System.Windows.Forms.ToolStripMenuItem
$launchDriverUpdaterGUI = New-Object System.Windows.Forms.ToolStripMenuItem
$menuSFCScan = New-Object System.Windows.Forms.ToolStripMenuItem
$menuSuspendBitlocker = New-Object System.Windows.Forms.ToolStripMenuItem
#$menuRenameComputer = New-Object System.Windows.Forms.ToolStripMenuItem - Commented out until I can figure out how to make it work
$menuTestNet = New-Object System.Windows.Forms.ToolStripMenuItem

#One-Off Tabs
$menuFeatures = New-Object System.Windows.Forms.ToolStripMenuItem
$menuExit = New-Object System.Windows.Forms.ToolStripMenuItem

#Keyboard Shortcuts

#CTRL + P to run deviceInfoPrint
$deviceInfoPrint.ShortcutKeys = [System.Windows.Forms.Keys]::Control + [System.Windows.Forms.Keys]::P
$deviceInfoPrint.ShortcutKeyDisplayString = "CTRL + P"

#CTRL + C to run deviceInfoClipboard
$deviceInfoClipboard.ShortcutKeys = [System.Windows.Forms.Keys]::Control + [System.Windows.Forms.Keys]::C
$deviceInfoClipboard.ShortcutKeyDisplayString = "CTRL + C"

#f1

#Assigning tab menu items

#Info Tab
$menuInfo.Text = "Info"
$outputsuppressed = $menu.Items.Add($menuInfo)

#Whoami Display
$menuWhoami.Text = "Username: " + $username
$menuWhoami.Add_Click({
        Set-Clipboard -Value $username
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("Username copied to clipboard", 0, "Username Copied", 64)
    })

$menuWhoami.ToolTipText = "Current username for session." + "`nClick to copy username to clipboard."
$menuWhoami.BackColor = $BGcolor
$menuWhoami.ForeColor = $TextColor
$outputsuppressed = $menuInfo.DropDownItems.Add($menuWhoami)

#Hostname Display
$menuHostname.Text = "Hostname: " + $hostname
$menuHostname.Add_Click({
        Set-Clipboard -Value $hostname
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("Hostname copied to clipboard", 0, "Hostname Copied", 64)
    })
$menuHostname.ToolTipText = "Current device hostname." + "`nClick to copy hostname to clipboard."
$menuHostname.BackColor = $BGcolor
$menuHostname.ForeColor = $TextColor
$outputsuppressed = $menuInfo.DropDownItems.Add($menuHostname)

#Windows Version Display
$windowsVersion.Text = "Windows Version: " + $winver
$windowsVersion.Add_Click({
        Set-Clipboard -Value $winver
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("Windows Version copied to clipboard", 0, "Windows Version Copied", 64)
    })
$windowsVersion.BackColor = $BGcolor
$windowsVersion.ForeColor = $TextColor
$windowsVersion.ToolTipText = "Current Windows version." + "`nClick to copy Windows version to clipboard."
$outputsuppressed = $menuInfo.DropDownItems.Add($windowsVersion)

#Manufacturer Info Display
$manufacturerInfo.Text = "Manufacturer: " + $manufacturer
$manufacturerInfo.Add_Click({
        Set-Clipboard -Value $manufacturer
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("Manufacturer copied to clipboard", 0, "Manufacturer Copied", 64)
    })
$manufacturerInfo.BackColor = $BGcolor
$manufacturerInfo.ForeColor = $TextColor
$manufacturerInfo.ToolTipText = "Current device manufacturer." + "`nClick to copy manufacturer to clipboard."
$outputsuppressed = $menuInfo.DropDownItems.Add($manufacturerInfo)

#Model Info Display
$modelInfo.Text = "Model: " + $model
$modelInfo.Add_Click({
        Set-Clipboard -Value $model
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("Model copied to clipboard", 0, "Model Copied", 64)
    })
$modelInfo.ToolTipText = "Current device model." + "`nClick to copy model to clipboard."
$modelInfo.BackColor = $BGcolor
$modelInfo.ForeColor = $TextColor
$outputsuppressed = $menuInfo.DropDownItems.Add($modelInfo)

#Domain Info Display
$domainInfo.Text = "Domain: " + $domain
$domainInfo.Add_Click({
        Set-Clipboard -Value $domain
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("Domain copied to clipboard", 0, "Domain Copied", 64)
    })
$domainInfo.ToolTipText = "Current device domain." + "`nClick to copy domain to clipboard."
$domainInfo.BackColor = $BGcolor
$domainInfo.ForeColor = $TextColor
$outputsuppressed = $menuInfo.DropDownItems.Add($domainInfo)

#Storage Info Display
$storageInfo.Text = "Storage: " + $drivespace
$storageInfo.Add_Click({
        Set-Clipboard -Value $drivespace
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("Storage copied to clipboard", 0, "Storage Copied", 64)
    })
$storageInfo.BackColor = $BGcolor
$storageInfo.ForeColor = $TextColor
$storageInfo.ToolTipText = "Current device storage availability." + "`nClick to copy storage to clipboard."
$outputsuppressed = $menuInfo.DropDownItems.Add($storageInfo)

#RAM Info Display
$ramInfo.Text = "RAM: " + $ramCheck + "GB"
$ramInfo.Add_Click({
        Set-Clipboard -Value $ramCheck
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("RAM copied to clipboard", 0, "RAM Copied", 64)
    })
$ramInfo.BackColor = $BGcolor
$ramInfo.ForeColor = $TextColor
$ramInfo.ToolTipText = "Current device RAM." + "`nClick to copy RAM to clipboard."
$outputsuppressed = $menuInfo.DropDownItems.Add($ramInfo)

#CPU Info Display
$cpuInfo.Text = "CPU: " + $cpuCheck
$cpuInfo.Add_Click({
        Set-Clipboard -Value $cpuCheck
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("CPU copied to clipboard", 0, "CPU Copied", 64)
    })
$cpuInfo.BackColor = $BGcolor
$cpuInfo.ForeColor = $TextColor
$cpuInfo.ToolTipText = "Current device CPU." + "`nClick to copy CPU to clipboard."
$outputsuppressed = $menuInfo.DropDownItems.Add($cpuInfo)

#Device Info Print to Text File in C Temp
$deviceInfoPrint.Text = "Print Device Info to Text File"
$deviceInfoPrint.Add_Click({
        $deviceInfo | Out-File -FilePath C:\Temp\DeviceInfo.txt
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("Device Info printed to C:\Temp\DeviceInfo.txt", 0, "Device Info Printed", 64)
    })
$deviceInfoPrint.BackColor = $BGcolor
$deviceInfoPrint.ForeColor = $TextColor
$deviceInfoPrint.ToolTipText = "Prints device info to a text file in C:\Temp." + "`nClick to print device info to text file."
$outputsuppressed = $menuInfo.DropDownItems.Add($deviceInfoPrint)

$deviceInfoClipboard.Text = "Copy Device Info to Clipboard"
$deviceInfoClipboard.Add_Click({
        Set-Clipboard -Value $deviceInfo
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("Device Info copied to clipboard", 0, "Device Info Copied", 64)
    })
$deviceInfoClipboard.BackColor = $BGcolor
$deviceInfoClipboard.ForeColor = $TextColor
$deviceInfoClipboard.ToolTipText = "Copies device info to clipboard." + "`nClick to copy device info to clipboard."
$outputsuppressed = $menuInfo.DropDownItems.Add($deviceInfoClipboard)

#Help Tab
$menuHelp.Text = "Help"
$outputsuppressed = $menu.Items.Add($menuHelp)

#About Button - Displays basic information about the script
$menuAbout.Text = "About"
$menuAbout.Add_Click({
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("This script was created by the Eli Weitzman to assist in simplifying technical tasks.", 0, "About", 64)
    })
$menuAbout.BackColor = $BGcolor
$menuAbout.ForeColor = $TextColor
$outputsuppressed = $menuHelp.DropDownItems.Add($menuAbout)

#Fun Button - It's fun (lol)
$menuFun = New-Object System.Windows.Forms.ToolStripMenuItem
$menuFun.Text = "Fun"
$menuFun.Add_Click({
        #Open a web browser to a fun website
        Start-Process https://www.youtube.com/watch?v=a3Z7zEc7AXQ
    })
$menuFun.BackColor = $BGcolor
$menuFun.ForeColor = $TextColor
$outputsuppressed = $menuHelp.DropDownItems.Add($menuFun)

#Licenses Button - Displays basic license information
$menuLicenses.Text = "Licenses"
$menuLicenses.Add_Click({
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("This application uses code under MIT Open License by Eli Weitzman. For more information, visit our GitHub Repository", 0, "About", 64)
    })
$menuLicenses.BackColor = $BGcolor
$menuLicenses.ForeColor = $TextColor
$outputsuppressed = $menuHelp.DropDownItems.Add($menuLicenses)

#Bug Report Button
$menuBugReport.Text = "Bug Report"
$menuBugReport.Add_Click({
        #Open a web browser to a bug report website
        Start-Process https://github.com/eliweitzman/EnterpriseTechTool/issues
    })
$menuBugReport.BackColor = $BGcolor
$menuBugReport.ForeColor = $TextColor
$outputsuppressed = $menuHelp.DropDownItems.Add($menuBugReport)

#Functions Tab
$menuFunctions.Text = "Functions"
$outputsuppressed = $menu.Items.Add($menuFunctions)

#Launch Driver Updater Button - Launches driver update script and auto updates based on manufacturer - Currently only supports Dell and Lenovo
$launchDriverUpdater.Text = "Launch Driver Updater (CLI)"
$launchDriverUpdater.Add_Click({
        #Launch Driver Updater
        if ($manufacturer -eq "Dell Inc.") {
            Start-Process -Filepath "C:\Program Files (x86)\Dell\CommandUpdate\dcu-cli.exe" -ArgumentList "/applyUpdates -outputLog=C:\Temp\dellUpdateOutput.log" -WorkingDirectory "C:\Program Files (x86)\Dell\CommandUpdate" -PassThru -Verb RunAs
        }
        elseif ($manufacturer -eq "LENOVO") {
            Start-Process "C:\Program Files (x86)\Lenovo\System Update\tvsu.exe" -ArgumentList "/CM -search C -action INSTALL -includerebootpackages 1,3,4 -noreboot" -WorkingDirectory "C:\Program Files (x86)\Lenovo\System Update" -PassThru -Verb RunAs
            $wshell = New-Object -ComObject Wscript.Shell
            $wshell.Popup("Lenovo Updates Completed!", 0, "Driver Updater", 64)
        }
        else {
            $wshell = New-Object -ComObject Wscript.Shell
            $wshell.Popup("Driver Updater not found for this manufacturer", 0, "Driver Updater", 64)
        }
    })
$launchDriverUpdater.BackColor = $BGcolor
$launchDriverUpdater.ForeColor = $TextColor
$outputsuppressed = $menuFunctions.DropDownItems.Add($launchDriverUpdater)

#Launch Driver Updater GUI Button - Launches driver update GUI based on manufacturer - Currently only supports Dell and Lenovo
$launchDriverUpdaterGUI.Text = "Launch Driver Updater (GUI)"
$launchDriverUpdaterGUI.Add_Click({
        #Launch Driver Updater
        if ($manufacturer -eq "Dell Inc.") {
            Start-Process "C:\Program Files\Dell\CommandUpdate\DellCommandUpdate.exe"
        }
        elseif ($manufacturer -eq "LENOVO") {
            Start-Process "C:\Program Files (x86)\Lenovo\System Update\tvsu.exe"
        }
        else {
            $wshell = New-Object -ComObject Wscript.Shell
            $wshell.Popup("Driver Updater not found for this manufacturer", 0, "Driver Updater", 64)
        }
    })
$launchDriverUpdaterGUI.BackColor = $BGcolor
$launchDriverUpdaterGUI.ForeColor = $TextColor
$outputsuppressed = $menuFunctions.DropDownItems.Add($launchDriverUpdaterGUI)

#SFC Scan Button - Runs SFC Scan on the computer
$menuSFCScan.Text = "SFC Scan"
$menuSFCScan.Add_Click({
        #SFC Scan
        Start-Process powershell.exe -ArgumentList "-command sfc /scannow" -PassThru -Verb RunAs
    })
$menuSFCScan.BackColor = $BGcolor
$menuSFCScan.ForeColor = $TextColor
$outputsuppressed = $menuFunctions.DropDownItems.Add($menuSFCScan)

#Suspend BitLocker Button - Suspends BitLocker for one reboot
$menuSuspendBitLocker.Text = "Suspend BitLocker"
$menuSuspendBitLocker.Add_Click({
        #Suspend BitLocker
        Suspend-BitLocker -MountPoint "C:" -RebootCount 1
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("BitLocker suspended for one reboot.", 0, "BitLocker", 64)
    })
$menuSuspendBitLocker.BackColor = $BGcolor
$menuSuspendBitLocker.ForeColor = $TextColor
$outputsuppressed = $menuFunctions.DropDownItems.Add($menuSuspendBitLocker)

#Test Network Button - Tests network connectivity
$menuTestNet.Text = "Test Network"
$menuTestNet.Add_Click({
        #Test Network
        Start-Process powershell.exe -ArgumentList "-command Test-NetConnection -ComputerName google.com" -PassThru -Wait
    })
$menuTestNet.BackColor = $BGcolor
$menuTestNet.ForeColor = $TextColor
$outputsuppressed = $menuFunctions.DropDownItems.Add($menuTestNet)

<#
#Rename Computer Button
$menuRenameComputer.Text = "Rename Computer"
$menuRenameComputer.Add_Click({
    $newname = Read-Host "Enter new computer hostname"
    $renAuth = Read-Host "Enter your username"
    #Rename Computer (run powershell command)
    Start-Process powershell.exe -ArgumentList "-command Rename-Computer -NewName $newname -LocalCredential $renAuth" -PassThru -Verb RunAs
    Start-Process shutdown -argumentlist "-r -t 0" -PassThru
    })
$menuFunctions.DropDownItems.Add($menuRenameComputer)
#>

#Features List Button - Displays a list of features
$menuFeatures.Text = "Features"
$menuFeatures.Add_Click({
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("Current Features:
    - Auto-elevate to admin
    - Clear last Windows login
    - Check for app updates thru WinGet
    - Retreive Local Admin Passwords thru LAPS
    - Force GPUpdate and Intune Sync", 0, "Functions", 64)
    })
$outputsuppressed = $menu.Items.Add($menuFeatures)

#Exit Button
$menuExit.Text = "Exit"
$menuExit.Add_Click({ $Form.Close() })
$outputsuppressed = $menu.Items.Add($menuExit)

#Add all buttons and functions to the GUI menu
$Form.controls.AddRange(@($Logo, $Heading, $ClearLastLogin, $Lapspw, $appUpdate, $PolicyPatch, $menu))

#region Logic 

#endregion

[void]$Form.ShowDialog()

$outputsuppressed