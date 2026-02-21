<#
Documentation: https://learn.microsoft.com/en-us/graph/api/authenticationmethodspolicy-get
Least Privilege Delegated   = Policy.Read.AuthenticationMethod
Least Privilege Application = Policy.Read.AuthenticationMethod
#>
function Test-LessSecureAuthNDisabled {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment
  $AuthNMethodPolicies = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/policies/authenticationMethodsPolicy").authenticationMethodConfigurations

# Grab SMS, Voicecall, and Email AuthN settings
  foreach ($_ in $AuthNMethodPolicies) {
    if ($_.id -eq "Sms") {                   
      $SmsSettings = $_
    } elseif ($_.id -eq "Voice") {
      $VoiceSettings = $_
    } elseif ($_.id -eq "Email") {
      $EmailSettings = $_
    }
  }

# Verify policy to our liking

# Set default to Fail
  $PassFail = "Fail"

  if ($SmsSettings.state -eq "disabled") {
    $SmsDisabled = $true
  }

  if ($VoiceSettings.state -eq "disabled") {
    $VoiceDisabled = $true
  }

  if ($EmailSettings.state -eq "disabled") {
    $EmailDisabled = $true
  }

# Verify both are true
  if ($SmsDisabled -eq $true -and $VoiceDisabled -eq $true -and $EmailDisabled -eq $true) {
    $PassFail = "Pass"
  } else {
      $PassFail = "Fail"
  }

# Output for Pester
  Write-Output $PassFail

### Html Construction ###

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "SMS, Voice Call, and Email One-Time Passcode (TOTP) Shall be disabled." -Result "$PassFail" -Resolution "Disable SMS, Voice, and Email authentication methods in favor of stronger MFA methods." -Controls "Use these technologies to remediate" -Citations "https://learn.microsoft.com/en-us/entra/identity/authentication/howto-authentication-sms-signin, https://learn.microsoft.com/en-us/entra/identity/authentication/concept-authentication-phone-options, https://learn.microsoft.com/en-us/entra/identity/authentication/howto-authentication-use-email-signin" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Environment Data Array
  $htmlConstruction = @()

  $htmlConstruction = [ordered] @{
    'SMS Display Name'   = $SmsSettings.id
    'SMS State'          = $SmsSettings.state
    'Voice Display Name' = $VoiceSettings.id
    'Voice State'        = $VoiceSettings.state
    'Email Display Name' = $EmailSettings.id
    'Email State'        = $EmailSettings.state
  }

# Get Reports folder
  $CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.AAD.3.5 - Verifying SMS, Voice, and Email authentication methods are disabled' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'SMS, Voice, & Email state' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\LessSecureAuthNDisabled.html"
}
