# Serverless Paste Bin

Welcome to the Serverless Paste Bin project! This project is a web application hosted on GitHub Pages, allowing users to create and retrieve data with ease. Below you'll find detailed information about the features and infrastructure of this application.

## Features

- **User-friendly Web Interface**: Simple and intuitive webpage hosted on GitHub Pages for creating and retrieving data.
- **Custom Keys**: Users can select custom keys for their data for easier retrieval.
- **Data Expiry**: Data are set to expire after 2 weeks by default.
- **API Throttling**: An API Gateway with throttling capabilities ensures the service remains performant and fair to all users.
- **Error Notifications**: Any failures in the lambda function trigger an event to an SNS topic, notifying subscribed users via email.

## Infrastructure

This application leverages a serverless architecture hosted on AWS, utilizing the following components:

- **API Gateway**: Handles incoming HTTP requests and applies throttling to manage request rates.
- **Lambda Function**: Processes the incoming requests, performs necessary operations, and interfaces with DynamoDB.
- **DynamoDB**: An auto-scalable NoSQL database that stores the data.
- **SNS (Simple Notification Service)**: Sends notifications to subscribed users in case of system failures.

### Technology Stack

- **Infrastructure as Code**: Managed using Terraform for easy deployment and maintenance.
- **AWS Services**: API Gateway, Lambda, DynamoDB, SNS.
- **GitHub Pages**: Hosts the static webpage.

## Getting Started

### Prerequisites

- AWS account with permissions to create and manage Lambda, API Gateway, DynamoDB, and SNS resources.
- Terraform installed on your local machine.
- GitHub account for hosting the webpage.

### Deployment

1. **Clone the Repository**:
   ```sh
   git clone https://github.com/horefice/serverless-paste.git
   cd serverless-paste
   ```

2. **Setup AWS Credentials**: Ensure your AWS credentials are configured. You can set them up using the AWS CLI:
   ```sh
   aws configure
   ```

3. **Deploy Infrastructure**:
   ```sh
   zip tf/lambda_function.zip lambda/function.py
   cd tf
   terraform init
   terraform apply
   ```

4. **Configure GitHub Pages**:
   - Push the project to your GitHub repository.
   - Enable GitHub Pages in the repository settings and select the branch to serve the webpage.

### Usage

1. **Access the Webpage**: Visit the GitHub Pages URL provided in your repository settings.
2. **Create or update data**: Use the form on the webpage to input your data and a custom key.
3. **Retrieve data**: Use the custom key to retrieve your data from the webpage.

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request for any features, enhancements, or bug fixes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

Thank you for using the Serverless Paste Bin project! If you have any questions or need assistance, feel free to open an issue in the repository.