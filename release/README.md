
# Release Script

This script automates the process of creating and pushing a new Git tag and corresponding GitHub release. It is designed to be used in a Git repository with the GitHub CLI (`gh`) installed.

## Prerequisites

- **Git**: Ensure that Git is installed on your system.
- **GitHub CLI (gh)**: Install GitHub CLI from [https://cli.github.com](https://cli.github.com).
- **GitHub CLI Login**: You must be logged in to GitHub CLI to create a release.

## Usage

```bash
./script.sh [release_type]
```

### Parameters

- **release_type** (optional): The type of release you want to create. It can be one of the following:
  - \`--major\`: Increment the major version (e.g., \`v1.0.0\` -> \`v2.0.0\`).
  - \`--minor\`: Increment the minor version (e.g., \`v1.0.0\` -> \`v1.1.0\`).
  - \`--patch\`: Increment the patch version (e.g., \`v1.0.0\` -> \`v1.0.1\`). This is the default if no release type is provided.
  - **specific version** (e.g., \`v1.2.3\`): Use a specific version directly.

### Example

To create a new patch release:

```bash
./script.sh --patch
```

To create a specific version release:

```bash
./script.sh v1.2.3
```

## Script Workflow

1. **Check Prerequisites**: The script checks if Git is installed and if it’s running inside a Git repository. It also checks if the GitHub CLI (\`gh\`) is installed and logged in.
   
2. **Determine Release Version**: If no specific version is provided, the script calculates the new version based on the latest Git tag and the specified release type (major, minor, or patch).
   
3. **Create Git Tag**: The script prompts the user to confirm tag creation. If confirmed, it creates the tag and pushes it to the remote repository.
   
4. **Create GitHub Release**: After the tag is pushed, the script checks if a release with that tag exists on GitHub. If not, it creates a new release with the specified version.

## Error Handling

- **Invalid Release Type**: If an invalid release type is provided, the script will exit with an error message.
- **GitHub CLI Not Installed**: The script will notify you if the GitHub CLI is not installed.
- **GitHub CLI Not Logged In**: If you are not logged into GitHub CLI, the script will prompt you to log in.

## Notes

- Ensure that you are inside a Git repository when running the script.
- You can abort the tag creation process at the confirmation step if needed.
