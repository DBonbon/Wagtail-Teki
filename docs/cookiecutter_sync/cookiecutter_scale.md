# Synchronizing a Cookiecutter Template with a Project

This document outlines three methods for synchronizing and managing changes between a project and its Cookiecutter template: **Rsync**, **Cruft**, and **Retrocookie**. It includes detailed steps, limitations, and a recommended workflow for using these tools effectively.

## Overview of Synchronization Methods

### Rsync: Manual Synchronization
Rsync is a file synchronization tool that can copy changes from your project to the Cookiecutter template while excluding unnecessary files. This method requires careful manual handling to preserve `{{cookiecutter.*}}` placeholders in the template.

#### Steps for Rsync-Based Synchronization
1. **Prepare an `.rsync-filter` File**:  
   Define the files and directories to exclude during synchronization. Example:  
   \```plaintext
   - .env
   - node_modules/
   - .next/
   - *.pyc
   \```

2. **Synchronize Files**:  
   Use Rsync to copy project changes to the template directory:  
   \```bash
   rsync -av --filter="merge .rsync-filter" project-dir/ template-dir/{{cookiecutter.project_name}}/
   \```

3. **Restore Placeholders**:  
   Replace hardcoded values with their corresponding `{{cookiecutter.*}}` placeholders using tools like `sed` or scripts.

4. **Validate Changes**:  
   Generate a new project from the updated template to verify the placeholders were restored correctly.

#### Limitations of Rsync
- Manual Placeholder Restoration: Rsync overwrites placeholders (`{{cookiecutter.*}}`) with static values, requiring additional scripts to restore them.
- Error-Prone: Risk of missing placeholders or incorrectly replacing hardcoded values.
- Time-Consuming: Complex or dynamic variables require extensive manual intervention.
- Not Scalable: Difficult to manage for large projects or teams.

#### Advancing Beyond Rsync
To overcome Rsync's limitations:  
- Use **Retrocookie** to automate placeholder restoration and synchronization.  
- Introduce **Cruft** to manage updates from the template to the project once Retrocookie is in place.

### Cruft: Template to Project Synchronization
Cruft is designed to keep projects synchronized with their Cookiecutter templates, applying updates from the template to existing projects. It tracks the template source and version used to generate the project.

#### Steps for Using Cruft
1. **Install Cruft**:  
   \```bash
   pip install cruft
   \```

2. **Track Template**:  
   When generating a project with Cookiecutter, track the template using Cruft:  
   \```bash
   cruft create <template-repo-url>
   \```

3. **Check for Updates**:  
   Periodically check for template updates:  
   \```bash
   cruft check
   \```

4. **Apply Updates**:  
   Apply updates from the template to the project:  
   \```bash
   cruft update
   \```

#### Limitations of Cruft
- One-Way Sync: Works only from the template to the project, not the other way around.
- Requires Template Tracking: Only works if the project was generated with Cruft or has tracking metadata.

#### Advancing with Cruft
- Use **Cruft** alongside Retrocookie to manage updates in both directions.  
- Retrocookie can reconstruct templates from updated projects, which can then be re-applied to existing projects via Cruft.

### Retrocookie: Project to Template Synchronization
Retrocookie automates the process of reconstructing a Cookiecutter template from a project. It identifies hardcoded values and replaces them with `{{cookiecutter.*}}` placeholders.

#### Steps for Using Retrocookie
1. **Install Retrocookie**:  
   \```bash
   pip install retrocookie
   \```

2. **Reconstruct the Template**:  
   Use Retrocookie to synchronize project changes back to the template:  
   \```bash
   retrocookie --template <path-to-template-repo> --project <path-to-project>
   \```

3. **Review and Commit Changes**:  
   Inspect the changes made to the template and commit them to the template repository.

#### Limitations of Retrocookie
- Initial Setup Complexity: Requires configuring and testing the tool for your specific template and project structure.
- Dynamic Placeholder Logic: May require manual intervention for placeholders with complex logic (e.g., computed values).

#### Advancing with Retrocookie
- Use Retrocookie as a bridge between project changes and template updates.  
- Combine with Cruft to maintain synchronization in both directions:  
  - Retrocookie: Project ➡ Template.  
  - Cruft: Template ➡ Project.

## Comparison of Methods

| Feature                      | Rsync                     | Cruft                     | Retrocookie               |
|------------------------------|---------------------------|---------------------------|---------------------------|
| Sync Direction               | Project ➡ Template        | Template ➡ Project        | Project ➡ Template        |
| Automation                   | Partial (manual scripts)  | Yes                       | Yes                       |
| Placeholder Handling         | Manual                   | N/A (template only)       | Automatic                 |
| Scalability                  | Low                       | High                      | High                      |
| Ease of Use                  | Medium                    | High                      | Medium                    |
| Suitable for Teams           | No                        | Yes                       | Yes                       |
| Works Without Placeholder Restoration | Yes            | Yes                       | No                        |

## Recommended Workflow

### Initial Steps
1. Start with Rsync for basic synchronization but document placeholder mappings carefully.
2. Gradually adopt Retrocookie for automation to streamline project-to-template synchronization.

### Long-Term Workflow
1. Use **Retrocookie** to update the template when changes are made in the project.
2. Use **Cruft** to propagate template updates to all generated projects.

This combination ensures your projects and templates remain synchronized with minimal manual effort.
