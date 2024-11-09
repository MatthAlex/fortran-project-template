# Migrating Your Project

This section provides a step-by-step guide to migrating your existing Fortran project into the structure and setup of this template.

## Summary Checklist

- Create a new repository with "Use this template".
- Verify the setup by building the example and running the test.
- Integrate your existing project files.
- Update configuration files.
- Make final adjustments and review the `README.md`.
- Commit and push the project to your remote repository.

## Step 1: Use the Template Repository

On GitHub, select "Use this template", then "Create a new repository". This will create a new repository to your GitHub account, containing everything in the template as is and replacing the commits' author as well.

### Cloning the repository

Cloning as usual works as expected: The commits already present will be of a different author, and the remote points directly to this template repository. To create an own project by cloning, 1) remove the `.git` directory from root, 2) run `git init`, 3) create a project on GitHub, 4) follow the instructions to set up the remote and push your changes.

## Step 2: Verify `fpm` Setup

Build and run the example code and added test to ensure the project is correctly configured:

```sh
fpm test
fpm run
```

This step relies on creating and activating your environment, including installing all packages. See the main [Step-by-step instructions](../README.md#step-by-step-instructions).

## Step 3: Integrate Your Existing Project Files

Copy your existing project files into the relevant directories within the template structure. Ensure that:

- The main program driver is placed in the `app/` directory. The driver file is the one that contains the Fortran `program`. There can be multiple driver programs present.
- Source files are placed in the `src/` directory. The hierarchy doesn't have to be flat.
- Tests are placed in the `test/` directory.
- Documentation is placed in the `docs/` directory.

## Step 4: Update Configuration Files

Review and update the configuration files to reflect your project's specifics. Key files to review include:

- `fpm.toml`: Update with your project's name, version, and dependencies.
- `.vscode/settings.json`: Ensure paths and settings are appropriate for your project.
- `.pre-commit-config.yaml`: Adjust or update pre-commit hooks as necessary.

## Step 5: Final Adjustments

- Review and Edit `README.md`, to reflect your project's details, ensuring all sections are relevant. Remove redundant or unneeded information.
- Configure Additional Tools: If your project uses additional tools or configurations, ensure they are properly set up and documented.
