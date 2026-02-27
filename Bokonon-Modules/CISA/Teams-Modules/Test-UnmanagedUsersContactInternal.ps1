<#
Documentation: https://learn.microsoft.com/en-us/powershell/module/microsoftteams/get-cstenantfederationconfiguration
Least Privilege Delegated = 
Least Privilege Application = 
#>
function Test-UnmanagedUsersContactInternal {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment

  $teamsInboundUnmanagedSetting = Get-CsTenantFederationConfiguration

# Set default to Fail

  $PassFail = "Fail"

  if ($teamsInboundUnmanagedSetting.AllowTeamsConsumer -eq $true -and $teamsInboundUnmanagedSetting.AllowTeamsConsumerInbound -eq $false) {
    $PassFail = "Pass"
    $consumerTeamsEnabled = $true
  } elseif ($teamsInboundUnmanagedSetting.AllowTeamsConsumer -eq $false) {
    $PassFail = "Pass"
    $consumerTeamsEnabled = $false
  } else {
    $PassFail = "Fail"
  }

# Output for Pester
  Write-Output $PassFail

### Html Construction ###

  $htmlConstruction = @()

  if ($PassFail -eq "Pass" -and $consumerTeamsEnabled -eq $true) {
    $htmlConstruction = [ordered] @{
      'External Unmanaged users can initiate' = $teamsInboundUnmanagedSetting.AllowTeamsConsumerInbound
      'External Users Organization Setting'   = "External Unmanaged accounts cannot message internal users via Teams"
      }
    } elseif ($PassFail -eq "Pass" -and $consumerTeamsEnabled -eq $false) {
      $htmlConstruction = [ordered] @{
        'External Unmanaged users can initiate' = $teamsInboundUnmanagedSetting.AllowTeamsConsumerInbound
        'External Users Organization Setting'   = "External Unmanaged accounts cannot message internal users via Teams"
      }
    } elseif ($PassFail -eq "Fail") {
      $htmlConstruction = [ordered] @{
        'External Unmanaged users can initiate' = $teamsInboundUnmanagedSetting.AllowTeamsConsumerInbound
        'External Users Organization Setting'   = "External Unmanaged accounts can message internal users via Teams"
      }
    }

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "Unmanaged Users Shall Not be enabled to initiate contact with Internal Users." -Result "$PassFail" -Resolution "Ensure unmanaged users cannot initiate contact with your users via Teams." -Controls "See the below reference" -Citations "https://learn.microsoft.com/en-us/microsoftteams/trusted-organizations-external-meetings-chat?tabs=organization-settings#manage-chats-and-meetings-with-external-teams-users-not-managed-by-an-organization" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Get Reports folder
$CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.TEAMS.2.2 - Unmanaged Users Shall Not be enabled to initiate contact with Internal Users' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'External Unmanaged User Contact Settings' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\UnmanagedUsersContactInternal.html"
}
