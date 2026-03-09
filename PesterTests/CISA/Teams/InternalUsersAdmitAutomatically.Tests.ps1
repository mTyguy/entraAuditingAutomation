BeforeAll {
Write-TestInProgress
}

Describe "Test-InternalUsersAdmitAutomatically" -Tag "CISA", "Teams" {
  Context "Internal Users Should be admitted automatically - MS.TEAMS.1.4" {
    It "Validates Internal Users are admitted automatically" {
      $result = Test-InternalUsersAdmitAutomatically
      $result | Should -Be "Pass" -Because "Internal Users Should be admitted automatically."
    }
  }
}
