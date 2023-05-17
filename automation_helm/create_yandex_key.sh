#!/bin/bash
printf "Enter your cloud details to generate a temporary Yandex access key.\nThe square brackets (e.g. [default]) indicate the parameters that can be applied by default if you do not enter new ones\n"
read -p "Enter the SERVICE ACCOUNT ID: " service_account_id
read -p "Enter the NAME OF DIRECTORY that your service account administers[default]: " folder_name
read -p "Enter the path to generate .json file[./ya_key.json]: " output_file

folder_name=${folder_name:-default}
output_file=${output_file:-./ya_key.json}

yc iam key create \
  --service-account-id $service_account_id \
  --folder-name $folder_name \
  --output $output_file

