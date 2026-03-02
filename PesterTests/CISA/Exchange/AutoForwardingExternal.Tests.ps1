BeforeAll {
Write-TestInProgress
}

Describe "Test-AutoForwardingExternal" -Tag "CISA", "Exchange", "Done" {
  Context "Automatic forwarding to External Domains Shall be Disabled - MS.EXCHANGE.1.1" {
    It "Validates emails cannot be forwarded to external domain automatically" {
      $result = Test-AutoForwardingExternal
      $result | Should -Be "Pass" -Because "Automatic forwarding to External Domains Shall be Disabled"
    }
  }
}
