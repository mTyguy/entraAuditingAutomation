BeforeAll {
Write-TestInProgress
}

Describe "Test-PermActivePrivRoles" -Tag "CISA", "Entra" {
  Context "Permanently Active roles Shall not be assigned for privileged roles - MS.AAD.7.4" {
    It "Validates Accounts with Privileged Roles are not permanently active" {
      $result = Test-PermActivePrivRoles
      $result | Should -Be "Pass" -Because "Permanently Active roles Shall not be assigned for privileged roles"
    }
  }
}
