function Open-LAPSToolWindow
{
    $GetLAPSToolButtonLogic = {
        if($SourceEntraIDCheckBox.Checked -and $AzureADHostNameTextBox.Text -ne "")
        {
            try{
                Connect-MgGraph -Scopes Device.Read.All, DeviceLocalCredential.Read.All
                $lapsResult = (Get-LapsAADPassword -DeviceIds $AzureADHostNameTextBox.Text -IncludePasswords -AsPlainText).Password
            }
            catch{
                $wshell = New-Object -ComObject wscript.shell
                $wshell.popup("There was an error while retreiving the LAPS Password from Entra ID. Please verify that the Device exists in the Entra ID Directory and you have the appropriate permissions to view LAPS Passwords", 0, $WindowTitle, 0x00000040)
                return
            }
        }
        elseif ($SourceOnPremCheckBox.Checked -and $ADHostNameTextBox.Text -ne "") {
            try {
                if ($ADUserNameTextBox.Text -ne "$($domain + "\" + $env:USERNAME)")
                {
                    $alternateCredential = Get-Credential $ADUserNameTextBox.Text
                    $lapsResult = Get-LapsADPassword $ADHostNameTextBox.Text -Credential $alternateCredential -DecryptionCredential $alternateCredential -Domain $ADDomainNameTextBox.Text -AsPlainText
                }
                else {
                    $lapsResult = (Get-LapsADPassword $ADHostNameTextBox.Text -Domain $ADDomainNameTextBox.Text -AsPlainText).Password
                }
                $recoveryPassword = $bitlockerObj | Select-Object -ExpandProperty msFVE-RecoveryPassword
            }
            catch {
                $wshell = New-Object -ComObject wscript.shell
                $wshell.popup("There was an error while retreiving the LAPS Password from your on-premises Active Directory. Please verify that the Device exists in Active Directory and you have the appropriate permissions to view LAPS Passwords", 0, $WindowTitle, 0x00000040)
                return
            }
        }
        # Show LAPS Password and copy to clipboard
        $lapsResult | clip
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("LAPS Password is $lapsResult. Copied to clipboard.", 0, $WindowTitle, 0x00000040)
    }

    #Test RSAT AD Tools is installed
    if ((Get-Command -Name Get-LapsAADPassword -ErrorAction SilentlyContinue) -and (Get-Command -Name Get-LapsADPassword -ErrorAction SilentlyContinue)) {
        #RSAT is installed. Create the Window
        Create-GenericToolWindow -WindowTitle "LAPS GUI" -WindowBackgroundColor $BGcolor -WindowTextColor $TextColor -IconPathURL "https://winaero.com/blog/wp-content/uploads/2020/04/BitLocker-Big-256-Icon-2.png" -ExecuteButtonText "Get LAPS Password" -ExecuteButtonBackgroundColor $BrandColor -ExecuteButtonTextColor $ButtonTextColor -ExecuteButtonScriptBlock $GetLAPSToolButtonLogic
    }
    else {
        #RSAT is not installed
        $wshell = New-Object -ComObject wscript.shell
        $wshell.popup("Cannot launch LAPS Tool because the Windows LAPS modules were not detected in your PowerShell environment.", 0, "LAPS GUI", 0x00000040)             
    }
}