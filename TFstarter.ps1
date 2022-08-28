
# Login-AzAccount if you haven't before running this
#this sets you up with your storage account and a file with the config so you can init
$subname = "Visual Studio Enterprise Subscription"
$sub = Get-AzSubscription -SubscriptionName $subname
Select-AzSubscription -SubscriptionObject $sub
[Environment]::SetEnvironmentVariable('Foo', 'Bar', 'User')
export AZDO_PERSONAL_ACCESS_TOKEN=<Personal Access Token>
export AZDO_ORG_SERVICE_URL=https://dev.azure.com/<Your Org Name>

#variables to make up the name 
$location = "uksouth"
$org = "cc"
$locationshort = "uks"
$projectshort = "usl"
$you = "gabriel@cloudkingdoms.com"

#set the tf environment
$rgname = "$($org)-$($locationshort)-$($projectshort)-rg-tf".toLower()
$saname = ("$($org)$($locationshort)$($projectshort)tf").toLower() + (Get-Random -Minimum 1000 -maximum 9999)


$rg = New-AzResourceGroup -Name $rgname -Location $location
$sa = New-AzStorageAccount  -Name $saname -ResourceGroupName $rgname -Location $location `
-SkuName "Standard_LRS" -Kind "StorageV2" -EnableHTTPsTrafficOnly $True `
-AllowCrossTenantReplication  $False -AllowSharedKeyAccess $False


New-AzRoleAssignment -RoleDefinitionName "Storage Account Contributor" `
-SignInName $you -Scope $sa.Id

#wait for the perms
Start-Sleep -Seconds 30

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

$backend >> ./terraform/backend.conf
cd ./terraform
terraform init --backend-config=backend.conf 



# #for cleanup. don't delete
# Remove-AzResourceGroup -Name $rgname -force
# Remove-AzADServicePrincipal -DisplayName $spname
# Remove-AzStorageAccount -Name $saname -ResourceGroupName $rgname  -Confirm $false

