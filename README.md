# infrastructure
Terraform code to deploy GIP infrastructure

[Install Terraform](https://developer.hashicorp.com/terraform/install).

## Bootstrapping

Only needed when the organization has just been created.

Make sure you are authenticated on the GitHub CLI so that Terraform can create
the CI credentials:
https://registry.terraform.io/providers/integrations/github/latest/docs#github-cli.

1. Generate an API key using the Scaleway UI.
2. Export the API key in your environment:

    ```bash
    export TF_VAR_scw_access_key=ACCESS_KEY_GOES_HERE
    export TF_VAR_scw_secret_key=SECRET_KEY_GOES_HERE
    export TF_VAR_scw_organization_id=SCW_ORGANIZATION_ID_GOES_HERE
    ```

3. Delete the `backend.tf` file
4. Populate the state with `terraform init`
5. Bootstrap with `terraform apply`. The following warning is expected:

    ```
    ╷
    │ Warning: Cannot read bucket acl: Forbidden
    │
    │   with module.bootstrap.scaleway_object_bucket_policy.state-bucket-policy,
    │   on bootstrap/main.tf line 30, in resource "scaleway_object_bucket_policy" "state-bucket-policy":
    │   30: resource "scaleway_object_bucket_policy" "state-bucket-policy" {
    │
    │ Got 403 error while reading bucket acl, please check your IAM permissions and your bucket policy
    ╵
    ```

    The reason is the state bucket access is restricted to the terraform-ci
    application. When the policy is applied, your super user loses access to
    the bucket.

6. Change credentials to use the CI credentials.

    ```bash
    terraform output ci_access_key
    terraform output ci_secret_key
    ```

7. Restore the `backend.tf`, and use `terraform init` to migrate the local
   state to the state Object Storage.
