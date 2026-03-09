BeforeAll {
Write-TestInProgress
}

Describe "Test-DKIMCheck" -Tag "CISA", "Exchange" {
  Context "A DKIM Policy Shall be published for each domain - MS.EXCHANGE.3.1" {
    It "Validates DKIM Records" {
      $result = Test-DKIMCheck
      $result | Should -Be "Pass" -Because "A DKIM Policy Shall be published for each domain."
    }
  }
}
