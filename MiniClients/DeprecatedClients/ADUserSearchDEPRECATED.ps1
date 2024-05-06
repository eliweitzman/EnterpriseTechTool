#An AD User Search GUI

#Set up the form
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

#Temporary color placeholders
$BGcolor = [System.Drawing.Color]::FromArgb(255,255,255)
$TextColor = [System.Drawing.Color]::FromArgb(0,0,0)
#Pine green brand color
$BrandColor = [System.Drawing.Color]::FromArgb(1,121,111)

#Create the form
$ADUserSearchForm = New-Object system.Windows.Forms.Form
$ADUserSearchForm.Text = "AD User Search"
$ADUserSearchForm.Size = New-Object System.Drawing.Size(500,500)
$ADUserSearchForm.StartPosition = "CenterScreen"
$ADUserSearchForm.FormBorderStyle = 'FixedDialog'
$ADUserSearchForm.MaximizeBox = $false
$ADUserSearchForm.MinimizeBox = $false
$ADUserSearchForm.Topmost = $true
$ADUserSearchForm.BackColor = $BGcolor
$ADUserSearchForm.ForeColor = $TextColor

#Create the username label
$ADUserSearchLabel = New-Object system.Windows.Forms.Label
$ADUserSearchLabel.Text = "Enter a username for search:"
$ADUserSearchLabel.AutoSize = $true
$ADUserSearchLabel.Location = New-Object System.Drawing.Size(10,10)
$ADUserSearchLabel.Font = New-Object System.Drawing.Font("Microsoft Segoe UI",10,[System.Drawing.FontStyle]::Bold)
$ADUserSearchLabel.BackColor = $BGcolor
$ADUserSearchLabel.ForeColor = $TextColor
$ADUserSearchForm.Controls.Add($ADUserSearchLabel)

#Create the text box
$ADUserSearchTextBox = New-Object system.Windows.Forms.TextBox
$ADUserSearchTextBox.Location = New-Object System.Drawing.Size(10,30)
$ADUserSearchTextBox.Size = New-Object System.Drawing.Size(465,20)
$ADUserSearchTextBox.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",10,[System.Drawing.FontStyle]::Regular)
$ADUserSearchTextBox.BackColor = $BGcolor
$ADUserSearchTextBox.ForeColor = $TextColor
$ADUserSearchForm.Controls.Add($ADUserSearchTextBox)

#Create a domain label
$ADUserSearchDomainLabel = New-Object system.Windows.Forms.Label
$ADUserSearchDomainLabel.Text = "Enter a domain:"
$ADUserSearchDomainLabel.AutoSize = $true
$ADUserSearchDomainLabel.Location = New-Object System.Drawing.Size(10,60)
$ADUserSearchDomainLabel.Font = New-Object System.Drawing.Font("Microsoft Segoe UI",10,[System.Drawing.FontStyle]::Bold)
$ADUserSearchDomainLabel.BackColor = $BGcolor
$ADUserSearchDomainLabel.ForeColor = $TextColor
$ADUserSearchForm.Controls.Add($ADUserSearchDomainLabel)

#Create the domain text box
$ADUserSearchDomainTextBox = New-Object system.Windows.Forms.TextBox
$ADUserSearchDomainTextBox.Location = New-Object System.Drawing.Size(10,80)
$ADUserSearchDomainTextBox.Size = New-Object System.Drawing.Size(465,20)
$ADUserSearchDomainTextBox.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",10,[System.Drawing.FontStyle]::Regular)
$ADUserSearchDomainTextBox.BackColor = $BGcolor
$ADUserSearchDomainTextBox.ForeColor = $TextColor
$ADUserSearchForm.Controls.Add($ADUserSearchDomainTextBox)

#Add a checkbox for adding additional authentication
$ADUserSearchAuthCheckBox = New-Object system.Windows.Forms.CheckBox
$ADUserSearchAuthCheckBox.Text = "Use alternate credentials"
$ADUserSearchAuthCheckBox.AutoSize = $true
$ADUserSearchAuthCheckBox.Location = New-Object System.Drawing.Size(10,110)
$ADUserSearchAuthCheckBox.Font = New-Object System.Drawing.Font("Microsoft Segoe UI",10,[System.Drawing.FontStyle]::Bold)
$ADUserSearchAuthCheckBox.BackColor = $BGcolor
$ADUserSearchAuthCheckBox.ForeColor = $TextColor
$ADUserSearchForm.Controls.Add($ADUserSearchAuthCheckBox)

#Search button
$ADUserSearchButton = New-Object system.Windows.Forms.Button
$ADUserSearchButton.Text = "Search"
$ADUserSearchButton.Location = New-Object System.Drawing.Size(10,140)
$ADUserSearchButton.Size = New-Object System.Drawing.Size(465,30)
$ADUserSearchButton.Font = New-Object System.Drawing.Font("Microsoft Segoe UI",10,[System.Drawing.FontStyle]::Bold)
$ADUserSearchButton.BackColor = $BrandColor
$ADUserSearchButton.ForeColor = $TextColor

#Search button click event
$ADUserSearchButton.Add_Click({
    #Check if the domain text box is empty
    if ($ADUserSearchDomainTextBox.Text -eq "") {
        #If it is, use the default domain
        $ADUserSearchDomain = $env:USERDOMAIN

        #Check if the alternate credentials checkbox is checked
        if ($ADUserSearchAuthCheckBox.Checked -eq $true) {
            #If it is, prompt for credentials
            $ADUserSearchCred = Get-Credential

            #Run the search
            $ADUserSearchResults = Get-ADUser -Filter {SamAccountName -eq $ADUserSearchTextBox.Text} -Server $ADUserSearchDomain -Credential $ADUserSearchCred

            #Check if the search returned any results
            if ($ADUserSearchResults -eq $null) {
                #If it didn't, display a message box
                $Wshell = New-Object -ComObject Wscript.Shell
                $Wshell.Popup("No results found.",0,"No results found",0x0)
            }else {
                #If it did, output the results to the listbox
                #Name
                $ADUserSearchResultsListBox.Items.Add("Name: " + $ADUserSearchResults.Name)
                #SamAccountName
                $ADUserSearchResultsListBox.Items.Add("Username: " + $ADUserSearchResults.SamAccountName)
                #DistinguishedName
                $ADUserSearchResultsListBox.Items.Add("Distinguished Name: " + $ADUserSearchResults.DistinguishedName)
                #Enabled
                $ADUserSearchResultsListBox.Items.Add("Enabled: " + $ADUserSearchResults.Enabled)
                #LastLogonDate
                $ADUserSearchResultsListBox.Items.Add("Last Logon Date: " + $ADUserSearchResults.LastLogonDate)
                #Object Location
                $ADUserSearchResultsListBox.Items.Add("Object Location: " + $ADUserSearchResults.ObjectLocation)
            }
        }else {
            #If it isn't, use the current user's credentials, and run the search
            $ADUserSearchResults = Get-ADUser -Filter {SamAccountName -eq $ADUserSearchTextBox.Text} -Server $ADUserSearchDomain

            #Check if the search returned any results
            if ($ADUserSearchResults -eq $null) {
                #If it didn't, display a message box
                $Wshell = New-Object -ComObject Wscript.Shell
                $Wshell.Popup("No results found.",0,"No results found",0x0)
            }else {
                #If it did, output the results to the listbox
                #Name
                $ADUserSearchResultsListBox.Items.Add("Name: " + $ADUserSearchResults.Name)
                #SamAccountName
                $ADUserSearchResultsListBox.Items.Add("Username: " + $ADUserSearchResults.SamAccountName)
                #DistinguishedName
                $ADUserSearchResultsListBox.Items.Add("Distinguished Name: " + $ADUserSearchResults.DistinguishedName)
                #Enabled
                $ADUserSearchResultsListBox.Items.Add("Enabled: " + $ADUserSearchResults.Enabled)
                #LastLogonDate
                $ADUserSearchResultsListBox.Items.Add("Last Logon Date: " + $ADUserSearchResults.LastLogonDate)
                #Object Location
                $ADUserSearchResultsListBox.Items.Add("Object Location: " + $ADUserSearchResults.ObjectLocation)
            }
    } else {
        #If it isn't, use the domain from the text box
        $ADUserSearchDomain = $ADUserSearchDomainTextBox.Text

        #Check if the alternate credentials checkbox is checked
        if ($ADUserSearchAuthCheckBox.Checked -eq $true) {
            #If it is, prompt for credentials
            $ADUserSearchCred = Get-Credential

            #Run the search
            $ADUserSearchResults = Get-ADUser -Filter {SamAccountName -eq $ADUserSearchTextBox.Text} -Server $ADUserSearchDomain -Credential $ADUserSearchCred
            
            #Check if the search returned any results
            if ($ADUserSearchResults -eq $null) {
                #If it didn't, display a message box
                $Wshell = New-Object -ComObject Wscript.Shell
                $Wshell.Popup("No results found.",0,"No results found",0x0)
            }else{
                #If it did, output the results to the listbox
                #Name
                $ADUserSearchResultsListBox.Items.Add("Name: " + $ADUserSearchResults.Name)
                #SamAccountName
                $ADUserSearchResultsListBox.Items.Add("Username: " + $ADUserSearchResults.SamAccountName)
                #DistinguishedName
                $ADUserSearchResultsListBox.Items.Add("Distinguished Name: " + $ADUserSearchResults.DistinguishedName)
                #Enabled
                $ADUserSearchResultsListBox.Items.Add("Enabled: " + $ADUserSearchResults.Enabled)
                #LastLogonDate
                $ADUserSearchResultsListBox.Items.Add("Last Logon Date: " + $ADUserSearchResults.LastLogonDate)
                #Object Location
                $ADUserSearchResultsListBox.Items.Add("Object Location: " + $ADUserSearchResults.ObjectLocation)
            }
        }else {
            #If it isn't, use the current user's credentials
            $ADUserSearchResults = Get-ADUser -Filter {SamAccountName -eq $ADUserSearchTextBox.Text} -Server $ADUserSearchDomain

            #Check if the search returned any results
            if ($ADUserSearchResults -eq $null) {
                #If it didn't, display a message box
                $Wshell = New-Object -ComObject Wscript.Shell
                $Wshell.Popup("No results found.",0,"No results found",0x0)
            }else{
                #If it did, output the results to the listbox
                #Name
                $ADUserSearchResultsListBox.Items.Add("Name: " + $ADUserSearchResults.Name)
                #SamAccountName
                $ADUserSearchResultsListBox.Items.Add("Username: " + $ADUserSearchResults.SamAccountName)
                #DistinguishedName
                $ADUserSearchResultsListBox.Items.Add("Distinguished Name: " + $ADUserSearchResults.DistinguishedName)
                #Enabled
                $ADUserSearchResultsListBox.Items.Add("Enabled: " + $ADUserSearchResults.Enabled)
                #LastLogonDate
                $ADUserSearchResultsListBox.Items.Add("Last Logon Date: " + $ADUserSearchResults.LastLogonDate)
                #Object Location
                $ADUserSearchResultsListBox.Items.Add("Object Location: " + $ADUserSearchResults.ObjectLocation)
            }
            
        }
    }
}
})

$ADUserSearchForm.Controls.Add($ADUserSearchButton)

#Listbox for results
$ADUserSearchListBox = New-Object system.Windows.Forms.ListBox
$ADUserSearchListBox.Location = New-Object System.Drawing.Size(10,180)
$ADUserSearchListBox.Size = New-Object System.Drawing.Size(465,265)
$ADUserSearchListBox.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",10,[System.Drawing.FontStyle]::Regular)
$ADUserSearchListBox.BackColor = $BGcolor
$ADUserSearchListBox.ForeColor = $TextColor
$ADUserSearchListBox.SelectionMode = 'MultiExtended'
$ADUserSearchForm.Controls.Add($ADUserSearchListBox)

#Show the form
$ADUserSearchForm.ShowDialog()