BeforeAll {
Write-TestInProgress
}

Describe "Test-SmtpDisabled" -Tag "CISA", "Exchange" {
  Context "ASMTP Auth Shall be Disabled - MS.EXCHANGE.5.1" {
    It "Validates SMTP Auth is Disabled" {
      $result = Test-SmtpDisabled
      $result | Should -Be "Pass" -Because "SMTP Auth Shall be Disabled."
    }
  }
}
