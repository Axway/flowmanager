# appspace-cba-dev


# Host prerequisite :

## Tool versions :

## Set up AWS CLI

Configure your AWS credentials, refer to [the AWS CLI
documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
for guidance.

* Set the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables:

  ```sh
  export AWS_ACCESS_KEY_ID=your_access_key_id
  export AWS_SECRET_ACCESS_KEY=your_secret_access_key
  ```
* If you have multiple AWS profiles and don't use aws-vault, set the
  `AWS_PROFILE` environment variable:

  ```sh
  export AWS_PROFILE=your_aws_profile
  ```
* In case your IAM user authorization relies on MFA and / or assumed IAM role,
  set the `AWS_SESSION_TOKEN` environment variable:

  ```sh
  export AWS_SESSION_TOKEN=your_session_token
  ```

Please refer to [AWS Credentials Best Practices
[Confluence]](https://techweb.axway.com/confluence/display/RDAPI/AWS+Credentials+Best+Practices#AWSCredentialsBestPractices-nativeAWSCLI)
for more guidance.

> NB: **You must specify those environment variables when executing Docker commands.
> Refer to the [Deploying a cluster](#deploying-a-cluster) section below for an example.**

You're now all set to use the EKS Docker image to manage your EKS clusters.

## Set up kubectl
Exemple:
```bash
# Setting up Kubeconfig
export KUBECONFIG="/home/axway/.eks-kubeconfig-flowmanager-dev"
aws eks update-kubeconfig --name flowmanager-dev --region eu-west-3

# Setting up env vars for terraform.
export KUBE_CONFIG_PATH="${KUBECONFIG}"
export KUBE_CTX=""

```

You may need to add --role-arn if you need to assume the role of your cluster admin.


## Set up helm :

### Create auth token on Axway 'internal' artifactory that can be reach from cloud providers.(https://artifactory.axway.com).

- Go to https://artifactory.axway.com
- Register with 'SAML SSO' button
- On the top right click on your Email address then 'Edit Profile'
- Click on 'Generate Identity Token', provide a optioanl description and click 'Next'
- Save the generated token (using a secure password vault is a recommended practice here).
- To use the token (for rest API calls and Helm CLI): use your e-mail as username and token as password.

### Configure helm on the machine that will run the terraform :

```bash
# Configure Bitnami repository for Mondodb
helm repo add bitnami-full-index https://raw.githubusercontent.com/bitnami/charts/archive-full-index/bitnami

# Configure MFT Helm chart repository
#  - note : --pass-credential is mandatory if helm version is >= v3.6.1. Remove it for ealier versions
helm repo add mft-helm-release https://<TBD>/artifactory/api/helm/mft-helm-release --username "<email>" --password "<token>" --pass-credentials
```


# Setting secrets

<span style="color:red">***TO BE UPDATED*** : this chapter of the ReadMe is not up to date.</span>

# Usage

## Installation

```bash
terraform init
terraform apply
```

## Destruction

```bash
terraform destroy
```
