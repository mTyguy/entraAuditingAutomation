<#
Documentation: https://learn.microsoft.com/en-us/powershell/module/microsoftteams/get-cstenantfederationconfiguration
Least Privilege Delegated = 
Least Privilege Application = 
#>
function Test-InternalUsersContactUnmanagedUsers {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment

  $teamsUnmangedTeamsAllowed = (Get-CsTenantFederationConfiguration).AllowTeamsConsumer

# Set default to Fail

  $PassFail = "Fail"

  if ($teamsUnmangedTeamsAllowed -eq $false) {
    $PassFail = "Pass"
  } else {
    $PassFail = "Fail"
  }

# Output for Pester
  Write-Output $PassFail

### Html Construction ###

  $htmlConstruction = @()

  if ($PassFail -eq "Pass") {
    $htmlConstruction = [ordered] @{
      'Unmanaged Teams contact allowed' = $teamsUnmangedTeamsAllowed
      'Description' = "Contact with external unmanged Teams users is not permitted."
      }
    } elseif ($PassFail -eq "Fail") {
      $htmlConstruction = [ordered] @{
        'Unmanaged Teams contact allowed' = $teamsUnmangedTeamsAllowed
        'Description' = "Contact with external unmanged Teams users is permitted."
      }
    }

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "Internal Users Should not be enabled to initiate contact with Unmanaged Users." -Result "$PassFail" -Resolution "Ensure your users cannot initiate contact with external unmanged users via Teams." -Controls "See the below reference" -Citations "https://learn.microsoft.com/en-us/microsoftteams/trusted-organizations-external-meetings-chat?tabs=organization-settings#manage-chats-and-meetings-with-external-teams-users-not-managed-by-an-organization" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Get Reports folder
$CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.TEAMS.2.3 - Internal Users Should not be enabled to initiate contact with Unmanaged Users' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'External Unmanaged User Contact Settings' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\MS.TEAMS.2.3_InternalUsersContactUnmanagedUsers.html"
}
