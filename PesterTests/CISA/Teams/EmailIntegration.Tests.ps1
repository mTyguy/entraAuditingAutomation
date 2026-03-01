BeforeAll {
Write-TestInProgress
}

Describe "Test-EmailIntegration" -Tag "CISA", "Teams", "Done" {
  Context "Teams Email Integration Shall be disabled - MS.TEAMS.4.1" {
    It "Validates email integration in Teams is disabled" {
      $result = Test-EmailIntegration
      $result | Should -Be "Pass" -Because "Teams Email Integration Shall be disabled."
    }
  }
}
