BeforeAll {
Write-TestInProgress
}

Describe "Test-LiveEventRecordingDisabled" -Tag "CISA", "Teams", "Done" {
  Context "Live Event Recording Should not be set to Always Record - MS.TEAMS.1.7" {
    It "Validates Events are not automatically recorded" {
      $result = Test-LiveEventRecordingDisabled
      $result | Should -Be "Pass" -Because "Live Event Recording Should not be set to Always Record."
    }
  }
}
