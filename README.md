# gh Commenter

Atomatically posts comments on specified **Issues** or **Pull Requests (PRs)** in your repository.

This GitHub Action is useful for teams who want to **programmatically add comments** to Issues or Pull Requests, which is essential for CI/CD status reporting, automated code review feedback, and bot communication via webhooks.

---

## ✨ Features

- **Automated Commenting**: A core feature to post messages on Issues or Pull Requests directly from a workflow.
- **Simple Integration**: One-step usage in any workflow.
- **Powered by GitHub CLI**: Uses the official [GitHub CLI](https://cli.github.com/) for secure **Issue and Pull Request comment** management.
- **Organization-wide**: Can be used across any repository.


## 🛠️ Usage

### 1. **Prerequisites**

- Your workflow **must pass the necessary inputs** to this action.
- This action expects the [GitHub CLI (`gh`)](https://cli.github.com/) to be available (it is pre-installed on all GitHub-hosted runners).
- The environment variable `GH_TOKEN` must be set to a valid GitHub token with the required write permissions, typically `repo` and specific permissions like `pull_requests` or `issues`. (by default, `${{ github.token }}` will suffice for most repositories).

### 2. **Example Workflow Integration**

```yaml
name: Test GH Commenter Action

on:
  workflow_dispatch:
    inputs:
      kind_id:
        description: 'Issue or Pull Request ID or URL for commenting (e.g., 1)'
        required: true
        default: '1'
      message:
        description: 'Test comment content'
        required: true
        default: 'This is an automated test comment.'

jobs:
  comment_test:
    runs-on: ubuntu-latest
    
    # IMPORTANT: You must configure the GITHUB_TOKEN to have write permissions on Issues/PRs.
    permissions:
      issues: write
      pull-requests: write

    steps:
      - name: Use GH Commenter Action
        uses: ws2git/gh-commenter-action@v1 
        id: commenter
        env:
          GH_TOKEN: ${{ github.token }}
        with:
          # Reference type: issue or pr
          ref_kind: 'pr'
          # Kind ID (using workflow input)
          identifier: ${{ github.event.inputs.kind_id }}
          # Message content (using workflow input)
          message_content: ${{ github.event.inputs.message }}

      - name: Show Completion Message
        run: |
          echo "Status do Comentário: ${{ steps.commenter.outputs.completion-message }}"
````

## 📥 Inputs

| Name | Required | Description |
|---|---|---|
| `ref_kind` | Yes | The type of reference to comment on: must be `issue` or `pr`. |
| `identifier` | Yes | The Issue/PR identifier: number (e.g., `123`) or full URL (e.g., `${{ github.event.pull_request.html_url }}`). |
| `message_content` | No | The comment message body. **Note**: If not provided, the script will exit with an error because the underlying `gh` command requires content. |

## ⚙️ How It Works

Internally, this action calls a shell script that uses the [GitHub CLI](https://cli.github.com/) to **post a new comment** on the specified Issue or Pull Request.

**Script logic:**

```bash
# **ADJUST THE GH COMMAND HERE**
# Generic example:
gh "${REF_KIND}" comment "${IDENTIFIER}" --body "${MESSAGE_CONTENT}"
```

The script first validates that `ref_kind` is either 'pr' or 'issue'. If the `message_content` or other required parameters are missing, or if the `gh` command fails (e.g., due to insufficient permissions), the script exits with an error and exports a failure message.

## 🛡️ Security and Authentication

This Action uses the **GitHub CLI (`gh`)** to perform comment operations, and `gh` requires the authentication token to be provided through the **environment variable `GH_TOKEN`**.

**Recommended**: For most operations (in the current repository), use the default token **`${{ github.token }}`**. This is temporary and has limited permissions, which minimizes security risk. You will need to ensure the appropriate **write** permissions are set in the job (e.g., `pull-requests: write` or `issues: write`).

```yaml
env:
GH_TOKEN: ${{ github.token }}
````

**Advanced Operations/External Repositories**: If you need elevated permissions or access to external repositories (outside the workflow context), pass a **PAT** (Personal Access Token) stored as a **Secret**:

```yaml
env:
GH_TOKEN: ${{ secrets.MY_PAT_SECRET }}
````

**Never expose the PAT in plain text.**

## 📌 Notes

⚠️ Attention: Permissions Configuration

**It is crucial to set the correct `permissions` in your workflow job.**

  - To comment on **Pull Requests**, you must set `pull-requests: write`.
  - To comment on **Issues**, you must set `issues: write`.
  - The Action will fail with a permission error if the provided `GH_TOKEN` does not have the necessary scope to post the comment.

## 🔗 Related Documentation

- [GitHub Actions Contexts](https://docs.github.com/en/actions/learn-github-actions/contexts)
- [GitHub CLI `gh pr comment` command](https://cli.github.com/manual/gh_pr_comment)
- [GitHub CLI `gh issue comment` command](https://cli.github.com/manual/gh_issue_comment)

## ❓ Support

If you find a bug or have a question, [open an issue](https://github.com/ws2git/gh-commenter-action/issues).
