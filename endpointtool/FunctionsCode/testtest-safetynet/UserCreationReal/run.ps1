using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)
Import-Module AzureAD -UseWindowsPowershell 
$token = (Get-AzAccessToken -ResourceTypeName AadGraph).token

$currentAzureContext = Get-AzContext
$tenantId = $currentAzureContext.Tenant.Id
$accountId = $currentAzureContext.Account.Id
Connect-AzureAD -TenantId $tenantId -AccountId $accountId -AadAccessToken $token
$suffix = Get-Random -minimum 100000 -Maximum 999999
$length = 16
# Characters
$chars = (48..57) + (65..90) + (97..122) + 35 + 33 + 64
[string]$Password = $null
$chars | Get-Random -Count $length | %{ $Password += [char]$_ }	
$secpasswd = ConvertTo-SecureString $Password -AsPlainText -Force

$username = "TempUser" + $suffix
$domain = "purplepelican.onmicrosoft.com"
New-AzADUser -DisplayName $username -Password $secpasswd -MailNickname $username -UserPrincipalName "$username@$domain" -ForceChangePasswordNextLogin
$user = Get-AzAdUser -UserPrincipalName "$username@$domain"
# Assign the values to the variables
$userid = $user.Id
$spobjectid = "0bc5cb07-47d8-4db9-9ace-52f80916628c"

# Assign the user to the app role
New-AzureADUserAppRoleAssignment -ObjectId $userid -PrincipalId $userid -ResourceId $spobjectid -Id ([Guid]::Empty)
$UPN = $user.UserPrincipalName
# $body = @"
# [{
#         Username = $UPN
#         Password = $password
#         Uri = "https://envvendpurpel888577.azurewebsites.net/api/EnvironmentVend?code=4gUe7njrQaWk/cfcLLGszh7tNHEpmqbadLfZbkULXr8y5S/mqUIB5A=="
#         Logon_Instructions1 = "The user should sign into the Uri above, it will take up to 10 minutes to deploy the environment."
#         Logon_Instructions2 = "After 10 minutes, user should sign into https://portal.azure.com and they will see resources."
#         Logon_Instructions3 = "They will be prompted to change their password. They do not need to setup extra auth."
#         Logon_Instructions4 = "The user creds will last for 7 days."
# }]
# "@

$html = @"
<title>This is the title</title>
<h1>Congratulations!</h1>
<h2>You have create a new user</h2>
<body><b>Username:</b>    $UPN<br>
        <b>Password:</b>    $password<br>
        <b>Uri:</b>  https://envvendpurpel888577.azurewebsites.net/api/EnvironmentVend?code=4gUe7njrQaWk/cfcLLGszh7tNHEpmqbadLfZbkULXr8y5S/mqUIB5A==<br>
        <b>Logon_Instructions:</b> <br>
        The user should sign into the Uri above, it will take up to 10 minutes to deploy the environment.<br>
        After 10 minutes, user should sign into https://portal.azure.com and they will see resources.<br>
        They will be prompted to change their password. They do not need to setup extra auth.<br>
        The user creds will last for 7 days.   <br>
        </body>
"@

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    ContentType = 'text/html' #this line converts to html render
    Body = $html
})
