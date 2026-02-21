BeforeAll {
Write-TestInProgress
}

Describe "Test-UserApplicationConsent" -Tag "CISA", "ApplicationConsent", "Done" {
  Context "User Application Consent Settings - MS.AAD.5.2" {
    It "Validates that users cannot give Consent to Applications" {
      $result = Test-UserApplicationConsent
      $result | Should -Be "Pass" -Because "Users Shall not be able to consent to Applications"
    }
  }
}
