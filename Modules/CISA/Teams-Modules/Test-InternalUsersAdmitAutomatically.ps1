<#
Documentation: https://learn.microsoft.com/en-us/microsoftteams/who-can-bypass-meeting-lobby
Least Privilege Delegated = 
Least Privilege Application = 
#>
function Test-InternalUsersAdmitAutomatically {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment

  $teamsMeetingsPolicies = Get-CsTeamsMeetingPolicy

  $teamsInternalUserAdmissionPolicies = $teamsMeetingsPolicies | Where-Object {$_.AutoAdmittedUsers -ne "EveryoneInCompanyExcludingGuests"}

# Set default to Fail

  $PassFail = "Fail"

  if ($teamsInternalUserAdmissionPolicies.Count -eq "0") {
    $PassFail = "Pass"
  } elseif ($teamsInternalUserAdmissionPolicies.Count -ge "1") {
      $PassFail = "Fail"
  }

# Output for Pester
  Write-Output $PassFail

### Html Construction ###

  $htmlConstruction = @()

  if ($PassFail -eq "Pass") {
    $htmlConstruction = [ordered] @{
      'Policies' = "None"
      'Result'   = "No policies require Internal Users to be admitted from the lobby."
    }
  } elseif ($PassFail -eq "Fail") {
      $htmlConstruction += $globalPolicy = [ordered] @{
        'Policy Name'                   = ($teamsMeetingsPolicies | Where-Object {$_.Identity -eq "Global"}).Identity
        'Who is admitted automatically' = ($teamsMeetingsPolicies | Where-Object {$_.Identity -eq "Global"}).AutoAdmittedUsers
      }
    foreach ($_ in $teamsInternalUserAdmissionPolicies) {
      if ($_.AutoAdmittedUsers -ne "EveryoneInCompanyExcludingGuests" -and $_.Identity -ne "Global") {
        $htmlConstruction += $policyLoop = [ordered] @{
          'Policy Name'                   = $_.Identity
          'Who is admitted automatically' = $_.AutoAdmittedUsers
          }
        }
      }
    }

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "Internal Users Should be admitted automatically." -Result "$PassFail" -Resolution "Ensure Internal Users are admitted to meetings automatically to reduce admission fatigue. Guest Users Should not be admitted automatically." -Controls "The Global policy is the default. If a user has a policy assigned to them, that takes policy takes precedent." -Citations "https://learn.microsoft.com/en-us/microsoftteams/who-can-bypass-meeting-lobby" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Get Reports folder
$CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.TEAMS.1.4 - Internal Users Should be admitted automatically.' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'Global & Non-compliant policies regarding Internal Users Admission Settings' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\MS.TEAMS.1.4_InternalUsersAdmitAutomatically.html"
}
