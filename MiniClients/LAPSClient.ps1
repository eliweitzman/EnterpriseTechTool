#Standalone LAPS GUI Development Section

#Color placeholders
$BGcolor = "#000000"
$TextColor = "#FFFFFF"
$BoxColor = "#000000"
    
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
$titleTag.AutoSize = $true
$titleTag.width = 25
$titleTag.height = 10
$titleTag.location = New-Object System.Drawing.Point(88, 20)
$titleTag.Font = New-Object System.Drawing.Font('Segoe UI', 16, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
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

#Logic to enable/disable username input box
$altCreds.Add_CheckStateChanged({
        if ($altCreds.Checked -eq $true) {
            $usernameInput.Enabled = $true
        }
        else {
            $usernameInput.Enabled = $false
        }
    })

#Logic to update the username input box when the domain input box is updated
$domainInput.Add_TextChanged({
        $usernameInput.Text = $domainInput.Text + "\" + $env:USERNAME
    })

#Start button that closes window to run
$lapsStart = New-Object system.Windows.Forms.Button
$lapsStart.text = "Start"
$lapsStart.width = 125
$lapsStart.height = 30
$lapsStart.location = New-Object System.Drawing.Point(154, 251)
$lapsStart.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
$lapsStart.BackColor = $BoxColor
$lapsStart.Add_Click({ 
        #First, check if Windows LAPS is checked
        if ($windowsLaps.Checked -eq $false) {
            #Next, run a test AD query to see if the user has RSAT and entitlements to run the command
            try {
                $testcaser = Get-ADUser -Identity $env:USERNAME -ErrorAction SilentlyContinue
                if ($altCreds.Checked -eq $true) {
        
                    #IF Windows LAPS is off, alternate credentials is on, run the command with alternate credentials
                    $output = Get-ADComputer $hostname -Server $domain -Credential (Get-Credential -Credential $usernameInput.Text) -Properties ms-Mcs-AdmPwd | Select-Object -ExpandProperty ms-Mcs-AdmPwd
            
                    #If the output is null, the computer is not in AD
                    if ($output -eq $null) {
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
                else {
                    #If Windows LAPS is off, and alternate credentials is off, run the command with current credentials
                    $output = Get-ADComputer $hostname -Server $domain -Properties ms-Mcs-AdmPwd | Select-Object -ExpandProperty ms-Mcs-AdmPwd
            
                    #If the output is null, the computer is not in AD
                    if ($output -eq $null) {
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
            }
            catch {
                #If the user does not have RSAT or entitlements, the command will fail and the user will be notified
                $wshell = New-Object -ComObject Wscript.Shell
                $wshell.Popup("You do not have the required permissions to run this option. Either RSAT AD Tools, or User Permissions block this route. Use Windows LAPS instead.", 0, "Error", 0x1)

                #Check the Windows LAPS box to allow the user to run the command without RSAT or entitlements
                $windowsLaps.Checked = $true
            }
        }
        elseif ($windowsLaps.Checked -eq $true) {
            #Next, check if alternate credentials is checked
            if ($altCreds.Checked -eq $true) {
                $altcredCheck = Get-Credential -Credential $usernameInput.Text
                #IF Windows LAPS is on, alternate credentials is on, run the command with alternate credentials
                $output = Get-LapsADPassword  $hostnameInput.Text -Credential $altcredCheck -DecryptionCredential $altcredCheck -Domain $domainInput.Text $altcredCheck -AsPlainText
                
                #If the output is null, the computer is not in AD. If Output is a secure string, the LAPS is encrypted and requires a decryption credential
                if ($output -eq $null) {
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
            else {
                #If Windows LAPS is on, and alternate credentials is off, run the command with current credentials
                $output = Get-LapsADPassword $hostnameInput.Text -AsPlainText -Domain $domainInput.Text | Select-Object -ExpandProperty Password
                
                #If the output is null, the computer is not in AD. If Output is a secure string, the LAPS is encrypted and requires a decryption credential
                if ($output -eq $null) {
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
        }
    })
#Add keypress event to start button
$LapsForm.KeyPreview = $true
$LapsForm.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { $lapsStart.PerformClick() } })

#Print the above GUI applets in the box
$LapsForm.controls.AddRange(@($Lapslogo, $domainInput, $domainLabel, $titleTag, $hostnameLabel, $hostnameInput, $usernameInfo, $usernameInput, $lapsStart, $windowsLaps, $altCreds))

#SHOW ME THE MONEY
[void]$LapsForm.ShowDialog()