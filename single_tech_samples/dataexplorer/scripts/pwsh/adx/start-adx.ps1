<#
[Azure Data Explorer Create Cluster]
Azure Data Explorer resource provisioning
1. Azure Data Explorer Create Cluster
#>

#Reference Utility Function Scripts
. "..\util\common-util.ps1"
. "..\util\azure-util.ps1"

Write-Log "INFO"  "====     ADX DevOp Project - Start ADX      ===="
Write-Log "INFO"  "================================================" 

#Get Global Config
$config = Get-Content ..\config\provision-config.json | ConvertFrom-Json


Function Set-Environment-Variables {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$True)]
    [Object]
    $configObj,
    [Parameter(Mandatory=$True)]
    [ValidateSet("create","delete")]
    [String]
    $action
    )
    if($action.ToLower().Equals("create")){
        $clusterName = $configObj.ADX.ClusterName
        [Environment]::SetEnvironmentVariable('RETENTION_DAYS',$configObj.ADX.TableRetentionDays)
        [Environment]::SetEnvironmentVariable('CLIENT_ID',$configObj.DeployClientId)
        [Environment]::SetEnvironmentVariable('CLIENT_SECRET',$configObj.DeploySecret)
        [Environment]::SetEnvironmentVariable('TENANT_ID',$configObj.AzureTenantId)
        [Environment]::SetEnvironmentVariable('REGION',$configObj.Location)
        [Environment]::SetEnvironmentVariable('CLUSTER_NAME',$clusterName)
        [Environment]::SetEnvironmentVariable('SUBSCRIPTION_ID',$configObj.AzureSubscriptionId)
        [Environment]::SetEnvironmentVariable('RESOURCE_GROUP',$configObj.ResourceGroupName)
    }
    elseif ($action.ToLower().Equals("delete")){
        [Environment]::SetEnvironmentVariable('RETENTION_DAYS',$null)
        [Environment]::SetEnvironmentVariable('CLIENT_ID',$null)
        [Environment]::SetEnvironmentVariable('CLIENT_SECRET',$null)
        [Environment]::SetEnvironmentVariable('TENANT_ID',$null)
        [Environment]::SetEnvironmentVariable('REGION',$null)
        [Environment]::SetEnvironmentVariable('CLUSTER_NAME',$null)
        [Environment]::SetEnvironmentVariable('SUBSCRIPTION_ID',$null)
        [Environment]::SetEnvironmentVariable('RESOURCE_GROUP',$null)
    }
}


#Start to deploy Azure Resources
Write-Log "INFO" "Before deployment, please make sure you have installed the Powershell Core (version 6.x up) and latest Azure Cli"

Write-Log "INFO" "Connect to Azure using Service Principal" 
# Connect to Azure
Connect-Azure $config

Write-Log "INFO" "Starting $($config.ADX.ClusterName) ADX in $($config.ResourceGroupName) ! "

az kusto cluster start --name $config.ADX.ClusterName --resource-group $config.ResourceGroupName


Write-Log "INFO" "Start $($config.ADX.ClusterName) ADX databases successfully! "

# Logout from Azure when "AutoAzLogout" is set to true
if($config.AutoAzLogout -eq $true){
    Write-Log "INFO" "Logout from Azure"
    az logout
 }