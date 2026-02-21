BeforeAll {
Write-TestInProgress
}

Describe "Test-LessSecureAuthNDisabled" -Tag "CISA", "AuthenticationMethods", "Done" {
  Context "SMS, Voice, and Email authentication Shall be disabled - MS.AAD.3.5" {
    It "Validates SMS, Voice, and Email authentication state" {
      $result = Test-LessSecureAuthNDisabled
      $result | Should -Be "Pass" -Because "SMS, Voice, and Email authentication methods Shall be disabled"
    }
  }
}
