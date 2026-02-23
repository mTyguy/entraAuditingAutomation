<#
Documentation: https://learn.microsoft.com/en-us/microsoftteams/meeting-who-present-request-control
Least Privilege Delegated = 
Least Privilege Application = 
#>
function Test-ExternalParticipantsRequestControl {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment
 
  $teamsExternalParticipantRequestControl = Get-CsTeamsMeetingPolicy | Where-Object {$_.AllowExternalParticipantGiveRequestControl -eq $true}

# Set default to Fail

  $PassFail = "Fail"

  if ($teamsExternalParticipantRequestControl.Count -eq "0") {
    $PassFail = "Pass"
  } elseif ($teamsExternalParticipantRequestControl.Count -ge "1") {
      $PassFail = "Fail"
  }

# Output for Pester
  Write-Output $PassFail

### Html Construction ###

  $htmlConstruction = @()

  if ($PassFail -eq "Pass") {
    $htmlConstruction = [ordered] @{
      'Policies' = "None"
      'Result'   = "No policies allow external participants to request control."
    }
  } elseif ($PassFail -eq "Fail") {
    foreach ($_ in $teamsExternalParticipantRequestControl) {
      if ($_.AllowExternalParticipantGiveRequestControl -eq $true) {
        $htmlConstruction += $policyLoop = [ordered] @{
          'Policy Name'                          = $_.Identity
          'External Participant Request Control' = $_.AllowExternalParticipantGiveRequestControl
          }
        }
      }
    }

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "External meeting participants Should Not be allowed to request control of shared desktops or windows." -Result "$PassFail" -Resolution "Ensure each Meetings Policy does not allow external participants to request control." -Controls "Use these technologies to remediate" -Citations "https://learn.microsoft.com/en-us/microsoftteams/meeting-who-present-request-control" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Get Reports folder
$CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.TEAMS.1.1 - External meeting participants Should Not be allowed to request control of shared desktops or windows.' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'External Meeting Participants Settings' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\ExternalParticipantsRequestControl.html"
}
