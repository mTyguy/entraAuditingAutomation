BeforeAll {
Write-TestInProgress
}

Describe "Test-PhishResistantMFAForPrivRoles" -Tag "CISA", "Entra", "Done" {
  Context "Phishing Resistant MFA Shall be enforced for Privileged Roles - MS.AAD.3.6" {
    It "Validates Phishing Resistant MFA is enforced for for Privileged Roles" {
      $result = Test-PhishResistantMFAForPrivRoles
      $result | Should -Be "Pass" -Because "Phishing Resistant MFA Shall be required for Privileged Roles"
    }
  }
}
