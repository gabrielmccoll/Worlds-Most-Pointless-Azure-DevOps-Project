using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Define organization base url, PAT and API version variables
$orgUrl = "https://dev.azure.com/GTCIT/TechnicalTests/_apis/pipelines/160/runs?api-version=6.1-preview.1"
$pat = $env:adokey
# Create header with PAT
$token = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes(":$($pat)"))
$header = @{authorization = "Basic $token"}
$createProjectURL = "$orgUrl"
$User_name = $Request.Headers['X-MS-CLIENT-PRINCIPAL-NAME']
$User_id = $Request.Headers['X-MS-CLIENT-PRINCIPAL-ID']

$delay = $Request.Query.Delay_in_min

if (-not $Request.Query.Delay_in_min) {
    $delay = 59
}

$projectJSON = @{
    "templateParameters" =  @{
        Var_File = "../variables/dev/env_dep_dev.yml"
        Delay_in_min = $delay
        TFState_Key = "$($User_name)".Split('@')[0] + ".tfstate"
        User_Id = "$User_Id"
    }
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri $createProjectURL -Method Post -ContentType "application/json" -Headers $header -Body ($projectJSON )

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    Body = $response
})
