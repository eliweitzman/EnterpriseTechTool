#An AD Computer Search GUI

#Temporary color placeholders
$BGcolor = [System.Drawing.Color]::FromArgb(255,255,255)
$TextColor = [System.Drawing.Color]::FromArgb(0,0,0)
#Pine green brand color
$BrandColor = [System.Drawing.Color]::FromArgb(1,121,111)

#Set up the form
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

#Create the form
$ADComputerSearchForm = New-Object system.Windows.Forms.Form
$ADComputerSearchForm.Text = "AD Computer Search"
$ADComputerSearchForm.Size = New-Object System.Drawing.Size(500,500)
$ADComputerSearchForm.StartPosition = "CenterScreen"
$ADComputerSearchForm.FormBorderStyle = 'FixedDialog'
$ADComputerSearchForm.MaximizeBox = $false
$ADComputerSearchForm.MinimizeBox = $false
$ADComputerSearchForm.Topmost = $true
$ADComputerSearchForm.BackColor = $BGcolor
$ADComputerSearchForm.ForeColor = $TextColor

#Create the username label
$ADComputerSearchLabel = New-Object system.Windows.Forms.Label
$ADComputerSearchLabel.Text = "Enter a hostname for search:"
$ADComputerSearchLabel.AutoSize = $true
$ADComputerSearchLabel.Location = New-Object System.Drawing.Size(10,10)
$ADComputerSearchLabel.Font = New-Object System.Drawing.Font("Microsoft Segoe UI",10,[System.Drawing.FontStyle]::Bold)
$ADComputerSearchLabel.BackColor = $BGcolor
$ADComputerSearchLabel.ForeColor = $TextColor
$ADComputerSearchForm.Controls.Add($ADComputerSearchLabel)

#Create the text box
$ADComputerSearchTextBox = New-Object system.Windows.Forms.TextBox
$ADComputerSearchTextBox.Location = New-Object System.Drawing.Size(10,30)
$ADComputerSearchTextBox.Size = New-Object System.Drawing.Size(465,20)
$ADComputerSearchTextBox.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",10,[System.Drawing.FontStyle]::Regular)
$ADComputerSearchTextBox.BackColor = $BGcolor
$ADComputerSearchTextBox.ForeColor = $TextColor
$ADComputerSearchForm.Controls.Add($ADComputerSearchTextBox)

#Create a domain label
$ADComputerSearchDomainLabel = New-Object system.Windows.Forms.Label
$ADComputerSearchDomainLabel.Text = "Enter a domain:"
$ADComputerSearchDomainLabel.AutoSize = $true
$ADComputerSearchDomainLabel.Location = New-Object System.Drawing.Size(10,60)
$ADComputerSearchDomainLabel.Font = New-Object System.Drawing.Font("Microsoft Segoe UI",10,[System.Drawing.FontStyle]::Bold)
$ADComputerSearchDomainLabel.BackColor = $BGcolor
$ADComputerSearchDomainLabel.ForeColor = $TextColor
$ADComputerSearchForm.Controls.Add($ADComputerSearchDomainLabel)

#Create the domain text box
$ADComputerSearchDomainTextBox = New-Object system.Windows.Forms.TextBox
$ADComputerSearchDomainTextBox.Location = New-Object System.Drawing.Size(10,80)
$ADComputerSearchDomainTextBox.Size = New-Object System.Drawing.Size(465,20)
$ADComputerSearchDomainTextBox.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",10,[System.Drawing.FontStyle]::Regular)
$ADComputerSearchDomainTextBox.BackColor = $BGcolor
$ADComputerSearchDomainTextBox.ForeColor = $TextColor
$ADComputerSearchForm.Controls.Add($ADComputerSearchDomainTextBox)

#Add a checkbox for adding additional authentication
$ADComputerSearchAuthCheckBox = New-Object system.Windows.Forms.CheckBox
$ADComputerSearchAuthCheckBox.Text = "Use alternate credentials"
$ADComputerSearchAuthCheckBox.AutoSize = $true
$ADComputerSearchAuthCheckBox.Location = New-Object System.Drawing.Size(10,110)
$ADComputerSearchAuthCheckBox.Font = New-Object System.Drawing.Font("Microsoft Segoe UI",10,[System.Drawing.FontStyle]::Bold)
$ADComputerSearchAuthCheckBox.BackColor = $BGcolor
$ADComputerSearchAuthCheckBox.ForeColor = $TextColor
$ADComputerSearchForm.Controls.Add($ADComputerSearchAuthCheckBox)

#Search button
$ADComputerSearchButton = New-Object system.Windows.Forms.Button
$ADComputerSearchButton.Text = "Search"
$ADComputerSearchButton.Location = New-Object System.Drawing.Size(10,140)
$ADComputerSearchButton.Size = New-Object System.Drawing.Size(465,30)
$ADComputerSearchButton.Font = New-Object System.Drawing.Font("Microsoft Segoe UI",10,[System.Drawing.FontStyle]::Bold)
$ADComputerSearchButton.BackColor = $BrandColor
$ADComputerSearchButton.ForeColor = $TextColor

#Search button click event
$ADComputerSearchButton.Add_Click({
    #Check if the domain text box is empty
    if ($ADComputerSearchDomainTextBox.Text -eq "") {
        #If it is, use the default domain
        $ADComputerSearchDomain = $env:USERDOMAIN

        #Check if the alternate credentials checkbox is checked
        if ($ADComputerSearchAuthCheckBox.Checked -eq $true) {
            #If it is, prompt for credentials
            $ADComputerSearchCred = Get-Credential

            #Run the search
            $ADComputerSearchResults = Get-ADComputer -Filter {Name -like $ADComputerSearchTextBox.Text} -Server $ADComputerSearchDomain -Credential $ADComputerSearchCred

            #Check if the search returned any results
            if ($ADComputerSearchResults -eq $null) {
                #If it didn't, display a message box
                $Wshell = New-Object -ComObject Wscript.Shell
                $Wshell.Popup("No results found.",0,"No results found",0x0)
            }else {
                #If it did, output the results to the listbox
                #Name
                $ADComputerSearchResultsListBox.Items.Add("Name: " + $ADComputerSearchResults.Name)
                #CanonicalName
                $ADComputerSearchResultsListBox.Items.Add("Canonical Name: " + $ADComputerSearchResults.CanonicalName)
                #DistinguishedName
                $ADComputerSearchResultsListBox.Items.Add("Distinguished Name: " + $ADComputerSearchResults.DistinguishedName)
                #Updated
                $ADComputerSearchResultsListBox.Items.Add("Last Updated: " + $ADComputerSearchResults.Modified)
                #Description
                $ADComputerSearchResultsListBox.Items.Add("Description: " + $ADComputerSearchResults.Description)
                #OperatingSystem
                $ADComputerSearchResultsListBox.Items.Add("Operating System: " + $ADComputerSearchResults.OperatingSystem)
                #OperatingSystemVersion
                $ADComputerSearchResultsListBox.Items.Add("Operating System Version: " + $ADComputerSearchResults.OperatingSystemVersion)
            }
        }else {
            #If it isn't, use the current user's credentials, and run the search
            $ADComputerSearchResults = Get-ADComputer -Filter {Name -like $ADComputerSearchTextBox.Text} -Server $ADComputerSearchDomain

            #Check if the search returned any results
            if ($ADComputerSearchResults -eq $null) {
                #If it didn't, display a message box
                $Wshell = New-Object -ComObject Wscript.Shell
                $Wshell.Popup("No results found.",0,"No results found",0x0)
            }else {
                #If it did, output the results to the listbox
                #Name
                $ADComputerSearchResultsListBox.Items.Add("Name: " + $ADComputerSearchResults.Name)
                #CanonicalName
                $ADComputerSearchResultsListBox.Items.Add("Canonical Name: " + $ADComputerSearchResults.CanonicalName)
                #DistinguishedName
                $ADComputerSearchResultsListBox.Items.Add("Distinguished Name: " + $ADComputerSearchResults.DistinguishedName)
                #Updated
                $ADComputerSearchResultsListBox.Items.Add("Last Updated: " + $ADComputerSearchResults.Modified)
                #Description
                $ADComputerSearchResultsListBox.Items.Add("Description: " + $ADComputerSearchResults.Description)
                #OperatingSystem
                $ADComputerSearchResultsListBox.Items.Add("Operating System: " + $ADComputerSearchResults.OperatingSystem)
                #OperatingSystemVersion
                $ADComputerSearchResultsListBox.Items.Add("Operating System Version: " + $ADComputerSearchResults.OperatingSystemVersion)
            }
    } else {
        #If it isn't, use the domain from the text box
        $ADComputerSearchDomain = $ADComputerSearchDomainTextBox.Text

        #Check if the alternate credentials checkbox is checked
        if ($ADComputerSearchAuthCheckBox.Checked -eq $true) {
            #If it is, prompt for credentials
            $ADComputerSearchCred = Get-Credential

            #Run the search
            $ADComputerSearchResults = Get-ADComputer -Filter {Name -like $ADComputerSearchTextBox.Text} -Server $ADComputerSearchDomain -Credential $ADComputerSearchCred
            
            #Check if the search returned any results
            if ($ADComputerSearchResults -eq $null) {
                #If it didn't, display a message box
                $Wshell = New-Object -ComObject Wscript.Shell
                $Wshell.Popup("No results found.",0,"No results found",0x0)
            }else{
                #If it did, output the results to the listbox
                #Name
                $ADComputerSearchResultsListBox.Items.Add("Name: " + $ADComputerSearchResults.Name)
                #CanonicalName
                $ADComputerSearchResultsListBox.Items.Add("Canonical Name: " + $ADComputerSearchResults.CanonicalName)
                #DistinguishedName
                $ADComputerSearchResultsListBox.Items.Add("Distinguished Name: " + $ADComputerSearchResults.DistinguishedName)
                #Updated
                $ADComputerSearchResultsListBox.Items.Add("Last Updated: " + $ADComputerSearchResults.Modified)
                #Description
                $ADComputerSearchResultsListBox.Items.Add("Description: " + $ADComputerSearchResults.Description)
                #OperatingSystem
                $ADComputerSearchResultsListBox.Items.Add("Operating System: " + $ADComputerSearchResults.OperatingSystem)
                #OperatingSystemVersion
                $ADComputerSearchResultsListBox.Items.Add("Operating System Version: " + $ADComputerSearchResults.OperatingSystemVersion)
            }
        }else {
            #If it isn't, use the current user's credentials
            $ADComputerSearchResults = Get-ADComputer -Filter {Name -like $ADComputerSearchTextBox.Text} -Server $ADComputerSearchDomain

            #Check if the search returned any results
            if ($ADComputerSearchResults -eq $null) {
                #If it didn't, display a message box
                $Wshell = New-Object -ComObject Wscript.Shell
                $Wshell.Popup("No results found.",0,"No results found",0x0)
            }else{
                #If it did, output the results to the listbox
                #Name
                $ADComputerSearchResultsListBox.Items.Add("Name: " + $ADComputerSearchResults.Name)
                #CanonicalName
                $ADComputerSearchResultsListBox.Items.Add("Canonical Name: " + $ADComputerSearchResults.CanonicalName)
                #DistinguishedName
                $ADComputerSearchResultsListBox.Items.Add("Distinguished Name: " + $ADComputerSearchResults.DistinguishedName)
                #Updated
                $ADComputerSearchResultsListBox.Items.Add("Last Updated: " + $ADComputerSearchResults.Modified)
                #Description
                $ADComputerSearchResultsListBox.Items.Add("Description: " + $ADComputerSearchResults.Description)
                #OperatingSystem
                $ADComputerSearchResultsListBox.Items.Add("Operating System: " + $ADComputerSearchResults.OperatingSystem)
                #OperatingSystemVersion
                $ADComputerSearchResultsListBox.Items.Add("Operating System Version: " + $ADComputerSearchResults.OperatingSystemVersion)
            }
            
        }
    }
}
})

$ADComputerSearchForm.Controls.Add($ADComputerSearchButton)

#Listbox for results
$ADComputerSearchListBox = New-Object system.Windows.Forms.ListBox
$ADComputerSearchListBox.Location = New-Object System.Drawing.Size(10,180)
$ADComputerSearchListBox.Size = New-Object System.Drawing.Size(465,265)
$ADComputerSearchListBox.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",10,[System.Drawing.FontStyle]::Regular)
$ADComputerSearchListBox.BackColor = $BGcolor
$ADComputerSearchListBox.ForeColor = $TextColor
$ADComputerSearchListBox.SelectionMode = 'MultiExtended'
$ADComputerSearchForm.Controls.Add($ADComputerSearchListBox)

#Show the form
$ADComputerSearchForm.ShowDialog()