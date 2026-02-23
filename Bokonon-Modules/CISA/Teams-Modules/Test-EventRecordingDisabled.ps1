<#
Documentation: https://learn.microsoft.com/en-us/microsoftteams/teams-live-events/live-events-recording-policies
https://learn.microsoft.com/en-us/powershell/module/microsoftteams/get-csteamseventspolicy?view=teams-ps
Least Privilege Delegated = 
Least Privilege Application = 
#>
function Test-EventRecordingDisabled {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment

  $teamsEventPolicies = Get-CsTeamsEventsPolicy

  $teamsEventRecordingPolicies = $teamsEventPolicies | Where-Object {$_.AllowCloudRecording -eq "Enabled"}

# Set default to Fail

  $PassFail = "Fail"

  if ($teamsMeetingRecordingPolicies.Count -eq "0") {
    $PassFail = "Pass"
  } elseif ($teamsMeetingRecordingPolicies.Count -ge "1") {
      $PassFail = "Fail"
  }

# Output for Pester
  Write-Output $PassFail

### Html Construction ###

  $htmlConstruction = @()

  if ($PassFail -eq "Pass") {
    $htmlConstruction = [ordered] @{
      'Policies' = "None"
      'Result'   = "No policies allow meetings to be recorded."
    }
  } elseif ($PassFail -eq "Fail") {
      $htmlConstruction += $globalPolicy = [ordered] @{
        'Policy Name'                  = ($teamsMeetingsPolicies | Where-Object {$_.Identity -eq "Global"}).Identity
        'Is Meeting Recording Enabled' = ($teamsMeetingsPolicies | Where-Object {$_.Identity -eq "Global"}).AllowCloudRecording
      }
    foreach ($_ in $teamsMeetingRecordingPolicies) {
      if ($_.AllowCloudRecording -eq $true -and $_.Identity -ne "Global") {
        $htmlConstruction += $policyLoop = [ordered] @{
          'Policy Name'                   = $_.Identity
          'Is Meeting Recording Enabled'  = $_.AllowCloudRecording
          }
        }
      }
    }

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "Event Recording Should be not be set to Always Record." -Result "$PassFail" -Resolution "Ensure Events recording is set to Never Record or Organizer Can Record." -Controls "The Global policy is the default. If a user has a policy assigned to them, that takes policy takes precedent." -Citations "https://learn.microsoft.com/en-us/microsoftteams/teams-live-events/live-events-recording-policies" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Get Reports folder
$CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.TEAMS.1.7 - Event Recording Should not be set to Always Record' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'Global & Non-compliant policies regarding Event Recording Settings' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\EventRecordingDisabled.html"
}
