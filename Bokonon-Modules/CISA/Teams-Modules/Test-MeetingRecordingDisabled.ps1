<#
Documentation: https://learn.microsoft.com/en-us/microsoftteams/settings-policies-reference?WT.mc_id=TeamsAdminCenterCSH#recording--transcription
Least Privilege Delegated = 
Least Privilege Application = 
#>
function Test-MeetingRecordingDisabled {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment

  $teamsMeetingsPolicies = Get-CsTeamsMeetingPolicy

  $teamsMeetingRecordingPolicies = $teamsMeetingsPolicies | Where-Object {$_.AllowCloudRecording -eq $true}

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
      'Result'   = "No policies allow Meetings to be recorded."
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
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "Meeting Recording Should be disabled." -Result "$PassFail" -Resolution "Ensure meetings are not able to be recorded." -Controls "The Global policy is the default. If a user has a policy assigned to them, that takes policy takes precedent." -Citations "https://learn.microsoft.com/en-us/microsoftteams/settings-policies-reference?WT.mc_id=TeamsAdminCenterCSH#recording--transcription" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Get Reports folder
$CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.TEAMS.1.6 - Meeting Recording Should be disabled' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'Global & Non-compliant policies regarding Meeting Recording Settings' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\MeetingRecordingDisabled.html"
}
