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
    $SearchButton.BackColor = $BrandColor
    $SearchButton.ForeColor = $ButtonText
    MUST COMPILE WITH x64
#>
function ADLookup {
    Param(
        [Parameter(Position=0,mandatory=$true)]
        [System.Drawing.Color]$BackgroundColor, 
        [Parameter(Position=1,mandatory=$true)]
        [System.Drawing.Color]$TextColor,
        [Parameter(Position=2,mandatory=$true)]
        [System.Drawing.Color]$BrandColor,
        [Parameter(Position=3,mandatory=$true)]
        [System.Drawing.Color]$ButtonTextColor
        )

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
    $ADForm.BackColor = $BackgroundColor

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
    $SearchButton.ForeColor = $ButtonTextColor
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