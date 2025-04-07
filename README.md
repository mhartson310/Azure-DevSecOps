# Azure-DevSecOps

Welcome to the Azure-DevSecOps repository! This repository aims to provide resources, best practices, and practical examples for integrating security into your DevOps workflows within the Microsoft Azure ecosystem.

**Our Goal:** To help you build secure and compliant applications and infrastructure on Azure by embedding security throughout the entire development lifecycle.

**What you'll find here:**

* **Documentation:** Guides, articles, and best practices for various aspects of Azure DevSecOps.
* **Code Samples:** Practical examples, scripts, and templates demonstrating secure configurations and automation.
* **Tools & Integrations:** Information and examples of integrating security tools into your Azure DevOps pipelines.
* **Templates:** Infrastructure as Code (IaC) templates with security considerations baked in, and pre-configured Azure Pipelines templates for secure CI/CD.
* **Community Contributions:** Opportunities for the community to share their knowledge and experiences.

**Getting Started:**

1.  **Explore the File Structure:** Familiarize yourself with the organization of this repository (see below).
2.  **Browse the Documentation:** Check out the `docs` directory for guides and articles.
3.  **Review Code Samples:** Look at the `code-samples` directory for practical examples.
4.  **Explore Pipeline Templates:** Find reusable pipeline configurations in the `templates/azure-pipelines/` directory.
5.  **Contribute:** We encourage contributions! See the [Contributing Guidelines](CONTRIBUTING.md) for more information.


**Pipeline Templates:**

This repository includes pre-configured Azure Pipelines templates in the `templates/azure-pipelines/` directory to help you quickly set up secure CI/CD pipelines for different types of applications.

* **`web-app-security-template.yml`:** A template for building and deploying web applications with pre-configured stages for build, unit tests, static application security testing (SAST), and deployment with pre-deployment security checks.
* **`container-app-security-template.yml`:** A template for building and deploying containerized applications with stages for building and pushing the container image, container security scanning, and deployment to a container orchestrator (like AKS) with pre-deployment security checks.

**How to Use the Pipeline Templates:**

You can leverage these templates in your main `azure-pipelines.yml` file using the `extends` keyword. This allows you to inherit the predefined stages and steps from the templates and customize them with your specific project parameters.

Here's an example of a basic `azure-pipelines.yml` file that references these templates:

```yaml
# azure-pipelines.yml
# Main pipeline definition for the Azure-DevSecOps repository

trigger:
- main
- develop

pool:
  vmImage: ubuntu-latest

variables:
  azureSubscription: 'your-azure-service-connection' # Replace with your Azure service connection name
  dockerRegistryServiceConnection: 'your-docker-registry-connection' # Replace with your Docker registry service connection name
  kubernetesServiceConnection: 'your-aks-connection' # Replace with your AKS service connection name
  resourceGroupName: 'your-resource-group' # Replace with your Azure Resource Group name

  webAppName: 'your-web-app-name' # Replace with your actual web app name
  webAppSolution: '**/*.sln'
  webAppProject: 'YourWebApp/YourWebApp.csproj' # Adjust path to your web app project

  imageRepository: 'yourregistry.azurecr.io/your-image-name' # Replace with your ACR details

# --- Pipeline for building and deploying a Web Application with security ---
- template: templates/azure-pipelines/web-app-security-template.yml
  parameters:
    serviceConnection: $(azureSubscription)
    vmImage: 'windows-latest'
    buildConfiguration: 'Release'
    pathToSolution: $(webAppSolution)
    pathToWebAppProject: $(webAppProject)
    sa تحليلTool: 'SonarQube'
    sonarqubeServiceConnection: 'your-sonarqube-connection'
    sonarqubeProjectKey: 'your-web-app-project-key'
    deploymentEnvironment: 'Production'

# --- Pipeline for building and deploying a Containerized Application with security ---
- template: templates/azure-pipelines/container-app-security-template.yml
  parameters:
    serviceConnection: $(azureSubscription)
    dockerRegistryServiceConnection: $(dockerRegistryServiceConnection)
    imageName: '$(imageRepository)'
    containerScanTool: 'ACR'
    deploymentEnvironment: 'Production'
    kubernetesServiceConnection: $(kubernetesServiceConnection)
```

**Contributing:**

We welcome contributions from the community! Please read our [Contributing Guidelines](CONTRIBUTING.md) for details on how to submit pull requests and report issues.

**License:**

This project is licensed under the [LICENSE](LICENSE) - see the [LICENSE.md](LICENSE.md) file for details.

**Stay Connected:**

* [LINKEDIN](https://linkedin.com/in/mariohartson)
