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
    Version:        1.3
    Creation Date:  12-26-22

.LICENSE
    BSD 3-Clause License

    Copyright (c) 2024, Eli Weitzman

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice, this
    list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.

    3. Neither the name of the copyright holder nor the names of its
    contributors may be used to endorse or promote products derived from
    this software without specific prior written permission.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
    AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
    IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
    DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
    FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
    DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
    SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
    OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
    OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

# Create the Ternary Operator since PowerShell 5 doesn't have it
set-alias ?: Invoke-Ternary -Option AllScope -Description "PSCX filter alias"
filter Invoke-Ternary ([scriptblock]$decider, [scriptblock]$ifTrue, [scriptblock]$ifFalse) {
    if (&$decider) { 
        &$ifTrue
    }
    else { 
        &$ifFalse 
    }
}

#Load ETTConfig.json File
$jsonConfigString = Get-Content -Path ".\ETTConfig.json" -ErrorAction SilentlyContinue
$jsonConfig = $jsonConfigString | ConvertFrom-Json

#Import Winforms API for GUI
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

#Build Variables
$ETTVersion = "1.3"
$AutoUpdateCheckerEnabled = (?: { $jsonConfig.AutoUpdateCheckerEnabled -ne $null -and $jsonConfig.AutoUpdateCheckerEnabled -ne "" } { $jsonConfig.AutoUpdateCheckerEnabled } { $true })

## BEGIN INITIAL FLAGS - CHANGE THESE TO MATCH YOUR PREFERENCES

#Admin mode - if auto-elevate is enabled, this will be set to $true. If in EXE mode, this is automatically handled by Windows.
$adminmode = (?: { $jsonConfig.AdminMode -ne $null -and $jsonConfig.AdminMode -ne "" } { $jsonConfig.AdminMode } { $false })

#Set Branding - CHANGE THIS TO MATCH YOUR PREFERENCE
$BrandColor = (?: { $jsonConfig.BrandColor -ne $null -and $jsonConfig.BrandColor -ne "" } { $jsonConfig.BrandColor } { '#023a24' }) #Set the color of the form, currently populated with a hex value.
$LogoLocation = (?: { $jsonConfig.LogoLocation -ne $null -and $jsonConfig.LogoLocation -ne "" } { $jsonConfig.LogoLocation } { $null }) #If you want to use a custom logo, set the path here. Otherwise, leave as $null

#ETT UI Options
$backgroundImagePath = (?: { $jsonConfig.BackgroundImagePath -ne $null -and $jsonConfig.BackgroundImagePath -ne "" } { $jsonConfig.BackgroundImagePath } { "" }) #Set this to a web URL or local path to change the BG image of ETT
$ettApplicationTitle = (?: { $jsonConfig.ETTApplicationTitle -ne $null -and $jsonConfig.ETTApplicationTitle -ne "" } { "$($jsonConfig.ETTApplicationTitle) V$ETTVersion" } { "Eli's Enterprise Tech Tool V$ETTVersion" })
$ettHeaderText = (?: { ($jsonConfig.ETTHeaderText -ne $null -and $jsonConfig.ETTHeaderText -ne "") } { $jsonConfig.ETTHeaderText } { "Enterprise Tech Tool" })
$ettHeaderTextColor = (?: { $jsonConfig.ETTHeaderTextColor -ne $null -and $jsonConfig.ETTHeaderTextColor -ne "" } { [System.Drawing.Color]::FromName($jsonConfig.ETTHeaderTextColor) } { [System.Drawing.Color]::FromName("White") })#Override the color of the ETT header if a BG image is set. Otherwise, it will change based on system theme
$timeout = (?: { $jsonConfig.ApplicationTimeoutEnabled -ne $null -and $jsonConfig.ApplicationTimeoutEnabled -ne "" } { $jsonConfig.ApplicationTimeoutEnabled } { $false }) #Set this to $true to enable a timeout for ETT. Otherwise, set to $false
$timeoutLength = (?: { $jsonConfig.ApplicationTimeoutLength -ne $null -and $jsonConfig.ApplicationTimeoutLength -ne "" } { $jsonConfig.ApplicationTimeoutLength } { 300 }) #Set the length of the timeout in seconds. Default is 300 seconds (5 minutes)

#Custom Toolbox - CHANGE THIS TO MATCH YOUR PREFERENCE
$customTools = (?: { $jsonConfig.EnableCustomTools -ne $null -and $jsonConfig.EnableCustomTools -ne "" } { $jsonConfig.EnableCustomTools } { $true }) #Set this to $true to enable custom functions. Otherwise, set to $false

<#Compliance Thresholds - CHANGE THESE TO MATCH YOUR COMPLIANCE REQUIREMENTS
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#>

#RAM Check
$ramCheckActive = (?: { $jsonConfig.RAMCheckActive -ne $null -and $jsonConfig.RAMCheckActive -ne "" } { $jsonConfig.RAMCheckActive } { $false })
$ramMinimum = (?: { $jsonConfig.RAMCheckMinimum -ne $null -and $jsonConfig.RAMCheckMinimum -ne "" } { $jsonConfig.RAMCheckMinimum } { 8 }) #SET MINIMUM RAM IN GB

#Drivespace Check
$drivespaceCheckActive = (?: { $jsonConfig.DriveSpaceCheckActive -ne $null -and $jsonConfig.DriveSpaceCheckActive -ne "" } { $jsonConfig.DriveSpaceCheckActive } { $false })
$drivespaceMinimum = (?: { $jsonConfig.DriveSpaceCheckMinimum -ne $null -and $jsonConfig.DriveSpaceCheckMinimum -ne "" } { $jsonConfig.DriveSpaceCheckMinimum } { 20 }) #SET MINIMUM DRIVESPACE IN GB

#Windows Version Check
$winverCheckActive = (?: { $jsonConfig.WinVersionCheckActive -ne $null -and $jsonConfig.WinVersionCheckActive -ne "" } { $jsonConfig.WinVersionCheckActive } { $false })
$winverTarget = (?: { $jsonConfig.WinVersionTarget -ne $null -and $jsonConfig.WinVersionTarget -ne "" } { $jsonConfig.WinVersionTarget } { "24H2" }) #SET TARGET WINDOWS VERSION (21h1, 21h2, 22h2)

#Defender Enrollment Check
$defenderEnrollCheckActive = (?: { $jsonConfig.DefenderEnrollCheckActive -ne $null -and $jsonConfig.DefenderEnrollCheckActive -ne "" } { $jsonConfig.DefenderEnrollCheckActive } { $false })

#Azure Information
$azureADTenantId = (?: { $jsonConfig.AzureADTenantId -ne $null -and $jsonConfig.AzureADTenantId -ne "" } { $jsonConfig.AzureADTenantId } { "" })
$lapsAppClientId = (?: { $jsonConfig.LAPSAppClientId -ne $null -and $jsonConfig.LAPSAppClientId -ne "" } { $jsonConfig.LAPSAppClientId } { "" })
$bitLockerAppClientId = (?: { $jsonConfig.BitLockerAppClientId -ne $null -and $jsonConfig.BitLockerAppClientId -ne "" } { $jsonConfig.BitLockerAppClientId } { "" })

#Anime Mode
$animeMode = (?: { $jsonConfig.AnimeMode -ne $null -and $jsonConfig.AnimeMode -ne $false -and $jsonConfig.AnimeMode -ne "" } { $jsonConfig.AnimeMode } { "" })
$animeImageArr = @("https://cache.desktopnexus.com/thumbseg/2451/2451508-bigthumbnail.jpg", "https://wallpapercave.com/wp/wp9498801.jpg", "https://itsaboutanime.files.wordpress.com/2019/12/12-best-anime-wallpapers-in-hd-and-4k-that-you-must-get-now.jpg", "https://i.redd.it/qe5tn9xjubkc1.jpeg","https://images.hdqwalls.com/wallpapers/kawaii-neon-anime-girl-jr.jpg")
if ($animeMode) {
    $selectedAnimeImage = $animeImageArr | Get-Random
    $backgroundImagePath = $selectedAnimeImage
}

<#Custom Functions - Place custom functions below:
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Naming must follow this format in order to work: "custom_FUNCTIONNAME"
#>

#Custom Test Functions
function custom_ExampleFunction {
    $wshell = New-Object -ComObject Wscript.Shell
    $wshell.Popup("This example function was triggered from a Custom Function list click.", 0, "Example Function", 0x1)
}

<#
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
END CUSTOM FUNCTIONS
#>

<#Notification Framework - COMING SOON(TM)

#Set ticketing system - CHANGE THIS TO MATCH YOUR PREFERENCE (Jira or ServiceNow or Email. Null will disable)
$ticketType = $null

#IF Jira is selected, set the Jira URL and issue type here
$jiraURL = $null
$jiraIssueType = $null
$jiraProject = $null


#IF ServiceNow is selected, set the ServiceNow URL, token, and table here
$SNuri = $null
$SNtoken = $null

#For email, set the SMTP server, port, and credentials here (if required), as well as the email address to send to
$emailServer = $null
$emailPort = $null
$emailCreds = $null
$emailSSL = $null
$emailFrom = $null
$emailTo = $null
#>


## END INITIAL FLAGS

#Check Execution Path
if ($MyInvocation.MyCommand.CommandType -eq "ExternalScript") {
    # Powershell script
    $ScriptPath = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
}
else {
    # PS2EXE compiled script
    $ScriptPath = Split-Path -Parent -Path ([Environment]::GetCommandLineArgs()[0])
}

$installType = "Portable"
if (($ScriptPath -eq "C:\Users\$env:UserName\AppData\Local\Programs\Eli's Enterprise Tech Toolkit") -or ($ScriptPath -eq "C:\Program Files (x86)\Eli's Enterprise Tech Toolkit")) {
    #ETT Regular Install
    $installType = "Installed"
}

#Check for updates

if ($AutoUpdateCheckerEnabled -eq $true) {

    # GitHub API endpoint for tags
    $apiUrl = "https://api.github.com/repos/eliweitzman/EnterpriseTechTool/tags"
    # Make a web request to the GitHub API
    try {
        $response = Invoke-RestMethod -Uri $apiUrl -Method Get -ErrorAction SilentlyContinue

        # Extract the name of the latest tag
        $latestTag = $response[0].name

        #Check the tag against our current application version
        $applicationVersion = [System.Version]::new($ETTVersion)
        $githubVersion = [System.Version]::new($latestTag)
    }
    catch {
        #IF Device is offline, don't check for updates, and thus set these to a value that will not trigger an update prompt
        $applicationVersion = $true
        $githubVersion = $true
    }

    #Update Checker
    if ($applicationVersion -lt $githubVersion) {
        $updatePrompt = [System.Windows.Forms.MessageBox]::Show("An update to ETT is available! Would you like to update now?", "Update Available", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Information)
        if ($updatePrompt -eq "Yes") {
            #This is for if an application was installed with Winget, or with the self-extracting installer, and is a regular ETT variant
            if (($installType -eq "Installed")) {
                winget.exe upgrade --id=EliWeitzman.ETT
            }
            #If portable or PS1, refer that an update is available, and if yes, redirect to the repository to download the latest version
            elseif ($installType -eq "Portable") {
                Start-Process "https://github.com/eliweitzman/EnterpriseTechTool"
            }
        }
    }
}

#Determine Dark/Light Mode
# Get the current theme
$theme = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize").AppsUseLightTheme

#Dark/Light Parameters
# If the theme is 0, it is dark mode
if ($theme -eq 0) {
    #DARK MODE
    $BGcolor = 'Black'
    $TextColor = 'White'
    $ButtonTextColor = 'White'
    $BoxColor = $BrandColor
}
else {
    #LIGHT MODE
    $BGcolor = 'WhiteSmoke'
    $TextColor = 'Black'
    $ButtonTextColor = 'White'
    $BoxColor = $BrandColor
}

# Check if the script is running with administrator privileges
$adminmode = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

#Import Drawing API for Shield Icon
Add-Type -AssemblyName System.Drawing
$shieldIconBase64 = "AAABAAEAECAAAAEAIABoBAAAFgAAACgAAAAQAAAAIAAAAAEAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAR0dHYEdHR2AAAAAAAAAAAAAAAAAAAAAAAAAAAA
AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABHR0cQR0dHv0dHR/9HR0f/R0dHv0dHRxAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABHR0cwR0dH70VWXv86ndD/pFgS/1dKPv9HR0fvR0dH
MAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABHR0cwR0dH70JsgP83tPP/Nrv+/8ReAP+7XAT/bk4x/0dHR+9HR0cwAAAAAAAAAAAAAAAAAAAAAAAAAABHR0cwR0dH70JzjP84vf7/N7z+/za7/v/EXwD/xF
4A/8NdAP92Tyz/R0dH70dHRzAAAAAAAAAAAAAAAAAAAAAAR0dHz0Vdaf85vv7/OL3+/zi9/v83vP7/xWAA/8RfAP/EXgD/w10A/15LOv9HR0fPAAAAAAAAAAAAAAAAR0dHYEdHR/89qdz/Or/+/zm+/v84vf7/
OL3+/8VhAP/FYAD/xF8A/8ReAP+sWQ3/R0dH/0dHR2AAAAAAAAAAAEdHR69DdIz/O8D+/zq//v86v/7/Ob7+/zi9/v/GYwD/xWEA/8VgAP/EXwD/xF4A/3ZPLP9HR0evAAAAAAAAAABHR0f/oV8W/8lpAP/IaQ
D/yGcA/8dmAP/HZQD/OL3+/zi9/v83vP7/Nrv+/za7/v87lsX/R0dH/wAAAAAAAAAAR0dH/6ljEv/JawD/yWkA/8hpAP/IZwD/x2YA/zm+/v84vf7/OL3+/ze8/v82u/7/Op7Q/0dHR/8AAAAAAAAAAEdHR//K
bQD/ymwA/8lrAP/JaQD/yGkA/8hnAP86v/7/Ob7+/zi9/v84vf7/N7z+/za7/v9HR0f/AAAAAAAAAABHR0f/y24A/8ptAP/KbAD/yWsA/8lpAP/IaQD/Or/+/zq//v85vv7/OL3+/zi9/v83vP7/R0dH/wAAAA
AAAAAAR0dH/4lbJP+qZBL/ym0A/8psAP/JawD/yWkA/zvA/v86v/7/Or/+/zm+/v88oND/P4Kj/0dHR/8AAAAAAAAAAEdHR79HR0fPR0dH/1hMPv+ZXxv/ymwA/8lrAP88wP7/O8D+/z+Suf9FVl7/R0dH/0dH
R89HR0e/AAAAAAAAAAAAAAAAAAAAAEdHRyBHR0efR0dH/2hQNf+hYBb/QJvF/0Rldf9HR0f/R0dHn0dHRyAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEdHR0BHR0e/R0dH/0dHR/9HR0e/R0dHMA
AAAAAAAAAAAAAAAAAAAAAAAAAA/n/+//gf5//wD0f/4AcAAMADAADAA0f/gAEA/4ABAP+AAQD/gAEA/4ABAP+AAQD/gAEA/4ABAP/gB/7/+B/+/w=="
$shieldIconBytes = [Convert]::FromBase64String($shieldIconBase64)
$shieldMemoryStream = New-Object IO.MemoryStream($shieldIconBytes, 0, $shieldIconBytes.Length)
$shieldMemoryStream.Write($shieldIconBytes, 0, $shieldIconBytes.Length)
$shieldIcon = [System.Drawing.Image]::FromStream($shieldMemoryStream, $true)
#Convert icon to usable in text string (emoji)
$shieldIconEmoji = [char]::ConvertFromUtf32(0x1F6E1)


#Capture Machine Info, and make a loading screen

#Loading Screen
$LoadingForm = New-Object System.Windows.Forms.Form
$LoadingForm.Text = "Loading ETT..."
$LoadingForm.Width = 320
$LoadingForm.Height = 125
$LoadingForm.StartPosition = "CenterScreen"
$LoadingForm.MaximizeBox = $false
$LoadingForm.MinimizeBox = $false
$LoadingForm.ShowIcon = $false
$LoadingForm.TopMost = $true
$LoadingForm.AutoScale = $true
$LoadingForm.BackColor = $BGcolor

#Loading Label
$LoadingLabel = New-Object System.Windows.Forms.Label
$LoadingLabel.Location = New-Object System.Drawing.Point(10, 10)
$LoadingLabel.Width = 280
$LoadingLabel.Height = 20
$LoadingLabel.Text = "Loading..."
$LoadingLabel.Font = New-Object System.Drawing.Font("Segoe UI", 11)
$LoadingLabel.ForeColor = $TextColor
$LoadingLabel.TabIndex = 0
$LoadingLabel.TextAlign = "MiddleCenter"

#Loading Progress Bar
$LoadingProgressBar = New-Object System.Windows.Forms.ProgressBar
$LoadingProgressBar.Location = New-Object System.Drawing.Point(10, 40)
$LoadingProgressBar.Size = New-Object System.Drawing.Size(284, 20)
$LoadingProgressBar.Style = "Marquee"
$LoadingProgressBar.MarqueeAnimationSpeed = 10
$LoadingProgressBar.TabIndex = 1
$LoadingProgressBar.Value = 0

#Add controls to form
$LoadingForm.Controls.Add($LoadingLabel) | Out-Null
$LoadingForm.Controls.Add($LoadingProgressBar) | Out-Null

#Show the form
[void]$LoadingForm.Show()

#Conditions to load
$LoadingLabel.Text = "Getting username..."
$username = whoami.exe
$LoadingProgressBar.Value = 10

$LoadingLabel.Text = "Getting hostname..."
$hostname = HOSTNAME.EXE
$LoadingProgressBar.Value = 20

$LoadingLabel.Text = "Getting Windows Version..."
$winver = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").DisplayVersion
$LoadingProgressBar.Value = 30

$LoadingLabel.Text = "Getting Windows Defender Status..."
$defenderEnrollmentStatus = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\Status" -ErrorAction SilentlyContinue).OnboardingState
$LoadingProgressBar.Value = 35

$LoadingLabel.Text = "Getting Manufacturer..."
$manufacturer = Get-WmiObject -Class Win32_ComputerSystemProduct | Select-Object -ExpandProperty Vendor
$LoadingProgressBar.Value = 40

$LoadingLabel.Text = "Getting Model..."
$model = Get-WmiObject -Class Win32_ComputerSystem -Property Model | Select-Object -ExpandProperty Model
$LoadingProgressBar.Value = 50

$LoadingLabel.Text = "Checking Hosts File..."
$hostsHash = (Get-FileHash "C:\Windows\System32\Drivers\etc\hosts").Hash
$hostsCompliant = $true
$hostsText = "Host File Integrity: Unmodified"
if ($hostsHash -ne "2D6BDFB341BE3A6234B24742377F93AA7C7CFB0D9FD64EFA9282C87852E57085") {
    $hostsCompliant = $false
    $hostsText = "Host File Integrity: Modified"
}
$LoadingProgressBar.Value = 55

$LoadingLabel.Text = "Getting Domain..."
$domain = (Get-CIMInstance -ClassName Win32_ComputerSystem).Domain
$LoadingProgressBar.Value = 60

$LoadingLabel.Text = "Getting Drive Info..."
$drivespace = Get-WmiObject -ComputerName localhost -Class win32_logicaldisk | Where-Object caption -eq "C:" | foreach-object { Write-Output " $($_.caption) $('{0:N2}' -f ($_.Size/1gb)) GB total, $('{0:N2}' -f ($_.FreeSpace/1gb)) GB free " }
$freedrivespace = Get-WmiObject -ComputerName localhost -Class win32_logicaldisk | Where-Object caption -eq "C:" | foreach-object { Write-Output $('{0:N2}' -f ($_.FreeSpace / 1gb)) }
$LoadingProgressBar.Value = 70

$LoadingLabel.Text = "Getting RAM Info..."
$ramCheck = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum / 1gb
$LoadingProgressBar.Value = 80

$LoadingLabel.Text = "Getting Defender Enrollment Status..."
$checkDefenderEnroll = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows Advanced Threat Protection\Status" -ErrorAction SilentlyContinue).OnboardingState
if ($checkDefenderEnroll -eq 1) {
    $defenderEnrollStatus = $true
}
else {
    $defenderEnrollStatus = $false
}
$LoadingProgressBar.Value = 82

$loadingLabel.Text = "Getting RSAT Info..."
Import-Module ActiveDirectory -ErrorAction SilentlyContinue
if (Get-Module -Name "ActiveDirectory") {
    $rsatInfo = "Installed"
}
else {
    $rsatInfo = "NotPresent"
}
$LoadingProgressBar.Value = 85

$LoadingLabel.Text = "Getting CPU Info..."
$cpuCheck = Get-WmiObject -Class Win32_Processor | Select-Object -ExpandProperty Name
$LoadingProgressBar.Value = 90

$LoadingLabel.Text = "Getting Device Type..."
$devicetype = (Get-WmiObject -Class Win32_ComputerSystem -Property PCSystemType).PCSystemType
$LoadingProgressBar.Value = 95

$LoadingLabel.Text = "Getting Drive Type..."
$drivetype = Get-PhysicalDisk | Where-Object DeviceID -eq 0 | Select-Object -ExpandProperty MediaType
$LoadingProgressBar.Value = 100



$LoadingLabel.Text = "Loading Complete!"

#Close Loading Screen
$LoadingForm.Close()

$complianceFlag = $false

<#EXPERIMENTAL NEW INFO METHOD
# Capture machine info
$computerInfo = Get-ComputerInfo
$username = $computerInfo.CSUserName
$hostname = $computerInfo.CSName
$winver = $computerInfo.WindowsVersion
$manufacturer = $computerInfo.CSManufacturer
$model = $computerInfo.Model
$domain = $computerInfo.Domain
$drivespace = Get-Volume -DriveLetter C | Select-Object -Property DriveLetter, @{Name='TotalSizeGB';Expression={[math]::Round($_.Size/1GB, 2)}}, @{Name='FreeSpaceGB';Expression={[math]::Round($_.SizeRemaining/1GB, 2)}} | Format-Table -HideTableHeaders | Out-String
$ramCheck = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum / 1gb
$cpuCheck = (Get-Process -Id $PID).ProcessorName
$drivetype = (Get-PhysicalDisk | Where-Object DeviceID -eq 0).MediaType
$complianceFlag = $false#>


#MiniTools Dot Sourcing - For development purpose only. DOT Sourcing doesn't work correctly with ps2exe.
$Dependencies = "MiniClients\ADLookup.ps1", "MiniClients\LAPSToolV2.ps1", "MiniClients\BitlockerToolV2.ps1", "PSAssets\ToolboxFunctions.ps1", "PSAssets\GenericToolWindow.ps1", ".\MiniClients\SettingsMenu.ps1"
$Dependencies | ForEach-Object {
    try {
        $psFile = ".\$($_)"
        . $psFile
    }
    catch {
        # Do Nothing Here. We will always land here in a compiled version of ETT.
    }
}

#Device Compliance Checks
#RAM Check
if ($ramCheckActive -eq $true) {
    if ($ramCheck -ge $ramMinimum) {
        $complianceStatus = 'Compliant'
        $ramCompliant = $true
    }
    else {
        $complianceStatus = 'Non-Compliant'
        $ramCompliant = $false
        $complianceFlag = $true
    }
}
else {
    $ramCompliant = $true
}

#Drivespace Check
if ($drivespaceCheckActive -eq $true) {
    if ($freedrivespace -ge $drivespaceMinimum) {
        $complianceStatus = 'Compliant'
        $drivespaceCompliant = $true
    }
    else {
        $complianceStatus = 'Non-Compliant'
        $drivespaceCompliant = $false
        $complianceFlag = $true
    }
}
else {
    $drivespaceCompliant = $true
}

#Windows Version Check
if ($winverCheckActive -eq $true) {
    if ($winver -eq $winverTarget) {
        $complianceStatus = 'Compliant'
        $winverCompliant = $true
    }
    else {
        $complianceStatus = 'Non-Compliant'
        $winverCompliant = $false
        $complianceFlag = $true
    }
}
else {
    $winverCompliant = $true
}

#Defender Enrollment Check
if ($defenderEnrollCheckActive -eq $true) {
    if ($defenderEnrollStatus -eq $true) {
        $complianceStatus = 'Compliant'
        $defenderEnrollCompliant = $true
    }
    else {
        $complianceStatus = 'Non-Compliant'
        $defenderEnrollCompliant = $false
        $complianceFlag = $true
    }
}
else {
    $defenderEnrollCompliant = $true
}

#Device Type conversion
#A switch statement to convert the devicetype variable to a human readable format in a new systemType variable
switch ($devicetype) {
    0 { $systemType = "Unspecified" }
    1 { $systemType = "Desktop" }
    2 { $systemType = "Mobile" }
    3 { $systemType = "Workstation" }
    4 { $systemType = "Enterprise Server" }
    5 { $systemType = "SOHO Server" }
    6 { $systemType = "Appliance PC" }
    7 { $systemType = "Performance Server" }
    8 { $systemType = "Slate" }
    default { $systemType = "Unknown" }
}

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
Defender ATP Enrollment: $defenderEnrollStatus
Hosts File: $hostsText
System Type: $systemType
Storage: $drivespace
Storage Type: $drivetype
"@

function notificationPush {
    param (
        #Get message body
        [Parameter(Mandatory = $true)]
        [string]$messageBody
    )
    #Create notification framework
    if ($ticketType = "Jira") {
        #Create a title for the ticket using the current time
        $ticketTitle = "ETT Report " + (Get-Date -Format "MM/dd/yyyy HH:mm:ss") + " for " + $hostname

        #Assume the ticket body is the device info dump
        $ticketBody = $messageBody

        #Create a JSON object for the ticket
        $jiraJSON = @"
{
    "fields": {
       "project":
       {
          "key": "$jiraProject"
       },
       "summary": "$ticketTitle",
       "description": "$ticketBody",
       "issuetype": {
          "name": "$jiraIssueType"
         }
    }

"@
    
        #Send the ticket to Jira
        Invoke-RestMethod -Uri $jiraURL -Method Post -Headers $jiraHeaders -Body $jiraJSON -ContentType "application/json"

    }
    elseif ($ticketType = "ServiceNow") {
    
        #Create a title for the ticket using the current time
        $ticketTitle = "ETT Report " + (Get-Date -Format "MM/dd/yyyy HH:mm:ss") + " for " + $hostname

        #Assume the ticket body is the device info dump
        $ticketBody = $messageBody

        # Define headers
        $headers = @{
            Authorization  = "Bearer $SNtoken"
            "Content-Type" = "application/json"
        }

        # Define the body
        $body = @{
            short_description = $ticketTitle
            description       = $ticketBody
            urgency           = 1 # 1 - High, 2 - Medium, 3 - Low
            impact            = 1 # 1 - High, 2 - Medium, 3 - Low
        } | ConvertTo-Json


        # Send the request
        Invoke-RestMethod -Uri $SNuri -Method Post -Body $body -Headers $headers

    }
    elseif ($ticketType = "Email") {
        #Create a title for the ticket using the current time
        $ticketTitle = "ETT Report " + (Get-Date -Format "MM/dd/yyyy HH:mm:ss") + " for " + $hostname

        #Assume the ticket body is the device info dump
        $ticketBody = $messageBody

        #Send the ticket to email
        if ($emailSSL -eq $true) {
            Send-MailMessage -To $emailTo -From $emailFrom -Subject $ticketTitle -Body $ticketBody -SmtpServer $emailServer -Port $emailPort -UseSsl -Credential $emailCreds
        }
        elseif ($emailSSL -eq $false) {
            Send-MailMessage -To $emailTo -From $emailFrom -Subject $ticketTitle -Body $ticketBody -SmtpServer $emailServer -Port $emailPort -Credential $emailCreds
        }
        elseif ($null -eq $emailSSL) {
            Send-MailMessage -To $emailTo -From $emailFrom -Subject $ticketTitle -Body $ticketBody -SmtpServer $emailServer -Port $emailPort
        }
        elseif ($null -eq $emailPort) {
            Send-MailMessage -To $emailTo -From $emailFrom -Subject $ticketTitle -Body $ticketBody -SmtpServer $emailServer
        }
        elseif ($null -eq $emailServer) {
            Send-MailMessage -To $emailTo -From $emailFrom -Subject $ticketTitle -Body $ticketBody
        }
        elseif ($null -eq $emailFrom) {
            Send-MailMessage -To $emailTo -Subject $ticketTitle -Body $ticketBody -SmtpServer $emailServer
        }
        elseif ($null -eq $emailTo) {
            #Return an error if the emailTo field is null
            $wshell = New-Object -ComObject Wscript.Shell
            $wshell.Popup("Email To field is null. Please check your configuration.", 0, "Error", 0x1)
        }

    }
    else {
        #Do nothing
    }
    
}

function Create-ETTButton {
    param(
        [Parameter(Position = 0, mandatory = $true)]
        $ButtonText,
        [Parameter(Position = 1, mandatory = $true)]
        $ButtonWidth,
        [Parameter(Position = 2, mandatory = $true)]
        $ButtonHeight,
        [Parameter(Position = 3, mandatory = $true)]
        $ButtonXPosition,
        [Parameter(Position = 4, mandatory = $true)]
        $ButtonYPosition,
        [Parameter(Position = 5, mandatory = $true)]
        $ScriptBlock
    )
    $tmpButton = New-Object system.Windows.Forms.Button
    $tmpButton.text = $ButtonText
    $tmpButton.width = $ButtonWidth
    $tmpButton.height = $ButtonHeight
    $tmpButton.Anchor = 'top'
    $tmpButton.location = New-Object System.Drawing.Point($ButtonXPosition, $ButtonYPosition)
    $tmpButton.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
    $tmpButton.ForeColor = $ButtonTextColor
    $tmpButton.BackColor = $BoxColor

    #Enable clicking to run the action above
    $tmpButton.Add_Click($ScriptBlock)
    return $tmpButton
}

function Create-ToolboxListItem {
    param(
        $DisplayName,
        $Description,
        $Tab,
        $RequireAdmin,
        $ScriptBlock
    )
    $tmpObject = [PSCustomObject]@{ 
        displayName  = $DisplayName
        description  = $Description
        tab          = $Tab
        requireAdmin = $RequireAdmin
        codeBlock    = $ScriptBlock
    }
    if ($RequireAdmin -ne $null -and $RequireAdmin -eq $true) {
        $tmpObject.displayName = "$DisplayName $shieldIconEmoji"
    }
    return $tmpObject
}

#Constructs a new tab and returns the List object of created tab
function Create-ToolboxTabPage {
    param(
        [Parameter(Position = 0, mandatory = $true)]
        $PageName,
        [Parameter(Position = 1, mandatory = $false)]
        [System.Collections.ArrayList]$ToolboxItemsArray
    )
    #Construct Tab Page
    $tmpTab = New-Object System.Windows.Forms.TabPage
    $tmpTab.text = $PageName
    $tmpTab.Font = New-Object System.Drawing.Font('Segoe UI', 10)
    $tmpTab.ForeColor = $TextColor
    $tmpTab.BackColor = $BGcolor
    [void]$ToolboxMenu.Controls.Add($tmpTab)

    #Construct List
    $tmpList = New-Object System.Windows.Forms.Listbox
    $tmpList.Width = 312
    $tmpList.height = 259
    $tmpList.location = New-Object System.Drawing.Point(0, 0)
    $tmpList.Font = New-Object System.Drawing.Font('Segoe UI', 10)
    $tmpList.ForeColor = $TextColor
    $tmpList.BackColor = $BGcolor
    $tmpList.SelectionMode = "One"
    $tmpTab.Controls.Add($tmpList)
    $tmpList.DataSource = $ToolboxItemsArray
    $tmpList.DisplayMember = "displayName"
    $tmpList.ValueMember = "codeBlock"
    
    return $tmpList
}

#Create main frame (REMEMBER TO ITERATE VERSION NUMBER ON BUILD CHANGES)
$ETT = New-Object System.Windows.Forms.Form
$ETT.ClientSize = New-Object System.Drawing.Point(850, 330)
$ETT.text = "$ettApplicationTitle [Admin Mode: $adminmode]"
$ETT.StartPosition = 'CenterScreen'
$ETT.MaximizeBox = $false
$ETT.MaximumSize = $ETT.Size
$ETT.MinimumSize = $ETT.Size
$ETT.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($PSHOME + "\powershell.exe")
$ETT.TopMost = $false
$ETT.BackColor = $BGcolor

#Check to see if we have a BG Image, if we do, apply it.
if ($backgroundImagePath -ne "") {
    $wc = New-Object System.Net.WebClient
    $wcStream = $wc.OpenRead($backgroundImagePath)
    $Image = [system.drawing.image]::FromStream($wcStream)
    $ETT.BackgroundImage = $Image
    $ETT.BackgroundImageLayout = [System.Windows.Forms.ImageLayout]::Stretch
}

#Import and load in logo icon
$Logo = New-Object System.Windows.Forms.PictureBox
$Logo.width = 126
$Logo.height = 73
$Logo.location = New-Object System.Drawing.Point(377, 29)
$Logo.imageLocation = $LogoLocation
$Logo.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::zoom
$Logo.BackColor = [System.Drawing.Color]::FromName("Transparent")
if ($null -eq $LogoLocation) {
    $Logo.Visible = $false
}

$Heading = New-Object System.Windows.Forms.Label
$Heading.text = $ettHeaderText
$Heading.BackColor = [System.Drawing.Color]::FromName("Transparent")
$Heading.AutoSize = $true
$Heading.width = 25
$Heading.height = 10
#IF Logo is null, center the heading
if ($null -eq $LogoLocation) {
    $Heading.location = New-Object System.Drawing.Point(90, 47)
}
else {
    $Heading.location = New-Object System.Drawing.Point(40, 47)
}

$Heading.Font = New-Object System.Drawing.Font('Segoe UI', 25, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
$Heading.ForeColor = $TextColor
if ($null -ne $ETT.BackgroundImage) {
    $Heading.ForeColor = $ettHeaderTextColor
}

#Create Toast Notification Stack
$ToastStack = New-Object System.Windows.Forms.NotifyIcon
$Path = 'C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe'
$ToastStack.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$ToastStack.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
$ToastStack.BalloonTipTitle = $ettApplicationTitle
$ToastStack.BalloonTipText = "Welcome to $ettApplicationTitle!"
$ToastStack.Visible = $true
$ToastStack.ShowBalloonTip(5000)

#IF Compliance Flag is true, add a flyout notification
if ($complianceFlag -eq $true) {
    $ToastStack.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Error
    $ToastStack.BalloonTipTitle = $ettApplicationTitle
    $ToastStack.BalloonTipText = "This device is non-compliant!"
    $ToastStack.Visible = $true
    $ToastStack.ShowBalloonTip(5000)
}

#Create App Buttons
$ClearLastLogin = Create-ETTButton -ButtonText "Clear Last Login" -ButtonWidth 237 -ButtonHeight 89 -ButtonXPosition 13 -ButtonYPosition 117 -ScriptBlock { ClearLastLogin -adminmode $adminmode -ToastStack $ToastStack }
$Lapspw = Create-ETTButton -ButtonText "Get LAPS Password" -ButtonWidth 237 -ButtonHeight 89 -ButtonXPosition 267 -ButtonYPosition 117 -ScriptBlock { Open-LAPSToolWindow }
$appUpdate = Create-ETTButton -ButtonText "Update Apps (Winget)" -ButtonWidth 237 -ButtonHeight 89 -ButtonXPosition 13 -ButtonYPosition 219 -ScriptBlock { Start-WingetAppUpdates }
$PolicyPatch = Create-ETTButton -ButtonText "Windows Policy Update" -ButtonWidth 237 -ButtonHeight 89 -ButtonXPosition 266 -ButtonYPosition 219 -ScriptBlock { Start-PolicyPatch }

#"The Toolbox" - a side menu for additional tools

#Title
$ToolboxTitle = New-Object System.Windows.Forms.Label
$ToolboxTitle.text = "The Toolbox"
$ToolboxTitle.AutoSize = $true
$ToolboxTitle.width = 25
$ToolboxTitle.height = 10
$ToolboxTitle.location = New-Object System.Drawing.Point(600, 10)
$ToolboxTitle.Font = New-Object System.Drawing.Font('Segoe UI', 16, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
$ToolboxTitle.ForeColor = $TextColor
$ToolboxTitle.BackColor = [System.Drawing.Color]::FromName("Transparent")
$ETT.Controls.Add($ToolboxTitle)

#Tabbed Menu Box for Toolbox
$ToolboxMenu = New-Object System.Windows.Forms.TabControl
$ToolboxMenu.width = 320
$ToolboxMenu.height = 275
$ToolboxMenu.location = New-Object System.Drawing.Point(520, 45)
$ToolboxMenu.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
$ToolboxMenu.ForeColor = $TextColor
$ToolboxMenu.BackColor = $BGcolor
$ETT.Controls.Add($ToolboxMenu) | Out-Null

#Tab 1 - Actions Tab Creation
$ActionsTabArray = New-Object System.Collections.ArrayList
[void]$ActionsTabArray.Add((Create-ToolboxListItem -DisplayName "Driver Updater (GUI)" -ScriptBlock { Start-DriverUpdateGUI -manufacturer $manufacturer }))
[void]$ActionsTabArray.Add((Create-ToolboxListItem -DisplayName "Driver Updater (CLI)" -ScriptBlock { Start-DriverUpdateCLI  -manufacturer $manufacturer }))
[void]$ActionsTabArray.Add((Create-ToolboxListItem -DisplayName "SFC Scan" -RequireAdmin $true -ScriptBlock { Start-SFCScan }))
[void]$ActionsTabArray.Add((Create-ToolboxListItem -DisplayName "Suspend Bitlocker" -RequireAdmin $true -ScriptBlock { Start-SuspendBitlockerAction -adminmode $adminmode }))
[void]$ActionsTabArray.Add((Create-ToolboxListItem -DisplayName "Test Network" -ScriptBlock { Start-NetworkTest }))
[void]$ActionsTabArray.Add((Create-ToolboxListItem -DisplayName "WiFi Diagnostics" -RequireAdmin $true -ScriptBlock { Start-WiFiDiagnostics -adminmode $adminmode }))
[void]$ActionsTabArray.Add((Create-ToolboxListItem -DisplayName "Battery Diagnostics" -RequireAdmin $true -ScriptBlock { Start-BatteryDiagnostics -adminmode $adminmode }))
[void]$ActionsTabArray.Add((Create-ToolboxListItem -DisplayName "Quick Reboot" -ScriptBlock { QuickReboot }))
$ActionsTab = Create-ToolboxTabPage -PageName "Actions" -ToolboxItemsArray $ActionsTabArray
$ActionsTab.Add_Click({
        $runThis = [ScriptBlock]::Create($ActionsTab.SelectedValue)
        &$runThis
    })

#Tab 2 - Windows Tab Creation
$WindowsTabArray = New-Object System.Collections.ArrayList
[void]$WindowsTabArray.Add((Create-ToolboxListItem -DisplayName "Windows Update - Full Sweep" -ScriptBlock { CheckForWindowsUpdates -windowTitle "All Windows Updates" -noUpdatesMessage "No updates available." -updateSearchQuery "IsHidden=0 and IsInstalled=0" }))
[void]$WindowsTabArray.Add((Create-ToolboxListItem -DisplayName "Windows Update - Defender Only" -ScriptBlock { CheckForWindowsUpdates -windowTitle "Windows Defender Definition Updates" -noUpdatesMessage "No Windows Defender Definition updates found." -updateSearchQuery "IsInstalled=0 and Type='Software' and IsHidden=0 and BrowseOnly=0 and AutoSelectOnWebSites=1 and CategoryIDs contains '8c3fcc84-7410-4a95-8b89-a166a0190486'" }))
[void]$WindowsTabArray.Add((Create-ToolboxListItem -DisplayName "Get Windows Activation" -ScriptBlock { Get-WindowsActivationKey }))
[void]$WindowsTabArray.Add((Create-ToolboxListItem -DisplayName "Get Windows Activation Type" -ScriptBlock { Get-WindowsActivationType }))
$WindowsTab = Create-ToolboxTabPage -PageName "Windows" -ToolboxItemsArray $WindowsTabArray
$WindowsTab.Add_Click({
        $runThis = [ScriptBlock]::Create($WindowsTab.SelectedValue)
        &$runThis
    })

#Tab 3 - Security Tab Creation
$SecurityTabArray = New-Object System.Collections.ArrayList
[void]$SecurityTabArray.Add((Create-ToolboxListItem -DisplayName "$(Get-HostsFileIntegrity)" -ScriptBlock {}))
$SecurityTab = Create-ToolboxTabPage -PageName "Security" -ToolboxItemsArray $SecurityTabArray
$SecurityTab.Add_Click({
        $runThis = [ScriptBlock]::Create($SecurityTab.SelectedValue)
        &$runThis
    })

#Tab 4 - SCCM (if enabled) Tab Creation

#Check to see if the SCCM client is installed and we have the required WMI class
$sccmClass = Get-WmiObject -Class "SMS_Client" -List -Namespace "root\CCM" -ErrorAction SilentlyContinue
$sccmClassExists = $sccmClass -ne $null

if ($sccmClassExists) {
    $SCCMTabArray = New-Object System.Collections.ArrayList
    [void]$SCCMTabArray.Add((Create-ToolboxListItem -DisplayName "Application Deployment Evaluation Cycle" -ScriptBlock { Start-SCCMClientFunction -TriggerScheduleName "Application Deployment Evaluation Cycle" -TriggerScheduleGUID "{00000000-0000-0000-0000-000000000121}" }))
    [void]$SCCMTabArray.Add((Create-ToolboxListItem -DisplayName "Discovery Data Collection Cycle" -ScriptBlock { Start-SCCMClientFunction -TriggerScheduleName "Discovery Data Collection Cycle" -TriggerScheduleGUID "{00000000-0000-0000-0000-000000000103}" }))
    [void]$SCCMTabArray.Add((Create-ToolboxListItem -DisplayName "File Collection Cycle" -ScriptBlock { Start-SCCMClientFunction -TriggerScheduleName "File Collection Cycle" -TriggerScheduleGUID "{00000000-0000-0000-0000-000000000104}" }))
    [void]$SCCMTabArray.Add((Create-ToolboxListItem -DisplayName "Hardware Inventory Cycle" -ScriptBlock { Start-SCCMClientFunction -TriggerScheduleName "Hardware Inventory Cycle" -TriggerScheduleGUID "{00000000-0000-0000-0000-000000000001}" }))
    [void]$SCCMTabArray.Add((Create-ToolboxListItem -DisplayName "Machine Policy Retrieval" -ScriptBlock { Start-SCCMClientFunction -TriggerScheduleName "Machine Policy Retrieval" -TriggerScheduleGUID "{00000000-0000-0000-0000-000000000021}" }))
    [void]$SCCMTabArray.Add((Create-ToolboxListItem -DisplayName "Machine Policy Evaluation Cycle" -ScriptBlock { Start-SCCMClientFunction -TriggerScheduleName "Machine Policy Evaluation Cycle" -TriggerScheduleGUID "{00000000-0000-0000-0000-000000000022}" }))
    [void]$SCCMTabArray.Add((Create-ToolboxListItem -DisplayName "Software Inventory Cycle" -ScriptBlock { Start-SCCMClientFunction -TriggerScheduleName "Software Inventory Cycle" -TriggerScheduleGUID "{00000000-0000-0000-0000-000000000002}" }))
    [void]$SCCMTabArray.Add((Create-ToolboxListItem -DisplayName "Software Metering Usage Report Cycle" -ScriptBlock { Start-SCCMClientFunction -TriggerScheduleName "Software Metering Usage Report Cycle" -TriggerScheduleGUID "{00000000-0000-0000-0000-000000000106}" }))
    [void]$SCCMTabArray.Add((Create-ToolboxListItem -DisplayName "User Policy Retrieval" -ScriptBlock { Start-SCCMClientFunction -TriggerScheduleName "User Policy Retrieval" -TriggerScheduleGUID "{00000000-0000-0000-0000-000000000026}" }))
    [void]$SCCMTabArray.Add((Create-ToolboxListItem -DisplayName "User Policy Evaluation Cycle" -ScriptBlock { Start-SCCMClientFunction -TriggerScheduleName "User Policy Evaluation Cycle" -TriggerScheduleGUID "{00000000-0000-0000-0000-000000000027}" }))
    [void]$SCCMTabArray.Add((Create-ToolboxListItem -DisplayName "Windows Installer Source List Update Cycle" -ScriptBlock { Start-SCCMClientFunction -TriggerScheduleName "Windows Installer Source List Update Cycle" -TriggerScheduleGUID "{00000000-0000-0000-0000-000000000107}" }))
    $SCCMTab = Create-ToolboxTabPage -PageName "SCCM" -ToolboxItemsArray $SCCMTabArray
    $SCCMTab.Add_Click({
            $runThis = [ScriptBlock]::Create($SCCMTab.SelectedValue)
            &$runThis
        })
}

#Tab 5 - AD Tab Creation (Centered Text for title) - if RSAT is installed

#Check to see if RSAT is installed
if ($rsatInfo -eq "Installed") {
    $ADTabArray = New-Object System.Collections.ArrayList
    [void]$ADTabArray.Add((Create-ToolboxListItem -DisplayName "Launch AD Explorer" -ScriptBlock { ADLookup -BackgroundColor $BGcolor -WindowTextColor $TextColor -BrandColor $BrandColor -ButtonTextColor $ButtonTextColor }))
    [void]$ADTabArray.Add((Create-ToolboxListItem -DisplayName "Get Bitlocker Recovery Key" -ScriptBlock { Open-BitLockerRecoveryWindow }))
    $ADTab = Create-ToolboxTabPage -PageName "AD" -ToolboxItemsArray $ADTabArray
    $ADTab.Add_Click({
            $runThis = [ScriptBlock]::Create($ADTab.SelectedValue)
            &$runThis
        })
}

#Tab 6 - Custom Tools Tab Creation
if ($customTools -eq $true) {
    $CustomTabArray = New-Object System.Collections.ArrayList
    $toolboxIcon = [char]::ConvertFromUtf32(0x1F9F0)

    #Process hardcoded Custom Functions
    $userFunctions = Get-Command | Where-Object { $_.CommandType -eq 'Function' -and $_.Name -like 'custom_*' }
    ForEach ($func in $userFunctions) {
        $tmpObject = Create-ToolboxListItem -DisplayName $($toolboxIcon + " " + $func.Name) -ScriptBlock $func.Name
        [void]$CustomTabArray.Add($tmpObject)
    }

    #Process Config File Custom Functions
    if ($jsonConfig.CustomFunctions -ne $null) {
        ForEach ($customFunction in $jsonConfig.CustomFunctions) {
            $customFunctionDisplayName = "$toolboxIcon $($customFunction.displayName)"
            $tmpObject = Create-ToolboxListItem -DisplayName $customFunctionDisplayName -Description $customFunction.description -Tab $customFunction.tab -RequireAdmin $customFunction.requireAdmin -ScriptBlock $customFunction.codeBlock
            [void]$CustomTabArray.Add($tmpObject)
        }
    }

    #Create the Custom Tab GUI
    $CustomTab = Create-ToolboxTabPage -PageName "Custom" -ToolboxItemsArray $CustomTabArray
    $CustomTab.Add_Click({
            $runThis = [ScriptBlock]::Create($CustomTab.SelectedValue)
            &$runThis
        })
}

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
$devicetypeInfo = New-Object System.Windows.Forms.ToolStripMenuItem
$domainInfo = New-Object System.Windows.Forms.ToolStripMenuItem
$storageInfo = New-Object System.Windows.Forms.ToolStripMenuItem
$ramInfo = New-Object System.Windows.Forms.ToolStripMenuItem
$cpuInfo = New-Object System.Windows.Forms.ToolStripMenuItem
$adminInfo = New-Object System.Windows.Forms.ToolStripMenuItem
$securityInfo = New-Object System.Windows.Forms.ToolStripMenuItem
$hostsInfo = New-Object System.Windows.Forms.ToolStripMenuItem
$defenderInfo = New-Object System.Windows.Forms.ToolStripMenuItem
$deviceInfoPrint = New-Object System.Windows.Forms.ToolStripMenuItem
$deviceInfoClipboard = New-Object System.Windows.Forms.ToolStripMenuItem
$deviceInfoTicket = New-Object System.Windows.Forms.ToolStripMenuItem

#HELP TAB
$menuHelp = New-Object System.Windows.Forms.ToolStripMenuItem
$menuAbout = New-Object System.Windows.Forms.ToolStripMenuItem
$menuBugReport = New-Object System.Windows.Forms.ToolStripMenuItem
$menuLicenses = New-Object System.Windows.Forms.ToolStripMenuItem
$menuGitHub = New-Object System.Windows.Forms.ToolStripMenuItem

#One-Off Tabs
$menuSettings = New-Object System.Windows.Forms.ToolStripMenuItem
$menuExit = New-Object System.Windows.Forms.ToolStripMenuItem


#Keyboard Shortcuts

#CTRL + P to run deviceInfoPrint
$deviceInfoPrint.ShortcutKeys = [System.Windows.Forms.Keys]::Control + [System.Windows.Forms.Keys]::P
$deviceInfoPrint.ShortcutKeyDisplayString = "CTRL + P"

#CTRL + C to run deviceInfoClipboard
$deviceInfoClipboard.ShortcutKeys = [System.Windows.Forms.Keys]::Control + [System.Windows.Forms.Keys]::C
$deviceInfoClipboard.ShortcutKeyDisplayString = "CTRL + C"

#CTRL + Shift + R to run menuRenameComputer
#$menuRenameComputer.ShortcutKeys = [System.Windows.Forms.Keys]::Control + [System.Windows.Forms.Keys]::Shift + [System.Windows.Forms.Keys]::R
#$menuRenameComputer.ShortcutKeyDisplayString = "CTRL + SHIFT + R"

#Assigning tab menu items

#Info Tab
$menuInfo.Text = "Info"
[void]$menu.Items.Add($menuInfo)
#Set tab color to red if compliance is not met
if ($compliance -eq "Compliant") {
    $menuInfo.BackColor = $BGcolor
}
elseif ($compliance -eq "Non-Compliant") {
    $menuInfo.BackColor = 'Red'
}

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
[void]$menuInfo.DropDownItems.Add($menuWhoami)

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
[void]$menuInfo.DropDownItems.Add($menuHostname)

#Windows Version Display
$windowsVersion.Text = "Windows Version: " + $winver
$windowsVersion.Add_Click({
        Set-Clipboard -Value $winver
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("Windows Version copied to clipboard", 0, "Windows Version Copied", 64)
    })
if ($winverCompliant -eq $false) {
    $windowsVersion.BackColor = 'Red'
    $windowsVersion.ForeColor = 'White'
}
else {
    $windowsVersion.BackColor = $BGcolor
    $windowsVersion.ForeColor = $TextColor
}
$windowsVersion.ToolTipText = "Current Windows version." + "`nClick to copy Windows version to clipboard."
[void]$menuInfo.DropDownItems.Add($windowsVersion)

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
[void]$menuInfo.DropDownItems.Add($manufacturerInfo)

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
[void]$menuInfo.DropDownItems.Add($modelInfo)

#Device Type Info Display
$devicetypeInfo.Text = "Device Type: " + $systemType
$devicetypeInfo.Add_Click({
        Set-Clipboard -Value $systemType
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("Device Type copied to clipboard", 0, "Device Type Copied", 64)
    })
$devicetypeInfo.ToolTipText = "Current device type." + "`nClick to copy device type to clipboard."
$devicetypeInfo.BackColor = $BGcolor
$devicetypeInfo.ForeColor = $TextColor
[void]$menuInfo.DropDownItems.Add($devicetypeInfo)

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
[void]$menuInfo.DropDownItems.Add($domainInfo)

#Storage Info Display
$storageInfo.Text = "Storage: " + $drivespace
$storageInfo.Add_Click({
        Set-Clipboard -Value $drivespace
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("Storage copied to clipboard", 0, "Storage Copied", 64)
    })

if ($drivespaceCompliant -eq $false) {
    #Set color to red if storage check fails
    $storageInfo.BackColor = 'Red'
    $storageInfo.ForeColor = 'White'
}
else {
    $storageInfo.BackColor = $BGcolor
    $storageInfo.ForeColor = $TextColor
}
$storageInfo.ToolTipText = "Current device storage availability." + "`nClick to copy storage to clipboard."
[void]$menuInfo.DropDownItems.Add($storageInfo)

#RAM Info Display
$ramInfo.Text = "RAM: " + $ramCheck + "GB"
$ramInfo.Add_Click({
        Set-Clipboard -Value $ramCheck
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("RAM copied to clipboard", 0, "RAM Copied", 64)
    })
if ($ramCompliant -eq $false) {
    #Set color to red if RAM check fails
    $ramInfo.BackColor = 'Red'
    $ramInfo.ForeColor = 'White'
}
else {
    $ramInfo.BackColor = $BGcolor
    $ramInfo.ForeColor = $TextColor
}

$ramInfo.ToolTipText = "Current device RAM." + "`nClick to copy RAM to clipboard."
[void]$menuInfo.DropDownItems.Add($ramInfo)

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
[void]$menuInfo.DropDownItems.Add($cpuInfo)

#Admin Mode Status Display
$adminInfo.Text = "ETT Admin Mode: " + $adminmode
$adminInfo.Add_Click({
        Set-Clipboard -Value $adminInfo.Text
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("ETT Admin Mode copied to clipboard", 0, "Admin Mode Copied", 64)
    })
$adminInfo.BackColor = $BGcolor
$adminInfo.ForeColor = $TextColor
$adminInfo.ToolTipText = "Current ETT Admin Mode." + "`nClick to copy ETT Admin Mode to clipboard."
[void]$menuInfo.DropDownItems.Add($adminInfo)

#Security Info Top-Level Folder
$securityInfo.Text = "Security Information"
$securityInfo.BackColor = $BGcolor
$securityInfo.ForeColor = $TextColor
[void]$menuInfo.DropDownItems.Add($securityInfo)

#Hosts File Info Display
$hostsInfo.Text = $hostsText
$hostsInfo.Add_Click({
        Set-Clipboard -Value $hostsInfo.Text
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("Hosts File copied to clipboard", 0, "Hosts File Copied", 64)
    })
$hostsInfo.BackColor = $BGcolor
$hostsInfo.ForeColor = $TextColor
$hostsInfo.ToolTipText = "Current Hosts File Modification Status." + "`nClick to copy Hosts File to clipboard."
[void]$securityInfo.DropDownItems.Add($hostsInfo)

#Defender Info Display
$defenderInfo.Text = "Defender ATP Enrollment Status: " + $defenderEnrollStatus
$defenderInfo.Add_Click({
        Set-Clipboard -Value $defenderEnrollStatus
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("Defender Status copied to clipboard", 0, "Defender Status Copied", 64)
    })
#Set color to red if Defender ATP is not enrolled and compliance check is enabled
if ($defenderStatus -eq "Not Enrolled" -and $complianceFlag -eq $true) {
    $defenderInfo.BackColor = 'Red'
    $defenderInfo.ForeColor = 'White'
}
else {
    $defenderInfo.BackColor = $BGcolor
    $defenderInfo.ForeColor = $TextColor
}
$defenderInfo.ToolTipText = "Current Defender ATP Enrollment Status." + "`nClick to copy Defender ATP Enrollment Status to clipboard."
[void]$SecurityInfo.DropDownItems.Add($defenderInfo)

#Device Info Print to Text File in C Temp
$deviceInfoPrint.Text = "Print Device Info to Text File"
$deviceInfoPrint.Add_Click({
        $saveDialog = New-Object System.Windows.Forms.SaveFileDialog
        $saveDialog.Filter = "Text Files (*.txt)|*.txt"
        $saveDialog.Title = "Save Device Info to Text File"
        $saveDialog.InitialDirectory = "C:\Temp"
        $saveDialog.FileName = "Device_Info.txt"

        if ($saveDialog.ShowDialog() -eq "OK") {
            $deviceInfo | Out-File -FilePath $saveDialog.FileName
        }
    })
$deviceInfoPrint.BackColor = $BGcolor
$deviceInfoPrint.ForeColor = $TextColor
$deviceInfoPrint.ToolTipText = "Prints device info to a text file in C:\Temp." + "`nClick to print device info to text file."
[void]$menuInfo.DropDownItems.Add($deviceInfoPrint)

$deviceInfoClipboard.Text = "Copy Device Info to Clipboard"
$deviceInfoClipboard.Add_Click({
        Set-Clipboard -Value $deviceInfo
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("Device Info copied to clipboard", 0, "Device Info Copied", 64)
    })
$deviceInfoClipboard.BackColor = $BGcolor
$deviceInfoClipboard.ForeColor = $TextColor
$deviceInfoClipboard.ToolTipText = "Copies device info to clipboard." + "`nClick to copy device info to clipboard."
[void]$menuInfo.DropDownItems.Add($deviceInfoClipboard)

#Device Info Ticket
if ($null -eq $ticketType) {
    #If ticket type is null, do nothing, and disable the button
    $deviceInfoTicket.Text = "Send Device Info to Ticketing System"
    $deviceInfoTicket.BackColor = $BGcolor
    $deviceInfoTicket.ForeColor = $TextColor
    $deviceInfoTicket.Enabled = $false
    $deviceInfoTicket.ToolTipText = "Sends device info to ticketing system. Not configured presently. Coming soon."
    [void]$menuInfo.DropDownItems.Add($deviceInfoTicket)
}
else {
    #If ticket type is not null, run the ticketing function
    $deviceInfoTicket.Text = "Send Device Info to $ticketType"
    $deviceInfoTicket.Add_Click({
            #Run the ticketing function
            notificationPush -messageBody $deviceInfo
        })
    $deviceInfoTicket.BackColor = $BGcolor
    $deviceInfoTicket.ForeColor = $TextColor
    $deviceInfoTicket.ToolTipText = "Sends device info to $ticketType." + "`nClick to send device info to $ticketType."
    [void]$menuInfo.DropDownItems.Add($deviceInfoTicket)
}

#Help Tab
$menuHelp.Text = "Help"
[void]$menu.Items.Add($menuHelp)

#About Button - Displays basic information about the script
$menuAbout.Text = "About"
$menuAbout.Add_Click({
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("This script was created by the Eli Weitzman to assist in simplifying technical tasks.", 0, "About", 64)
    })
$menuAbout.BackColor = $BGcolor
$menuAbout.ForeColor = $TextColor
[void]$menuHelp.DropDownItems.Add($menuAbout)

#Fun Button - It's fun (lol)
$menuFun = New-Object System.Windows.Forms.ToolStripMenuItem
$menuFun.Text = "Fun"
$menuFun.Add_Click({
        #Open a web browser to a fun website
        Start-Process https://youtu.be/dQw4w9WgXcQ?si=HjDcCh_FForoWMq6
    })
$menuFun.BackColor = $BGcolor
$menuFun.ForeColor = $TextColor
#Set keyboard shortcut to Ctrl + R
$menuFun.ShortcutKeys = [System.Windows.Forms.Keys]::Control + [System.Windows.Forms.Keys]::R
[void]$menuHelp.DropDownItems.Add($menuFun)

#Licenses Button - Displays basic license information
$menuLicenses.Text = "Licenses"
$menuLicenses.Add_Click({
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("This application is written under a BSD 3-Clause License by Eli Weitzman. For more information on how this works, visit our GitHub Repository.", 0, "About", 64)
    })
$menuLicenses.BackColor = $BGcolor
$menuLicenses.ForeColor = $TextColor
[void]$menuHelp.DropDownItems.Add($menuLicenses)

#GitHub Button
$menuGitHub.Text = "GitHub"
$menuGitHub.Add_Click({
        #Open a web browser to the GitHub repository
        Start-Process https://github.com/eliweitzman/EnterpriseTechTool
    })
$menuGitHub.BackColor = $BGcolor
$menuGitHub.ForeColor = $TextColor
[void]$menuHelp.DropDownItems.Add($menuGitHub)

#Bug Report Button
$menuBugReport.Text = "Bug Report"
$menuBugReport.Add_Click({
        #Open a web browser to a bug report website
        Start-Process https://github.com/eliweitzman/EnterpriseTechTool/issues
    })
$menuBugReport.BackColor = $BGcolor
$menuBugReport.ForeColor = $TextColor
[void]$menuHelp.DropDownItems.Add($menuBugReport)

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

#Settings Button
$menuSettings.Text = "Settings"
$menuSettings.Add_Click({
        #First, check to see if running in admin mode
        if (($adminmode -eq $true) -or ($installType -eq "Portable")) {
            #Next, check to see if ETTConfig.json exists in the same directory as the script
            $configtest = Test-Path ".\ETTConfig.json" -ErrorAction SilentlyContinue
            #First, check to see if the settings file is present
            if ($configtest -eq $true) {
                Open-SettingsMenu
            }
            else {
                #Display a quick popup - "No settings file found, would you like to create one?" with a Yes/No option
                $wshell = New-Object -ComObject Wscript.Shell
                $request = $wshell.Popup("No settings file found. Would you like to create one?", 0, "Settings", 4)
                if ($request -eq 6) {
                    #If yes, create a new settings file with default settings and open the settings window script
                    $newConfig = @"
                {
                    "ETTSettingsGUI" : true,
                    "AutoUpdateCheckerEnabled" : true,
                    "AdminMode" : false,
                    "BrandColor" : "#023a24",
                    "LogoLocation" : null,
                    "BackgroundImagePath" : "",
                    "ETTApplicationTitle" : "",
                    "ETTHeaderText" : "",
                    "ETTHeaderTextColor" : "White",
                    "ApplicationTimeoutEnabled" : false,
                    "ApplicationTimeoutLength" : 300,
                    "EnableCustomTools" : true,
                    "RAMCheckActive": false,
                    "RAMCheckMinimum" : 8,
                    "DriveSpaceCheckActive" : false,
                    "DriveSpaceCheckMinimum" : 20,
                    "WinVersionCheckActive" : false,
                    "WinVersionTarget": "24H2",
                    "AzureADTenantId" : "",
                    "LAPSAppClientId" : "",
                    "BitLockerAppClientId" : "",
                    "AnimeMode" : false,
                    "DefenderEnrollCheckActive" : false,
                
                    "CustomFunctions": [
                        {
                          "displayName": "Display Hello World",
                          "description": "Returns a friendly 'Hello, World!' message.",
                          "tab" : "",
                          "requireAdmin" : true,
                          "codeBlock": "$wshell = New-Object -ComObject Wscript.Shell; $wshell.Popup('Hello, World!', 0, 'Hello, World!', 0x1)"
                        },
                        {
                          "displayName": "Display Random Number",
                          "description": "Generates a random number between 1 and 100.",
                          "tab": "",
                          "requireAdmin" : false,
                          "codeBlock": "$rand =  (Get-Random -Minimum 1 -Maximum 100); $wshell = New-Object -ComObject Wscript.Shell; $wshell.Popup($rand, 0, $rand, 0x1)"
                        }
                        ]
                    }
"@
                    #Create the new settings file in the same directory as the script using a here-string
                    $newConfig | Out-File -FilePath ".\ETTConfig.json"

                    #Display a message box to the user that the settings file has been created, and the path to it
                    $wshell.Popup("Settings file created. `n`n Now opening settings menu.", 0, "Settings Created", 64)
                    Open-SettingsMenu
                }
                else {
                    #If no, do nothing
                }
           
            }
        }
        else {
            #If we are not in admin mode, display a message box
            $wshell = New-Object -ComObject Wscript.Shell
            $wshell.Popup("You must be in Admin Mode to access settings.", 0, "Settings Error", 48)
        }
    })
[void]$menu.Items.Add($menuSettings)

#Exit Button
$menuExit.Text = "Exit"
$menuExit.Add_Click({ $ETT.Close() })
[void]$menu.Items.Add($menuExit)

#Add all buttons and functions to the GUI menu
$ETT.controls.AddRange(@($Logo, $Heading, $ClearLastLogin, $Lapspw, $appUpdate, $PolicyPatch, $menu))

#Timeout Logic - IF timeout is true, then set a timer to close the form after a specified amount of time - WIP
if ($timeout -eq $true) {
    $timeoutTimer = New-Object System.Windows.Forms.Timer
    #Set the interval to the timeout value (converted to milliseconds)
    $timeoutTimer.Interval = $timeoutLength * 1000
    $timeoutTimer.Add_Tick({ $ETT.Close() }) #Close the form when the timer ticks
    $timeoutTimer.Start() #Start the timer
}

[void]$ETT.ShowDialog()