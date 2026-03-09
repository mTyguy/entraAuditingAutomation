BeforeAll {
Write-TestInProgress
}

Describe "Test-ExternalParticipantsRequestControl" -Tag "CISA", "Teams" {
  Context "External meeting participants Should Not be allowed to Request Control - MS.TEAMS.1.1" {
    It "Validates external participant control settings in meetings policies" {
      $result = Test-ExternalParticipantsRequestControl
      $result | Should -Be "Pass" -Because "External meeting participants Should Not be allowed to Request Control"
    }
  }
}
