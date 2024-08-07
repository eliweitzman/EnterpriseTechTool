function BitlockerTool {
    Param(
        [Parameter(Position=0,mandatory=$true)]
        [System.Drawing.Color]$BackgroundColor, 
        [Parameter(Position=1,mandatory=$true)]
        [System.Drawing.Color]$WindowTextColor,
        [Parameter(Position=2,mandatory=$true)]
        [System.Drawing.Color]$ButtonColor,
        [Parameter(Position=2,mandatory=$true)]
        [System.Drawing.Color]$ButtonTextColor
        )

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
    $BForm.BackColor = $BackgroundColor
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
    $BTitle.ForeColor = $WindowTextColor
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
    $BHostname.ForeColor = $WindowTextColor
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
    $BUsername.ForeColor = $WindowTextColor
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
    $BSubmit.ForeColor = $ButtonTextColor
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