
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
$settingsForm.Size = New-Object System.Drawing.Size(775, 600)
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
$settingsLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$settingsLabel.ForeColor = $TextColor
$settingsForm.Controls.Add($settingsLabel)

#Add a frame to the form - Style Settings
$styleFrame = New-Object System.Windows.Forms.GroupBox
$styleFrame.Location = New-Object System.Drawing.Size(10, 40)
$styleFrame.Size = New-Object System.Drawing.Size(365, 225)
$styleFrame.Text = "Style"
$styleFrame.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$styleFrame.ForeColor = $TextColor
$styleFrame.BackColor = $BGcolor
$settingsForm.Controls.Add($styleFrame)

#Add another frame to the form - Runtime Settings
$runtimeFrame = New-Object System.Windows.Forms.GroupBox
$runtimeFrame.Location = New-Object System.Drawing.Size(385, 40)
$runtimeFrame.Size = New-Object System.Drawing.Size(365, 225)
$runtimeFrame.Text = "Runtime"
$runtimeFrame.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$runtimeFrame.ForeColor = $TextColor
$runtimeFrame.BackColor = $BGcolor
$settingsForm.Controls.Add($runtimeFrame)

#Add another frame to the form - Compliance Settings
$complianceFrame = New-Object System.Windows.Forms.GroupBox
$complianceFrame.Location = New-Object System.Drawing.Size(10, 270)
$complianceFrame.Size = New-Object System.Drawing.Size(365, 280)
$complianceFrame.Text = "Compliance"
$complianceFrame.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold) 
$complianceFrame.ForeColor = $TextColor
$complianceFrame.BackColor = $BGcolor
$settingsForm.Controls.Add($complianceFrame)

#Add another frame to the form - Query Settings
$queryFrame = New-Object System.Windows.Forms.GroupBox
$queryFrame.Location = New-Object System.Drawing.Size(385, 270)
$queryFrame.Size = New-Object System.Drawing.Size(365, 200)
$queryFrame.Text = "Query Configuration"
$queryFrame.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$queryFrame.ForeColor = $TextColor
$queryFrame.BackColor = $BGcolor
$settingsForm.Controls.Add($queryFrame)

#STYLE SETTINGS
#Style Settings include the following: brand color, logo location, background image path, application title, header text, header text, anime mode

#Create a label for the brand color
$brandColorLabel = New-Object System.Windows.Forms.Label
$brandColorLabel.Location = New-Object System.Drawing.Size(10, 20)
$brandColorLabel.Size = New-Object System.Drawing.Size(100, 20)
$brandColorLabel.Text = "Brand Color:"
$brandColorLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
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
$logoLocationLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
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
$backgroundImagePathLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
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
$ETTApplicationTitleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
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
$ETTHeaderTextLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
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
$ETTHeaderTextColorLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
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
$animeModeLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$animeModeLabel.ForeColor = $TextColor
$styleFrame.Controls.Add($animeModeLabel)

#Add a checkbox for the anime mode
$animeModeCheckBox = New-Object System.Windows.Forms.CheckBox
$animeModeCheckBox.Location = New-Object System.Drawing.Size(165, 198)
$animeModeCheckBox.Size = New-Object System.Drawing.Size(150, 20)
$animeModeCheckBox.Checked = $AnimeMode
$styleFrame.Controls.Add($animeModeCheckBox)

#RUNTIME SETTINGS
#Runtime Settings include the following: auto update checker enabled, admin mode, application timeout enabled, application timeout length, enable custom tools

#Create a label for the auto update checker enabled
$autoUpdateCheckerEnabledLabel = New-Object System.Windows.Forms.Label
$autoUpdateCheckerEnabledLabel.Location = New-Object System.Drawing.Size(10, 20)
$autoUpdateCheckerEnabledLabel.Size = New-Object System.Drawing.Size(210, 20)
$autoUpdateCheckerEnabledLabel.Text = "Auto Update Checker Enabled:"
$autoUpdateCheckerEnabledLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$autoUpdateCheckerEnabledLabel.ForeColor = $TextColor
$runtimeFrame.Controls.Add($autoUpdateCheckerEnabledLabel)

#Add a checkbox for the auto update checker enabled
$autoUpdateCheckerEnabledCheckBox = New-Object System.Windows.Forms.CheckBox
$autoUpdateCheckerEnabledCheckBox.Location = New-Object System.Drawing.Size(225, 18)
$autoUpdateCheckerEnabledCheckBox.Size = New-Object System.Drawing.Size(20, 20)
$autoUpdateCheckerEnabledCheckBox.Checked = $AutoUpdateCheckerEnabled
$runtimeFrame.Controls.Add($autoUpdateCheckerEnabledCheckBox)

#Create a label for the admin mode
$adminModeLabel = New-Object System.Windows.Forms.Label
$adminModeLabel.Location = New-Object System.Drawing.Size(10, 50)
$adminModeLabel.Size = New-Object System.Drawing.Size(110, 20)
$adminModeLabel.Text = "Admin Mode:"
$adminModeLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$adminModeLabel.ForeColor = $TextColor
$runtimeFrame.Controls.Add($adminModeLabel)

#Add a checkbox for the admin mode
$adminModeCheckBox = New-Object System.Windows.Forms.CheckBox
$adminModeCheckBox.Location = New-Object System.Drawing.Size(225, 50)
$adminModeCheckBox.Size = New-Object System.Drawing.Size(20, 20)
$adminModeCheckBox.Checked = $AdminMode
$runtimeFrame.Controls.Add($adminModeCheckBox)

#Create a label for the application timeout enabled
$applicationTimeoutEnabledLabel = New-Object System.Windows.Forms.Label
$applicationTimeoutEnabledLabel.Location = New-Object System.Drawing.Size(10, 80)
$applicationTimeoutEnabledLabel.Size = New-Object System.Drawing.Size(210, 20)
$applicationTimeoutEnabledLabel.Text = "Application Timeout Enabled:"
$applicationTimeoutEnabledLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$applicationTimeoutEnabledLabel.ForeColor = $TextColor
$runtimeFrame.Controls.Add($applicationTimeoutEnabledLabel)

#Add a checkbox for the application timeout enabled
$applicationTimeoutEnabledCheckBox = New-Object System.Windows.Forms.CheckBox
$applicationTimeoutEnabledCheckBox.Location = New-Object System.Drawing.Size(225, 78)
$applicationTimeoutEnabledCheckBox.Size = New-Object System.Drawing.Size(20, 20)
$applicationTimeoutEnabledCheckBox.Checked = $ApplicationTimeoutEnabled
$runtimeFrame.Controls.Add($applicationTimeoutEnabledCheckBox)

#Create a label for the application timeout length - readonly if application timeout is not enabled
$applicationTimeoutLengthLabel = New-Object System.Windows.Forms.Label
$applicationTimeoutLengthLabel.Location = New-Object System.Drawing.Size(10, 110)
$applicationTimeoutLengthLabel.Size = New-Object System.Drawing.Size(210, 20)
$applicationTimeoutLengthLabel.Text = "Application Timeout Length:"
$applicationTimeoutLengthLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$applicationTimeoutLengthLabel.ForeColor = $TextColor
$runtimeFrame.Controls.Add($applicationTimeoutLengthLabel)

#Add a textbox for the application timeout length
$applicationTimeoutLengthTextBox = New-Object System.Windows.Forms.TextBox
$applicationTimeoutLengthTextBox.Location = New-Object System.Drawing.Size(225, 108)
$applicationTimeoutLengthTextBox.Size = New-Object System.Drawing.Size(100, 20)
$applicationTimeoutLengthTextBox.Text = $ApplicationTimeoutLength
$applicationTimeoutLengthTextBox.ReadOnly = -not $ApplicationTimeoutEnabled
$runtimeFrame.Controls.Add($applicationTimeoutLengthTextBox)

#Create a label for the enable custom tools
$enableCustomToolsLabel = New-Object System.Windows.Forms.Label
$enableCustomToolsLabel.Location = New-Object System.Drawing.Size(10, 140)
$enableCustomToolsLabel.Size = New-Object System.Drawing.Size(210, 20)
$enableCustomToolsLabel.Text = "Enable Custom Tools:"
$enableCustomToolsLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$enableCustomToolsLabel.ForeColor = $TextColor
$runtimeFrame.Controls.Add($enableCustomToolsLabel)

#Add a checkbox for the enable custom tools
$enableCustomToolsCheckBox = New-Object System.Windows.Forms.CheckBox
$enableCustomToolsCheckBox.Location = New-Object System.Drawing.Size(225, 138)
$enableCustomToolsCheckBox.Size = New-Object System.Drawing.Size(20, 20)
$enableCustomToolsCheckBox.Checked = $EnableCustomTools
$runtimeFrame.Controls.Add($enableCustomToolsCheckBox)

#COMPLIANCE SETTINGS
#Compliance Settings include the following: RAM check active, RAM check minimum, drive space check active, drive space check minimum, Windows version check active, Windows version target

#Create a label for the RAM check active
$RAMCheckActiveLabel = New-Object System.Windows.Forms.Label
$RAMCheckActiveLabel.Location = New-Object System.Drawing.Size(10, 20)
$RAMCheckActiveLabel.Size = New-Object System.Drawing.Size(210, 20)
$RAMCheckActiveLabel.Text = "RAM Check Active:"
$RAMCheckActiveLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$RAMCheckActiveLabel.ForeColor = $TextColor
$complianceFrame.Controls.Add($RAMCheckActiveLabel)

#Add a checkbox for the RAM check active
$RAMCheckActiveCheckBox = New-Object System.Windows.Forms.CheckBox
$RAMCheckActiveCheckBox.Location = New-Object System.Drawing.Size(225, 18)
$RAMCheckActiveCheckBox.Size = New-Object System.Drawing.Size(20, 20)
$RAMCheckActiveCheckBox.Checked = $RAMCheckActive
$complianceFrame.Controls.Add($RAMCheckActiveCheckBox)

#Create a label for the RAM check minimum
$RAMCheckMinimumLabel = New-Object System.Windows.Forms.Label
$RAMCheckMinimumLabel.Location = New-Object System.Drawing.Size(10, 50)
$RAMCheckMinimumLabel.Size = New-Object System.Drawing.Size(210, 20)
$RAMCheckMinimumLabel.Text = "RAM Check Minimum:"
$RAMCheckMinimumLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$RAMCheckMinimumLabel.ForeColor = $TextColor
$complianceFrame.Controls.Add($RAMCheckMinimumLabel)

#Add a textbox for the RAM check minimum - readonly when ram check active is false
$RAMCheckMinimumTextBox = New-Object System.Windows.Forms.TextBox
$RAMCheckMinimumTextBox.Location = New-Object System.Drawing.Size(225, 48)
$RAMCheckMinimumTextBox.Size = New-Object System.Drawing.Size(100, 20)
$RAMCheckMinimumTextBox.Text = $RAMCheckMinimum
$RAMCheckMinimumTextBox.ReadOnly = -not $RAMCheckActive
if (-not $RAMCheckActive) {
    #Set the text color to gray if the RAM check is not active
    $RAMCheckMinimumTextBox.ForeColor = 'Charcoal'
    $RAMCheckMinimumTextBox.BackColor = 'Gray'
    $RAMCheckMinimumTextBox.Text = "N/A"
}else{
    $RAMCheckMinimumTextBox.ForeColor = 'Black'
    $RAMCheckMinimumTextBox.BackColor = 'White'
}
$complianceFrame.Controls.Add($RAMCheckMinimumTextBox)

#Create a label for the drive space check active
$DriveSpaceCheckActiveLabel = New-Object System.Windows.Forms.Label
$DriveSpaceCheckActiveLabel.Location = New-Object System.Drawing.Size(10, 80)
$DriveSpaceCheckActiveLabel.Size = New-Object System.Drawing.Size(210, 20)
$DriveSpaceCheckActiveLabel.Text = "Drive Space Check Active:"
$DriveSpaceCheckActiveLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$DriveSpaceCheckActiveLabel.ForeColor = $TextColor
$complianceFrame.Controls.Add($DriveSpaceCheckActiveLabel)

#Add a checkbox for the drive space check active
$DriveSpaceCheckActiveCheckBox = New-Object System.Windows.Forms.CheckBox
$DriveSpaceCheckActiveCheckBox.Location = New-Object System.Drawing.Size(225, 78)
$DriveSpaceCheckActiveCheckBox.Size = New-Object System.Drawing.Size(20, 20)
$DriveSpaceCheckActiveCheckBox.Checked = $DriveSpaceCheckActive
$complianceFrame.Controls.Add($DriveSpaceCheckActiveCheckBox)

#Create a label for the drive space check minimum
$DriveSpaceCheckMinimumLabel = New-Object System.Windows.Forms.Label
$DriveSpaceCheckMinimumLabel.Location = New-Object System.Drawing.Size(10, 110)
$DriveSpaceCheckMinimumLabel.Size = New-Object System.Drawing.Size(210, 20)
$DriveSpaceCheckMinimumLabel.Text = "Drive Space Check Minimum:"
$DriveSpaceCheckMinimumLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$DriveSpaceCheckMinimumLabel.ForeColor = $TextColor
$complianceFrame.Controls.Add($DriveSpaceCheckMinimumLabel)

#Add a textbox for the drive space check minimum
$DriveSpaceCheckMinimumTextBox = New-Object System.Windows.Forms.TextBox
$DriveSpaceCheckMinimumTextBox.Location = New-Object System.Drawing.Size(225, 108)
$DriveSpaceCheckMinimumTextBox.Size = New-Object System.Drawing.Size(100, 20)
$DriveSpaceCheckMinimumTextBox.Text = $DriveSpaceCheckMinimum
$complianceFrame.Controls.Add($DriveSpaceCheckMinimumTextBox)

#Create a label for the Windows version check active
$WinVersionCheckActiveLabel = New-Object System.Windows.Forms.Label
$WinVersionCheckActiveLabel.Location = New-Object System.Drawing.Size(10, 140)
$WinVersionCheckActiveLabel.Size = New-Object System.Drawing.Size(210, 20)
$WinVersionCheckActiveLabel.Text = "Windows Version Check Active:"
$WinVersionCheckActiveLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$WinVersionCheckActiveLabel.ForeColor = $TextColor
$complianceFrame.Controls.Add($WinVersionCheckActiveLabel)

#Add a checkbox for the Windows version check active
$WinVersionCheckActiveCheckBox = New-Object System.Windows.Forms.CheckBox
$WinVersionCheckActiveCheckBox.Location = New-Object System.Drawing.Size(225, 138)
$WinVersionCheckActiveCheckBox.Size = New-Object System.Drawing.Size(20, 20)
$WinVersionCheckActiveCheckBox.Checked = $WinVersionCheckActive
$complianceFrame.Controls.Add($WinVersionCheckActiveCheckBox)

#Create a label for the Windows version target
$WinVersionTargetLabel = New-Object System.Windows.Forms.Label
$WinVersionTargetLabel.Location = New-Object System.Drawing.Size(10, 170)
$WinVersionTargetLabel.Size = New-Object System.Drawing.Size(210, 20)
$WinVersionTargetLabel.Text = "Windows Version Target:"
$WinVersionTargetLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$WinVersionTargetLabel.ForeColor = $TextColor
$complianceFrame.Controls.Add($WinVersionTargetLabel)

#Add a textbox for the Windows version target
$WinVersionTargetTextBox = New-Object System.Windows.Forms.TextBox
$WinVersionTargetTextBox.Location = New-Object System.Drawing.Size(225, 168)
$WinVersionTargetTextBox.Size = New-Object System.Drawing.Size(100, 20)
$WinVersionTargetTextBox.Text = $WinVersionTarget
$complianceFrame.Controls.Add($WinVersionTargetTextBox)

#QUERY SETTINGS
#Query Settings include the following: Azure AD Tenant ID, LAPS App Client ID, BitLocker App Client ID

#Create a label for the Azure AD Tenant ID
$AzureADTenantIdLabel = New-Object System.Windows.Forms.Label
$AzureADTenantIdLabel.Location = New-Object System.Drawing.Size(10, 20)
$AzureADTenantIdLabel.Size = New-Object System.Drawing.Size(210, 20)
$AzureADTenantIdLabel.Text = "Azure AD Tenant ID:"
$AzureADTenantIdLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$AzureADTenantIdLabel.ForeColor = $TextColor
$queryFrame.Controls.Add($AzureADTenantIdLabel)

#Add a textbox for the Azure AD Tenant ID
$AzureADTenantIdTextBox = New-Object System.Windows.Forms.TextBox
$AzureADTenantIdTextBox.Location = New-Object System.Drawing.Size(225, 18)
$AzureADTenantIdTextBox.Size = New-Object System.Drawing.Size(150, 20)
$AzureADTenantIdTextBox.Text = $AzureADTenantId
$queryFrame.Controls.Add($AzureADTenantIdTextBox)

#Create a label for the LAPS App Client ID
$LAPSAppClientIdLabel = New-Object System.Windows.Forms.Label
$LAPSAppClientIdLabel.Location = New-Object System.Drawing.Size(10, 50)
$LAPSAppClientIdLabel.Size = New-Object System.Drawing.Size(210, 20)
$LAPSAppClientIdLabel.Text = "LAPS App Client ID:"
$LAPSAppClientIdLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$LAPSAppClientIdLabel.ForeColor = $TextColor
$queryFrame.Controls.Add($LAPSAppClientIdLabel)

#Add a textbox for the LAPS App Client ID
$LAPSAppClientIdTextBox = New-Object System.Windows.Forms.TextBox
$LAPSAppClientIdTextBox.Location = New-Object System.Drawing.Size(225, 48)
$LAPSAppClientIdTextBox.Size = New-Object System.Drawing.Size(150, 20)
$LAPSAppClientIdTextBox.Text = $LAPSAppClientId
$queryFrame.Controls.Add($LAPSAppClientIdTextBox)

#Create a label for the BitLocker App Client ID
$BitLockerAppClientIdLabel = New-Object System.Windows.Forms.Label
$BitLockerAppClientIdLabel.Location = New-Object System.Drawing.Size(10, 80)
$BitLockerAppClientIdLabel.Size = New-Object System.Drawing.Size(210, 20)
$BitLockerAppClientIdLabel.Text = "BitLocker App Client ID:"
$BitLockerAppClientIdLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$BitLockerAppClientIdLabel.ForeColor = $TextColor
$queryFrame.Controls.Add($BitLockerAppClientIdLabel)

#Add a textbox for the BitLocker App Client ID
$BitLockerAppClientIdTextBox = New-Object System.Windows.Forms.TextBox
$BitLockerAppClientIdTextBox.Location = New-Object System.Drawing.Size(225, 78)
$BitLockerAppClientIdTextBox.Size = New-Object System.Drawing.Size(150, 20)
$BitLockerAppClientIdTextBox.Text = $BitLockerAppClientId
$queryFrame.Controls.Add($BitLockerAppClientIdTextBox)

#Create a button to save the settings
$saveButton = New-Object System.Windows.Forms.Button
$saveButton.Location = New-Object System.Drawing.Size(650, 560)
$saveButton.Size = New-Object System.Drawing.Size(75, 23)
$saveButton.Text = "Save"
$saveButton.BackColor = $BoxColor
$saveButton.ForeColor = $ButtonTextColor
$saveButton.Add_Click({
    #Save the settings to the ETTConfig.json file
    $settings.AutoUpdateCheckerEnabled = $autoUpdateCheckerEnabledCheckBox.Checked
    $settings.AdminMode = $adminModeCheckBox.Checked
    $settings.BrandColor = $brandColorTextBox.Text
    $settings.LogoLocation = $logoLocationTextBox.Text
    $settings.BackgroundImagePath = $backgroundImagePathTextBox.Text
    $settings.ETTApplicationTitle = $ETTApplicationTitleTextBox.Text
    $settings.ETTHeaderText = $ETTHeaderTextTextBox.Text
    $settings.ETTHeaderTextColor = $ETTHeaderTextColorTextBox.Text
    $settings.ApplicationTimeoutEnabled = $applicationTimeoutEnabledCheckBox.Checked
    $settings.ApplicationTimeoutLength = $applicationTimeoutLengthTextBox.Text
    $settings.EnableCustomTools = $enableCustomToolsCheckBox.Checked
    $settings.RAMCheckActive = $RAMCheckActiveCheckBox.Checked
    $settings.RAMCheckMinimum = $RAMCheckMinimumTextBox.Text
    $settings.DriveSpaceCheckActive = $DriveSpaceCheckActiveCheckBox.Checked
    $settings.DriveSpaceCheckMinimum = $DriveSpaceCheckMinimumTextBox.Text
    $settings.WinVersionCheckActive = $WinVersionCheckActiveCheckBox.Checked
    $settings.WinVersionTarget = $WinVersionTargetTextBox.Text
    $settings.AzureADTenantId = $AzureADTenantIdTextBox.Text
    $settings.LAPSAppClientId = $LAPSAppClientIdTextBox.Text
    $settings.BitLockerAppClientId = $BitLockerAppClientIdTextBox.Text
    $settings.AnimeMode = $animeModeCheckBox.Checked

    #Convert the settings to JSON and save them to the ETTConfig.json file
    $settings | ConvertTo-Json | Set-Content -Path ".\ETTConfig.json"

    #Close the form
    $settingsForm.Close()
})
$settingsForm.Controls.Add($saveButton)

#Show the form
$settingsForm.ShowDialog()
