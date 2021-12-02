# NTC-AVD-Create-Lab
NTC-AVD-Create-Lab

From the Azure Portal open Cloud Shell (create new instance if required)

Run the below commands from Cloud Shell to create your AVD lab

git clone https://github.com/deanl1982/NTC-AVD-Create-Lab.git NTC-AVD-Create-Lab

cd NTC-AVD-Create-Lab

terraform init

terraform plan

terraform apply --auto-approve

az vm run-command invoke  --command-id RunPowerShellScript --name avdlab-dc01 -g avdlab-resources --scripts @AVDLab-AD-Setup.ps1
