function Add-Import {
    param(
        [parameter(ValueFromPipelineByPropertyName = $true)]
        [string[]]$ProjectName,
        [parameter(Position = 0, Mandatory = $true)]
        [string]$targetPath
    )
    Process {
    
        $projects = Get-Project $ProjectName
   
        if(!$projects) {
            Write-Error "Unable to locate project. Make sure it isn't unloaded."
            return
        }
        
        #Write-Warning "Targets path: $($targetsPath)"
        
        $projects | %{ 
            $project = $_
     
 
             $project | Add-SolutionDirProperty
             
             $buildProject = $project | Get-MSBuildProject
             if(!($buildProject.Xml.Imports | ?{ $_.Project -eq $targetPath } )) {
                $buildProject.Xml.AddImport($targetPath) | Out-Null
                $project.Save()
                $buildProject.ReevaluateIfNecessary()

                #Write-Info "Updated '$($project.Name)' to use 'DynamicLocalhost.targets'"
             }

        }
    }
}


function Remove-Import {
    param(
        [parameter(Position = 0, Mandatory = $true)]
        [string]$targetPath
    )
    Process {

        $projects = Get-Project -All


        if(!$projects) {
            Write-Error "Unable to locate project. Make sure it isn't unloaded."
            return
        }
        
        #Write-Warning "Targets path: $($targetsPath)"
        
        $projects | %{ 
            $project = $_
                          
                 $project | Add-SolutionDirProperty
                 
                 $buildProject = $project | Get-MSBuildProject

                 $targets = $buildProject.Xml.Imports | where { $_.Project -eq $targetPath } | %{

                    $target = $_
                        if($target -ne $null)
                        {
                            $buildProject.Xml.RemoveChild($target)
                            $project.Save()
                            $buildProject.ReevaluateIfNecessary()
                        }     
                 }
            }
    }
}