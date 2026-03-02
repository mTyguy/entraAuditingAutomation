BeforeAll {
Write-TestInProgress
}

Describe "Test-DefenderStandardAndStrictPoliciesAllUsers" -Tag "CISA", "Defender" {
  Context "Standard and Strict O365 Security Policies Shall be Enabled All Users - MS.DEFENDER.1.2" {
    It "Validates Standard and Strict policies are enabled for all" {
      $result = Test-DefenderStandardAndStrictPoliciesAllUsers
      $result | Should -Be "Pass" -Because "Standard and Strict O365 Security Policies Shall be Enabled for All Users"
    }
  }
}
