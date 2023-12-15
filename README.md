# mediawiki-aks

### Azure Setup
- You should have a Azure Service Principle created before hand with `Contributor` role to create azure resources. Note its Client Id and password
```sh
az ad sp create-for-rbac --name your-spn --role Contributor --scopes /subscriptions/<sub-id>
```
- Create storage account and blob to store TF state file using bash script [./storage_account.sh](storage_account.sh)
    - az cli should be installed to run this or you can do the same from `Azure portal` or `Cloud Shell`

## AKS Setup
- Update `azureSubscription` under [aks-setup/pipelines/build_aks_cluster.yaml](aks-setup/pipelines/build_aks_cluster.yaml) file
- Create pipeline using [build_aks_cluster.yaml](aks-setup/pipelines/build_aks_cluster.yaml)
- Add below variables to above pipeline
```sh
# Your SPN Client iD here
servicePrincipalID
# Your SPN password here
servicePrincipalKey
# YOur AD tenant ID
tenant_id
```

## ArgoCD
- The Terraform pipeline will also install argocd for kubernetes manifest installation. Whenever a commit is made on perticular repo, branch and on path, the argocd will pull that updates and sync that with Kubernetes cluster. So this is a continuous deployment solution

Once Azure Pipeline runs successfully: 
- You can get its `External IP` or argocd from azure portal or run below command
```sh
echo "ArgocdIngress IP: $(kubectl get service -n argocd argocd-server -o=jsonpath='{.status.loadBalancer.ingress[].ip}')"
```
- Login to argocd with `admin` username and get password from this command
```sh
 kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```
- Once you logged in, click on `New App` --> `EDIT AS YAML` and copy below. This creates application on argocd with git repo, path and branch
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: mediawiki
spec:
  destination:
    name: ''
    namespace: ''
    server: 'https://kubernetes.default.svc'
  source:
    path: mediawiki_app/dev
    repoURL: 'https://github.com/subhosmane/mediawiki-aks.git'
    targetRevision: HEAD
  sources: []
  project: default
  syncPolicy:
    automated:
      prune: false
      selfHeal: false
```
This creates mediawiki app and Deploys manifests to kubernetes cluster

- Now get its Ingress IP and access Mediawiki App
```sh
kubectl get service -n mw-dev mw-svc -o json| jq -r '.status.loadBalancer.ingress[].ip'
```
## Automation
### Docker image update
- Any commit to `main` branch and path `mediawiki_app/Dockerfile` will be triggering [Dockerfile pipeline](./app-pipeline.yaml)  to generate a Docker image and push to ACR
```yaml
trigger:
  branches:
    include:
    - main
  paths:
    include:
    - 'mediawiki_app/Dockerfile'
```
### AKS Infra Update
- If you want Infra automation, update `trigger: <>` to your branch so that pipeline will be triggered for any infra code updates but this could be destructive

### App and DB Update
- As said above this will be taken care by ArgoCD tool, any chnages to mediawiki-app will be picked by Argocd and applied to AKS 

## Deployment Status
- You can look into [Images](./images/Argocd_deployment.png) for deployment status and app configuration