function Create-GenericToolWindow{
    Param(
        [Parameter(Position=0,mandatory=$true)]
        $WindowTitle,
        [Parameter(Position=1,mandatory=$true)]
        $WindowBackgroundColor,
        [Parameter(Position=2,mandatory=$true)]
        $WindowTextColor,
        [Parameter(Position=3,mandatory=$true)]
        $IconPathURL,
        [Parameter(Position=4,mandatory=$true)]
        $ExecuteButtonText,
        [Parameter(Position=5,mandatory=$true)]
        $ExecuteButtonBackgroundColor,
        [Parameter(Position=6,mandatory=$true)]
        $ExecuteButtonTextColor,
        [Parameter(Position=7,mandatory=$true)]
        $ExecuteButtonScriptBlock

    )

    # Import the module
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()

    #Create Window
    $MainForm = New-Object system.Windows.Forms.Form
    $MainForm.ClientSize = New-Object System.Drawing.Point(470, 230)
    $MainForm.text = $WindowTitle
    $MainForm.TopMost = $true
    $MainForm.BackColor = $WindowBackgroundColor
    $MainForm.MaximizeBox = $false
    $MainForm.MaximumSize = $MainForm.Size
    $MainForm.MinimumSize = $MainForm.Size

    #Create Header Label
    $HeaderTitle = New-Object system.Windows.Forms.Label
    $HeaderTitle.text = $WindowTitle
    $HeaderTitle.AutoSize = $true
    $HeaderTitle.location = New-Object System.Drawing.Point(88, 10)
    $HeaderTitle.Font = New-Object System.Drawing.Font('Segoe UI', 16, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
    $HeaderTitle.ForeColor = $WindowTextColor
    $MainForm.Controls.Add($HeaderTitle)

    #Logo (sourced from WinAero gal)
    $LogoPictureBox = New-Object system.Windows.Forms.PictureBox
    $LogoPictureBox.width = 75
    $LogoPictureBox.height = 75
    $LogoPictureBox.location = New-Object System.Drawing.Point(375, 17)
    $LogoPictureBox.imageLocation = $IconPathURL
    $LogoPictureBox.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::zoom
    $MainForm.Controls.Add($LogoPictureBox)

    #Create ADPanel
    $ADQueryPanel = New-Object system.Windows.Forms.Panel
    $ADQueryPanel.Width = 385
    $ADQueryPanel.Height = 90
    $ADQueryPanel.location = New-Object System.Drawing.Point(0, 85)
    #$ADQueryPanel.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
    $ADQueryPanel.BackColor = $WindowBackgroundColor
    $MainForm.Controls.Add($ADQueryPanel)

    #Create ADHostNameLabel
    $ADHostNameLabel = New-Object system.Windows.Forms.Label
    $ADHostNameLabel.text = "Hostname:"
    $ADHostNameLabel.width = 85
    $ADHostNameLabel.height = 17
    $ADHostNameLabel.location = New-Object System.Drawing.Point(16, 0)
    $ADHostNameLabel.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
    $ADHostNameLabel.ForeColor = $WindowTextColor
    $ADQueryPanel.Controls.Add($ADHostNameLabel)

    #Create ADHostNameTextBox
    $ADHostNameTextBox = New-Object system.Windows.Forms.TextBox
    $ADHostNameTextBox.Text = ""
    $ADHostNameTextBox.multiline = $false
    $ADHostNameTextBox.width = 269
    $ADHostNameTextBox.height = 20
    $ADHostNameTextBox.location = New-Object System.Drawing.Point(100, 0)
    $ADHostNameTextBox.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)
    $ADQueryPanel.Controls.Add($ADHostNameTextBox)

    #Create ADUserNameLabel
    $ADUserNameLabel = New-Object system.Windows.Forms.Label
    $ADUserNameLabel.text = "Username:"
    $ADUserNameLabel.width = 85
    $ADUserNameLabel.height = 17
    $ADUserNameLabel.location = New-Object System.Drawing.Point(16, 30)
    $ADUserNameLabel.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
    $ADUserNameLabel.ForeColor = $WindowTextColor
    $ADQueryPanel.Controls.Add($ADUserNameLabel)

    $domain = (Get-CIMInstance -ClassName Win32_ComputerSystem).Domain
    #Create ADUserNameTextBox
    $ADUserNameTextBox = New-Object system.Windows.Forms.TextBox
    $ADUserNameTextBox.Text = "$($domain + "\" + $env:USERNAME)"
    $ADUserNameTextBox.multiline = $false
    $ADUserNameTextBox.width = 269
    $ADUserNameTextBox.height = 20
    $ADUserNameTextBox.location = New-Object System.Drawing.Point(100, 30)
    $ADUserNameTextBox.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)
    $ADQueryPanel.Controls.Add($ADUserNameTextBox)

    #Create ADDomainNameLabel
    $ADDomainNameLabel = New-Object system.Windows.Forms.Label
    $ADDomainNameLabel.text = "Domain:"
    $ADDomainNameLabel.width = 85
    $ADDomainNameLabel.height = 17
    $ADDomainNameLabel.location = New-Object System.Drawing.Point(16, 60)
    $ADDomainNameLabel.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
    $ADDomainNameLabel.ForeColor = $WindowTextColor
    $ADQueryPanel.Controls.Add($ADDomainNameLabel)

    $domain = (Get-CIMInstance -ClassName Win32_ComputerSystem).Domain
    #Create ADDomainNameTextBox
    $ADDomainNameTextBox = New-Object system.Windows.Forms.TextBox
    $ADDomainNameTextBox.Text = "$($domain)"
    $ADDomainNameTextBox.multiline = $false
    $ADDomainNameTextBox.width = 269
    $ADDomainNameTextBox.height = 20
    $ADDomainNameTextBox.location = New-Object System.Drawing.Point(100, 60)
    $ADDomainNameTextBox.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)
    $ADQueryPanel.Controls.Add($ADDomainNameTextBox)

    #Entra ID Stuff
    #Create AzureADQueryPanel
    $AzureADQueryPanel = New-Object system.Windows.Forms.Panel
    $AzureADQueryPanel.Width = 385
    $AzureADQueryPanel.Height = 90
    $AzureADQueryPanel.location = New-Object System.Drawing.Point(0, 85)
    #$ADQueryPanel.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
    $AzureADQueryPanel.BackColor = $WindowBackgroundColor
    $AzureADQueryPanel.Visible = $false
    $MainForm.Controls.Add($AzureADQueryPanel)

    #Create ADHostNameLabel
    $AzureADHostNameLabel = New-Object system.Windows.Forms.Label
    $AzureADHostNameLabel.text = "Hostname:"
    $AzureADHostNameLabel.width = 85
    $AzureADHostNameLabel.height = 17
    $AzureADHostNameLabel.location = New-Object System.Drawing.Point(16, 0)
    $AzureADHostNameLabel.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
    $AzureADHostNameLabel.ForeColor = $WindowTextColor
    $AzureADQueryPanel.Controls.Add($AzureADHostNameLabel)

    #Create ADHostNameTextBox
    $AzureADHostNameTextBox = New-Object system.Windows.Forms.TextBox
    $AzureADHostNameTextBox.Text = ""
    $AzureADHostNameTextBox.multiline = $false
    $AzureADHostNameTextBox.width = 269
    $AzureADHostNameTextBox.height = 20
    $AzureADHostNameTextBox.location = New-Object System.Drawing.Point(100, 0)
    $AzureADHostNameTextBox.Font = New-Object System.Drawing.Font('Microsoft Sans Serif', 10)
    $AzureADQueryPanel.Controls.Add($AzureADHostNameTextBox)

    #Create MSGraphSessionLabel
    $MSGraphSessionLabel = New-Object system.Windows.Forms.Label
    $MSGraphSessionLabel.Text = "MS Graph Session: $(Get-MGContext | Select -expandproperty Account)"
    $MSGraphSessionLabel.width = 500
    $MSGraphSessionLabel.height = 17
    $MSGraphSessionLabel.location = New-Object System.Drawing.Point(16, 30)
    $MSGraphSessionLabel.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
    $MSGraphSessionLabel.ForeColor = $WindowTextColor
    $AzureADQueryPanel.Controls.Add($MSGraphSessionLabel)

    #Create LogoutMSGraph Button
    $LogoutMSGraphButton = New-Object system.Windows.Forms.Button
    $LogoutMSGraphButton.text = "Logout MS Graph"
    $LogoutMSGraphButton.width = 150
    $LogoutMSGraphButton.height = 30
    $LogoutMSGraphButton.location = New-Object System.Drawing.Point(150, 55)
    $LogoutMSGraphButton.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
    $LogoutMSGraphButton.ForeColor = $ExecuteButtonTextColor
    $LogoutMSGraphButton.BackColor = $ExecuteButtonBackgroundColor
    $LogoutMSGraphButton.Add_Click({Disconnect-MgGraph -ErrorAction SilentlyContinue; $MSGraphSessionLabel.Text = "MS Graph Session: $(Get-MGContext | Select -expandproperty Account)"})
    $AzureADQueryPanel.Controls.Add($LogoutMSGraphButton)


    #Create SourcePanel
    $SourcePanel = New-Object system.Windows.Forms.Panel
    $SourcePanel.Width = 385
    $SourcePanel.Height = 25
    $SourcePanel.location = New-Object System.Drawing.Point(0, 60)
    $SourcePanel.BackColor = $WindowBackgroundColor
    $MainForm.Controls.Add($SourcePanel)

    #Create SourceLabel
    $SourceLabel = New-Object System.Windows.Forms.Label
    $SourceLabel.text = "Source:"
    $SourceLabel.width = 65
    $SourceLabel.height = 23
    $SourceLabel.location = New-Object System.Drawing.Point(16, 0)
    $SourceLabel.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
    $SourceLabel.ForeColor = $WindowTextColor
    $SourcePanel.Controls.Add($sourceLabel)

    #Create SourceOnPremCheckBox
    $SourceOnPremCheckBox = New-Object System.Windows.Forms.RadioButton
    $SourceOnPremCheckBox.Text = "On-Prem"
    $SourceOnPremCheckBox.Width = 104
    $SourceOnPremCheckBox.Height = 24
    $SourceOnPremCheckBox.location = New-Object System.Drawing.Point(100, 0)
    $SourceOnPremCheckBox.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
    $SourceOnPremCheckBox.Checked = $true
    $SourcePanel.Controls.Add($SourceOnPremCheckBox)

    #Create SourceEntraIDCheckBox
    $SourceEntraIDCheckBox = New-Object System.Windows.Forms.RadioButton
    $SourceEntraIDCheckBox.Text = "Microsoft Entra ID"
    $SourceEntraIDCheckBox.Width = 200
    $SourceEntraIDCheckBox.Height = 24
    $SourceEntraIDCheckBox.location = New-Object System.Drawing.Point(218, 0)
    $SourceEntraIDCheckBox.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
    $SourcePanel.Controls.Add($SourceEntraIDCheckBox)

    #Create ExecuteFunctionButton
    $ExecuteFunctionButton = New-Object system.Windows.Forms.Button
    $ExecuteFunctionButton.text = $ExecuteButtonText
    $ExecuteFunctionButton.width = 150
    $ExecuteFunctionButton.height = 30
    $ExecuteFunctionButton.location = New-Object System.Drawing.Point(150, 175)
    $ExecuteFunctionButton.Font = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
    $ExecuteFunctionButton.ForeColor = $ExecuteButtonTextColor
    $ExecuteFunctionButton.BackColor = $ExecuteButtonBackgroundColor
    $MainForm.Controls.Add($ExecuteFunctionButton)

    #Logic Goes Here
    $SourceChangeLogic = {
        if ($SourceEntraIDCheckBox.Checked)
        {
            $ADQueryPanel.Visible = $false
            $AzureADQueryPanel.Visible = $true
            $MSGraphSessionLabel.Text = "MS Graph Session: $(Get-MGContext | Select -expandproperty Account)"
        }
        else {
            $ADQueryPanel.Visible = $true
            $AzureADQueryPanel.Visible = $false
            $SourceEntraIDCheckBox.Checked = $false
        }
    }
    $SourceOnPremCheckBox.Add_Click($SourceChangeLogic)
    $SourceEntraIDCheckBox.Add_Click($SourceChangeLogic)
    $ExecuteFunctionButton.Add_Click($ExecuteButtonScriptBlock)

    #Show Form
    $MainForm.ShowDialog()

}