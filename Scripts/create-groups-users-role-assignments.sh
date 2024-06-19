#!/bin/bash

export resourceGroupName="<RESOURCEGROUPNAME>"
export clusterName="<AKSCLUSTERNAME>"

devUsers=1
sreUsers=1
devUserName="<USERNAME>"
sreUserName="<USERNAME>"
initialDomain="<USER>.onmicrosoft.com"

userNames=()
UPNs=()
aadGroupIds=()

aadGroupNames=(
    "<GROUPNAME>"
    "<GROUPNAME>"
)

roleDefinitions=(
    "3498e952-d568-435e-9b2c-8d77e338d7f7" # "Azure Kubernetes Service RBAC Admin"
    "7f6c6a51-bcf8-42ba-9220-52d62157d7db" # "Azure Kubernetes Service RBAC Reader"
)

checkAKS () {
    echo "Checking if cluster exists and retrieving resource Id..."
    aksId=$(az aks show \
        --resource-group $resourceGroupName \
        --name $clusterName \
        --query id -o tsv)
    if [[ -z $aksId ]]; then
        echo "$clusterName does not exist."
        exit
    fi
}

createUPNs () {
    # Generate user names with devUserName. Add a leading zero if i is a single digit
    for (( i=1; i<=$devUsers; i++)); do
        formattedIndex=$(printf "%02d" "$i")
        userNames+=("${devUserName}${formattedIndex}")
    done
    # Generate user names with sreUserName
    for (( i=1; i<=$sreUsers; i++)); do
        formattedIndex=$(printf "%02d" "$i")
        userNames+=("${sreUserName}${formattedIndex}")
    done
    # Generate UPNs
    for ((i=0; i<${#userNames[@]}; ++i)); do
        UPNs+=("${userNames[i]}@$initialDomain")
        echo "${UPNs[i]}"
    done
    echo ${#userNames[@]} "UPNs generated..."   
}

getAADGroupId () {
    groupId=$(az ad group show --group $groupName --query id -o tsv --only-show-errors)
    if [[ $? == 0 ]]; then
        echo "Retrieved groupId"            
    else
        echo "groupId not retrieved"
    fi    
}

getRoleAssignmentName () {
    roleAssignmentName=$(az role assignment list --assignee $groupId --role $roleDefinitionId --scope $aksId --query [0].roleDefinitionName)
}

createRoleAssignment () {
    az role assignment create --assignee $groupId --role $roleDefinitionId --scope $aksId
    if [[ $? == 0 ]]; then
        getRoleAssignmentName $groupId $roleDefinitionId $aksId
        echo "Created $roleAssignmentName role assignment for $groupName group."            
    else
        echo "$roleDefinitionId role assignment not created for $groupName"
    fi              
}

checkAKS
createUPNs

# Create groups
for groupName in ${aadGroupNames[@]}; do
    echo "Checking if $groupName group exists..."
    getAADGroupId
    if [[ -z $groupId ]]; then
        echo "$groupName does not exist. Creating group..."
        az ad group create --display-name $groupName --mail-nickname $groupName  
        if [[ $? == 0 ]]; then
            echo "$groupName group created"
        else
            echo "$groupName group not created"
        fi
    else
        echo "$groupName group already exists."
    fi
done

# create users and add them to the groups
for (( i=0; i<${#UPNs[*]}; i++)); do
    echo "Checking if "${UPNs[i]}" exists..."
    userExists=$(az ad user show --id ${UPNs[i]} --query userPrincipalName -o tsv)
    if [[ -z $userExists ]]; then
        echo "Creating user for "${UPNs[i]}...
        pwd=$(openssl rand -base64 16) 
        userId=$(az ad user create \
        --display-name ${userNames[i]} \
        --user-principal-name ${UPNs[i]} \
        --password $pwd \
        --query id -o tsv)
        if [[ $? == 0 ]]; then
            echo ${userNames[i]}" user created"
            if [[ ${userNames[i]} == *"dev"* ]]; then
                echo "Adding "${userNames[i]}" to the "${aadGroupNames[0]}" group"    
                az ad group member add --group ${aadGroupNames[0]} --member-id $userId
                # echo pwd for testing role assignments only
                echo "dev pwd is :" $pwd         
            fi
            if [[ ${userNames[i]} == *"sre"* ]]; then
                echo "Adding "${userNames[i]}" to the "${aadGroupNames[1]}" group"    
                az ad group member add --group ${aadGroupNames[1]} --member-id $userId
                # echo pwd for testing role assignments only
                echo "SRE pwd is :" $pwd
            fi
        else
            echo ${userNames[i]}" user not created"
        fi
    else
        echo ${UPNs[i]} "User already exists."
    fi    
done

# Check and create role assignments for each group (separate code here due to AAD propagation delay bug)
for groupName in ${aadGroupNames[@]}; do
    echo "Checking existing role assignments for $groupName..."
    getAADGroupId
    if [[ -n $groupId ]]; then 

        # get the list of current role assignments where the principalId in the role assignment == the AAD groupId
        roleAssignmentsJson=$(az role assignment list  \
        --scope $aksId \
        --query "[?contains(principalId,'$groupId')]" \
        --output json)

        jsonLength=$(echo "$roleAssignmentsJson" | jq length)        
        echo "Length of JSON: $jsonLength"
        if [[ "$jsonLength" -eq 0 ]]; then
            echo "No role assignments discovered for $groupName. Assigning roles..."
            for roleDefinitionId in "${roleDefinitions[@]}"; do
                createRoleAssignment $groupId $roleDefinitionId $aksId $groupName             
            done        
        else
            # Check if the roles are already applied - if the roleDefinitionId property of the role assignment contains the same value as ${roleDefinitions[@]} guid  
            for roleDefinitionId in "${roleDefinitions[@]}"; do      
                checkRoleDefinitionIdExists=$(echo "$roleAssignmentsJson" | jq --arg roleDef "$roleDefinitionId" '.[] | select(.roleDefinitionId | contains($roleDef))')
                if [[ -n "$checkRoleDefinitionIdExists" ]]; then
                    getRoleAssignmentName $groupId $roleDefinitionId $aksId
                    echo "The $roleAssignmentName role assignment for $groupName already exists."
                else
                    echo "Missing role assignment for $groupName. Applying role assignment: $roleDefinitionId"
                    createRoleAssignment $groupId $roleDefinitionId $aksId $groupName             
                fi
            done
        fi
    else
        echo "$groupName does not exist."
    fi
done