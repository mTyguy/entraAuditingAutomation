BeforeAll {
Write-TestInProgress
}

Describe "Test-DialInBypassLobby" -Tag "CISA", "Teams" {
  Context "Dial-in Users Should Not be able to bypass the lobby - MS.TEAMS.1.5" {
    It "Validates Dial-in users must wait in lobby to be admitted" {
      $result = Test-DialInBypassLobby
      $result | Should -Be "Pass" -Because "Dial-in Users Should Not be able to bypass the lobby"
    }
  }
}
