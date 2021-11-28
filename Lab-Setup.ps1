azcopy cp https://hobbitfeetpublic.blob.core.windows.net/ntc-files/NTC-AVD-Create-Lab.zip .
Expand-Archive ./NTC-AVD-Create-Lab.zip .
cd ./NTC-AVD-Create-Lab/

terraform init
terraform plan
terraform apply --auto-approve

az vm run-command invoke  --command-id RunPowerShellScript --name avdlab-dc01 -g avdlab-resources --scripts @AVDLab-AD-Setup.ps1


az group delete -n avdlab-resources