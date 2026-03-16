BeforeAll {
Write-TestInProgress
}

Describe "Test-MultiAdminDeviceRetire" -Tag "Custom", "Intune", "Devices", "BetaAPI" {
  Context "Multi Admin Access Policy Device Retire" {
    It "Validates multiple Admins required to Retire a device - Custom.Intune.Devices.1.02" {
      $result = Test-MultiAdminDeviceRetire
      $result | Should -Be "Pass" -Because "Multiple Admins Should be required to Retire a device"
    }
  }
}
