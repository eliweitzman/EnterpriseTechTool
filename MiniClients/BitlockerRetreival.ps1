
    #Test RSAT AD Tools is installed
    if (Get-Command -Name Get-ADComputer -ErrorAction SilentlyContinue) {
        #RSAT is installed
        $RSATStatus = "Installed"
    }
    else {
        #RSAT is not installed
        $RSATStatus = "Not Installed"
    }

    ##FIRST SECTION INPUT FIELD
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()

    #Create box
    $BForm = New-Object system.Windows.Forms.Form
    $BForm.ClientSize = New-Object System.Drawing.Point(500, 280)
    $BForm.text = "BitLocker Retreival"
    $BForm.TopMost = $true
    $BForm.BackColor = $BGcolor
    $BForm.MaximizeBox = $false
    $BForm.MaximumSize = $BTLForm.Size
    $BForm.MinimumSize = $BTLForm.Size

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
    $BSubmit.BackColor = $ButtonColor

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
            $wshell.Popup("Hostname cannot be empty",0,"Error",0x1)

            #Stop action
            return
        }

        try {
            $ADComputer = Get-ADComputer -Identity $hostname -ErrorAction Stop
        }
        catch {
            $wshell = New-Object -ComObject Wscript.Shell
            $wshell.Popup("Hostname not found in AD",0,"Error",0x1)
        }

        #Create LDAP path
        $LDAPPath = "LDAP://" + $ADComputer.DistinguishedName

        #Generate LDAP Object
        $LADPObj = Get-ChildItem $LDAPPath | Where-Object {$_.ObjectClass -eq "msFVE-RecoveryInformation"}

        #Adapt AD Query
        $LDAPPath = "AD:\", $LDAPObj.DistinguishedName -join ""

        #Get Bitlocker Recovery Key
        $pw = Get-Item $LDAPObj -properties "msFVE-RecoveryPassword"
        $recoveryPassword = $pw."msFVE-RecoveryPassword"

        #Check if LDAP Object is empty
        if ($LADPObj -eq $null) {
            $wshell = New-Object -ComObject Wscript.Shell
            $wshell.Popup("No Bitlocker Recovery Key found",0,"Error",0x1)
        }

        #Check if Bitlocker Recovery Key is empty
        elseif ($recoveryPassword -eq $null) {
            $wshell = New-Object -ComObject Wscript.Shell
            $wshell.Popup("No Bitlocker Recovery Key found",0,"Error",0x1)
        }

        #If Bitlocker Recovery Key is found, display it
        else {
            $wshell = New-Object -ComObject Wscript.Shell
            $wshell.Popup("Bitlocker Recovery Key: " + $recoveryPassword + "`n`nResult Copied to Clipboard",0,"Bitlocker Recovery Key",0x0)
            $recoveryPassword | clip
        }

    })

    $BForm.Controls.Add($BSubmit)

    


    #Show Form
    $BForm.ShowDialog()