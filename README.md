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
                           anthosconfigmanagement.googleapis.com
    ```

1. Create storage bucket that will be used to keep Terraform state:

    ```bash
    gsutil mb gs://${PROJECT_ID}-tfstate
    gsutil versioning set on gs://${PROJECT_ID}-tfstate # enable versioning to keep history
    ```

1. Terraform init:

    ```bash
    terraform init -backend-config "bucket=$PROJECT_ID-state"
