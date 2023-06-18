```
# Website for Airbnb Condo

This project provides Terraform configurations to deploy a static website to AWS S3 and configure Cloudflare DNS.

## Prerequisites

Before you begin, ensure that you have the following prerequisites installed:

- [Terraform](https://www.terraform.io/downloads.html)
- [AWS CLI](https://aws.amazon.com/cli/)

## Getting Started

1. **Clone the repository:**

   ```shell
   git clone <repository-url>
   cd my-website-terraform
   ```

2. **Set up your AWS credentials:**

   If you haven't already, configure your AWS credentials by running `aws configure` and providing your Access Key ID, Secret Access Key, and default region.

3. **Customize the configuration:**

   - Open `variables.tf` and update the variables to match your desired configuration. Set the `aws_region` variable to your preferred AWS region, and the `site_domain` variable to your website's domain name.
   - Replace the `index.html` file in the `website/html` directory with your own custom `index.html` file.

4. **Initialize Terraform:**

   Run the following command to initialize Terraform:

   ```shell
   terraform init
   ```

5. **Review the plan:**

   Generate an execution plan to see the proposed changes:

   ```shell
   terraform plan
   ```

   Review the plan output to ensure it matches your expectations.

6. **Deploy the infrastructure:**

   Apply the Terraform configuration to provision the AWS S3 bucket, Cloudflare DNS records, and related resources:

   ```shell
   terraform apply
   ```

   Terraform will prompt for confirmation. Type "yes" and press Enter to proceed.

7. **Access your website:**

   Once the deployment is complete, your static website should be accessible at the configured domain name. It may take a few minutes for DNS changes to propagate.

8. **Cleanup and teardown:**

   To remove all the resources created by Terraform and tear down the infrastructure:

   ```shell
   terraform destroy
   ```

   Review the plan output and type "yes" when prompted to confirm the destruction of resources.

## Contributing

Contributions are welcome! If you encounter any issues or have suggestions for improvements, please open an issue or submit a pull request.

## License

This project is licensed under the [MPL-2.0 License](LICENSE).
```
```
