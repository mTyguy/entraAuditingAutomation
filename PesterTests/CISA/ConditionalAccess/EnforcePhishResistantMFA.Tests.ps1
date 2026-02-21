BeforeAll {
Write-TestInProgress
}

Describe "Test-EnforcePhishResistantMFA" -Tag "CISA", "ConditionalAccess", "Done" {
  Context "Phishing Resistant MFA Shall be Enabled for all Users - MS.AAD.3.1" {
    It "Validates Phishing Resistant MFA is enabled for everyone" {
      $result = Test-EnforcePhishResistantMFA
      $result | Should -Be "Pass" -Because "Phishing Resistant MFA Shall be Enabled for all Users"
    }
  }
}
