<#
Documentation: https://learn.microsoft.com/en-us/graph/api/resources/authenticationmethodspolicy
Least Privilege Delegated   = Policy.Read.AuthenticationMethod
Least Privilege Application = Policy.Read.AuthenticationMethod
#>
function Test-AuthNMigrationStatus {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment
  $AuthNMethodMigrationStatus = Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/policies/authenticationMethodsPolicy"

# Verify policy to our liking

# Set default to Fail
  $PassFail = "Fail"

  if ($AuthNMethodMigrationStatus.policyMigrationState -eq "migrationComplete" ) {
    $PassFail = "Pass"
  } else {
    $PassFail = "Fail"
  }

# Output for Pester
  Write-Output $PassFail

### Html Construction ###

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "Authentication Methods Migration feature Shall be set to Migration Complete." -Result "$PassFail" -Resolution "Complete that Authentication migration from legacy policy settings is completed." -Controls "Use these technologies to remediate" -Citations "https://learn.microsoft.com/en-us/entra/identity/authentication/how-to-authentication-methods-manage#start-the-migration" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Environment Data Array
  $htmlConstruction = @()

  $htmlConstruction = [ordered] @{
    'Display Name'     = $AuthNMethodMigrationStatus.displayName
    'Migration Status' = $AuthNMethodMigrationStatus.policyMigrationState
  }

# Get Reports folder
  $CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.AAD.3.4 - Verifying that Authentication Migration is completed' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'Migration Status' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\MS.AAD.3.4_AuthnMigrationStatus.html"
}
