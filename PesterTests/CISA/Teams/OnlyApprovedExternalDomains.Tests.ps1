BeforeAll {
Write-TestInProgress
}

Describe "Test-OnlyApprovedExternalDomains" -Tag "CISA", "Teams" {
  Context "External Users Shall only be enabled on per domain basis - MS.TEAMS.2.1" {
    It "Validates External users can only be from approved domains" {
      $result = Test-OnlyApprovedExternalDomains
      $result | Should -Be "Pass" -Because "External Users Shall only be enabled on per domain basis."
    }
  }
}
