# Migrating Your Project

This section provides a step-by-step guide to migrating your existing Fortran project into the structure and setup of this template.

## Summary Checklist

- Clone the template repository.
- Remove the `.git` directory from the cloned template.
- Initialize a new Git repository.
- Integrate your existing project files.
- Update configuration files.
- Commit and push the project to your remote repository.
- Verify the setup by running tests and builds.
- Make final adjustments and review the `README.md`.

By following these steps, you can seamlessly migrate your existing Fortran project into the template structure, ensuring a consistent and streamlined development environment.

## Step 1: Clone the Template Repository

Start by cloning the template repository to your local machine:

```sh
git clone git@github.com:MatthAlex/fortran-project-template.git
cd fortran-project-template
```

## Step 2: Remove Existing Git History

Regardless of whether migrating an existing project or creating a new one, remove the existing `.git/` directory to detach it from the template's version history:

```sh
rm -rf .git
```

## Step 3: Initialize a New Git Repository

Initialize a new Git repository in your project's directory:

```sh
git init
```

## Step 4: Integrate Your Existing Project Files

Copy your existing project files into the relevant directories within the template structure. Ensure that:

- Source files are placed in the `src/` directory.
- The main program driver is placed in the `app/` directory.
- Tests are placed in the `test/` directory.
- Documentation is placed in the `docs/` directory.

## Step 5: Update Configuration Files

Review and update the configuration files to reflect your project's specifics. Key files to review include:

- `fpm.toml`: Update with your project's name, version, and dependencies.
- `.vscode/settings.json`: Ensure paths and settings are appropriate for your project.
- `.pre-commit-config.yaml`: Adjust pre-commit hooks if necessary.

## Step 6: Initialize Git and Make the First Commit

Add all your project files to the new repository, commit the changes, and push to your remote repository (e.g., GitHub, GitLab).

```sh
git add .
git commit -m "Initial commit: Migrated project to Fortran Project Template"
git remote add origin <your-remote-repository-url>
git push -u origin master
```

## Step 7: Verify Setup

Run the provided tests and build commands to ensure everything is correctly configured:

```sh
fpm test
fpm run
```

This step relies on creating and activating your environment, including installing all packages. See the main [Step-by-step instructions](../README.md#step-by-step-instructions).

## Step 8: Final Adjustments

- Review and Edit `README.md`: Update this file to reflect your project's details, ensuring all sections are relevant.
- Configure Additional Tools: If your project uses additional tools or configurations, ensure they are properly set up and documented.
