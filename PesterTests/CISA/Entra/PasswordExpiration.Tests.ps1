BeforeAll {
Write-TestInProgress
}

Describe "Test-PasswordExpiration" -Tag "CISA", "Entra", "Done" {
  Context "Password Shall not Expire - MS.AAD.6.1" {
    It "Validates that Passwords do not expire" {
      $result = Test-PasswordExpiration
      $result | Should -Be "Pass" -Because "Password Shall not Expire"
    }
  }
}
