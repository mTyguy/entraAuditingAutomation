<#
Documentation: https://learn.microsoft.com/en-us/powershell/module/exchangepowershell/get-eopprotectionpolicyrule?view=exchange-ps
#>
function Test-DefenderStandardAndStrictPoliciesAllUsers {
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
        foreach ($_ in $defenderExchangeOnlineProtectionPolicies) {
          if ($_.SentTo.Count -ge "1" -or $_.SentToMemberOf.Count -ge "1" -or $_.RecipientDomainIs.Count -ge "1" -or $_.ExceptIfSentTo.Count -ge "1" -or $_.ExceptIfSentToMemberOf.Count -ge "1" -or $_.ExceptIfRecipientDomainIs.Count -ge "1") {
            $PassFail = "Fail"
            $exceptionsEnabled = $true
          }
        }
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
  } elseif ($exceptionsEnabled -eq $true) {
    foreach ($_ in $defenderExchangeOnlineProtectionPolicies) {
      $htmlConstruction += $resultArray = [ordered] @{
        'Display Name'                = $_.Identity
        'State'                       = $_.State
        'Exclusion if Sent to'        = ($_.SentTo) -join ", "
        'Exclusion if member of'      = ($_.SentToMemberOf) -join ", "
        'Exclusion if sent to domain' = ($_.RecipientDomainIs) -join ", "
        'Except if sent to'           = ($_.ExceptIfSentTo) -join ", "
        'Except if member of'         = ($_.ExceptIfSentToMemberOf) -join ", "
        'Except if sent to domain'   = ($_.ExceptIfRecipientDomainIs) -join ", "
        }
      }
    } else {
    foreach ($_ in $defenderExchangeOnlineProtectionPolicies) {
      $htmlConstruction += $resultArray = [ordered] @{
        'Display Name' = $_.Identity
        'State'        = $_.State
        'Enabled for'  = "All users/recipients"
        }
      }
    }
    
# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "Standard and Strict O365 Security Policies Shall be Enabled for All Users." -Result "$PassFail" -Resolution "Ensure Standard and Strict policies are enabled in Threat policies section of Defender." -Controls "See the below reference" -Citations "https://learn.microsoft.com/en-us/defender-office-365/preset-security-policies" -Framework "Nist SP 800-53 Rev 5 FedRAMP High"

# Get Reports folder
$CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'MS.DEFENDER.1.2 - Standard and Strict O365 Security Policies Shall be Enabled for All Users' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'Standard and Strict Policy Settings' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\DefenderStandardAndStrictPoliciesAllUsers.html"
}
