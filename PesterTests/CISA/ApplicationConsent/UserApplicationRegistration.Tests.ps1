BeforeAll {
Write-TestInProgress
}

Describe "Test-UserApplicationRegistration" -Tag "CISA", "Entra", "Done" {
  Context "Administrator Application Registration Settings - MS.AAD.5.1" {
    It "Validates that only Admins can register Applications" {
      $result = Test-UserApplicationRegistration
      $result | Should -Be "Pass" -Because "Only Administrator Shall be able to Registration Applications"
    }
  }
}
