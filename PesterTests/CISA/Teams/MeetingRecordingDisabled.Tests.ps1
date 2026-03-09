BeforeAll {
Write-TestInProgress
}

Describe "Test-MeetingRecordingDisabled" -Tag "CISA", "Teams" {
  Context "Meeting Recording Should be disabled - MS.TEAMS.1.6" {
    It "Validates Meeting Recording is not permitted" {
      $result = Test-MeetingRecordingDisabled
      $result | Should -Be "Pass" -Because "Meeting Recording Should be disabled."
    }
  }
}
