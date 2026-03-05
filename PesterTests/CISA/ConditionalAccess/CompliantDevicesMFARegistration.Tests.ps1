BeforeAll {
Write-TestInProgress
}

Describe "Test-CompliantDevicesMFARegistration" -Tag "CISA", "Entra", "Done" {
  Context "Managed devices Should be required to register MFA - MS.AAD.3.8" {
    It "Validates a conditional access policy that requires devices be managed and compliant to register MFA" {
      $result = Test-CompliantDevicesMFARegistration
      $result | Should -Be "Pass" -Because "Managed devices Should be required for MFA registration"
    }
  }
}
