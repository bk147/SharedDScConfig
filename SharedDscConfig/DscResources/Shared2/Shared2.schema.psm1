Configuration Shared2 {
    Param(
        $Param1 = 'Param from config2',
        $DestinationPath = 'C:\test2.txt'
    )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    
    File "TestFile_$(1..999|Get-Random)" {
        Ensure          = 'Present'
        DestinationPath = $DestinationPath
        Contents        = $Param1
    }

}