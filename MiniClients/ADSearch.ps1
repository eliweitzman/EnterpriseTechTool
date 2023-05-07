#An AD User Search GUI

#Set up the form
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

#Temporary color placeholders
$BGcolor = [System.Drawing.Color]::FromArgb(255, 255, 255)
$TextColor = [System.Drawing.Color]::FromArgb(0, 0, 0)
#Pine green brand color
$BrandColor = [System.Drawing.Color]::FromArgb(1, 121, 111)

$searchType = "User"

#Create the form
$ADSearchForm = New-Object system.Windows.Forms.Form
$ADSearchForm.Text = "AD $searchType Search"
$ADSearchForm.Size = New-Object System.Drawing.Size(500, 500)
$ADSearchForm.StartPosition = "CenterScreen"
$ADSearchForm.FormBorderStyle = 'FixedDialog'
$ADSearchForm.MaximizeBox = $false
$ADSearchForm.MinimizeBox = $false
$ADSearchForm.Topmost = $true
$ADSearchForm.BackColor = $BGcolor
$ADSearchForm.ForeColor = $TextColor

#Create the username label
$ADSearchLabel = New-Object system.Windows.Forms.Label
$ADSearchLabel.Text = "Enter a $searchType search:"
$ADSearchLabel.AutoSize = $true
$ADSearchLabel.Location = New-Object System.Drawing.Size(10, 10)
$ADSearchLabel.Font = New-Object System.Drawing.Font("Microsoft Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$ADSearchLabel.BackColor = $BGcolor
$ADSearchLabel.ForeColor = $TextColor
$ADSearchForm.Controls.Add($ADSearchLabel)

#Create the text box
$ADSearchTextBox = New-Object system.Windows.Forms.TextBox
$ADSearchTextBox.Location = New-Object System.Drawing.Size(10, 30)
$ADSearchTextBox.Size = New-Object System.Drawing.Size(465, 20)
$ADSearchTextBox.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 10, [System.Drawing.FontStyle]::Regular)
$ADSearchTextBox.BackColor = $BGcolor
$ADSearchTextBox.ForeColor = $TextColor
$ADSearchForm.Controls.Add($ADSearchTextBox)

#Create a domain label
$ADSearchDomainLabel = New-Object system.Windows.Forms.Label
$ADSearchDomainLabel.Text = "Enter a domain:"
$ADSearchDomainLabel.AutoSize = $true
$ADSearchDomainLabel.Location = New-Object System.Drawing.Size(10, 60)
$ADSearchDomainLabel.Font = New-Object System.Drawing.Font("Microsoft Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$ADSearchDomainLabel.BackColor = $BGcolor
$ADSearchDomainLabel.ForeColor = $TextColor
$ADSearchForm.Controls.Add($ADSearchDomainLabel)

#Create the domain text box
$ADSearchDomainTextBox = New-Object system.Windows.Forms.TextBox
$ADSearchDomainTextBox.Location = New-Object System.Drawing.Size(10, 80)
$ADSearchDomainTextBox.Size = New-Object System.Drawing.Size(465, 20)
$ADSearchDomainTextBox.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 10, [System.Drawing.FontStyle]::Regular)
$ADSearchDomainTextBox.BackColor = $BGcolor
$ADSearchDomainTextBox.ForeColor = $TextColor
$ADSearchForm.Controls.Add($ADSearchDomainTextBox)

#Add a checkbox for adding additional authentication
$ADSearchAuthCheckBox = New-Object system.Windows.Forms.CheckBox
$ADSearchAuthCheckBox.Text = "Use alternate credentials"
$ADSearchAuthCheckBox.AutoSize = $true
$ADSearchAuthCheckBox.Location = New-Object System.Drawing.Size(10, 110)
$ADSearchAuthCheckBox.Font = New-Object System.Drawing.Font("Microsoft Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$ADSearchAuthCheckBox.BackColor = $BGcolor
$ADSearchAuthCheckBox.ForeColor = $TextColor
$ADSearchForm.Controls.Add($ADSearchAuthCheckBox)

#Search button
$ADSearchButton = New-Object system.Windows.Forms.Button
$ADSearchButton.Text = "Search"
$ADSearchButton.Location = New-Object System.Drawing.Size(10, 140)
$ADSearchButton.Size = New-Object System.Drawing.Size(465, 30)
$ADSearchButton.Font = New-Object System.Drawing.Font("Microsoft Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$ADSearchButton.BackColor = $BrandColor
$ADSearchButton.ForeColor = $TextColor

#Search button click event
$ADSearchButton.Add_Click({
        #Check searchType (User or Computer)
        if ($searchType -eq "User") {
            #Check if the domain text box is empty
            if ($ADSearchDomainTextBox.Text -eq "") {
                #If it is, use the default domain
                $ADSearchDomain = $env:USERDOMAIN

                #Check if the alternate credentials checkbox is checked
                if ($ADSearchAuthCheckBox.Checked -eq $true) {
                    #If it is, prompt for credentials
                    $ADSearchCred = Get-Credential

                    #Run the search
                    $ADSearchResults = Get-ADUser -Filter { SamAccountName -eq $ADSearchTextBox.Text } -Server $ADSearchDomain -Credential $ADSearchCred

                    #Check if the search returned any results
                    if ($ADSearchResults -eq $null) {
                        #If it didn't, display a message box
                        $Wshell = New-Object -ComObject Wscript.Shell
                        $Wshell.Popup("No results found.", 0, "No results found", 0x0)
                    }
                    else {
                        #If it did, output the results to the listbox
                        #Name
                        $ADSearchResultsListBox.Items.Add("Name: " + $ADSearchResults.Name)
                        #SamAccountName
                        $ADSearchResultsListBox.Items.Add("Username: " + $ADSearchResults.SamAccountName)
                        #DistinguishedName
                        $ADSearchResultsListBox.Items.Add("Distinguished Name: " + $ADSearchResults.DistinguishedName)
                        #Enabled
                        $ADSearchResultsListBox.Items.Add("Enabled: " + $ADSearchResults.Enabled)
                        #LastLogonDate
                        $ADSearchResultsListBox.Items.Add("Last Logon Date: " + $ADSearchResults.LastLogonDate)
                        #Object Location
                        $ADSearchResultsListBox.Items.Add("Object Location: " + $ADSearchResults.ObjectLocation)
                    }
                }
                else {
                    #If it isn't, use the current user's credentials, and run the search
                    $ADSearchResults = Get-ADUser -Filter { SamAccountName -eq $ADSearchTextBox.Text } -Server $ADSearchDomain

                    #Check if the search returned any results
                    if ($ADSearchResults -eq $null) {
                        #If it didn't, display a message box
                        $Wshell = New-Object -ComObject Wscript.Shell
                        $Wshell.Popup("No results found.", 0, "No results found", 0x0)
                    }
                    else {
                        #If it did, output the results to the listbox
                        #Name
                        $ADSearchResultsListBox.Items.Add("Name: " + $ADSearchResults.Name)
                        #SamAccountName
                        $ADSearchResultsListBox.Items.Add("Username: " + $ADSearchResults.SamAccountName)
                        #DistinguishedName
                        $ADSearchResultsListBox.Items.Add("Distinguished Name: " + $ADSearchResults.DistinguishedName)
                        #Enabled
                        $ADSearchResultsListBox.Items.Add("Enabled: " + $ADSearchResults.Enabled)
                        #LastLogonDate
                        $ADSearchResultsListBox.Items.Add("Last Logon Date: " + $ADSearchResults.LastLogonDate)
                        #Object Location
                        $ADSearchResultsListBox.Items.Add("Object Location: " + $ADSearchResults.ObjectLocation)
                    }
                }
                else {
                    #If it isn't, use the domain from the text box
                    $ADSearchDomain = $ADSearchDomainTextBox.Text

                    #Check if the alternate credentials checkbox is checked
                    if ($ADSearchAuthCheckBox.Checked -eq $true) {
                        #If it is, prompt for credentials
                        $ADSearchCred = Get-Credential

                        #Run the search
                        $ADSearchResults = Get-ADUser -Filter { SamAccountName -eq $ADSearchTextBox.Text } -Server $ADSearchDomain -Credential $ADSearchCred
            
                        #Check if the search returned any results
                        if ($ADSearchResults -eq $null) {
                            #If it didn't, display a message box
                            $Wshell = New-Object -ComObject Wscript.Shell
                            $Wshell.Popup("No results found.", 0, "No results found", 0x0)
                        }
                        else {
                            #If it did, output the results to the listbox
                            #Name
                            $ADSearchResultsListBox.Items.Add("Name: " + $ADSearchResults.Name)
                            #SamAccountName
                            $ADSearchResultsListBox.Items.Add("Username: " + $ADSearchResults.SamAccountName)
                            #DistinguishedName
                            $ADSearchResultsListBox.Items.Add("Distinguished Name: " + $ADSearchResults.DistinguishedName)
                            #Enabled
                            $ADSearchResultsListBox.Items.Add("Enabled: " + $ADSearchResults.Enabled)
                            #LastLogonDate
                            $ADSearchResultsListBox.Items.Add("Last Logon Date: " + $ADSearchResults.LastLogonDate)
                            #Object Location
                            $ADSearchResultsListBox.Items.Add("Object Location: " + $ADSearchResults.ObjectLocation)
                        }
                    }
                    else {
                        #If it isn't, use the current user's credentials
                        $ADSearchResults = Get-ADUser -Filter { SamAccountName -eq $ADSearchTextBox.Text } -Server $ADSearchDomain

                        #Check if the search returned any results
                        if ($ADSearchResults -eq $null) {
                            #If it didn't, display a message box
                            $Wshell = New-Object -ComObject Wscript.Shell
                            $Wshell.Popup("No results found.", 0, "No results found", 0x0)
                        }
                        else {
                            #If it did, output the results to the listbox
                            #Name
                            $ADSearchResultsListBox.Items.Add("Name: " + $ADSearchResults.Name)
                            #SamAccountName
                            $ADSearchResultsListBox.Items.Add("Username: " + $ADSearchResults.SamAccountName)
                            #DistinguishedName
                            $ADSearchResultsListBox.Items.Add("Distinguished Name: " + $ADSearchResults.DistinguishedName)
                            #Enabled
                            $ADSearchResultsListBox.Items.Add("Enabled: " + $ADSearchResults.Enabled)
                            #LastLogonDate
                            $ADSearchResultsListBox.Items.Add("Last Logon Date: " + $ADSearchResults.LastLogonDate)
                            #Object Location
                            $ADSearchResultsListBox.Items.Add("Object Location: " + $ADSearchResults.ObjectLocation)
                        }
            
                    }
                }
            }
        }elseif ($searchType -eq "Computer"){
            #Check if the domain text box is empty
            if ($ADSearchDomainTextBox.Text -eq "") {
               #If so, use the current domain
                $ADSearchDomain = $env:USERDOMAIN
                #Check if the alternate credentials checkbox is checked
                if ($ADSearchAuthCheckBox.Checked -eq $true) {
                    #If it is, prompt for credentials
                    $ADSearchCred = Get-Credential

                    #Run the search
                    $ADSearchResults = Get-ADComputer -Filter { SamAccountName -eq $ADSearchTextBox.Text } -Server $ADSearchDomain -Credential $ADSearchCred

                    #Check if the search returned any results
                    if ($ADSearchResults -eq $null) {
                        #If it didn't, display a message box
                        $Wshell = New-Object -ComObject Wscript.Shell
                        $Wshell.Popup("No results found.", 0, "No results found", 0x0)
                    }
                    else {
                        #If it did, output the results to the listbox
                        #Name
                        $ADSearchResultsListBox.Items.Add("Name: " + $ADComputerSearchResults.Name)
                        #CanonicalName
                        $ADSearchResultsListBox.Items.Add("Canonical Name: " + $ADComputerSearchResults.CanonicalName)
                        #DistinguishedName
                        $ADSearchResultsListBox.Items.Add("Distinguished Name: " + $ADComputerSearchResults.DistinguishedName)
                        #Updated
                        $ADSearchResultsListBox.Items.Add("Last Updated: " + $ADComputerSearchResults.Modified)
                        #Description
                        $ADSearchResultsListBox.Items.Add("Description: " + $ADComputerSearchResults.Description)
                        #OperatingSystem
                        $ADSearchResultsListBox.Items.Add("Operating System: " + $ADComputerSearchResults.OperatingSystem)
                        #OperatingSystemVersion
                        $ADSearchResultsListBox.Items.Add("Operating System Version: " + $ADComputerSearchResults.OperatingSystemVersion)
                    }
                }else {
                    #If it isn't, use the current user's credentials, and run the search
                    $ADSearchResults = Get-ADComputer -Filter { SamAccountName -eq $ADSearchTextBox.Text } -Server $ADSearchDomain

                    #Check if the search returned any results
                    if ($ADSearchResults -eq $null) {
                        #If it didn't, display a message box
                        $Wshell = New-Object -ComObject Wscript.Shell
                        $Wshell.Popup("No results found.", 0, "No results found", 0x0)
                    }
                    else {
                        #If it did, output the results to the listbox
                        #Name
                        $ADSearchResultsListBox.Items.Add("Name: " + $ADComputerSearchResults.Name)
                        #CanonicalName
                        $ADSearchResultsListBox.Items.Add("Canonical Name: " + $ADComputerSearchResults.CanonicalName)
                        #DistinguishedName
                        $ADSearchResultsListBox.Items.Add("Distinguished Name: " + $ADComputerSearchResults.DistinguishedName)
                        #Updated
                        $ADSearchResultsListBox.Items.Add("Last Updated: " + $ADComputerSearchResults.Modified)
                        #Description
                        $ADSearchResultsListBox.Items.Add("Description: " + $ADComputerSearchResults.Description)
                        #OperatingSystem
                        $ADSearchResultsListBox.Items.Add("Operating System: " + $ADComputerSearchResults.OperatingSystem)
                        #OperatingSystemVersion
                        $ADSearchResultsListBox.Items.Add("Operating System Version: " + $ADComputerSearchResults.OperatingSystemVersion)
                    }
                }
            } else {
                #If it isn't, use the domain specified in the text box
                $ADSearchDomain = $ADSearchDomainTextBox.Text
                #Check if the alternate credentials checkbox is checked
                if ($ADSearchAuthCheckBox.Checked -eq $true) {
                    #If it is, prompt for credentials
                    $ADSearchCred = Get-Credential

                    #Run the search
                    $ADSearchResults = Get-ADComputer -Filter { SamAccountName -eq $ADSearchTextBox.Text } -Server $ADSearchDomain -Credential $ADSearchCred

                    #Check if the search returned any results
                    if ($ADSearchResults -eq $null) {
                        #If it didn't, display a message box
                        $Wshell = New-Object -ComObject Wscript.Shell
                        $Wshell.Popup("No results found.", 0, "No results found", 0x0)
                    }
                    else {
                        #If it did, output the results to the listbox
                        #Name
                        $ADSearchResultsListBox.Items.Add("Name: " + $ADComputerSearchResults.Name)
                        #CanonicalName
                        $ADSearchResultsListBox.Items.Add("Canonical Name: " + $ADComputerSearchResults.CanonicalName)
                        #DistinguishedName
                        $ADSearchResultsListBox.Items.Add("Distinguished Name: " + $ADComputerSearchResults.DistinguishedName)
                        #Updated
                        $ADSearchResultsListBox.Items.Add("Last Updated: " + $ADComputerSearchResults.Modified)
                        #Description
                        $ADSearchResultsListBox.Items.Add("Description: " + $ADComputerSearchResults.Description)
                        #OperatingSystem
                        $ADSearchResultsListBox.Items.Add("Operating System: " + $ADComputerSearchResults.OperatingSystem)
                        #OperatingSystemVersion
                        $ADSearchResultsListBox.Items.Add("Operating System Version: " + $ADComputerSearchResults.OperatingSystemVersion)
                    }
                }else {
                    #If it isn't, use the current user's credentials, and run the search
                    $ADSearchResults = Get-ADComputer -Filter { SamAccountName -eq $ADSearchTextBox.Text } -Server $ADSearchDomain

                    #Check if the search returned any results
                    if ($ADSearchResults -eq $null) {
                        #If it didn't, display a message box
                        $Wshell = New-Object
                        $Wshell.Popup("No results found.", 0, "No results found", 0x0)
                    }
                    else {
                        #If it did, output the results to the listbox
                        #Name
                        $ADSearchResultsListBox.Items.Add("Name: " + $ADComputerSearchResults.Name)
                        #CanonicalName
                        $ADSearchResultsListBox.Items.Add("Canonical Name: " + $ADComputerSearchResults.CanonicalName)
                        #DistinguishedName
                        $ADSearchResultsListBox.Items.Add("Distinguished Name: " + $ADComputerSearchResults.DistinguishedName)
                        #Updated
                        $ADSearchResultsListBox.Items.Add("Last Updated: " + $ADComputerSearchResults.Modified)
                        #Description
                        $ADSearchResultsListBox.Items.Add("Description: " + $ADComputerSearchResults.Description)
                        #OperatingSystem
                        $ADSearchResultsListBox.Items.Add("Operating System: " + $ADComputerSearchResults.OperatingSystem)
                        #OperatingSystemVersion
                        $ADSearchResultsListBox.Items.Add("Operating System Version: " + $ADComputerSearchResults.OperatingSystemVersion)
                    }
                }
            }
        }
    })

$ADSearchForm.Controls.Add($ADSearchButton)

#Listbox for results
$ADSearchListBox = New-Object system.Windows.Forms.ListBox
$ADSearchListBox.Location = New-Object System.Drawing.Size(10, 180)
$ADSearchListBox.Size = New-Object System.Drawing.Size(465, 265)
$ADSearchListBox.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 10, [System.Drawing.FontStyle]::Regular)
$ADSearchListBox.BackColor = $BGcolor
$ADSearchListBox.ForeColor = $TextColor
$ADSearchListBox.SelectionMode = 'MultiExtended'
$ADSearchForm.Controls.Add($ADSearchListBox)

#Show the form
$ADSearchForm.ShowDialog()