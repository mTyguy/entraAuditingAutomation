function Test-StaleGuests {
  [Cmdletbinding()]
  Param(
  )
# Grab required data from environment
  $guestUsers = (Invoke-MgGraphRequest -Method GET -Uri "https://graph.microsoft.com/v1.0/users?`$filter=userType eq 'Guest'&`$select=id,displayName,userPrincipalName,accountEnabled,userType").Value

# Check each guest account for last login date/time & Pass/Fail logic

  $PassFail = "Inconclusive"

  foreach ($_ in $guestUsers) {
    $lastSignIn = (Get-MgUser -UserId "$($_.id)" -Property SignInActivity).SignInActivity.LastSignInDateTime

    if ($lastSignIn -eq $null -or "") {
      #Write-Output "No sign in info record for $($_.userPrincipalName)"
      $PassFail = "Fail"
    } 

    #else {
    #    #Write-Output "$($_.userPrincipalName) last sign in $lastSignIn"
    #    $PassFail = "Pass"
    #  }
  }

# Output for Pester
  Write-Output $PassFail

### Html Construction ###

# Create Rule Meta Data
  $htmlRuleMetaData = New-RuleMetaData -RuleDescription "Looking for Guest user account that have never logged in" -Result "$PassFail" -Resolution "Review the users above and determine if their accounts should be deleted." -Controls "Use these technologies to remediate" -Citations "https://learn.microsoft.com/en-us/entra/external-id/user-properties" -Framework "N/A"

# Environment Data Array
  $htmlConstruction = @()

  foreach ($_ in $guestUsers) {
    $htmlConstruction += $resultArray = [ordered] @{
      'Display Name'            = $_.displayName
      'User Principal Name'     = $_.userPrincipalName
      'Object GUID'             = $_.id
      'Account Enabled'         = $_.accountEnabled
      'User Type'               = $_.userType
      'Last Interactive Signin' = (Get-MgUSer -UserId "$($_.id)"-Property SignInActivity).SignInActivity.LastSignInDateTime
    }
  }

# Get Reports folder
$CurrentReportFolderName = (Get-ChildItem -Path ".\Reports" -Directory | Sort-Object CreationTime -Descending | Select-Object -First 1).Name

# Create Html Report
  New-HTML {
    New-HtmlSection -HeaderText 'Rule #002 - Auditing for Stale Guest Users' {
      New-HtmlTable -DataTable $htmlRuleMetaData -HideFooter -Transpose -DisableInfo
    }
    New-HtmlSection -HeaderText 'Guest User Information' {
      New-HTMLTable -DataTable $htmlConstruction -HideFooter -Transpose -DisableInfo
    }
  } -FilePath ".\Reports\$CurrentReportFolderName\HtmlReports\GuestUsers00.html"
}
