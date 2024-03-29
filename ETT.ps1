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
    Version:        1.2.1
    Creation Date:  12-26-22
    Last Updated:   12-17-23
    Purpose/Change: Timeout implementation

.LICENSE
    BSD 3-Clause License

    Copyright (c) 2023, Eli Weitzman

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

#Import Winforms API for GUI
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

#Build Variables
$ETTVersion = "1.2.1"


## BEGIN INITIAL FLAGS - CHANGE THESE TO MATCH YOUR PREFERENCES

#Admin mode - if auto-elevate is enabled, this will be set to $true. If in EXE mode, this is automatically handled by Windows.
$adminmode = $false

#Set Branding - CHANGE THIS TO MATCH YOUR PREFERENCE
$BrandColor = '#023a24' #Set the color of the form, currently populated with a hex value.
$LogoLocation = $null #If you want to use a custom logo, set the path here. Otherwise, leave as $null

#ETT UI Options
$backgroundImagePath = "" #Set this to a web URL or local path to change the BG image of ETT
$ettHeaderTextColor = [System.Drawing.Color]::FromName("White")#Override the color of the ETT header if a BG image is set. Otherwise, it will change based on system theme
$timeout = $false #Set this to $true to enable a timeout for ETT. Otherwise, set to $false
$timeoutLength = 300 #Set the length of the timeout in seconds. Default is 300 seconds (5 minutes)

#Compliance Thresholds - CHANGE THESE TO MATCH YOUR COMPLIANCE REQUIREMENTS
#RAM Check
$ramCheckActive = $false
$ramMinimum = 8 #SET MINIMUM RAM IN GB

#Drivespace Check
$drivespaceCheckActive = $false
$drivespaceMinimum = 20 #SET MINIMUM DRIVESPACE IN GB

#Windows Version Check
$winverCheckActive = $false
$winverTarget = '22h2' #SET TARGET WINDOWS VERSION (21h1, 21h2, 22h2)

<#Notification Framework - COMING IN 1.2.1

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

#Determine Dark/Light Mode
# Get the current theme
$theme = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize").AppsUseLightTheme

#Dark/Light Parameters
# If the theme is 0, it is dark mode
if ($theme -eq 0) {
    #DARK MODE
    $BGcolor = 'Black'
    $TextColor = 'White'
    $ButtonText = 'White'
    $BoxColor = $BrandColor
}
else {
    #LIGHT MODE
    $BGcolor = 'WhiteSmoke'
    $TextColor = 'Black'
    $ButtonText = 'White'
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
$LoadingForm.Controls.Add($LoadingLabel)
$LoadingForm.Controls.Add($LoadingProgressBar)

#Show the form
[void]$LoadingForm.Show()

#Conditions to load
$LoadingLabel.Text = "Getting username..."
$username = whoami.exe
$outputsuppressed = $LoadingProgressBar.Value = 10

$LoadingLabel.Text = "Getting hostname..."
$hostname = HOSTNAME.EXE
$outputsuppressed = $LoadingProgressBar.Value = 20

$LoadingLabel.Text = "Getting Windows Version..."
$winver = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").DisplayVersion
$outputsuppressed = $LoadingProgressBar.Value = 30

$LoadingLabel.Text = "Getting Manufacturer..."
$manufacturer = Get-WmiObject -Class Win32_ComputerSystemProduct | Select-Object -ExpandProperty Vendor
$outputsuppressed = $LoadingProgressBar.Value = 40

$LoadingLabel.Text = "Getting Model..."
$model = Get-WmiObject -Class Win32_ComputerSystem -Property Model | Select-Object -ExpandProperty Model
$outputsuppressed = $LoadingProgressBar.Value = 50

$LoadingLabel.Text = "Getting Domain..."
$domain = (Get-CIMInstance -ClassName Win32_ComputerSystem).Domain
$outputsuppressed = $LoadingProgressBar.Value = 60

$LoadingLabel.Text = "Getting Drive Info..."
$drivespace = Get-WmiObject -ComputerName localhost -Class win32_logicaldisk | Where-Object caption -eq "C:" | foreach-object { Write-Output " $($_.caption) $('{0:N2}' -f ($_.Size/1gb)) GB total, $('{0:N2}' -f ($_.FreeSpace/1gb)) GB free " }
$outputsuppressed = $LoadingProgressBar.Value = 70

$LoadingLabel.Text = "Getting RAM Info..."
$ramCheck = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum / 1gb
$outputsuppressed = $LoadingProgressBar.Value = 80

$LoadingLabel.Text = "Getting CPU Info..."
$cpuCheck = Get-WmiObject -Class Win32_Processor | Select-Object -ExpandProperty Name
$outputsuppressed = $LoadingProgressBar.Value = 90

$LoadingLabel.Text = "Getting Device Type..."
$devicetype = (Get-WmiObject -Class Win32_ComputerSystem -Property PCSystemType).PCSystemType
$outputsuppressed = $LoadingProgressBar.Value = 95

$LoadingLabel.Text = "Getting Drive Type..."
$drivetype = Get-PhysicalDisk | Where-Object DeviceID -eq 0 | Select-Object -ExpandProperty MediaType
$outputsuppressed = $LoadingProgressBar.Value = 100

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

#Function for AD Computer or User Lookup, depending on the value of $ADLookupType parameter - DISABLED FOR INITIAL RELEASE, WILL BE RE-ENABLED IN FUTURE, after fixing bugs

function ADLookup {
    <# 
.NAME
    Active Directory Explorer
.SYNOPSIS
    A simplified version of Active Directory
.DESCRIPTION
    Imagine Active Directory Users and Computers... but with massive training wheels. Introducing AD Explorer!     
.AUTHOR
    Eli Weitzman
.NOTES
    Version:        1.0
    Creation Date:  4-24-23
    Last Updated:   4-24-23
    Purpose/Change: Initial Build

    MUST COMPILE WITH x64
#>

    # Import Modules

    #Import Winforms API for GUI
    $outputsuppressed = Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()

    #Initial Declarations
    $outputSuppressed # A Buffer for GUI Processing

    #GUI
    $ADForm = New-Object System.Windows.Forms.Form
    $ADForm.Text = "Active Directory Explorer"
    $ADForm.Width = 800
    $ADForm.Height = 600
    $ADForm.StartPosition = "CenterScreen"
    $ADForm.FormBorderStyle = "Fixed3D"
    $ADForm.MaximizeBox = $false
    $ADForm.MinimizeBox = $false
    $ADForm.ShowIcon = $false
    $ADForm.TopMost = $true
    $ADForm.BackColor = $BGcolor

    #Label next to Search Field - Call it "Search Query:"
    $SearchLabel = New-Object System.Windows.Forms.Label
    $SearchLabel.Location = New-Object System.Drawing.Point(10, 10)
    $SearchLabel.Width = 105
    $SearchLabel.Height = 20
    $SearchLabel.Text = "Search Query:"
    $SearchLabel.Font = New-Object System.Drawing.Font("Arial", 11)
    $SearchLabel.ForeColor = $TextColor
    $SearchLabel.TabIndex = 0
    $SearchLabel.TextAlign = "MiddleLeft"
    $SearchLabel.UseMnemonic = $false
    $SearchLabel.Visible = $true
    $ADForm.Controls.Add($SearchLabel)

    #Field for User Input - Call it "Search"
    $Search = New-Object System.Windows.Forms.TextBox
    $Search.Location = New-Object System.Drawing.Point(115, 10)
    $Search.Width = 300
    $Search.Height = 20
    $Search.Multiline = $false
    $Search.ReadOnly = $false
    $Search.ScrollBars = "None"
    $Search.TextAlign = "Left"
    $Search.WordWrap = $false
    $Search.Font = New-Object System.Drawing.Font("Arial", 10)
    $Search.BackColor = "White"
    $Search.ForeColor = "Black"
    $Search.BorderStyle = "FixedSingle"
    $Search.TabIndex = 0
    $Search.AcceptsReturn = $false
    $Search.AcceptsTab = $false
    $Search.HideSelection = $true
    $Search.ShortcutsEnabled = $true
    $Search.ImeMode = "NoControl"
    $ADForm.Controls.Add($Search)

    #Dropdown for User Input - Choose User, Group, or Computer
    $SearchType = New-Object System.Windows.Forms.ComboBox
    $SearchType.Location = New-Object System.Drawing.Point(420, 10)
    $SearchType.Width = 100
    $SearchType.Height = 20
    $SearchType.Text = "Search Type"
    $SearchType.Font = New-Object System.Drawing.Font("Arial", 10)
    $SearchType.BackColor = "White"
    $SearchType.ForeColor = "Black"
    $SearchType.DropDownStyle = "DropDownList"
    $SearchType.TabIndex = 2
    $SearchType.Items.Add("User")
    $SearchType.Items.Add("Group")
    $SearchType.Items.Add("Computer")
    $ADForm.Controls.Add($SearchType)

    #Button for User Input - Call it "Search"
    $SearchButton = New-Object System.Windows.Forms.Button
    $SearchButton.Location = New-Object System.Drawing.Point(530, 10)
    $SearchButton.Width = 100
    $SearchButton.Height = 23
    $SearchButton.Text = "Search"
    $SearchButton.Font = New-Object System.Drawing.Font("Arial", 10)
    $SearchButton.BackColor = $BrandColor
    $SearchButton.ForeColor = $ButtonText
    $SearchButton.FlatStyle = "Flat"
    $SearchButton.TabIndex = 1
    $ADForm.Controls.Add($SearchButton)

    #DomainLabel for User Input - Call it "Domain:"
    $DomainLabel = New-Object System.Windows.Forms.Label
    $DomainLabel.Location = New-Object System.Drawing.Point(10, 40)
    $DomainLabel.Width = 75
    $DomainLabel.Height = 20
    $DomainLabel.Text = "Domain:"
    $DomainLabel.Font = New-Object System.Drawing.Font("Arial", 11)
    $DomainLabel.ForeColor = $TextColor
    $DomainLabel.TabIndex = 0
    $DomainLabel.TextAlign = "MiddleLeft"
    $DomainLabel.UseMnemonic = $false
    $DomainLabel.Visible = $true
    $ADForm.Controls.Add($DomainLabel)

    #DomainBox for User Input - TextInput for Domain
    $DomainBox = New-Object System.Windows.Forms.TextBox
    $DomainBox.Location = New-Object System.Drawing.Point(115, 40)
    $DomainBox.Width = 230
    $DomainBox.Height = 20
    $DomainBox.Multiline = $false
    $DomainBox.ReadOnly = $false
    $DomainBox.ScrollBars = "None"
    $DomainBox.TextAlign = "Left"
    $DomainBox.WordWrap = $false
    $DomainBox.Font = New-Object System.Drawing.Font("Arial", 10)
    $DomainBox.BackColor = "White"
    $DomainBox.ForeColor = "Black"
    $DomainBox.BorderStyle = "FixedSingle"
    $DomainBox.TabIndex = 0
    $DomainBox.AcceptsReturn = $false
    $DomainBox.Enabled = $false
    $DomainBox.Text = $env:USERDNSDOMAIN
    $ADForm.Controls.Add($DomainBox)

    #Domain Checkbox to enable Domain Search
    $DomainCheck = New-Object System.Windows.Forms.CheckBox
    $DomainCheck.Location = New-Object System.Drawing.Point(85, 40)
    $DomainCheck.Width = 20
    $DomainCheck.Height = 20
    $DomainCheck.Checked = $false
    $ADForm.Controls.Add($DomainCheck)

    $DomainCheck.Add_Click({
            if ($DomainCheck.Checked -eq $true) {
                $DomainBox.Enabled = $true
                #Clear DomainBox
                $DomainBox.Text = $null
                #White out DomainBox
                $DomainBox.BackColor = "White"
                $DomainBox.ReadOnly = $false
            }
            else {
                $DomainBox.Enabled = $false
                #Grab Domain from System
                $DomainBox.Text = $env:USERDNSDOMAIN
                #Grey out DomainBox
                $DomainBox.BackColor = "LightGray"
                $DomainBox.ReadOnly = $true
            }
        })

    #Dynamic Frame for Results
    $Results = New-Object System.Windows.Forms.ListBox
    $Results.Location = New-Object System.Drawing.Point(10, 80)
    $Results.Width = 760
    $Results.Height = 500
    $Results.Text = "Results"
    $Results.Font = New-Object System.Drawing.Font("Arial", 10)
    $Results.BackColor = "White"
    $Results.ForeColor = "Black"
    $Results.TabIndex = 3
    $Results.TabStop = $false
    $Results.Visible = $true
    $Results.Enabled = $true
    $Results.Items.Add("Results:")
    $ADForm.Controls.Add($Results)

    #Create logic for on search button click, with a switch statement for the search type

    #Search Button Click Event
    $searchOnClick = ({
            try {
                if ($SearchType.Text -eq "User") {
                    #Capture ADUser Object from Search, and add properties (DistinguishedName, Enabled, GivenName, Name, ObjectClass, ObjectGUID, SamAccountName, SID, Surname, UserPrincipalName) as rows to an array
                    $Info = Get-ADUser $Search.Text -Server $DomainBox.Text -Properties Name, SamAccountName, Description, DistinguishedName, Enabled, GivenName, Surname, SID, UserPrincipalName
                    foreach ($User in $Info) {
                        $UserArray = @()
                        $UserArray += "Name: " + $User.Name
                        $UserArray += "SamAccountName: " + $User.SamAccountName
                        $UserArray += "Description: " + $User.Description
                        $UserArray += "DistinguishedName: " + $User.DistinguishedName
                        $UserArray += "Enabled: " + $User.Enabled
                        $UserArray += "GivenName: " + $User.GivenName
                        $UserArray += "Surname: " + $User.Surname
                        $UserArray += "SID: " + $User.SID
                        $UserArray += "UserPrincipalName: " + $User.UserPrincipalName
                    }
                    #Populate Results Frame with User Results
                    $Results.Items.Clear()
                    $Results.Items.AddRange(@($UserArray))
    
                }
                elseif ($SearchType.Text -eq "Group") {
                    $Info = Get-ADGroup -Identity $Search.Text -Server $DomainBox.Text -Properties DistinguishedName, GroupCategory, GroupScope, Name, SamAccountName, Description, Members
                    #Populate Results Frame with Group Results
                    foreach ($Group in $Info) {
                        $GroupArray = @()
                        $GroupArray += "Name: " + $Group.Name
                        $GroupArray += "SamAccountName: " + $Group.SamAccountName
                        $GroupArray += "Description: " + $Group.Description
                        $GroupArray += "DistinguishedName: " + $Group.DistinguishedName
                        $GroupArray += "GroupCategory: " + $Group.GroupCategory
                        $GroupArray += "GroupScope: " + $Group.GroupScope
                        $GroupArray += "Members: " + $Group.Members
                    }
                    $Results.Items.Clear()
                    $Results.Items.AddRange(@($GroupArray))
    
                }
                elseif ($SearchType.Text -eq "Computer") {
                    $Info = Get-ADComputer -Identity $Search.Text -Server $DomainBox.Text -Properties Description, DistinguishedName, DNSHostName, Enabled, LastLogonDate, LockedOut, Name, ObjectClass, ObjectGUID, OperatingSystem, OperatingSystemVersion, SamAccountName, SID, WhenChanged, WhenCreated, WhenCreated
                    #Populate Results Frame with Computer Results
                    foreach ($Computer in $Info) {
                        $ComputerArray = @()
                        $ComputerArray += "Name: " + $Computer.Name
                        $ComputerArray += "SamAccountName: " + $Computer.SamAccountName
                        $ComputerArray += "Description: " + $Computer.Description
                        $ComputerArray += "DistinguishedName: " + $Computer.DistinguishedName
                        $ComputerArray += "DNSHostName: " + $Computer.DNSHostName
                        $ComputerArray += "Enabled: " + $Computer.Enabled
                        $ComputerArray += "LastLogonDate: " + $Computer.LastLogonDate
                        $ComputerArray += "LockedOut: " + $Computer.LockedOut
                        $ComputerArray += "OperatingSystem: " + $Computer.OperatingSystem
                        $ComputerArray += "OperatingSystemVersion: " + $Computer.OperatingSystemVersion
                        $ComputerArray += "SID: " + $Computer.SID
                        $ComputerArray += "WhenChanged: " + $Computer.WhenChanged
                        $ComputerArray += "WhenCreated: " + $Computer.WhenCreated
                    }
    
                    $Results.Items.Clear()
                    $Results.Items.AddRange(@($ComputerArray))
                }
                else {
                    #Fallback, populate with error to select a search type
                    $Results.Items.Clear()
                    $Results.Items.AddRange("Please select a search type")
                }
            }
            catch {
                $Results.Items.Clear()
                $Results.Items.AddRange("Error: " + $_.Exception.Message)
            }
        })

    #Add Event Handler to Search Button
    $SearchButton.add_Click($searchOnClick)

    #Add Enter Key Event Handler to Search Field
    $Search.add_KeyDown({
            if ($_.KeyCode -eq "Enter") {
                $searchOnClick.Invoke()
            }
        })

    #Show GUI
    $ADForm.ShowDialog()
    
}

function LAPSTool {
    # Import the module
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()

    #Create box
    $LapsForm = New-Object system.Windows.Forms.Form
    $LapsForm.ClientSize = New-Object System.Drawing.Point(450, 301)
    $LapsForm.text = "LAPS GUI"
    $LapsForm.BackColor = $BGcolor
    $LapsForm.ForeColor = $TextColor
    $LapsForm.FormBorderStyle = 'FixedDialog'
    $LapsForm.StartPosition = 'CenterScreen'

    #Title for box
    $titleTag = New-Object system.Windows.Forms.Label
    $titleTag.text = "LAPS GUI"
    $titleTag.width = 25
    $titleTag.height = 10
    $titleTag.location = New-Object System.Drawing.Point(88, 20)
    $titleTag.Font = New-Object System.Drawing.Font('Segoe UI', 16, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
    $titleTag.AutoSize = $true
    $titleTag.ForeColor = $TextColor

    #Logo sourced from choccolatey gal
    $Lapslogo = New-Object system.Windows.Forms.PictureBox
    $Lapslogo.width = 106
    $Lapslogo.height = 72
    $Lapslogo.location = New-Object System.Drawing.Point(313, 17)
    $Lapslogo.imageLocation = "https://community.chocolatey.org/content/packageimages/laps.6.2.0.20210403.png"
    $Lapslogo.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::zoom

    #Checkbox for using Windows LAPS
    $windowsLaps = New-Object system.Windows.Forms.CheckBox
    $windowsLaps.text = "Use Windows LAPS"
    $windowsLaps.AutoSize = $true
    $windowsLaps.width = 25
    $windowsLaps.height = 10
    $windowsLaps.location = New-Object System.Drawing.Point(17, 60)

    #To the right of the checkbox for using Windows LAPS, add a LAPS Azure AD option checkbox
    $azureLaps = New-Object system.Windows.Forms.CheckBox
    $azureLaps.text = "Use Azure AD LAPS"
    $azureLaps.AutoSize = $true
    $azureLaps.width = 25
    $azureLaps.height = 10
    $azureLaps.location = New-Object System.Drawing.Point(150, 60)

    #IF Azure LAPS is checked, disable the Windows LAPS checkbox, and domain input box
    $azureLaps.Add_CheckStateChanged({
            if ($azureLaps.Checked -eq $true) {
                #Re-enable the start button if it was disabled by RSAT not being installed
                $lapsStart.Enabled = $true

                $windowsLaps.Checked = $false
                $windowsLaps.Enabled = $false
                $altCreds.Enabled = $false
                $altCreds.Checked = $false

                #If azure LAPS is checked, change the domain input box to the Azure AD tenant ID input box
                $domainLabel.Text = "Tenant ID:"
                $domainInput.Text = ""

                #Move the domain input box to the right to make room for title text
                $domainInput.Location = New-Object System.Drawing.Point(90, 114)

                #If Azure LAPS is checked, change the hostname input box to the device ID input box
                $hostnameLabel.Text = "Device ID:"
                $hostnameInput.Text = ""
            

                #Align the username input box with the hostname input box
                $usernameInfo.Location = New-Object System.Drawing.Point(16, 189)

                #If Azure LAPS is checked, change the username input box to the client ID input box
                $usernameInfo.Text = "Client ID:"
                $usernameInput.Text = ""
                $usernameInput.Enabled = $true

                #Enable the domain input box, and remove the domain from the input box
                $domainInput.Enabled = $true
                $domainInput.Text = ""

                #If Azure LAPS is checked, change the start button to say "Get Password"
                $lapsStart.Text = "Get Password"
            }
            else {
                $windowsLaps.Enabled = $true
                $domainInput.Enabled = $true
                $altCreds.Enabled = $true

                #If Azure LAPS is not checked, change the domain input box to the domain input box
                $domainLabel.Text = "Domain:"
                $domainInput.Text = $domain

                #Reset the domain input box to the left
                $domainInput.Location = New-Object System.Drawing.Point(80, 114)

                #If Azure LAPS is not checked, change the hostname input box to the hostname input box
                $hostnameLabel.Text = "Machine Hostname:"
                $hostnameInput.Text = ""
            
                #If Azure LAPS is not checked, change the username input box to the username input box
                $usernameInfo.Text = "Your Username:"
                $usernameInput.Text = $domain + "\" + $env:USERNAME
                $usernameInput.Enabled = $false

                #If Azure LAPS is not checked, change the start button to say "Start"
                $lapsStart.Text = "Start"

                #Also, check to see if RSAT is installed. If not, disable the start button
                if (Get-Module -ListAvailable -Name ActiveDirectory) {
                    $lapsStart.Enabled = $true
                }
                else {
                    $lapsStart.Enabled = $false
                    #set text to say RSAT is not installed
                    $lapsStart.Text = "RSAT Missing"
                }
            }
        })

    #Checkbox for using alternate credentials
    $altCreds = New-Object system.Windows.Forms.CheckBox
    $altCreds.text = "Use Alternate Credentials"
    $altCreds.AutoSize = $true
    $altCreds.width = 25
    $altCreds.height = 10
    $altCreds.location = New-Object System.Drawing.Point(17, 80)

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
    $domainInput.width = 300
    $domainInput.height = 20
    $domainInput.Anchor = 'top'
    $domainInput.location = New-Object System.Drawing.Point(80, 114)
    $domainInput.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)

    #Hostname information label
    $hostnameLabel = New-Object system.Windows.Forms.Label
    $hostnameLabel.text = "Machine Hostname:"
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
    $hostname = $hostnameInput.Text

    #Username information label
    $usernameInfo = New-Object system.Windows.Forms.Label
    $usernameInfo.text = "Your Username:"
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
    #Lock input box until alternate credentials is checked
    $usernameInput.Text = $domain + "\" + $env:USERNAME
    $usernameInput.Enabled = $false

    #Logic to enable/disable username input box - if alternate credentials is checked, enable the username input box. If not, disable it, unless Azure LAPS is checked
    $altCreds.Add_CheckStateChanged({
            if ($altCreds.Checked -eq $true) {
                $usernameInput.Enabled = $true
            }
            else {
                if ($azureLaps.Checked -eq $false) {
                    $usernameInput.Enabled = $false
                }
                else {
                    $usernameInput.Enabled = $false
                }
            }
        })

    #Logic to update the username input box when the domain input box is updated, but only if Azure LAPS is not checked
    $domainInput.Add_TextChanged({
            if ($azureLaps.Checked -eq $false) {
                $usernameInput.Text = $domainInput.Text + "\" + $env:USERNAME
            }
        })

    #Start button that closes window to run
    $lapsStart = New-Object system.Windows.Forms.Button
    $lapsStart.text = "Start"
    $lapsStart.width = 125
    $lapsStart.height = 30
    $lapsStart.location = New-Object System.Drawing.Point(154, 251)
    $lapsStart.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
    $lapsStart.BackColor = $BoxColor
    $lapsStart.ForeColor = $TextColor
    $lapsStart.Add_Click({ 
            <#Based on toggle switches, there are a few different ways to run the script
        1. Standard LAPS, no alternate credentials
        2. Standard LAPS, alternate credentials
        3. Windows LAPS, no alternate credentials
        4. Windows LAPS, alternate credentials
        5. Azure LAPS (no alternate credentials)
        #>

            #If Azure LAPS is checked, run the Azure LAPS process
            if ($azureLaps.Checked -eq $true -and $altCreds.Checked -eq $false -and $windowsLaps.Checked -eq $false) {
                #First, get the Azure AD Tenant ID
                $tenantID = $domainInput.Text
                $clientID = $usernameInput.Text


                #test to see if Microsoft Graph PowerShell module is installed. If not, show a popup and exit
                if (Get-Module -ListAvailable -Name Microsoft.Graph.Authentication) {
                    #Next, verify the Azure AD Tenant ID and Client ID and Device ID are not blank
                    if ($tenantID -eq "" -or $clientID -eq "" -or $hostnameInput.Text -eq "") {
                        $wshell = New-Object -ComObject Wscript.Shell
                        $wshell.Popup("Tenant ID and Client ID cannot be blank", 0, "Error", 0x1)
                    }
                    else {
                        #Next, actually connect to the MS Graph API
                        Connect-MgGraph -TenantId $tenantID -ClientId $clientID
                        #Now, get the password
                        $lapsResult = (Get-LapsAADPassword -DeviceIds $hostnameInput.Text -IncludePasswords -AsPlainText).Password
                        #If the output is null, the computer is not in Azure AD. If Output is a secure string, the LAPS is encrypted and requires a decryption credential
                        if ($null -eq $lapsResult) {
                            $wshell = New-Object -ComObject Wscript.Shell
                            $wshell.Popup("Computer not found in Azure AD", 0, "Error", 0x1)
                        }
                        else {
                            #If the output is not null, the computer is in Azure AD and the password is returned
                            $lapsResult | clip
 
                            $wshell = New-Object -ComObject Wscript.Shell
                            $wshell.Popup("Password for $hostname is $lapsResult. Copied to clipboard.", 0, "Password", 0x0)
                        }
                    }
                }
                else {
                    $wshell = New-Object -ComObject Wscript.Shell
                    $wshell.Popup("Microsoft Graph PowerShell module not installed. Please install the module and try again.", 0, "Error", 0x1)
                }
            }
            #If Windows LAPS is checked, run the Windows LAPS process
            if ($windowsLaps.Checked -eq $true -and $altCreds.Checked -eq $false) {
                $output = Get-LapsADPassword $hostnameInput.Text -AsPlainText -Domain $domainInput.Text | Select-Object -ExpandProperty Password
            
                #If the output is null, the computer is not in AD. If Output is a secure string, the LAPS is encrypted and requires a decryption credential
                if ($null -eq $output) {
                    $wshell = New-Object -ComObject Wscript.Shell
                    $wshell.Popup("Computer not found in Active Directory", 0, "Error", 0x1)
                }
                else {
                    #If the output is not null, the computer is in AD and the password is returned
                    $output | clip

                    $wshell = New-Object -ComObject Wscript.Shell
                    $wshell.Popup("Password for $hostname is $output. Copied to clipboard.", 0, "Password", 0x0)
                }
            }
            #If Windows LAPS is checked, and alternate credentials are checked, run the Windows LAPS process with alternate credentials
            if ($windowsLaps.Checked -eq $true -and $altCreds.Checked -eq $true -and $azureLaps.Checked -eq $false) {
                $altcredCheck = Get-Credential -Credential $usernameInput.Text
                #IF Windows LAPS is on, alternate credentials is on, run the command with alternate credentials
                $output = Get-LapsADPassword  $hostnameInput.Text -Credential $altcredCheck -DecryptionCredential $altcredCheck -Domain $domainInput.Text $altcredCheck -AsPlainText
            
                #If the output is null, the computer is not in AD. If Output is a secure string, the LAPS is encrypted and requires a decryption credential
                if ($null -eq $output) {
                    $wshell = New-Object -ComObject Wscript.Shell
                    $wshell.Popup("Computer not found in Active Directory", 0, "Error", 0x1)
                }
                else {
                    #If the output is not null, the computer is in AD and the password is returned
                    $output | clip

                    $wshell = New-Object -ComObject Wscript.Shell
                    $wshell.Popup("Password for $hostname is $output. Copied to clipboard.", 0, "Password", 0x0)
                }
            }
            #If Windows LAPS is not checked, and alternate credentials are not checked, run the standard LAPS process
            if ($windowsLaps.Checked -eq $false -and $altCreds.Checked -eq $false -and $azureLaps.Checked -eq $false) {
                $output = Get-ADComputer $hostname -Server $domain -Properties ms-Mcs-AdmPwd | Select-Object -ExpandProperty ms-Mcs-AdmPwd
        
                #If the output is null, the computer is not in AD
                if ($null -eq $output) {
                    $wshell = New-Object -ComObject Wscript.Shell
                    $wshell.Popup("Computer not found in Active Directory", 0, "Error", 0x1)
                }
                else {
                    #If the output is not null, the computer is in AD and the password is returned
                    $output | clip

                    $wshell = New-Object -ComObject Wscript.Shell
                    $wshell.Popup("Password for $hostname is $output. Copied to clipboard.", 0, "Password", 0x0)
                }
            }
            #If Windows LAPS is not checked, and alternate credentials are checked, run the standard LAPS process with alternate credentials
            if ($windowsLaps.Checked -eq $false -and $altCreds.Checked -eq $true -and $azureLaps.Checked -eq $false) {
                $output = Get-ADComputer $hostname -Server $domain -Credential (Get-Credential -Credential $usernameInput.Text) -Properties ms-Mcs-AdmPwd | Select-Object -ExpandProperty ms-Mcs-AdmPwd
        
                #If the output is null, the computer is not in AD
                if ($null -eq $output) {
                    $wshell = New-Object -ComObject Wscript.Shell
                    $wshell.Popup("Computer not found in Active Directory", 0, "Error", 0x1)
                }
                else {
                    #If the output is not null, the computer is in AD and the password is returned
                    $output | clip

                    $wshell = New-Object -ComObject Wscript.Shell
                    $wshell.Popup("Password for $hostname is $output. Copied to clipboard.", 0, "Password", 0x0)
                }
            }
        })
    #Add keypress event to start button
    $LapsForm.KeyPreview = $true
    $LapsForm.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { $lapsStart.PerformClick() } })

    #check to see if RSAT is installed. If not, disable the start button
    if (Get-Module -ListAvailable -Name ActiveDirectory) {
        $lapsStart.Enabled = $true
    }
    else {
        $lapsStart.Enabled = $false
        #set text to say RSAT is not installed
        $lapsStart.Text = "RSAT Missing"
    }

    #Print the above GUI applets in the box
    $LapsForm.controls.AddRange(@($Lapslogo, $domainInput, $domainLabel, $titleTag, $hostnameLabel, $hostnameInput, $usernameInfo, $usernameInput, $lapsStart, $windowsLaps, $altCreds, $azureLaps))

    #SHOW ME THE MONEY
    [void]$LapsForm.ShowDialog()

}

function bitlockerTool {
    #Test RSAT AD Tools is installed
    if (Get-Command -Name Get-ADComputer -ErrorAction SilentlyContinue) {
        #RSAT is installed
        $RSATStatus = "Installed"
    }
    else {
        #RSAT is not installed
        $RSATStatus = "Not Installed"
    }

    # Import the module
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()

    #Create box
    $BForm = New-Object system.Windows.Forms.Form
    $BForm.ClientSize = New-Object System.Drawing.Point(500, 200)
    $BForm.text = "BitLocker Retreival"
    $BForm.TopMost = $true
    $BForm.BackColor = $BGcolor
    $BForm.MaximizeBox = $false
    $BForm.MaximumSize = $BForm.Size
    $BForm.MinimumSize = $BForm.Size

    #Title for box
    $BTitle = New-Object system.Windows.Forms.Label
    $BTitle.text = "Bitlocker Retreival"
    $BTitle.AutoSize = $true
    $BTitle.width = 25
    $BTitle.height = 10
    $BTitle.location = New-Object System.Drawing.Point(88, 10)
    $BTitle.Font = New-Object System.Drawing.Font('Segoe UI', 16, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
    $BTitle.ForeColor = $TextColor
    $BForm.Controls.Add($BTitle)

    #Logo (sourced from WinAero gal)
    $BLogo = New-Object system.Windows.Forms.PictureBox
    $BLogo.width = 75
    $BLogo.height = 75
    $BLogo.location = New-Object System.Drawing.Point(375, 17)
    $BLogo.imageLocation = "https://winaero.com/blog/wp-content/uploads/2020/04/BitLocker-Big-256-Icon-2.png"
    $BLogo.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::zoom
    $BForm.Controls.Add($BLogo)

    #Hostname INPUT FIELD and LABEL
    $BHostname = New-Object system.Windows.Forms.Label
    $BHostname.text = "Hostname:"
    $BHostname.AutoSize = $true
    $BHostname.width = 25
    $BHostname.height = 10
    $BHostname.location = New-Object System.Drawing.Point(16, 60)
    $BHostname.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
    $BHostname.ForeColor = $TextColor
    $BForm.Controls.Add($BHostname)

    $BHostnameInput = New-Object system.Windows.Forms.TextBox
    $BHostnameInput.multiline = $false
    $BHostnameInput.width = 269
    $BHostnameInput.height = 20
    $BHostnameInput.location = New-Object System.Drawing.Point(90, 60)
    $BHostnameInput.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)
    $BHostname = $BHostnameInput.Text
    $BForm.Controls.Add($BHostnameInput)

    #Username INPUT FIELD and LABEL
    $BUsername = New-Object system.Windows.Forms.Label
    $BUsername.text = "Username:"
    $BUsername.AutoSize = $true
    $BUsername.width = 25
    $BUsername.height = 10
    $BUsername.location = New-Object System.Drawing.Point(16, 90)
    $BUsername.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
    $BUsername.ForeColor = $TextColor
    $BForm.Controls.Add($BUsername)

    $BUsernameInput = New-Object system.Windows.Forms.TextBox
    $BUsernameInput.multiline = $false
    $BUsernameInput.width = 269
    $BUsernameInput.height = 20
    $BUsernameInput.location = New-Object System.Drawing.Point(90, 90)
    $BUsernameInput.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)
    $BUsername = $BUsernameInput.Text
    $BForm.Controls.Add($BUsernameInput)

    #Set default username to current user
    $BUsernameInput.Text = (whoami.exe)

    #Submit button
    $BSubmit = New-Object system.Windows.Forms.Button
    $BSubmit.text = "Submit"
    $BSubmit.width = 60
    $BSubmit.height = 30
    $BSubmit.location = New-Object System.Drawing.Point(90, 120)
    $BSubmit.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
    $BSubmit.ForeColor = $TextColor
    $BSubmit.BackColor = $BoxColor

    #If RSAT is not installed, disable button
    if ($RSATStatus -eq "Not Installed") {
        $BSubmit.Enabled = $false
        $BSubmit.BackColor = 'Gray'
        $BSubmit.ForeColor = 'Black'
        $BSubmit.Text = "RSAT Not Installed"
    }

    $BSubmit.Add_Click({
            $hostname = $BHostnameInput.Text

            #Check if hostname is empty
            if ($hostname -eq "") {
                $wshell = New-Object -ComObject Wscript.Shell
                $wshell.Popup("Hostname cannot be empty", 0, "Error", 0x1)

                #Stop action
                return
            }
            
            try {
                $ADComputer = Get-ADComputer -Identity $hostname
                $bitlockerObj = Get-ADObject -Filter { objectclass -eq 'msFVE-RecoveryInformation' } -SearchBase $ADComputer.DistinguishedName -Properties 'msFVE-RecoveryPassword'
                $recoveryPassword = $bitlockerObj | Select-Object -ExpandProperty msFVE-RecoveryPassword
            }
            catch {
                $recoveryPassword = "Error: Computer not found"
            }

        
            #Copy to clipboard
            $recoveryPassword | clip

            #Wshell popup window with password, and show on top
            $wshell = New-Object -ComObject wscript.shell
            $wshell.popup("BitLocker Key: " + $recoveryPassword + "`nResult copied to clipboard.", 0, "Bitlocker Key", 0x00000040)

        })

    $BForm.Controls.Add($BSubmit)

    #Show Form
    $BForm.ShowDialog()
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
    if ($drivespace -ge $drivespaceMinimum) {
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
    } else {
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
        }else{
            #If no, show a popup that updates are available, but admin mode needs to be run
            $wshell = New-Object -ComObject Wscript.Shell
            $wshell.popup("Updates found. Please run ETT in admin mode to install updates.", 0, $windowTitle, 64)
        }
    }
}

#Create main frame (REMEMBER TO ITERATE VERSION NUMBER ON BUILD CHANGES)
$ETT = New-Object System.Windows.Forms.Form
$ETT.ClientSize = New-Object System.Drawing.Point(519, 330)
$ETT.text = "Eli's Enterprise Tech Tool V$ETTVersion"
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
$Logo = New-Object system.Windows.Forms.PictureBox
$Logo.width = 126
$Logo.height = 73
$Logo.location = New-Object System.Drawing.Point(377, 29)
$Logo.imageLocation = $LogoLocation
$Logo.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::zoom
if ($null -eq $LogoLocation) {
    $Logo.Visible = $false
}

$Heading = New-Object system.Windows.Forms.Label
$Heading.text = "Enterprise Tech Tool"
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
$ToastStack.BalloonTipTitle = "Eli's Enterprise Tech Tool"
$ToastStack.BalloonTipText = "Welcome to Eli's Enterprise Tech Tool!"
$ToastStack.Visible = $true
$ToastStack.ShowBalloonTip(5000)

#IF Compliance Flag is true, add a flyout notification
if ($complianceFlag -eq $true) {
    $ToastStack.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Error
    $ToastStack.BalloonTipTitle = "Eli's Enterprise Tech Tool"
    $ToastStack.BalloonTipText = "This device is non-compliant!"
    $ToastStack.Visible = $true
    $ToastStack.ShowBalloonTip(5000)
}

#Button placeholder for clearing last login
$ClearLastLogin = New-Object system.Windows.Forms.Button
$ClearLastLogin.text = "Clear Last Login"
$ClearLastLogin.width = 237
$ClearLastLogin.height = 89
$ClearLastLogin.location = New-Object System.Drawing.Point(13, 117)
$ClearLastLogin.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
$ClearLastLogin.ForeColor = $ButtonText
$ClearLastLogin.BackColor = $BoxColor

$ClearLastLogin_Action = {

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
$ClearLastLogin.Add_Click($ClearLastLogin_Action)

#LAPS button
$Lapspw = New-Object system.Windows.Forms.Button
$Lapspw.text = "Get LAPS Password"
$Lapspw.width = 237
$Lapspw.height = 89
$Lapspw.Anchor = 'top'
$Lapspw.location = New-Object System.Drawing.Point(267, 117)
$Lapspw.Font = New-Object System.Drawing.Font('Segoe UI', 12, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
$Lapspw.ForeColor = $ButtonText
$Lapspw.BackColor = $BoxColor

#A seperate GUI applet for LAPS openable when the function is selected
$Lapspw_Action = {
    LAPSTool
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
$appUpdate.ForeColor = $ButtonText
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
$PolicyPatch.ForeColor = $ButtonText
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
$devicetypeInfo = New-Object System.Windows.Forms.ToolStripMenuItem
$domainInfo = New-Object System.Windows.Forms.ToolStripMenuItem
$storageInfo = New-Object System.Windows.Forms.ToolStripMenuItem
$ramInfo = New-Object System.Windows.Forms.ToolStripMenuItem
$cpuInfo = New-Object System.Windows.Forms.ToolStripMenuItem
$adminInfo = New-Object System.Windows.Forms.ToolStripMenuItem
$deviceInfoPrint = New-Object System.Windows.Forms.ToolStripMenuItem
$deviceInfoClipboard = New-Object System.Windows.Forms.ToolStripMenuItem
$deviceInfoTicket = New-Object System.Windows.Forms.ToolStripMenuItem

#HELP TAB
$menuHelp = New-Object System.Windows.Forms.ToolStripMenuItem
$menuAbout = New-Object System.Windows.Forms.ToolStripMenuItem
$menuBugReport = New-Object System.Windows.Forms.ToolStripMenuItem
$menuLicenses = New-Object System.Windows.Forms.ToolStripMenuItem
$menuGitHub = New-Object System.Windows.Forms.ToolStripMenuItem

#FUNCTIONS TAB
$menuFunctions = New-Object System.Windows.Forms.ToolStripMenuItem
$launchDriverUpdater = New-Object System.Windows.Forms.ToolStripMenuItem
$launchDriverUpdaterGUI = New-Object System.Windows.Forms.ToolStripMenuItem
$menuSFCScan = New-Object System.Windows.Forms.ToolStripMenuItem
$menuSuspendBitlocker = New-Object System.Windows.Forms.ToolStripMenuItem
#$menuRenameComputer = New-Object System.Windows.Forms.ToolStripMenuItem - Commented out until I can figure out how to make it work
$menuTestNet = New-Object System.Windows.Forms.ToolStripMenuItem
$menuWiFiDiag = New-Object System.Windows.Forms.ToolStripMenuItem
$menuBatteryDiagnostic = New-Object System.Windows.Forms.ToolStripMenuItem
$menuRebootQuick = New-Object System.Windows.Forms.ToolStripMenuItem
$menuBitlockerRetreive = New-Object System.Windows.Forms.ToolStripMenuItem

#AD Tab
$menuAD = New-Object System.Windows.Forms.ToolStripMenuItem

#Windows Tools
$menuWindowsTools = New-Object System.Windows.Forms.ToolStripMenuItem
$menuWindowsUpdateCheck = New-Object System.Windows.Forms.ToolStripMenuItem
$menuWindowsActivation = New-Object System.Windows.Forms.ToolStripMenuItem

#SCCM Tools
$sccmClientTools = New-Object System.Windows.Forms.ToolStripMenuItem

#SECURITY TAB
$menuSecurity = New-Object System.Windows.Forms.ToolStripMenuItem

#One-Off Tabs
$menuExit = New-Object System.Windows.Forms.ToolStripMenuItem

#Keyboard Shortcuts

#CTRL + P to run deviceInfoPrint
$deviceInfoPrint.ShortcutKeys = [System.Windows.Forms.Keys]::Control + [System.Windows.Forms.Keys]::P
$deviceInfoPrint.ShortcutKeyDisplayString = "CTRL + P"

#CTRL + C to run deviceInfoClipboard
$deviceInfoClipboard.ShortcutKeys = [System.Windows.Forms.Keys]::Control + [System.Windows.Forms.Keys]::C
$deviceInfoClipboard.ShortcutKeyDisplayString = "CTRL + C"

#CTRL + D to run launchDriverUpdaterGUI
$launchDriverUpdaterGUI.ShortcutKeys = [System.Windows.Forms.Keys]::Control + [System.Windows.Forms.Keys]::D
$launchDriverUpdaterGUI.ShortcutKeyDisplayString = "CTRL + D"

#CTRL + F to run launchDriverUpdater
$launchDriverUpdater.ShortcutKeys = [System.Windows.Forms.Keys]::Control + [System.Windows.Forms.Keys]::F
$launchDriverUpdater.ShortcutKeyDisplayString = "CTRL + F"

#CTRL + S to run menuSFCScan
$menuSFCScan.ShortcutKeys = [System.Windows.Forms.Keys]::Control + [System.Windows.Forms.Keys]::S
$menuSFCScan.ShortcutKeyDisplayString = "CTRL + S"

#CTRL + Shift +  B to run menuSuspendBitlocker
$menuSuspendBitlocker.ShortcutKeys = [System.Windows.Forms.Keys]::Control + [System.Windows.Forms.Keys]::Shift + [System.Windows.Forms.Keys]::B
$menuSuspendBitlocker.ShortcutKeyDisplayString = "CTRL + SHIFT + B"

#CTRL + Shift + T to run menuTestNet
$menuTestNet.ShortcutKeys = [System.Windows.Forms.Keys]::Control + [System.Windows.Forms.Keys]::Shift + [System.Windows.Forms.Keys]::T
$menuTestNet.ShortcutKeyDisplayString = "CTRL + SHIFT + T"

#CTRL + Shift + W to run menuWiFiDiag
$menuWiFiDiag.ShortcutKeys = [System.Windows.Forms.Keys]::Control + [System.Windows.Forms.Keys]::Shift + [System.Windows.Forms.Keys]::W
$menuWiFiDiag.ShortcutKeyDisplayString = "CTRL + SHIFT + W"

#CTRL + Shift + Q to run menuRebootQuick
$menuRebootQuick.ShortcutKeys = [System.Windows.Forms.Keys]::Control + [System.Windows.Forms.Keys]::Shift + [System.Windows.Forms.Keys]::Q
$menuRebootQuick.ShortcutKeyDisplayString = "CTRL + SHIFT + Q"

#CTRL + Shift + R to run menuRenameComputer
#$menuRenameComputer.ShortcutKeys = [System.Windows.Forms.Keys]::Control + [System.Windows.Forms.Keys]::Shift + [System.Windows.Forms.Keys]::R
#$menuRenameComputer.ShortcutKeyDisplayString = "CTRL + SHIFT + R"

#Assigning tab menu items

#Info Tab
$menuInfo.Text = "Info"
$outputsuppressed = $menu.Items.Add($menuInfo)
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
if ($winverCompliant -eq $false) {
    $windowsVersion.BackColor = 'Red'
    $windowsVersion.ForeColor = 'White'
}
else {
    $windowsVersion.BackColor = $BGcolor
    $windowsVersion.ForeColor = $TextColor
}
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
$outputsuppressed = $menuInfo.DropDownItems.Add($devicetypeInfo)

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
$outputsuppressed = $menuInfo.DropDownItems.Add($storageInfo)

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
$outputsuppressed = $menuInfo.DropDownItems.Add($adminInfo)

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

#Device Info Ticket
if ($null -eq $ticketType) {
    #If ticket type is null, do nothing, and disable the button
    $deviceInfoTicket.Text = "Send Device Info to Ticketing System"
    $deviceInfoTicket.BackColor = $BGcolor
    $deviceInfoTicket.ForeColor = $TextColor
    $deviceInfoTicket.Enabled = $false
    $deviceInfoTicket.ToolTipText = "Sends device info to ticketing system. Not configured presently. Coming in 1.2.1"
    $outputsuppressed = $menuInfo.DropDownItems.Add($deviceInfoTicket)
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
    $outputsuppressed = $menuInfo.DropDownItems.Add($deviceInfoTicket)
}

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
#Set keyboard shortcut to Ctrl + R
$menuFun.ShortcutKeys = [System.Windows.Forms.Keys]::Control + [System.Windows.Forms.Keys]::R

$outputsuppressed = $menuHelp.DropDownItems.Add($menuFun)

#Licenses Button - Displays basic license information
$menuLicenses.Text = "Licenses"
$menuLicenses.Add_Click({
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("This application is written under a BSD 3-Clause License by Eli Weitzman. For more information on how this works, visit our GitHub Repository.", 0, "About", 64)
    })
$menuLicenses.BackColor = $BGcolor
$menuLicenses.ForeColor = $TextColor
$outputsuppressed = $menuHelp.DropDownItems.Add($menuLicenses)

#GitHub Button
$menuGitHub.Text = "GitHub"
$menuGitHub.Add_Click({
        #Open a web browser to the GitHub repository
        Start-Process https://github.com/eliweitzman/EnterpriseTechTool
    })
$menuGitHub.BackColor = $BGcolor
$menuGitHub.ForeColor = $TextColor
$outputsuppressed = $menuHelp.DropDownItems.Add($menuGitHub)

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
    })
$launchDriverUpdater.BackColor = $BGcolor
$launchDriverUpdater.ForeColor = $TextColor
$outputsuppressed = $menuFunctions.DropDownItems.Add($launchDriverUpdater)

#Launch Driver Updater GUI Button - Launches driver update GUI based on manufacturer - Currently only supports Dell and Lenovo
$launchDriverUpdaterGUI.Text = "Launch Driver Updater (GUI)"
$launchDriverUpdaterGUI.Add_Click({
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
    })
$menuSuspendBitLocker.BackColor = $BGcolor
$menuSuspendBitLocker.ForeColor = $TextColor
$outputsuppressed = $menuFunctions.DropDownItems.Add($menuSuspendBitLocker)

#Test Network Button - Tests network connectivity
$menuTestNet.Text = "Test Network"
$menuTestNet.Add_Click({
        #Test Network
        Start-Process powershell.exe -ArgumentList "-command Test-NetConnection -ComputerName google.com; pause" -PassThru -Wait
    })
$menuTestNet.BackColor = $BGcolor
$menuTestNet.ForeColor = $TextColor
$outputsuppressed = $menuFunctions.DropDownItems.Add($menuTestNet)

#WiFi Diagnostics Button - Tests WiFi Connection
$menuWiFiDiag.Text = "Launch Wi-Fi Diagnostics"
$menuWiFiDiag.Add_Click({
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
    })
$menuWiFiDiag.BackColor = $BGcolor
$menuWiFiDiag.ForeColor = $TextColor
$outputsuppressed = $menuFunctions.DropDownItems.Add($menuWiFiDiag)

#Battery Diagnostic Button - Tests Battery Health
$menuBatteryDiagnostic.Text = "Launch Battery Diagnostic"
$menuBatteryDiagnostic.Add_Click({
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
    })
$menuBatteryDiagnostic.BackColor = $BGcolor
$menuBatteryDiagnostic.ForeColor = $TextColor
$outputsuppressed = $menuFunctions.DropDownItems.Add($menuBatteryDiagnostic)

#Quick Reboot Button - Reboots the computer
$menuRebootQuick.Text = "Quick Reboot"
$menuRebootQuick.Add_Click({
        #First, confirm reboot
        $wshell = New-Object -ComObject Wscript.Shell
        if ($wshell.Popup("Are you sure you want to reboot? Make sure everything is saved before proceeding.", 0, "Reboot", 4 + 32) -eq 6) {
            #Reboot
            Start-Process shutdown -argumentlist "-r -t 0" -PassThru
        }

    })
$menuRebootQuick.BackColor = $BGcolor
$menuRebootQuick.ForeColor = $TextColor
$outputsuppressed = $menuFunctions.DropDownItems.Add($menuRebootQuick)

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

$menuBitlockerRetreive.Text = "Retrieve BitLocker Key"
$menuBitlockerRetreive.Add_Click({
        bitlockerTool
    })
$menuBitlockerRetreive.BackColor = $BGcolor
$menuBitlockerRetreive.ForeColor = $TextColor
$outputsuppressed = $menuFunctions.DropDownItems.Add($menuBitlockerRetreive)

#AD Tab
$menuAD.Text = "AD Lookup"
$menuAD.Add_Click({
        #Test if RSAT is installed
        try {
            Get-ADUser -Identity $env:USERNAME -ErrorAction SilentlyContinue
            #AD Lookup
            ADLookup
        }
        catch {
            $wshell = New-Object -ComObject Wscript.Shell
            $wshell.Popup("RSAT AD Tools or your permissions level are not compliant. Please install RSAT AD tools or use an entitled account and try again.", 0, "RSAT", 64)
        }
    })
$outputsuppressed = $menu.Items.Add($menuAD)

#Windows Tools Tab
$menuWindowsTools.Text = "Windows"
$outputsuppressed = $menu.Items.Add($menuWindowsTools)

#Windows Update Check Button - Checks for Windows Updates
$menuWindowsUpdateCheck.Text = "Check for Windows Updates"
$menuWindowsUpdateCheck.BackColor = $BGcolor
$menuWindowsUpdateCheck.ForeColor = $TextColor

#Add sub-menu items to Windows Update Check Button - Full Sweep
$menuWindowsUpdateCheckFullSweep = New-Object System.Windows.Forms.ToolStripMenuItem
$menuWindowsUpdateCheckFullSweep.Text = "Full Sweep"
$menuWindowsUpdateCheckFullSweep.Add_Click({

        CheckForWindowsUpdates -windowTitle "All Windows Updates" -noUpdatesMessage "No updates available." -updateSearchQuery "IsHidden=0 and IsInstalled=0"
        
    })
$menuWindowsUpdateCheckFullSweep.BackColor = $BGcolor
$menuWindowsUpdateCheckFullSweep.ForeColor = $TextColor
$outputsuppressed = $menuWindowsUpdateCheck.DropDownItems.Add($menuWindowsUpdateCheckFullSweep)

#Add sub-menu items to Windows Update Check Button - Defender Definition Updates
$menuWindowsUpdateCheckDefender = New-Object System.Windows.Forms.ToolStripMenuItem
$menuWindowsUpdateCheckDefender.Text = "Defender Definition Updates"
$menuWindowsUpdateCheckDefender.Add_Click({

        CheckForWindowsUpdates -windowTitle "Windows Defender Definition Updates" -noUpdatesMessage "No Windows Defender Definition updates found." -updateSearchQuery "IsInstalled=0 and Type='Software' and IsHidden=0 and BrowseOnly=0 and AutoSelectOnWebSites=1 and CategoryIDs contains '8c3fcc84-7410-4a95-8b89-a166a0190486'"
  
    })
$menuWindowsUpdateCheckDefender.BackColor = $BGcolor
$menuWindowsUpdateCheckDefender.ForeColor = $TextColor
$outputsuppressed = $menuWindowsUpdateCheck.DropDownItems.Add($menuWindowsUpdateCheckDefender)

$outputsuppressed = $menuWindowsTools.DropDownItems.Add($menuWindowsUpdateCheck)

#Windows Activation Button - Windows Activation Key
$menuWindowsActivation.Text = "Get Windows Activation Key"
$menuWindowsActivation.Add_Click({
        $HardwareKey = (Get-WmiObject -query 'select * from SoftwareLicensingService' | Select-Object OA3xOriginalProductKey).OA3xOriginalProductKey
        
        #Verify that the key is not null
        if ($HardwareKey -eq $null -or $HardwareKey -eq "") {
            $wshell = New-Object -ComObject Wscript.Shell
            $wshell.Popup("No Windows Activation Key found in WMI." + "`n`nThis could be the result of running in a VM, or not stored in BIOS", 0, "Windows Activation", 64)
        }
        else {
            #Key is not null, so display it in a popup
            $wshell = New-Object -ComObject Wscript.Shell
            $wshell.Popup("Windows Activation Key: " + $HardwareKey + "`n`nKey Copied to Clipboard.", 0, "Windows Activation Key", 64)
        }
        
    })
$menuWindowsActivation.BackColor = $BGcolor
$menuWindowsActivation.ForeColor = $TextColor
$outputsuppressed = $menuWindowsTools.DropDownItems.Add($menuWindowsActivation)

#SCCM Functions Button - Displays a list of SCCM Client functions if the client is present on the machine
#Check to see if the SCCM client is installed and we have the required WMI class
$sccmClass = Get-WmiObject -Class "SMS_Client" -List -Namespace "root\CCM" -ErrorAction SilentlyContinue
$sccmClassExists = $sccmClass -ne $null

#Create the SCCM Trigger Schedule Table
$sccmTSTable = [ordered]@{}
$sccmTSTable.Add("Application Deployment Evaluation Cycle", "{00000000-0000-0000-0000-000000000121}")
$sccmTSTable.Add("Discovery Data Collection Cycle", "{00000000-0000-0000-0000-000000000103}")
$sccmTSTable.Add("File Collection Cycle", "{00000000-0000-0000-0000-000000000104}")
$sccmTSTable.Add("Hardware Inventory Cycle", "{00000000-0000-0000-0000-000000000001}")
$sccmTSTable.Add("Machine Policy Retrieval", "{00000000-0000-0000-0000-000000000021}")
$sccmTSTable.Add("Machine Policy Evaluation Cycle", "{00000000-0000-0000-0000-000000000022}")
$sccmTSTable.Add("Software Inventory Cycle", "{00000000-0000-0000-0000-000000000002}" )
$sccmTSTable.Add("Software Metering Usage Report Cycle", "{00000000-0000-0000-0000-000000000106}")
$sccmTSTable.Add("Software Updates Deployment Evaluation Cycle", "{00000000-0000-0000-0000-000000000114}")
$sccmTSTable.Add("User Policy Retrieval", "{00000000-0000-0000-0000-000000000026}")
$sccmTSTable.Add("User Policy Evaluation Cycle", "{00000000-0000-0000-0000-000000000027}")
$sccmTSTable.Add("Windows Installer Source List Update Cycle", "{00000000-0000-0000-0000-000000000107}")

#SCCM Trigger helper function
function TriggerSCCMClientFunction {
    param (
        $TriggerScheduleGUID,
        $TriggerScheduleName
    )
    Invoke-CimMethod -Namespace 'root\CCM' -ClassName SMS_Client -MethodName TriggerSchedule -Arguments @{sScheduleID = $TriggerScheduleGUID }
    $wshell = New-Object -ComObject Wscript.Shell
    $wshell.Popup("SCCM Client Task $TriggerScheduleName Triggered. The selected task will run and might take several minutes to finish.", 0, "SCCM Client Task", 64)
}

#SCCM Tools Menu Construction
#If the SCCM Client is not installed on the computer, the menu option will be unavailable.
if ($sccmClassExists) {
    $outputsuppressed = $menu.Items.Add($sccmClientTools)
}
$sccmClientTools.Text = "SCCM Tools"

foreach ($key in $($sccmTSTable.Keys)) {
    $tmpButton = New-Object System.Windows.Forms.ToolStripMenuItem
    $tmpButton.Text = $key
    $tmpButton.BackColor = $BGcolor
    $tmpButton.ForeColor = $TextColor
    $tmpButton.Add_Click({
            TriggerSCCMClientFunction -TriggerScheduleGUID $sccmTSTable[$key] -TriggerScheduleName $key
        })
    $outputsuppressed = $sccmClientTools.DropDownItems.Add($tmpButton)
}

#Security TAB Construction
$menuSecurity.Text = "Security"
$outputsuppressed = $menu.Items.Add($menuSecurity)

$hostsHash = (Get-FileHash "C:\Windows\System32\Drivers\etc\hosts").Hash
$hostsCompliant = $true
$hostsText = "Host File Integrity: Unmodified"
if ($hostsHash -ne "2D6BDFB341BE3A6234B24742377F93AA7C7CFB0D9FD64EFA9282C87852E57085") {
    $hostsCompliant = $false
    $hostsText = "Host File Integrity: Modified"
}

$hostsChkButton = New-Object System.Windows.Forms.ToolStripMenuItem
$hostsChkButton.Text = $hostsText
$hostsChkButton.BackColor = $BGcolor
$hostsChkButton.ForeColor = $TextColor
$outputsuppressed = $menuSecurity.DropDownItems.Add($hostsChkButton)

#Exit Button
$menuExit.Text = "Exit"
$menuExit.Add_Click({ $ETT.Close() })
$outputsuppressed = $menu.Items.Add($menuExit)

#For non-admin mode, show the UAC shield on the buttons that require admin mode
if ($adminmode -eq $false) {
    $menuWiFiDiag.Image = $shieldIcon
    $menuSFCScan.Image = $shieldIcon
    $menuSuspendBitlocker.Image = $shieldIcon
    $menuBatteryDiagnostic.Image = $shieldIcon
}

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