function Open-BitLockerRecoveryWindow
{
    $GetBitLockerKeyButtonLogic = {
        if($SourceEntraIDCheckBox.Checked -and $AzureADHostNameTextBox.Text -ne "")
        {
            try{
                if($UseProxyAppCheckBox.Checked)
                {
                    if(($bitLockerAppClientId -ne "" -and $tenantID -ne ""))
                    {
                        Connect-MgGraph -TenantId $tenantID -ClientId $bitLockerAppClientId -Scopes Device.Read.All, DeviceLocalCredential.Read.All
                    }
                    else {
                        $wshell = New-Object -ComObject wscript.shell
                        $wshell.popup("In order to use the Proxy App Configuration, the AzureADTenantId and BitLockerAppClientId needs to be set in the ETT.config file. ", 0, $WindowTitle, 0x00000040)
                        return
                    }
                }
                else {
                    Connect-MgGraph -Scopes BitlockerKey.Read.All
                }

                #Start by getting the recovery key id from Azure
                $deviceId = Get-MgDevice -Filter "displayName eq '$($AzureADHostNameTextBox.Text)'" -Property DisplayName, DeviceId | Select-Object DeviceId

                #Clean out the header
                $deviceIdclean = $deviceId.DeviceId

                #Using the device id, run a get-mginformationprotectionbitlockerrecoverykey to get the recovery key
                $recoveryPasswordId = Get-MgInformationProtectionBitlockerRecoveryKey -filter "DeviceId eq '$deviceIdclean'" | Select-Object Id
                $btlkeyid = $recoveryPasswordId.Id
                $recoveryPasswordRetreival = Get-MgInformationProtectionBitlockerRecoveryKey -BitlockerRecoveryKeyId $btlkeyid -Property key | Select-Object Key
                $recoveryPassword = $recoveryPasswordRetreival.Key    
                Write-Output $recoveryPassword
            }
            catch{
                $wshell = New-Object -ComObject wscript.shell
                $wshell.popup("There was an error while retreiving the Bitlocker Password from Entra ID. Please verify that the Device exists in the Entra ID Directory and you have the appropriate permissions to view BitLocker Keys", 0, $WindowTitle, 0x00000040)
                return
            }
        }
        elseif ($SourceOnPremCheckBox.Checked -and $ADHostNameTextBox.Text -ne "") {
            try {
                if ($ADUserNameTextBox.Text -ne "$($domain + "\" + $env:USERNAME)")
                {
                    $alternateCredential = Get-Credential $ADUserNameTextBox.Text
                    $ADComputer = Get-ADComputer -Identity $($ADHostNameTextBox.Text) -Credential $alternateCredential
                    $bitlockerObj = Get-ADObject -Filter { objectclass -eq 'msFVE-RecoveryInformation' } -SearchBase $ADComputer.DistinguishedName -Properties 'msFVE-RecoveryPassword' -Credential $alternateCredential
                }
                else {
                    $ADComputer = Get-ADComputer -Identity $($ADHostNameTextBox.Text)
                    $bitlockerObj = Get-ADObject -Filter { objectclass -eq 'msFVE-RecoveryInformation' } -SearchBase $ADComputer.DistinguishedName -Properties 'msFVE-RecoveryPassword'
                }
                $recoveryPassword = $bitlockerObj | Select-Object -ExpandProperty msFVE-RecoveryPassword
                if ($recoveryPassword -eq $null)
                {
                    throw
                }
            }
            catch {
                $wshell = New-Object -ComObject wscript.shell
                $wshell.popup("There was an error while retreiving the Bitlocker Password from your on-premises Active Directory. Please verify that the Device exists in Active Directory and you have the appropriate permissions to view BitLocker Keys", 0, $WindowTitle, 0x00000040)
                return
            }
        }

        #Copy to clipboard
        $recoveryPassword | clip

        #Wshell popup window with password, and show on top
        $wshell = New-Object -ComObject wscript.shell
        $wshell.popup("BitLocker Key: " + $recoveryPassword + "`nResult copied to clipboard.", 0, $WindowTitle, 0x00000040)
    }

    #Test RSAT AD Tools is installed
    if (Get-Command -Name Get-ADComputer -ErrorAction SilentlyContinue) {
        #RSAT is installed. Create the Window
        Create-GenericToolWindow -WindowTitle "Bitlocker Retreival" -WindowBackgroundColor $BGcolor -WindowTextColor $TextColor -IconPathURL "https://winaero.com/blog/wp-content/uploads/2020/04/BitLocker-Big-256-Icon-2.png" -ExecuteButtonText "Get BitLocker Key" -ExecuteButtonBackgroundColor $BrandColor -ExecuteButtonTextColor $ButtonTextColor -ExecuteButtonScriptBlock $GetBitLockerKeyButtonLogic
    }
    else {
        #RSAT is not installed
        $wshell = New-Object -ComObject wscript.shell
        $wshell.popup("Cannot launch BitLocker Tool because RSAT Tools was not detected in your PowerShell environment.", 0, "Bitlocker Retreival Error", 0x00000040)             
    }
}