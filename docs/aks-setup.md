**AKS cluser components**
1.  AKS cluster
2.  Vnet
3. Resource group
4. Application gateway for use by ingress
5. Cert manager helm chart which issues letsencrypt certificates for the application gateway ingress controller
6. Azure AD admins group
7. ELK for logs
8. Prometheus and Grafana for metrics, dashboards and alerts


## AKS Setup Instructions
- set up a terraform cloud workspace named aks-dev.
- Terraform needs to authenticate to azure to enable it to create resources. Create a service principal using the cli.

    `az ad sp create-for-rbac --name terraform-service-principal --role owner --scopes /subscriptions/<SubscriptionID>`

- You need to configure permissions for the service principal so that it can create AD objects such as groups. Follow the instructions given [here](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/guides/service_principal_configuration). Also add the RoleManagement.ReadWrite.Directory API permission which is required to set the attribute assignable_to_role on created groups.
- Create environment variables in terraform cloud with the following keys.

1. ARM_CLIENT_ID
2. ARM_CLIENT_SECRET
3. ARM_SUBSCRIPTION_ID
4. ARM_TENANT_ID

- Clone this repo
- Navigate to the aks folder
- set up aks/backend.tf
- set up these environment variables in terraform cloud.

1. letsencrypt_email
2. env
3. elastic_password
4. grafana_password
5. grafana_user
6. slack_incoming_webhook_url

- Modify any variables in aks/variables.tf that you may need to e.g region
- Run terraform init and terraform apply
- At this point, the cluster has been created
- To log in via kubectl, first setup [kubelogin](https://github.com/Azure/kubelogin). Note we are using [-   Azure AD authentication with Kubernetes RBAC](https://techcommunity.microsoft.com/t5/fasttrack-for-azure/azure-kubernetes-service-rbac-options-in-practice/ba-p/3684275) which requires us to setup kubelogin.
- Then run the command below.

`az aks get-credentials --resource-group RESOURCE_GROUP_NAME --name CLUSTER_NAME --overwrite-existing`

e.g
`az aks get-credentials --resource-group aks-dev --name dev-compute --overwrite-existing`

- verify the worker nodes are ready

 `k get nodes`

- set the value of the cluster_created variable in aks/variable.ts to true. This will create resources that needed the cluster to be created first eg the argocd helm chart
- run terraform apply
- verify that

1. An ingress exposes kibana and grafana. The ingress should have certificates from letsencrypt.

`k get certificaterequest --all-namespaces`
`k get certificate --all-namespaces`

3. You can log in to kibana using the default elastic user and the password set in the variable `elastic_password` and can see kubernetes logs.
4. You can log in to grafana using the password set in the variable `grafana_password`. You should be able to see a kubernetes dashboard with various metrics as well as alerts. We use the grafana terraform provider to create alerts.


