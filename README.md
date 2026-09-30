# Terraform AWS test

This example has two parts:

- `component/` is a reusable S3 bucket module with public access blocked and AES-256 server-side encryption enabled.
- `blueprint/` is a runnable Terraform root configuration that uses the component in `us-east-1` by default.
- `components/s3/` is the deployment root used by the portal and the generic GitHub Actions workflow.

The workflow maps the allowlisted component ID `s3` to `components/s3/`; it never uses a caller-provided filesystem path. The deployment root calls the existing `component/` module, so the reusable implementation and `blueprint/` remain intact. Future components can add a root under `components/` plus a registry/schema entry and a fixed workflow allowlist case without adding another workflow.

Portal configuration is passed as the `config_json` workflow input and converted to Terraform environment variables at runtime. It is not written to a `.tfvars` file or committed. GitHub retains workflow input values in run metadata, so do not pass secrets in `config_json`.

## Bootstrap the state bucket

Before running the workflow, create the dedicated state bucket using an AWS identity with permission to manage S3 buckets. The bucket name in the backend is `terraform-state-720771544603` in `us-east-1`; change the backend configuration if that name is unavailable. Do not add this bucket to `component/` or store runtime inputs in a `.tfvars` file.

With AWS CLI credentials configured for the bootstrap identity, run:

```sh
aws s3api create-bucket --bucket terraform-state-720771544603 --region us-east-1
aws s3api put-public-access-block --bucket terraform-state-720771544603 --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
aws s3api put-bucket-encryption --bucket terraform-state-720771544603 --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
aws s3api put-bucket-versioning --bucket terraform-state-720771544603 --versioning-configuration Status=Enabled
```

The GitHub Actions role `TerraformGitHubActionsRole` must be allowed to list this bucket, read and write `states/*/*/terraform.tfstate`, and read, write, and delete the matching `.tflock` objects. The backend enables S3-native lock files with Terraform 1.10.5. Keep the existing OIDC trust and authentication configuration. The bucket versioning, encryption, and public-access-block settings protect state independently of the component bucket.

On the first `s3`/`dev` deployment, the workflow copies the previous `component/terraform.tfstate` object to `states/s3/dev/terraform.tfstate` if the destination does not exist. Terraform `moved` blocks in `components/s3/` transfer the three S3 resource addresses into the wrapper module without recreating the bucket. The old state object is intentionally retained as a backup. Other component/environment pairs get independent state keys.

## Local configuration checks

Install Terraform 1.10.5 or newer. Production applies run only in GitHub Actions through OIDC. For local syntax checks of the standalone blueprint, run:

```sh
terraform fmt -check -recursive
terraform -chdir=blueprint init
terraform -chdir=blueprint validate
```

S3 usage may incur AWS charges. The bucket name is generated with a unique suffix; `bucket_prefix` must remain globally unique enough for S3.

## Run the workflow

Push `.github/workflows/terraform-deploy.yml` and `components/s3/` to `main`. In GitHub, open **Actions** → **Terraform deploy** → **Run workflow**, select component `s3` and environment `dev`, then supply this JSON as `config_json`:

```json
{"bucket_prefix":"alish-terraform-test"}
```

The `deployment_id` input is optional for a manual run. A successful run shows the AWS identity check, Terraform init/validate/plan/apply steps, and the S3 bucket name and ARN in the Terraform output. The dashboard dispatches the same workflow with a generated UUID and polls the run status.

The dashboard dispatch payload uses the fixed workflow and `main` ref:

```json
{
	"ref": "main",
	"inputs": {
		"component": "s3",
		"environment": "dev",
		"config_json": "{\"bucket_prefix\":\"alish-terraform-test\"}",
		"deployment_id": "generated-uuid"
	}
}
```