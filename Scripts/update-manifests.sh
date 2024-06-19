#!/bin/bash

subscriptionId=$(az account show --query "id" -o tsv)

clientId=$(az identity show --name "$IDENTITYNAME" --resource-group "$RESOURCEGROUPNAME" --query "clientId" -o tsv)

keyvaultName=$(az keyvault list --resource-group "$RESOURCEGROUPNAME" --subscription "$subscriptionId" --query "[0].name" -o tsv)

tenantId=$(az keyvault show --name "$keyvaultName" --resource-group "$RESOURCEGROUPNAME" --query "properties.tenantId" -o tsv)

acrName=$(az acr list --resource-group "$RESOURCEGROUPNAME" --query "[0].name" --output tsv)


sed -i "s/<CLIENTID>/${clientId}/g" secretproviderclass.yml
sed -i "s/<KEYVAULTNAME>/${keyvaultName}/g" secretproviderclass.yml
sed -i "s/<TENANTID>/${tenantId}/g" secretproviderclass.yml


sed -i "s/<CLIENTID>/${clientId}/g" akstododeploy.yml
sed -i "s/<KEYVAULTNAME>/${keyvaultName}/g" akstododeploy.yml
sed -i "s/<ACRNAME>/${acrName}/g" akstododeploy.yml

echo "Subscription ID: $subscriptionId"
echo "Key Vault Name: $keyvaultName"
echo "User-Assigned Managed Identity Client ID: $clientId"
echo "Tenant ID of Key Vault: $tenantId"
echo "ACR name: $acrName"
