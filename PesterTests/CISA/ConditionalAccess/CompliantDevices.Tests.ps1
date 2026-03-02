BeforeAll {
Write-TestInProgress
}

Describe "Test-CompliantDevices" -Tag "CISA", "ConditionalAccess", "Done" {
  Context "Managed devices Should be required to login successfully - MS.AAD.3.7" {
    It "Validates a conditional access policy that requires devices be managed or compliant exists" {
      $result = Test-CompliantDevices
      $result | Should -Be "Pass" -Because "Managed devices Should be required for Authentication"
    }
  }
}
