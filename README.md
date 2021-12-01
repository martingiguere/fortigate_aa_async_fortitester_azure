FortiGate Active Active Active Active
with UTM Async and FortiTester and Iperf



to deploy via powershell:

Connect-AzAccount
Set-AzContext -Subscription "xxxx-xxxx-xxxx-xxxx"
terraform init

terraform apply `
                -var "LOCATION=azureregion" `
                -var "FGT_USERNAME=adminuser" `
                -var "FGT_PASSWORD=adminpassword"

terraform destroy `
                -var "LOCATION=azureregion" `
                -var "FGT_USERNAME=adminuser" `
                -var "FGT_PASSWORD=adminpassword"



to deploy via bash:

az login
az account set --subscription="xxxx-xxxx-xxxx-xxxx"
terraform init

terraform apply \
                -var "LOCATION=azureregion" \
                -var "FGT_USERNAME=adminuser" \
                -var "FGT_PASSWORD=adminpassword"

terraform destroy \
                -var "LOCATION=azureregion" \
                -var "FGT_USERNAME=adminuser" \
                -var "FGT_PASSWORD=adminpassword"