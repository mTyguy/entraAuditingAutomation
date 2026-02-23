BeforeAll {
Write-TestInProgress
}

Describe "Test-AnonAndDialInBypassLobby" -Tag "CISA", "Teams", "Done" {
  Context "Anonymous and Dial-in Users Should Not be admitted automatically - MS.TEAMS.1.3" {
    It "Validates Anon and Dail-in users must wait in lobby to be admitted" {
      $result = Test-AnonAndDialInBypassLobby
      $result | Should -Be "Pass" -Because "Anonymous and Dial-in Users Should Not be admitted automatically"
    }
  }
}
