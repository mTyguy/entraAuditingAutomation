BeforeAll {
Write-TestInProgress
}

Describe "Test-AnonUsersStartMeeting" -Tag "CISA", "Teams", "Done" {
  Context "Anonymous Users Shall Not be allowed to start meetings - MS.TEAMS.1.2" {
    It "Validates anonymous user settings in meetings policies" {
      $result = Test-AnonUsersStartMeeting
      $result | Should -Be "Pass" -Because "Anonymous Users Shall Not be allowed to start meetings"
    }
  }
}
