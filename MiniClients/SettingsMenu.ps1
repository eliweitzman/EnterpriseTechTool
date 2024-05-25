
#Import the required assemblies
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

#Grab content from the settings file - ".\ETTConfig.json"
$settings = Get-Content -Path ".\ETTConfig.json" | ConvertFrom-Json

#Parse the ETTConfig settings file, and assign the values to variables

#Assign the values to variables
$AutoUpdateCheckerEnabled = $settings.AutoUpdateCheckerEnabled
$AdminMode = $settings.AdminMode
$BrandColor = $settings.BrandColor
$LogoLocation = $settings.LogoLocation
$BackgroundImagePath = $settings.BackgroundImagePath
$ETTApplicationTitle = $settings.ETTApplicationTitle
$ETTHeaderText = $settings.ETTHeaderText
$ETTHeaderTextColor = $settings.ETTHeaderTextColor
$ApplicationTimeoutEnabled = $settings.ApplicationTimeoutEnabled
$ApplicationTimeoutLength = $settings.ApplicationTimeoutLength
$EnableCustomTools = $settings.EnableCustomTools
$RAMCheckActive = $settings.RAMCheckActive
$RAMCheckMinimum = $settings.RAMCheckMinimum
$DriveSpaceCheckActive = $settings.DriveSpaceCheckActive
$DriveSpaceCheckMinimum = $settings.DriveSpaceCheckMinimum
$WinVersionCheckActive = $settings.WinVersionCheckActive
$WinVersionTarget = $settings.WinVersionTarget
$AzureADTenantId = $settings.AzureADTenantId
$LAPSAppClientId = $settings.LAPSAppClientId
$BitLockerAppClientId = $settings.BitLockerAppClientId
$AnimeMode = $settings.AnimeMode

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

#Create a new form to display the settings
$settingsForm = New-Object System.Windows.Forms.Form
$settingsForm.Text = "ETT Settings"
$settingsForm.SizeGripStyle = "Hide"
$settingsForm.Size = New-Object System.Drawing.Size(400, 600)
$settingsForm.StartPosition = "CenterScreen"
$settingsForm.FormBorderStyle = "FixedToolWindow"
$settingsForm.MaximizeBox = $false
$settingsForm.showintaskbar = $false
$settingsForm.TopMost = $true
$settingsForm.BackColor = $BGcolor

#Create a label to display the header of the settings
$settingsLabel = New-Object System.Windows.Forms.Label
$settingsLabel.Location = New-Object System.Drawing.Size(10, 10)
$settingsLabel.Size = New-Object System.Drawing.Size(280, 20)
$settingsLabel.Text = "ETT Settings"
$settingsLabel.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
$settingsLabel.ForeColor = $TextColor
$settingsForm.Controls.Add($settingsLabel)

#Add a frame to the form - Style Settings
$styleFrame = New-Object System.Windows.Forms.GroupBox
$styleFrame.Location = New-Object System.Drawing.Size(10, 40)
$styleFrame.Size = New-Object System.Drawing.Size(365, 225)
$styleFrame.Text = "Style"
$styleFrame.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$styleFrame.ForeColor = $TextColor
$styleFrame.BackColor = $BGcolor
$settingsForm.Controls.Add($styleFrame)

#Add another frame to the form - Runtime Settings
$runtimeFrame = New-Object System.Windows.Forms.GroupBox
$runtimeFrame.Location = New-Object System.Drawing.Size(10, 240)
$runtimeFrame.Size = New-Object System.Drawing.Size(365, 200)
$runtimeFrame.Text = "Runtime"
$runtimeFrame.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$runtimeFrame.ForeColor = $TextColor
$runtimeFrame.BackColor = $BGcolor
$settingsForm.Controls.Add($runtimeFrame)

#Add another frame to the form - Compliance Settings
$complianceFrame = New-Object System.Windows.Forms.GroupBox
$complianceFrame.Location = New-Object System.Drawing.Size(10, 445)
$complianceFrame.Size = New-Object System.Drawing.Size(365, 100)
$complianceFrame.Text = "Compliance"
$complianceFrame.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$complianceFrame.ForeColor = $TextColor
$complianceFrame.BackColor = $BGcolor
$settingsForm.Controls.Add($complianceFrame)

#STYLE SETTINGS
#Style Settings include the following: brand color, logo location, background image path, application title, header text, header text, anime mode

#Create a label for the brand color
$brandColorLabel = New-Object System.Windows.Forms.Label
$brandColorLabel.Location = New-Object System.Drawing.Size(10, 20)
$brandColorLabel.Size = New-Object System.Drawing.Size(100, 20)
$brandColorLabel.Text = "Brand Color:"
$brandColorLabel.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$brandColorLabel.ForeColor = $TextColor
$styleFrame.Controls.Add($brandColorLabel)

#Add a textbox for the brand color
$brandColorTextBox = New-Object System.Windows.Forms.TextBox
$brandColorTextBox.Location = New-Object System.Drawing.Size(110, 18)
$brandColorTextBox.Size = New-Object System.Drawing.Size(150, 20)
$brandColorTextBox.Text = $BrandColor
$styleFrame.Controls.Add($brandColorTextBox)

#Create a label for the logo location
$logoLocationLabel = New-Object System.Windows.Forms.Label
$logoLocationLabel.Location = New-Object System.Drawing.Size(10, 50)
$logoLocationLabel.Size = New-Object System.Drawing.Size(110, 20)
$logoLocationLabel.Text = "Logo Location:"
$logoLocationLabel.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$logoLocationLabel.ForeColor = $TextColor
$styleFrame.Controls.Add($logoLocationLabel)

#Add a textbox for the logo location
$logoLocationTextBox = New-Object System.Windows.Forms.TextBox
$logoLocationTextBox.Location = New-Object System.Drawing.Size(125, 48)
$logoLocationTextBox.Size = New-Object System.Drawing.Size(150, 20)
$logoLocationTextBox.Text = $LogoLocation
$styleFrame.Controls.Add($logoLocationTextBox)

#Create a label for the background image path
$backgroundImagePathLabel = New-Object System.Windows.Forms.Label
$backgroundImagePathLabel.Location = New-Object System.Drawing.Size(10, 80)
$backgroundImagePathLabel.Size = New-Object System.Drawing.Size(168, 20)
$backgroundImagePathLabel.Text = "Background Image Path:"
$backgroundImagePathLabel.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$backgroundImagePathLabel.ForeColor = $TextColor
$styleFrame.Controls.Add($backgroundImagePathLabel)

#Add a textbox for the background image path
$backgroundImagePathTextBox = New-Object System.Windows.Forms.TextBox
$backgroundImagePathTextBox.Location = New-Object System.Drawing.Size(178, 78)
$backgroundImagePathTextBox.Size = New-Object System.Drawing.Size(150, 20)
$backgroundImagePathTextBox.Text = $BackgroundImagePath
$styleFrame.Controls.Add($backgroundImagePathTextBox)

#Create a label for the ETT application title
$ETTApplicationTitleLabel = New-Object System.Windows.Forms.Label
$ETTApplicationTitleLabel.Location = New-Object System.Drawing.Size(10, 110)
$ETTApplicationTitleLabel.Size = New-Object System.Drawing.Size(150, 20)
$ETTApplicationTitleLabel.Text = "ETT Application Title:"
$ETTApplicationTitleLabel.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$ETTApplicationTitleLabel.ForeColor = $TextColor
$styleFrame.Controls.Add($ETTApplicationTitleLabel)

#Add a textbox for the ETT application title
$ETTApplicationTitleTextBox = New-Object System.Windows.Forms.TextBox
$ETTApplicationTitleTextBox.Location = New-Object System.Drawing.Size(165, 108)
$ETTApplicationTitleTextBox.Size = New-Object System.Drawing.Size(150, 20)
$ETTApplicationTitleTextBox.Text = $ETTApplicationTitle
$styleFrame.Controls.Add($ETTApplicationTitleTextBox)

#Create a label for the ETT header text
$ETTHeaderTextLabel = New-Object System.Windows.Forms.Label
$ETTHeaderTextLabel.Location = New-Object System.Drawing.Size(10, 140)
$ETTHeaderTextLabel.Size = New-Object System.Drawing.Size(150, 20)
$ETTHeaderTextLabel.Text = "ETT Header Text:"
$ETTHeaderTextLabel.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$ETTHeaderTextLabel.ForeColor = $TextColor
$styleFrame.Controls.Add($ETTHeaderTextLabel)

#Add a textbox for the ETT header text
$ETTHeaderTextTextBox = New-Object System.Windows.Forms.TextBox
$ETTHeaderTextTextBox.Location = New-Object System.Drawing.Size(165, 138)
$ETTHeaderTextTextBox.Size = New-Object System.Drawing.Size(150, 20)
$ETTHeaderTextTextBox.Text = $ETTHeaderText
$styleFrame.Controls.Add($ETTHeaderTextTextBox)

#Create a label for the ETT header text color
$ETTHeaderTextColorLabel = New-Object System.Windows.Forms.Label
$ETTHeaderTextColorLabel.Location = New-Object System.Drawing.Size(10, 170)
$ETTHeaderTextColorLabel.Size = New-Object System.Drawing.Size(160, 20)
$ETTHeaderTextColorLabel.Text = "ETT Header Text Color:"
$ETTHeaderTextColorLabel.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$ETTHeaderTextColorLabel.ForeColor = $TextColor
$styleFrame.Controls.Add($ETTHeaderTextColorLabel)

#Add a textbox for the ETT header text color
$ETTHeaderTextColorTextBox = New-Object System.Windows.Forms.TextBox
$ETTHeaderTextColorTextBox.Location = New-Object System.Drawing.Size(170, 168)
$ETTHeaderTextColorTextBox.Size = New-Object System.Drawing.Size(150, 20)
$ETTHeaderTextColorTextBox.Text = $ETTHeaderTextColor
$styleFrame.Controls.Add($ETTHeaderTextColorTextBox)

#Create a label for the anime mode
$animeModeLabel = New-Object System.Windows.Forms.Label
$animeModeLabel.Location = New-Object System.Drawing.Size(10, 200)
$animeModeLabel.Size = New-Object System.Drawing.Size(150, 20)
$animeModeLabel.Text = "Anime Mode:"
$animeModeLabel.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$animeModeLabel.ForeColor = $TextColor
$styleFrame.Controls.Add($animeModeLabel)

#Add a checkbox for the anime mode
$animeModeCheckBox = New-Object System.Windows.Forms.CheckBox
$animeModeCheckBox.Location = New-Object System.Drawing.Size(165, 198)
$animeModeCheckBox.Size = New-Object System.Drawing.Size(150, 20)
$animeModeCheckBox.Checked = $AnimeMode
$styleFrame.Controls.Add($animeModeCheckBox)

#Show the form
$settingsForm.ShowDialog()
