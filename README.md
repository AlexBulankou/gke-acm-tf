# Example of using Terraform to provision ACM features on GKE clusters

1. Clone this repo
1. Set variables that will be used in multiple commands:

    ```bash
    FOLDER_ID = [FOLDER]
    BILLING_ACCOUNT = [BILLING_ACCOUNT]
    PROJECT_ID = [PROJECT_ID]
    ```

1. Create project:

    ```bash
    gcloud auth login
    gcloud projects create $PROJECT_ID --name=$PROJECT_ID --folder=$FOLDER_ID
    gcloud alpha billing projects link $PROJECT_ID --billing-account $BILLING_ACCOUNT
    gcloud config set project $PROJECT_ID
    ```

1. Enable multiple APIs on the Cloud Build project:

    ```bash
    gcloud services enable cloudbuild.googleapis.com \
                           compute.googleapis.com \
                           cloudresourcemanager.googleapis.com \
                           iam.googleapis.com \
                           container.googleapis.com \
                           gkehub.googleapis.com \
                           anthosconfigmanagement.googleapis.com \
                           sqladmin.googleapis.com
    ```

1. Create storage bucket that will be used to keep Terraform state:

    ```bash
    gsutil mb gs://${PROJECT_ID}-tfstate
    gsutil versioning set on gs://${PROJECT_ID}-tfstate # enable versioning to keep history
    ```

1. Initialize your csproot folder using Helm and customized values:

    ```bash
    helm template ./templates/wp-chart/ --set google.projectId=$PROJECT_ID --set google.namespace=service-a \
        > ./csproot/namespaces/service-a/wp.yaml
    helm template ./templates/config-sync-namespace/ --set google.projectId=$PROJECT_ID --set google.namespace=service-a \
        > ./csproot/namespaces/service-a/namespace.yaml
    helm template ./templates/configconnector/ --set google.projectId=$PROJECT_ID \
        > ./csproot/cluster/configconnector.yaml
    ```

1. Submit your changes to git.

1. Initialize Terraform with the backend in the specified bucket:

    ```bash
    cd deploy/
    gcloud auth application-default login
    terraform init -backend-config "bucket=$PROJECT_ID-tfstate"
    ```

1. Create cluster using terraform:

    ```bash
    # continue in /deploy directory
    terraform plan -var="project=$PROJECT_ID" \
                   -var="sync_repo=https://github.com/AlexBulankou/gke-acm-tf" \
                   -var="sync_branch=main" \
                   -var="policy_dir=csproot" \
                   -var="bucket=$PROJECT_ID-tfstate"

    terraform apply -var="project=$PROJECT_ID" \
                    -var="sync_repo=https://github.com/AlexBulankou/gke-acm-tf" \
                    -var="sync_branch=main" \
                    -var="policy_dir=csproot" \
                    -var="bucket=$PROJECT_ID-tfstate"
    ```

1. Validate that Wordpress instance was created

    ```bash
    gcloud container clusters get-credentials cluster-1 --region=us-central1-b
    kubectl get service wordpress-external -n=service-a
    ping [external-ip]
    ```
