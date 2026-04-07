# kubetentes nginx deployment with GKE Gateway Controller #

API Requirements : 

- artifactregistry.googleapis.com
- container.googleapis.com
- compute.googleapis.com
- iam.googleapis.com
- cloudbuild.googleapis.com
- logging.googleapis.com
- monitoring.googleapis.com

Infra requirements : 
- GKE cluster 
- 2 nodes
- Repo named : nginx-repo

Skip the manual install & check with this Terraform configuration : https://github.com/maximus514/GCP_Terraform/tree/main/gcp-k8s-infra

Service Account requirements : 
- Service account permission (XXXXXXXXXX-compute@developer.gserviceaccount.com)  :
  - storage.objects.get
  - artifactregistry.repositories.uploadArtifacts

Create the nginx-project directory : 
```bash
mkdir nginx-project 
cd nginx-project
```
create the application directory : 
```bash
mkdir red-app 
cd red-app
```
###create the dockerfile inside the red-app directory : ###

## Create the endpoint contents : ##
```bash
nano index.html 
```
```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title> Hello From Nginx Red Container </title>
  <link rel="stylesheet" href="./style.css">
</head>
<body>
  <h2>Hello from Nginx container Red</h2>
  <p>Hostname: ${HOSTNAME}</p>
</body>
</html>
```
```bash
nano style.css  
```
```css
html, body{
        width: 100%;
        height: 100%;
        margin: 0;
        padding: 0;
        scroll-behavior: smooth;
        top: auto;
        background-color: red;
}
h2{
        color: rgb(104, 107, 117);
}
```
## Create the startup.sh file : ##  
```bash
nano startup.sh  
```
```bash
#!/bin/sh

# Fetch metadata
HOSTNAME=$(curl -s -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/hostname)

# Export for envsubst
export HOSTNAME

# Replace variables in template → final HTML
envsubst < /usr/share/nginx/html/index.html.template \
         > /usr/share/nginx/html/index.html

# Start nginx
nginx -g "daemon off;"
```
## Create the docker file : ## 
```bash
nano Dockerfile 
```
```bash
FROM nginx:latest

# Install envsubst
RUN apt-get update && apt-get install -y gettext-base && rm -rf /var/lib/apt/lists/*
# Update the package manager, install gettext-base, delete the installed files. This is used to export the variable. 
# Gettext-base is a small package from GNU gettext that provides basic tools for handling text and environment variable substitution in Linux systems.

COPY index.html.template /usr/share/nginx/html/index.html.template
COPY style.css /usr/share/nginx/html/style.css
COPY start.sh /startup.sh

RUN chmod +x /startup.sh

CMD ["/startup.sh"]
```
## Create the red-app container, push to Articat Registry : ## 
```gcloud
gcloud builds submit \
  --tag us-central1-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/nginx-repo/nginx-image-red:tag1
```
## Create the following .yaml files in nginx-project directory: ##
Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-red
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-red
  template:
    metadata:
      labels:
        app: nginx-red
    spec:
      containers:
      - name: nginx
        image: us-central1-docker.pkg.dev/<PROJECT_ID>/nginx-repo/nginx-image-red:tag1
        ports:
        - containerPort: 80
```
Service
```yaml 
apiVersion: v1
kind: Service
metadata:
  name: nginx-red-svc
spec:
  type: ClusterIP
  selector:
    app: nginx-red
  ports:
    - port: 80
      targetPort: 80
```
Gateway
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: external-gateway
spec:
  gatewayClassName: gke-l7-global-external-managed
  listeners:
  - name: http
    protocol: HTTP
    port: 80
```
HTTPRoute (connect Gateway → Service)
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: nginx-route
spec:
  parentRefs:
  - name: external-gateway
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: nginx-red-svc
      port: 80
```
## Now verify your gateway : ##
```kubectl
kubectl get gateway
```
After deployment, it may take 5–10 minutes for the Gateway’s external IP to propagate and become accessible through Google Front Ends (GFEs).
```
maximus_dev@cloudshell:~/nginx-project (maximus-dev-01)$ kubectl get gateway
NAME               CLASS                            ADDRESS          PROGRAMMED   AGE
external-gateway   gke-l7-global-external-managed   35.227.205.148   True         8m45s
```
