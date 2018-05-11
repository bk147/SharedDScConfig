@{
    PSDependOptions = @{
        AddToPath = $True
        Target = 'DSC_Resources'
        Parameters = @{
            #Force = $True
            #Import = $True
        }
    }

    Chocolatey = 'latest'
#    Chocolatey = '0.0.48'
}