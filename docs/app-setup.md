
## Demo app set up instructions

**Demo app components**
 - Pod service account. We use [workload identity](https://surajblog.medium.com/workload-identity-in-aks-with-terraform-9d6866b2bfa2) to assign the pods azure permissions.
 - ACR (Azure Container Registry) repo
 - Azure key vault to store secrets
 - Argocd application
 - A helm chart that sets up: HPA (Horizontal App Autoscaler), deployment, ingress, service, ExternalSecret and SecretStore required in order to sync secrets from key vault
 - App namespace
 - App DNS record


**Setup**

Set up these environment variables in terraform cloud.
1. env
2. ARGOCD_AUTH_USERNAME 
3. ARGOCD_AUTH_PASSWORD

 - Set up a terraform cloud workspace named azure-demo-app-dev 
 - Attach the variable set containing azure credentials.
 - Navigate to the demo-app/terraform folder
 - Set up backend.tf, variables.tf & providers.tf with values suitable for your environment.
 - Run terraform apply to create key vault, the app namespace, set up workload identity, the app's DNS record, ACR. Verify these components have been created.
 - Modify `argocd_image_updater_values` in aks/variables.tf and add the details of the ACR repo that has been created under registries.


**Pipeline setup**
- We use github actions to push an image to ACR. ArgoCD will detect this new image and trigger a new deployment.
- Set up these repository secrets in github.

1. ACR_LOGIN_SERVER
2. ACR_USERNAME
3. ACR_PASSWORD
4. TERRAFORM_CLOUD_TOKEN

- Push the changes to github so that the pipeline is triggered and an image is pushed to ACR.

**Verify**
Verify these components have been created

- deployment
- service
- secrets
- ingress
- HPA

Also verify that
- The app can be accessed via its domain name
- The app can access secrets manager secrets
- An argocd application has been created
-  Argocd notifications are working and notifications are being sent to slack. To post to Slack, the app you create needs chat:write and incoming-webhook permissions. You also need to add the app to the slack channel.
-  Argocd image updater triggers a deployment when an image is pushed to ACR

**Helm Cmds**

    helm install --dry-run demo-app app -f values.yaml
    helm install demo-app app -f values.yaml -n demo-app
    helm uninstall demo-app -n demo-app
    
    helm upgrade --dry-run demo-app app -f values.yaml -n demo-app
    helm upgrade demo-app app -f values.yaml -n demo-app
