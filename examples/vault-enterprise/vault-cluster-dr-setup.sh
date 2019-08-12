#!/bin/bash

license_key=""
vault_init_info_path=~/vault_init_info.txt

vault status

sleep 2

echo -e "\nInitializing Vault...\n"
vault operator init -recovery-shares=1 -recovery-threshold=1 | tee $vault_init_info_path

echo -e "\nRestarting Vault...\n"
sudo systemctl restart vault

sleep 2

vault_token=$(grep 'Initial Root Token' $vault_init_info_path | cut -d ':' -f2 | tr -d '[:space:]')
vault login $vault_token

if [[ -n "$VAULT_LICENSE_KEY" ]]; then
    echo -e "\nLicensing Vault...\n"
    vault write sys/license text=$VAULT_LICENSE_KEY

    echo -e "\nRestarting Vault...\n"
    sudo systemctl restart vault
    sleep 2
fi

echo
vault status

sleep 2

echo -e "\nUse the following command to enable DR replication...\n"
echo "vault write sys/replication/dr/secondary/enable token=<wrapping token>"
