# 🔒 Azure DevOps vs. GitHub Advanced Security: Best Practices Guide

---

## 📋 Table of Contents
* Overview
* Platform Feature Comparison
* 🔑 Secret Scanning
    * Best Practices
* 💻 Code Scanning (SAST)
    * Best Practices
* 📦 Dependency Scanning (SCA)
    * Best Practices
* ⚙️ Implementation & Integration
* 🌍 Real-World Scenarios & Synergy
* 🤔 Frequently Asked Questions
* 💡 Recommendations

---

## 🔍 Overview
Both Azure DevOps (ADO) and GitHub offer robust platforms for software development, but they approach integrated security tooling differently. Microsoft backs both platforms.

* **Azure DevOps:** Provides a comprehensive suite of DevOps tools (Boards, Repos, Pipelines, Test Plans, Artifacts). Security features are often integrated via **Azure Pipelines tasks and extensions**, offering flexibility but requiring configuration. Native capabilities exist, like basic secret scanning in Repos and pipelines.
* **GitHub Advanced Security (GHAS):** An **add-on suite** for GitHub Enterprise (Cloud or Server). It tightly integrates security tools (**Secret Scanning, Code Scanning with CodeQL, Dependabot alerts**) directly into the GitHub repository and developer workflow (e.g., PR checks via GitHub Actions). It emphasizes ease of use and built-in automation.

---

## 📊 Platform Feature Comparison

| Feature             | Azure DevOps (Native/Common Extensions)                                     | GitHub Advanced Security (GHAS)             |
| :------------------ | :-------------------------------------------------------------------------- | :------------------------------------------ |
| **Primary Focus** | Pipeline Integration, Extensibility, Enterprise Governance                  | Repository Integration, Developer Workflow  |
| **Secret Scanning** | ✅ (Native Repo push protection & pipeline task; Extensible via extensions) | ✅ (Native Repo push protection & historical) |
| **Code Scanning (SAST)**| ✅ (Via Extensions: SonarQube/Cloud, Checkmarx, Microsoft Security DevOps) | ✅ (CodeQL - integrated in Repos/Actions)   |
| **Dependency Scanning (SCA)** | ✅ (Via Extensions: OWASP Dep-Check, Mend, Snyk, WhiteSource Bolt, Microsoft Security DevOps, Community Dependabot tasks) | ✅ (Dependabot - integrated in Repos/Actions) |
| **Licensing** | Core features included; Extensions may have own costs.                      | Add-on license per active committer for GH Enterprise. |
| **Setup** | Requires pipeline/extension configuration for advanced features.            | Features enabled via repository/org settings. |

---

## 🔑 Secret Scanning
Identifies accidentally committed credentials (API keys, passwords, tokens, certificates) in your codebase.

### Best Practices
* **Enable Push Protection:** Configure this in both ADO Repo settings and GHAS settings to block secrets *before* they are committed to shared branches.
* **Scan Repositories:** Regularly scan the entire history of repositories for exposed secrets (GHAS does this automatically; ADO may require specific tasks or third-party tools like GitGuardian).
* **Scan CI/CD Pipelines:** Use tasks (like ADO's built-in CredScan or the Microsoft Security DevOps extension) to scan build artifacts and logs for secrets missed by repo scanning.
* **Use Secure Secret Storage:** Never hardcode secrets. Use managed secret stores like Azure Key Vault, GitHub Secrets, or HashiCorp Vault. Access them securely from pipelines (e.g., via ADO Variable Groups linked to Key Vault, or GH Actions secrets).
* **Immediate Remediation:** If a secret is exposed:
    1.  Revoke the compromised credential immediately.
    2.  Remove the secret from the codebase history (this is difficult and often requires tools/expertise; revoking is the priority).
    3.  Replace with a reference to a secure secret store.
* **Minimize Exclusions:** Only exclude specific files/paths (e.g., test data, documentation examples) from scanning if absolutely necessary, and document why (GHAS uses `.github/secret_scanning.yml`).
* **Educate Developers:** Train teams on the importance of secret management and secure coding practices.

---

## 💻 Code Scanning (SAST - Static Application Security Testing)
Analyzes source code for potential security vulnerabilities and coding errors without executing the code.

### Best Practices
* **Integrate Early & Often ("Shift Left"):**
    * **ADO:** Add SAST tasks (e.g., SonarCloud/SonarQube analysis, Microsoft Security DevOps) to your YAML pipelines, triggered on Pull Requests and main branch commits.
    * **GHAS:** Enable CodeQL analysis via GitHub Actions (default or advanced setup). Configure it to run on PRs to `main`/`master` and potentially on a schedule for the default branch.
* **Block Critical Issues:** Configure branch policies (ADO) or required status checks (GitHub) to block PR merges if critical or high-severity vulnerabilities are detected.
* **Prioritize Remediation:** Focus on fixing high-impact vulnerabilities first (e.g., SQL Injection, Remote Code Execution). Use context (like CodeQL's data flow analysis) to understand the risk.
* **Customize Rule Sets:** Fine-tune the analysis rules or queries (e.g., CodeQL query suites, SonarQube Quality Profiles) to reduce noise (false positives) and focus on relevant risks for your application context. Disable irrelevant rules.
* **Track Findings:** Use the platform's dashboards (ADO build results/dashboards, GitHub Security tab) to track vulnerability trends and manage remediation efforts.
* **Combine with Developer Training:** SAST tools are most effective when developers understand the vulnerabilities they find and how to fix them securely.

---

## 📦 Dependency Scanning (SCA - Software Composition Analysis)
Identifies known vulnerabilities (CVEs) and potential license compliance issues in the open-source libraries and components your project uses.

### Best Practices
* **Scan Regularly:**
    * **ADO:** Integrate SCA tasks (e.g., OWASP Dependency-Check, Mend, Snyk, WhiteSource Bolt via extensions; Microsoft Security DevOps extension; community Dependabot tasks) into your CI pipelines.
    * **GHAS:** Enable Dependabot alerts. GitHub automatically scans manifests in supported ecosystems.
* **Use Lock Files:** Ensure your project uses package lock files (e.g., `package-lock.json`, `yarn.lock`, `Gemfile.lock`, `pom.xml`, `*.csproj`) to guarantee reproducible builds and accurate dependency analysis. Commit these lock files to your repository.
* **Prioritize Fixes:** Focus on vulnerabilities with high severity scores (CVSS), known exploits, or those impacting critical application functions. Use resources like EPSS (Exploit Prediction Scoring System) if available.
* **Automate Updates:**
    * **GHAS:** Enable Dependabot security updates (creates PRs automatically to update vulnerable dependencies to the minimum patched version) and Dependabot version updates (keeps dependencies fresh based on `dependabot.yml` config).
    * **ADO:** Some extensions offer automated update capabilities, or use community Dependabot pipeline tasks which can generate PRs.
* **Review Automated PRs:** Carefully test automated dependency update PRs, as updates can sometimes introduce breaking changes. Ensure your test suites are comprehensive.
* **Manage Licenses:** Use SCA tools to identify the licenses of your dependencies and ensure compliance with your organization's policies.

---

## ⚙️ Implementation & Integration

* **Azure DevOps:**
    * Security features often require installing extensions from the Visual Studio Marketplace (e.g., Microsoft Security DevOps, SonarSource, Snyk, WhiteSource, GitGuardian).
    * Configure YAML pipelines to include security scanning tasks (SAST, SCA, Secret Scanning).
    * Enable native repo secret scanning push protection in Project Settings -> Repositories -> Settings.
    * Secure pipelines by using templates, variable groups linked to Key Vault, secure agent pools, and limiting job authorization scopes.
* **GitHub Advanced Security (GHAS):**
    * Requires a GitHub Enterprise license plus the GHAS add-on license.
    * Enable GHAS features at the organization or repository level under Settings -> Code security and analysis.
    * Configure features like CodeQL (via Actions workflows - `.github/workflows/codeql-analysis.yml`), Dependabot (`.github/dependabot.yml`), and Secret Scanning exclusions (`.github/secret_scanning.yml`).

---

## 🌍 Real-World Scenarios & Synergy

* **Scenario 1: ADO for CI/CD, GitHub for Source (Common):**
    * Use **GitHub** for source control, leveraging **GHAS** for integrated secret scanning push protection, CodeQL PR checks, and Dependabot alerts/updates within the developer workflow.
    * Use **Azure Pipelines** for complex build, testing, and deployment orchestration.
    * *Synergy:* ADO Pipelines can trigger off GitHub commits/PRs. Security results from GHAS are visible in GitHub. ADO Pipelines can run *additional* security checks (e.g., dynamic analysis, container scanning, specialized SCA/SAST not covered by GHAS) and enforce deployment gates based on quality/security criteria. You could even run the CodeQL CLI within an ADO Pipeline task and upload results to GitHub if needed.
* **Scenario 2: Primarily Azure DevOps:**
    * Use ADO Repos for source control.
    * Enable native secret scanning push protection.
    * Integrate extensions like **Microsoft Security DevOps** or tools like SonarQube/Cloud, OWASP Dependency-Check/Mend/Snyk into **Azure Pipelines** for SAST, SCA, and pipeline secret scanning.
    * Configure build validation policies to run these checks on PRs.
    * Use ADO Boards for tracking vulnerability remediation work.
* **Scenario 3: Primarily GitHub:**
    * Use GitHub for source control and **GitHub Actions** for CI/CD.
    * Leverage **GHAS** fully (CodeQL, Dependabot, Secret Scanning) integrated within Actions and the repository Security tab.
    * Use GitHub Projects for planning and tracking security work.

---

## 🤔 Frequently Asked Questions

1.  **Do I need GHAS if I'm using Azure DevOps security extensions?**
    * Not necessarily, but GHAS offers a more tightly integrated, developer-centric experience within GitHub itself, especially CodeQL's deep code analysis and Dependabot's automation. ADO extensions provide flexibility but require pipeline configuration and management.
2.  **Can I use GHAS features directly on Azure Repos?**
    * No. GitHub Advanced Security is specifically licensed and designed for repositories hosted on GitHub (Enterprise Cloud or Server). Microsoft has discussed "GHAS for Azure DevOps" which aims to bring similar capabilities natively, but full parity isn't available today (as of early 2025). Some features are being bridged via the Microsoft Security DevOps extension.
3.  **How does ADO's native secret scanning compare to GHAS?**
    * Both offer push protection. GHAS generally has broader historical scanning capabilities, more partnerships for automatic token revocation, and potentially more built-in patterns. ADO's native scanning is improving, and pipeline scanning adds another layer.
4.  **Can I run CodeQL analysis in Azure Pipelines?**
    * Yes. While not natively integrated like in GitHub Actions, you can install and run the CodeQL CLI within an Azure Pipeline task, perform the analysis, and then potentially upload the SARIF results back to GitHub (if using GitHub repos) or process them directly in the pipeline.
5.  **Is Dependabot available for Azure DevOps?**
    * Not natively from Microsoft/GitHub. However, the core Dependabot logic is open source, and community-developed Azure DevOps extensions exist (like Tingle Software's) that allow you to run Dependabot scans via pipeline tasks, requiring configuration.
6.  **Which platform's security features are easier to set up?**
    * GHAS features (CodeQL default setup, Dependabot, Secret Scanning) are often considered easier for initial setup within GitHub Enterprise due to their tight integration – usually just enabling them in settings. ADO requires finding, installing, and configuring extensions/tasks within pipelines.
7.  **Can I use third-party security tools with both platforms?**
    * Yes. Both platforms are highly extensible. You can integrate various third-party SAST, DAST, SCA, and secret scanning tools into both Azure Pipelines and GitHub Actions.

---

## 💡 Recommendations

* **Shift Security Left:** Integrate security scanning (Secrets, SAST, SCA) early in the development lifecycle, ideally within Pull Request checks, regardless of the platform.
* **Automate Where Possible:** Leverage automated features like GHAS push protection, CodeQL analysis triggers, Dependabot updates, or equivalent pipeline configurations in ADO.
* **Secure Your CI/CD Environment:** Protect your build agents (prefer managed/ephemeral agents), secure service connections (use workload identity federation/managed identities over PATs/secrets), and limit pipeline permissions (least privilege).
* **Don't Rely on One Tool:** Use a layered approach. Combine SAST, SCA, secret scanning, and potentially DAST (Dynamic Application Security Testing) and IAST (Interactive Application Security Testing) for comprehensive coverage.
* **Prioritize & Remediate:** Establish a process for triaging, prioritizing, and tracking the remediation of discovered vulnerabilities. Don't let alerts pile up ignored.
* **Manage Secrets Securely:** Use dedicated secret management solutions (Azure Key Vault, GitHub Secrets) and avoid hardcoding credentials.
* **Choose Based on Workflow:** If your team lives in GitHub, GHAS provides seamless integration. If your organization is heavily invested in Azure DevOps, leverage its extensibility and pipeline security features, potentially integrating with GitHub for source control if desired.
