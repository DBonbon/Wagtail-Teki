name: Sync Company-Project to {{cookiecutter.project_name}}

on:
  workflow_call:

jobs:
  sync:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Install jq (for JSON parsing)
        run: sudo apt-get install -y jq

      - name: Make sync.sh executable
        run: chmod +x .github/workflows/sync.sh

      - name: Run sync script
        run: .github/workflows/sync.sh

      - name: Set up git for committing changes
        run: |
          git config user.name "github-actions"
          git config user.email "github-actions@github.com"

      - name: Push changes to a new branch
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          BRANCH_NAME="sync-changes-$(date +'%Y%m%d%H%M%S')"
          git checkout -b "$BRANCH_NAME"
          # Stage all changes, including the .github directory
          git add {{cookiecutter.project_name}}/ .github/
          # Commit the changes
          if git diff --cached --quiet; then
            echo "No changes to commit."
            exit 0
          fi
          git commit -m "Sync updates from Company-Project to {{cookiecutter.project_name}}"
          git push origin "$BRANCH_NAME"

      - name: Create Pull Request
        uses: peter-evans/create-pull-request@v4
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          branch: $BRANCH_NAME
          title: "Sync updates from Company-Project to {{cookiecutter.project_name}}"
          body: "This PR syncs changes from Company-Project to {{cookiecutter.project_name}}."
