<#  ------------------------------          NSA Professional Services          ------------------------------

    Author: Rob Thayer
    E-Mail: support@nsacom.com
    Description: Script can be used to upload documents to the tenant report directory.

    ------------------------------                Instructions                 ------------------------------

    1. Edit the $IONAPIFILE variable to point to the location of your tenants .ionapi file.
    2. Edit the $INPUTFILE variable to point to the location of the file you wish to upload.
    3. Edit the $RESULTFILE variable to provide a name for the file once uploaded to your tenants report folder.
    4. Edit the $CONO variable to use a valid CSD Cono
    5. Edit the $OPER variable to use a valid operator 
    6. Edit the $SUBDIR variable to send your document to the appropriate location in the report folder. 
    7. Run the script either via Windows scheduled task or command line like so: powershell.exe ./fileTransfer.ps1

    ---------------------------------------------------------------------------------------------------------  #>

$IONAPIFILE = "c:\creds.ionapi"
$INPUTFILE = "C:\myfile.txt"
$RESULTFILE = "myfile.txt"
$CONO = 1000
$OPER = "sys"
$SUBDIR = ""

function buildPayload {
    param (
        [string[]]$ParameterName
        )

    $encoded = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes((Get-Content -Path $ParameterName -Raw -Encoding UTF8)))

    $payload = [ordered] @{
        CompanyNumber = $CONO
        Operator = $OPER
        filename = $RESULTFILE
        base64contents = $encoded
        subdir = $SUBDIR
        overwrite = $true
        addatetime = $false
        } | ConvertTo-Json

return $payload
};

function authRequest {
    $json = (Get-Content $IONAPIFILE -Raw) | ConvertFrom-Json

    $TENANT = $json.ti
    $USERNAME = $json.saak
    $PASSWORD = $json.sask
    $CLIENT_ID = $json.ci
    $CLIENT_SECRET = $json.cs

    $authUrl = ($json.pu+$json.ot)

    $creds = @{
        username = $USERNAME
        password = $PASSWORD
        client_id = $CLIENT_ID
        client_secret = $CLIENT_SECRET
        grant_type = "password"    
        };

    $header_token = @{"Content-Type" = "application/x-www-form-urlencoded"}
    $header_Out = @{"Accept" = "application/json" ; "authorization" = "bearer $token"}
    $authResponse = Invoke-RestMethod $authUrl -Method Post -Body $creds -Headers $header_token
    $token = $authResponse.access_token

    return $token,$TENANT
};

function fileUploadRequest {
    $t=authRequest
    $token = $t[0]
    $tenant = $t[1]

    $filePayload = buildPayload -ParameterName $INPUTFILE
    $fileUploadUrl = "https://mingle-ionapi.inforcloudsuite.com/$tenant/SX/rest/serviceinterface/proxy/FileTransfer"
    $fileUploadHeader = @{"Accept" = "application/json" ; "Content-Type" = "application/json" ; "authorization" = "bearer $token"}
    Invoke-RestMethod $fileUploadUrl -Method Post -Body $filePayload -Headers $fileUploadHeader
    echo $fileUploadUrl
};

fileUploadRequest
