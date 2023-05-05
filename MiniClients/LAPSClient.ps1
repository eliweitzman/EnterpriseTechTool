#Standalone LAPS GUI Development Section
    
##FIRST SECTION INPUT FIELD
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()
    
#Create box
$LapsForm = New-Object system.Windows.Forms.Form
$LapsForm.ClientSize = New-Object System.Drawing.Point(500, 301)
$LapsForm.text = "LAPS GUI"
$LapsForm.TopMost = $true
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
$usernameInfo.text = "Your Username"
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
$lapsStart.Add_Click({ 
        #RUN LAPS OPERATION
    
        #Converting input from prior box into a LAPS run
        $hostname = $hostnameInput.Text
        $domain = $domainInput.Text
        $username = "$hostname\$usernameInput.Text"

        #Run LAPS in new powershell window
        $output = Get-ADComputer $hostname -Properties * -Server $domain -Credential $username | Select-Object -ExpandProperty ms-Mcs-AdmPwd

        #Add password to the clipboard
        Set-Clipboard -Value $output
    
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("Password: " + $output + "`r`n(Result has as well been copied to clipboard)", 0, "LAPS Result", 64) 
})
    
#Print the above GUI applets in the box
$LapsForm.controls.AddRange(@($Lapslogo, $domainInput, $domainLabel, $titleTag, $hostnameLabel, $hostnameInput, $usernameInfo, $usernameInput, $lapsStart))

#SHOW ME THE MONEY
[void]$LapsForm.ShowDialog()
    

