BeforeAll {
Write-TestInProgress
}

Describe "Test-InternalUsersContactUnmanagedUsers" -Tag "CISA", "Teams", "Done" {
  Context "Internal Users Should not be enabled to initiate contact with Unmanaged Users - MS.TEAMS.2.3" {
    It "Validates Internal users cannot initiate external users via Teams" {
      $result = Test-InternalUsersContactUnmanagedUsers
      $result | Should -Be "Pass" -Because "Internal Users Should not be enabled to initiate contact with Unmanaged Users."
    }
  }
}
