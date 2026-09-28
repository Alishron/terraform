# Terraform AWS test

This example has two parts:

- `component/` is a reusable S3 bucket module with public access blocked and AES-256 server-side encryption enabled.
- `blueprint/` is a runnable Terraform root configuration that uses the component in `us-east-1` by default.

## Run it

Install Terraform 1.5 or newer and configure AWS credentials with permission to create and delete S3 buckets. From this directory, run:

```sh
terraform -chdir=blueprint init
terraform -chdir=blueprint plan
terraform -chdir=blueprint apply
terraform -chdir=blueprint output
```

When finished, remove the test bucket and other managed resources:

```sh
terraform -chdir=blueprint destroy
```

S3 usage may incur AWS charges. The bucket name is generated with a unique suffix; `bucket_prefix` must remain globally unique enough for S3.