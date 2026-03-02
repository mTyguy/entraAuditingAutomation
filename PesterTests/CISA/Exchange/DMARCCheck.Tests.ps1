BeforeAll {
Write-TestInProgress
}

Describe "Test-DMARCCheck" -Tag "CISA", "Exchange" {
  Context "A DMARC Record Shall be published for each domain - MS.EXCHANGE.4.1" {
    It "Validates DMARC Records" {
      $result = Test-DMARCCheck
      $result | Should -Be "Pass" -Because "A DMARC Record Shall be published for each domain."
    }
  }
}
