# Examensarbete_Erik_och_Sara_DOE21
Examensarbete av Erik Olsson och Sara Petré.


## Introduction
This project is a proof of concept of how the JTMM migrator can be deployed in the cloud. It's purpose is to see if it is possible, and how it would be done. We have managed to create a pipeline that builds a VM in Azure, and then deploys our docker image with Ansible.

To put it simply, our project runs our migration tool developed at Solidify AB and does a simple migration from Zephyr to Azure DevOps.


## Setup
This project is ment to be ran in the github actions pipeline provided under ".github > workflows > github.actions.yml". To run the pipeline, the following needs to be provided as repository secrets:


```
ARM_CLIENT_ID
ARM_CLIENT_SECRET
ARM_SUBSCRIPTION_ID
ARM_TENANT_ID
JIRA_DOMAIN
JIRA_API_TOKEN
JIRA_ACCOUNT_EMAIL
JIRA_PROJECT_ID
AZURE_ORGANISATION
AZURE_API_TOKEN
AZURE_PROJECT_NAME
ZEPHYR_API_TOKEN
EJO_GITHUB_USERNAME
EJO_GITHUB_TOKEN
TF_VAR_RBAC_TOKEN
```

### The values of the secrets should be the following:

```
ARM_CLIENT_ID
ARM_CLIENT_SECRET
ARM_SUBSCRIPTION_ID
ARM_TENANT_ID
```
Should contain the ID;s and secrets gathered from setting up Terraform to your Azure account. To do this, please refer to this guide: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret


After that, set up the right Jira credentials
```
JIRA_DOMAIN
JIRA_API_TOKEN
JIRA_ACCOUNT_EMAIL
JIRA_PROJECT_ID
```
JIRA_DOMAIN should be the domain of the Jira organisation you want to migrate from. It should look something like this: *your-organisation*.atlassian.net

JIRA_API_TOKEN should be the API token gathered from Jira. You can get your API token here: https://id.atlassian.com/manage-profile/security/api-tokens

JIRA_ACCOUNT_EMAIL should be the email of the one who is migrating, or the owner of the project.

JIRA_PROJECT_ID should be the project that you want to migrate Zephyr data from.

You got the Jira credentials down? Great, let's move on to Azure DevOps
```
AZURE_ORGANISATION
AZURE_API_TOKEN
AZURE_PROJECT_NAME
```

AZURE_ORGANISATION should be the Azure DevOps organisation that you are migrating to. 

AZURE_API_TOKEN should be your Azure DevOps PAT (Personal Access Token) token.

AZURE_PROJECT_NAME should be the name of the project that you want to migrate to.

Azure DevOps done? Perfect! Now on to Zephyr:
```
ZEPHYR_API_TOKEN
```
ZEPHYR_API_TOKEN, just as the name suggests, should be the API token for your Jira Zephyr Extension.

Now, to log in to Github Docker Registry, we need to provide our credentials
```
EJO_GITHUB_USERNAME
EJO_GITHUB_TOKEN
```
I will not specify this part as it requires the username and github access token to the owner of this repository. We can't help unfortunately.


Lastly, we need to give Terraform an RBAC token.
```
TF_VAR_RBAC_TOKEN
```
Terraform needs an RBAC token for the key vault. Create one using
```
az ad sp create-for-rbac --name ejoexamensarbete --role contributor --scopes /subscriptions/f40f1509-d114-44bc-b317-de2055f5310b/
```
And provide the "appid" as TF_VAR_RBAC_TOKEN.


## Run

All you need to do is run the pipeline, and everything should set up itself.
