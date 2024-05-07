function LAPSTool {
    Param(
        [Parameter(Position=0,mandatory=$true)]
        [System.Drawing.Color]$BackgroundColor, 
        [Parameter(Position=1,mandatory=$true)]
        [System.Drawing.Color]$TextColor,
        [Parameter(Position=2,mandatory=$true)]
        [System.Drawing.Color]$BoxColor
        )

    # Import the module
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()

    #Create box
    $LapsForm = New-Object system.Windows.Forms.Form
    $LapsForm.ClientSize = New-Object System.Drawing.Point(450, 301)
    $LapsForm.text = "LAPS GUI"
    $LapsForm.BackColor = $BackgroundColor
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
                $domainInput.Enabled = $true

                #Enable the domain input box, and remove the domain from the input box
                $domainInput.Text = ""
                $domainInput.Text = $azureADTenantId
                
                #Move the domain input box to the right to make room for title text
                $domainInput.Location = New-Object System.Drawing.Point(90, 114)

                #If Azure LAPS is checked, change the hostname input box to the device ID input box
                $hostnameLabel.Text = "Device ID:"
                $hostnameInput.Text = ""

                #Align the username input box with the hostname input box
                $usernameInfo.Location = New-Object System.Drawing.Point(16, 189)

                #If Azure LAPS is checked, change the username input box to the client ID input box
                $usernameInfo.Text = "Client ID:"
                $usernameInput.Text = $lapsAppClientId
                $usernameInput.Enabled = $true

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
    $domainInput.Text = $domain

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
                        Connect-MgGraph -TenantId $tenantID -ClientId $clientID -Scope Device.Read.All
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
                            $wshell.Popup("Password for $($hostnameInput.Text) is $lapsResult. Copied to clipboard.", 0, "Password", 0x0)
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