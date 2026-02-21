BeforeAll {
Write-TestInProgress
}

Describe "Test-MSAuthNLoginContext" -Tag "CISA", "AuthenticationMethods", "Done" {
  Context "The Microsoft Authenticator Shall display Application and Location information - MS.AAD.3.3" {
    It "Validates Microsoft Authenticator displays Application and Location information" {
      $result = Test-MSAuthNLoginContext
      $result | Should -Be "Pass" -Because "The Microsoft Authenticator Shall display Application and Location information"
    }
  }
}
