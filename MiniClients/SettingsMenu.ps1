
#Import the required assemblies
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

#Grab content from the settings file - ".\ETTConfig.json"
$settings = Get-Content -Path ".\ETTConfig.json" | ConvertFrom-Json


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
$settingsForm.Text = "Settings"
$settingsForm.SizeGripStyle = "Hide"
$settingsForm.Size = New-Object System.Drawing.Size(400, 600)
$settingsForm.StartPosition = "CenterScreen"
$settingsForm.FormBorderStyle = "FixedToolWindow"
$settingsForm.MaximizeBox = $false
$settingsForm.BackColor = $BGcolor

#Create a label to display the header of the settings
$settingsLabel = New-Object System.Windows.Forms.Label
$settingsLabel.Location = New-Object System.Drawing.Size(10, 10)
$settingsLabel.Size = New-Object System.Drawing.Size(280, 20)
$settingsLabel.Text = "Settings"
$settingsLabel.Font = New-Object System.Drawing.Font("Arial", 12, [System.Drawing.FontStyle]::Bold)
$settingsLabel.ForeColor = $TextColor
$settingsForm.Controls.Add($settingsLabel)

#Add a frame to the form - Style Settings
$styleFrame = New-Object System.Windows.Forms.GroupBox
$styleFrame.Location = New-Object System.Drawing.Size(10, 40)
$styleFrame.Size = New-Object System.Drawing.Size(365, 200)
$styleFrame.Text = "Style"
$styleFrame.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$styleFrame.ForeColor = $TextColor
$styleFrame.BackColor = $BoxColor
$settingsForm.Controls.Add($styleFrame)

#Show the form
$settingsForm.ShowDialog()
