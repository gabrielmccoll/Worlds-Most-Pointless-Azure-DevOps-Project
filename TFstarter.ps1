
# Login-AzAccount if you haven't before running this
#this sets you up with your storage account and a file with the config so you can init
$subname = "Visual Studio Enterprise Subscription"
$sub = Get-AzSubscription -SubscriptionName $subname
Select-AzSubscription -SubscriptionObject $sub
$env:AZDO_PERSONAL_ACCESS_TOKEN = ''
$env:AZDO_ORG_SERVICE_URL = 'https://dev.azure.com/cloudkingdoms'


#variables to make up the name 
$location = "uksouth"
$org = "cc"
$locationshort = "uks"
$projectshort = "usl"
$you = "gabriel@cloudkingdoms.com"

#set the tf environment
$rgname = "$($org)-$($locationshort)-$($projectshort)-rg-tf".toLower()
$saname = ("$($org)$($locationshort)$($projectshort)tf").toLower() + (Get-Random -Minimum 1000 -maximum 9999)
$kvname = ("$($org)$($locationshort)$($projectshort)tf").toLower() + (Get-Random -Minimum 1000 -maximum 9999)

$rg = New-AzResourceGroup -Name $rgname -Location $location
$sa = New-AzStorageAccount  -Name $saname -ResourceGroupName $rgname -Location $location `
-SkuName "Standard_LRS" -Kind "StorageV2" -EnableHTTPsTrafficOnly $True `
-AllowCrossTenantReplication  $False -AllowSharedKeyAccess $False
$kv = New-AzKeyVault -Name $kvname -ResourceGroupName $rgname -Location $location -EnableRbacAuthorization -Sku 'Standard' 
Set-AzKeyVaultAccessPolicy -
New-AzRoleAssignment -RoleDefinitionName "Key Vault Secrets Officer" `
-SignInName $you -Scope $kv.ResourceId

New-AzRoleAssignment -RoleDefinitionName "Storage Blob Data Contributor" `
-SignInName $you -Scope $sa.Id


#wait for the perms
Start-Sleep -Seconds 60

#Log the secrets for later
Set-AzKeyVaultSecret -VaultName $kvname -Name "AZDO-PERSONAL-ACCESS-TOKEN" `
-SecretValue (ConvertTo-SecureString -AsPlainText -Force -String $env:AZDO_PERSONAL_ACCESS_TOKEN)
Set-AzKeyVaultSecret -VaultName $kvname -Name "AZDO-ORG-SERVICE-URL" `
-SecretValue (ConvertTo-SecureString -AsPlainText -Force -String $env:AZDO_ORG_SERVICE_URL)
#create the storage container (if errors then wait longer)
$sacontname = "tfstate"
$context = New-AzStorageContext -StorageAccountName $saname 
$sacont = New-AzStorageContainer -Name $sacontname -Context $context

## export the terraform config to the terraform directory, change to it and init.
$backend = @"
tenant_id            = "$($sub.TenantId)"
subscription_id      = "$($sub.Id)"
resource_group_name  = "$($rgname)"
storage_account_name = "$($saname)"
container_name       = "$($sacontname)"
use_azuread_auth     = true
key                  = "useless.devops.tfstate"
"@

$tfvars = @"
tenantId            = "$($sub.TenantId)"
subscriptionId      = "$($sub.Id)"
subscriptionName      = "$($subname)"
"@

$tfvars | Out-File -FilePath "./terraform/useless.auto.tfvars" -NoClobber  
$backend | Out-File -FilePath "./terraform/backend.conf" -NoClobber



$backendproject = @"
tenant_id            = "$($sub.TenantId)"
subscription_id      = "$($sub.Id)"
resource_group_name  = "$($rgname)"
storage_account_name = "$($saname)"
container_name       = "$($sacontname)"
use_azuread_auth     = true
key                  = "useless.project.tfstate"
"@

$tfvarsproject = @"
tenantId            = "$($sub.TenantId)"
subscriptionId      = "$($sub.Id)"
subscriptionName      = "$($subname)"
"@
$tfvarsproject | Out-File -FilePath "./project_files/terraform/useless.auto.tfvars" -NoClobber  
$backendproject | Out-File -FilePath "./project_files/terraform/backend.conf" -NoClobber

cd ./terraform
terraform init --backend-config=backend.conf 



# #for cleanup. don't delete
# Remove-AzResourceGroup -Name $rgname -force
# Remove-AzADServicePrincipal -DisplayName $spname
# Remove-AzStorageAccount -Name $saname -ResourceGroupName $rgname  -Confirm $false

