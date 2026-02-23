BeforeAll {
Write-TestInProgress
}

Describe "Test-EventRecordingDisabled" -Tag "CISA", "Teams" {
  Context "Event Recording Should not be set to Always Record - MS.TEAMS.1.7" {
    It "Validates Events are not automatically recorded" {
      $result = Test-EventRecordingDisabled
      $result | Should -Be "Pass" -Because "Event Recording Should not be set to Always Record."
    }
  }
}
