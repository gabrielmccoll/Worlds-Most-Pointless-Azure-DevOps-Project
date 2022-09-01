# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format.
Import-Module AzureAD -UseWindowsPowershell 
$token = (Get-AzAccessToken -ResourceTypeName AadGraph).token

$currentAzureContext = Get-AzContext
$tenantId = $currentAzureContext.Tenant.Id
$accountId = $currentAzureContext.Account.Id
Connect-AzureAD -TenantId $tenantId -AccountId $accountId -AadAccessToken $token

$currenttime = (get-date).ToUniversalTime()
 
$users = Get-AzureADUser -All $true | where {$_.DisplayName -like "TempUser*"}

foreach ($user in $users) {

    $createddate = [datetime]$user.ExtensionProperty.createdDateTime
    $diff = $currenttime - $createddate 
    if ($diff.Days -gt 7) {
       write-host "Deleting" $user.UserPrincipalName
       Remove-AzADUser -UserPrincipalName $user.UserPrincipalName -force
    }
}

