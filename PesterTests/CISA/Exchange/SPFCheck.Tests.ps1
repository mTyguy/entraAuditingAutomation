BeforeAll {
Write-TestInProgress
}

Describe "Test-SPFCheck" -Tag "CISA", "Exchange", "Done" {
  Context "An SPF Policy Shall be published for each domain. - MS.EXCHANGE.2.2" {
    It "Validates SPF Records" {
      $result = Test-SPFCheck
      $result | Should -Be "Pass" -Because "An SPF Policy Shall be published for each domain."
    }
  }
}
