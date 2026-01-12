# Deploy Local Vault

A simple Terraform config to deploy local Vault changes on an AWS instance.

The repository contains some simple configs to build a Vault binary from a local repository and deploy it on an EC2 instance on AWS. The output prints the IP address of the EC2 instance.

As part of the deployment, the tool also creates an ssh key file that can be used to ssh into the EC2 instance that runs Vault.

```

    ssh -i vault-key.pem ubuntu@<public_ip_address>

```

All the operations the tool supports are mentioned in the Makefile.

In order to build and deploy the local Vault code.

export the Vault license and the AWS credentials for your account in the terminal as below

```

    export TF_VAR_VAULT_LICENSE=<LICENSE_CONTENT>

    export AWS_ACCESS_KEY_ID=...
    export AWS_SECRET_ACCESS_KEY=...
    export AWS_SESSION_TOKEN=...

```

and run 

```

    make deploy REPO=<path_to_local_vault_repo>

```

Access the deployed Vault server at

```
http://<public_ip>:8200
```

## Prerequisites

Please make sure the below tools are installed

1. Hashicorp Packer
2. Hashicorp Terraform

