<#
Documentation: https://learn.microsoft.com/en-us/powershell/module/exchangepowershell/get-eopprotectionpolicyrule?view=exchange-ps
#>
function Test-DefenderStandardAndStrictPolicies {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment

  $defenderExchangeOnlineProtectionPolicies = Get-EOPProtectionPolicyRule

  $standardPolicyEnabled = $false
  $strictPolicyEnabled   = $false

  foreach ($_ in $defenderExchangeOnlineProtectionPolicies) {
    if ($_.Identity -eq "Standard Preset Security Policy" -and $_.State -eq "Enabled") {
      $standardPolicyEnabled = $true
    }
  }
  foreach ($_ in $defenderExchangeOnlineProtectionPolicies) {
    if ($_.Identity -eq "Strict Preset Security Policy" -and $_.State -eq "Enabled") {
      $strictPolicyEnabled = $true
    }
  }

# Set default to Fail

  $PassFail = "Fail"

  if ($defenderExchangeOnlineProtectionPolicies.Count -eq "0") {
    $PassFail = "Fail"
    } elseif ($standardPolicyEnabled -eq $false -and $strictPolicyEnabled -eq $false) {
        $PassFail = "Fail"
    } elseif ($standardPolicyEnabled -eq $true -and $strictPolicyEnabled -eq $false) {
        $PassFail = "Fail"
    } elseif ($standardPolicyEnabled -eq $false -and $strictPolicyEnabled -eq $true) {
        $PassFail = "Fail"
    } elseif ($standardPolicyEnabled -eq $true -and $strictPolicyEnabled -eq $true) {
        $PassFail = "Pass"
    } else {
      $PassFail = "Fail"
    }

# Output for Pester
  Write-Output $PassFail

### Html Construction ###

  $htmlConstruction = @()

  if ($defenderExchangeOnlineProtectionPolicies.Count -eq "0") {
    $htmlConstruction = [ordered] @{
      'Result'      = "Neither policies are enabled."
      'Description' = "Enabled Standard and Strict protection."
    }
  } else {
    foreach ($_ in $defenderExchangeOnlineProtectionPolicies) {
      $htmlConstruction += $resultArray = [ordered] @{
        'Display Name'               = $_.Identity
        'State'                      = $_.State
        }
      }
    }
    
# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "Standard and Strict O365 Security Policies Shall be Enabled." -Result "$PassFail" -Resolution "Ensure Standard and Strict policies are enabled in Threat policies section of Defender." -Controls "See the below reference" -Citations "https://learn.microsoft.com/en-us/defender-office-365/preset-security-policies" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Get Reports folder
$CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.DEFENDER.1.1 - Standard and Strict O365 Security Policies Shall be Enabled' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'Standard and Strict Policy Settings' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\MS.DEFENDER.1.1_DefenderStandardAndStrictPolicies.html"
}
