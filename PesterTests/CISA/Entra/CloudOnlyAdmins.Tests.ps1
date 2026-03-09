BeforeAll {
Write-TestInProgress
}

Describe "Test-CloudOnlyAdmins" -Tag "CISA", "Entra" {
  Context "Administrator Accounts Shall be Cloud Only Accounts - MS.AAD.7.3" {
    It "Validates Accounts with Privileged Roles are Cloud Only" {
      $result = Test-CloudOnlyAdmins
      $result | Should -Be "Pass" -Because "Admins Shall be Cloud Only"
    }
  }
}
