<#
Documentation: https://learn.microsoft.com/en-us/graph/api/authenticationmethodspolicy-get
Least Privilege Delegated   = Policy.Read.AuthenticationMethod
Least Privilege Application = Policy.Read.AuthenticationMethod
#>
function Test-MSAuthNLoginContext {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment
  $AuthNMethodPolicies = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/policies/authenticationMethodsPolicy").authenticationMethodConfigurations

# Grab Microsoft Authenticator Policy
  foreach ($_ in $AuthNMethodPolicies) {
    if ($_.id -eq "MicrosoftAuthenticator") {
      $MSAuthN = $_
    }
  }

# Verify policy to our liking

# Set default to Fail
  $PassFail = "Fail"

  if ($MSAuthN.featureSettings.displayAppInformationRequiredState.state -eq "enabled" -and $MSAuthN.featureSettings.displayAppInformationRequiredState.includeTarget.id -eq "all_users") {
    $displayAppInformationEnabled = $true
  }

  if ($MSAuthN.featureSettings.displayLocationInformationRequiredState.state -eq "enabled" -and $MSAuthN.featureSettings.displayLocationInformationRequiredState.includeTarget.id -eq "all_users") {
    $displayLocationInformationEnabled = $true
  }

# Verify both are true
  if ($displayAppInformationEnabled -eq $true -and $displayLocationInformationEnabled -eq $true) {
    $PassFail = "Pass"
  } else {
      $PassFail = "Fail"
  }

# Output for Pester
  Write-Output $PassFail

### Html Construction ###

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "The Microsoft Authenticator Shall be configured to display Login Context Information." -Result "$PassFail" -Resolution "Edit the Microsoft Authenticator policy to show both App and Location information and that it is scoped to All Users" -Controls "Use these technologies to remediate" -Citations "https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-mfa-additional-context" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Environment Data Array
  $htmlConstruction = @()

  $htmlConstruction = [ordered] @{
    'Display Name'             = $MSAuthN.id
    'State'                    = $MSAuthN.state
    'Included Targets'         = $MSAuthN.id
    'Display App Name State'   = $MSAuthN.featureSettings.displayAppInformationRequiredState.state
    'Display App Name Targets' = $MSAuthN.featureSettings.displayAppInformationRequiredState.includeTarget.id
    'Display Location State'   = $MSAuthN.featureSettings.displayLocationInformationRequiredState.state
    'Display Location Targets' = $MSAuthN.featureSettings.displayLocationInformationRequiredState.includeTarget.id
  }

# Get Reports folder
  $CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.AAD.3.3 - Verifying Microsoft Authenticator displays Application and Location information' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'Microsoft Authenticator policy information' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\MSAuthNLoginContext.html"
}
