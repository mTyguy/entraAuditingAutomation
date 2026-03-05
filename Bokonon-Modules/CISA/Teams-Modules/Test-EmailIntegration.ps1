<#
Documentation: https://learn.microsoft.com/en-us/powershell/module/microsoftteams/get-csteamsclientconfiguration
Least Privilege Delegated = 
Least Privilege Application = 
#>
function Test-EmailIntegration {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment

  $teamsEmailIntegration = (Get-CsTeamsClientConfiguration).AllowEmailIntoChannel

# Set default to Fail

  $PassFail = "Fail"

  if ($teamsEmailIntegration -eq $false) {
    $PassFail = "Pass"
  } elseif ($teamsEmailIntegration -eq $true) {
    $PassFail = "Fail"
  }

# Output for Pester
  Write-Output $PassFail

### Html Construction ###

  $htmlConstruction = @()

  if ($PassFail -eq "Pass") {
    $htmlConstruction = [ordered] @{
      'Email Integration Enabled?' = $teamsEmailIntegration
      'Description'                = "Teams Channel Emails integration is Disabled"
      }
    } elseif ($PassFail -eq "Fail") {
      $htmlConstruction = [ordered] @{
        'Email Integration Enabled?' = $teamsEmailIntegration
        'Description'                = "Teams Channel Emails integration is Enabled"
      }
    }

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "Teams Email Integration Shall be disabled." -Result "$PassFail" -Resolution "Ensure email addresses are not created for Teams Channels." -Controls "See the below reference" -Citations "https://learn.microsoft.com/en-us/microsoftteams/manage-teams-overview" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Get Reports folder
$CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.TEAMS.4.1 - Teams Email Integration Shall be disabled' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'Email Integration Settings' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\MS.TEAMS.4.1_EmailIntegration.html"
}
