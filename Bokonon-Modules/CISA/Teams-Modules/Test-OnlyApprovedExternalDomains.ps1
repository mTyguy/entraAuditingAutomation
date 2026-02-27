<#
Documentation: https://learn.microsoft.com/en-us/powershell/module/microsoftteams/get-cstenantfederationconfiguration
Least Privilege Delegated = 
Least Privilege Application = 
#>
function Test-OnlyApprovedExternalDomains {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment

  $teamsExternalAccessPolicies = Get-CsTenantFederationConfiguration

# Set default to Fail

  $PassFail = "Fail"

  if ($teamsExternalAccessPolicies.AllowedDomains -like "AllowAllKnownDomains") {
    $PassFail = "Fail"
  } elseif ($teamsExternalAccessPolicies.AllowedDomains -notlike "AllowAllKnownDomains" -and $teamsExternalAccessPolicies.AllowedDomains.AllowedDomain.Count -ge "1") {
      $PassFail = "Pass"
  } elseif ($teamsExternalAccessPolicies.AllowedDomains -notlike "AllowAllKnownDomains" -and $teamsExternalAccessPolicies.AllowedDomains.AllowedDomain.Count -eq "0") {
      $PassFail = "Pass"
    }

# Output for Pester
  Write-Output $PassFail

### Html Construction ###

  $htmlConstruction = @()

  if ($PassFail -eq "Fail" -and $teamsExternalAccessPolicies.AllowedDomains -like "AllowAllKnownDomains" -and $teamsExternalAccessPolicies.BlockedDomains.Count -eq "0") {
    $htmlConstruction = [ordered] @{
      'Approved External Domains' = "All External Domains"
      'Result'                    = "All External Domains can communicate with internal Users."
    }
  } elseif ($PassFail -eq "Pass" -and $teamsExternalAccessPolicies.AllowedDomains.AllowedDomain.Count -ge "1") {
      $htmlConstruction = [ordered] @{
        'Allowed External Domains' = ($teamsExternalAccessPolicies.AllowedDomains.AllowedDomain) -join ", " -replace "Domain=", ""
        'Result'                   = "Only Approved Domains can communicate with internal users."
      }
  } elseif ($PassFail -eq "Fail" -and $teamsExternalAccessPolicies.BlockedDomains.Count -ge "1") {
      $htmlConstruction = [ordered] @{
        'Allowed External Domains' = "All, except the below"
        'Blocked External Domains' = ($teamsExternalAccessPolicies.BlockedDomains) -join ", " -replace "Domain=", ""
        'Result'                   = "All External Domains, except for the above, are allowed to communicate with internal users."
      }
  } elseif ($PassFail -eq "Pass" -and $teamsExternalAccessPolicies.AllowedDomains.AllowedDomain.Count -eq "0") {
      $htmlConstruction = [ordered] @{
        'Allowed External Domains' = "None"
        'Result'                   = "All External domains are blocked from communicating with internal users."
      }
    }

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "External Users Shall only be enabled on per domain basis." -Result "$PassFail" -Resolution "Ensure only approved external domains can communicate with internal users via Teams." -Controls "See the below reference" -Citations "https://learn.microsoft.com/en-us/defender-office-365/tenant-allow-block-list-teams-domains-configure" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Get Reports folder
$CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.TEAMS.2.1 - Meeting Recording Should be disabled' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'Global & Non-compliant policies regarding Meeting Recording Settings' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\OnlyApprovedExternalDomains.html"
}
