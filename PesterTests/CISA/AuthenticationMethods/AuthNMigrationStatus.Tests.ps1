BeforeAll {
Write-TestInProgress
}

Describe "Test-AuthNMigrationStatus" -Tag "CISA", "AuthenticationMethods", "Done" {
  Context "Authentication Migration Shall be completed - MS.AAD.3.4" {
    It "Validates the completion of migration from legacy policy settings" {
      $result = Test-AuthNMigrationStatus
      $result | Should -Be "Pass" -Because "Authentication Migration Shall be completed"
    }
  }
}
