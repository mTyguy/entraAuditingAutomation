BeforeAll {
Write-TestInProgress
}

Describe "Test-UnmanagedUsersContactInternal" -Tag "CISA", "Teams" {
  Context "Unmanaged Users Shall Not be enabled to initiate contact with Internal Users - MS.TEAMS.2.2" {
    It "Validates unmanaged users cannot initiate users via Teams" {
      $result = Test-UnmanagedUsersContactInternal
      $result | Should -Be "Pass" -Because "Unmanaged Users Shall Not be enabled to initiate contact with Internal Users."
    }
  }
}
