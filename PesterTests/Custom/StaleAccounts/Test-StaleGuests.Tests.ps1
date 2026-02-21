BeforeAll {
Write-TestInProgress
}

Describe "Test-StaleGuests" -Tag "Custom", "Guests", "Done" {
  Context "There Should be no stale guest accounts" {
    It "Looks for Guest Accounts that may have never signed in" {
      $result = Test-StaleGuests
      $result | Should -Be "Pass" -Because "There should not be any stale Guest accounts"
    }
  }
}
