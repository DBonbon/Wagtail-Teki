# Automated Sync of Company-Project to {{cookiecutter.project_name}} in GitHub Actions

To split the workflow into two separate scripts, sync.yml and test.yml, you can simplify the main workflow by creating a "dispatcher" file, main.yml, which triggers both sub-workflows. Here’s how to structure it:

**1. main.yml (Trigger and dispatcher workflow)**

This will trigger on push and sequentially call sync.yml and test.yml.
```
name: Main Workflow Dispatcher

on: [push, pull_request]

jobs:
  sync_job:
    uses: ./.github/workflows/sync.yml  # References sync.yml in the workflows directory

  test_job:
    needs: sync_job  # Runs after sync_job completes
    uses: ./.github/workflows/test.yml  # References test.yml in the workflows directory
```

2. sync.yml (Sync task)

Create .github/workflows/sync.yml, which will only handle the sync process.
```
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

      # Optionally, push changes to a new branch and create a PR if necessary
      - name: Set up git for committing changes
        run: |
          git config user.name "github-actions"
          git config user.email "github-actions@github.com"

      - name: Push changes to a new branch
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          git checkout -b sync-changes
          git add {{cookiecutter.project_name}}/
          git commit -m "Sync updates from Company-Project to {{cookiecutter.project_name}}"
          git push origin sync-changes

      - name: Create Pull Request
        uses: peter-evans/create-pull-request@v4
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          branch: sync-changes
          title: "Sync updates from Company-Project to {{cookiecutter.project_name}}"
          body: "This PR syncs changes from Company-Project to {{cookiecutter.project_name}}."
```

**3. test.yml (Testing tasks)**

Create .github/workflows/test.yml for running your testing tasks.
```
name: Test Company-Project

on:
  workflow_call:

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        experimental_use_app_router: [
          {name: "Page router", value: "False"},
          {name: "App router", value: "True"},
        ]

    steps:
      - uses: actions/checkout@v4

      - name: Install jq
        run: sudo apt-get install -y jq

      # Set up Docker Compose
      - name: Set up Docker Compose
        run: |
          LATEST_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.tag_name')
          sudo curl -L "https://github.com/docker/compose/releases/download/$LATEST_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
          sudo chmod +x /usr/local/bin/docker-compose
          docker-compose --version
        shell: bash

      # Continue with testing steps
      - uses: "actions/setup-python@v5"
        with:
          python-version: "3.11"
      - name: Install cookiecutter
        run: |
          python -m pip install --upgrade pip
          pip install cookiecutter
      - name: Cleanup
        run: |
          set -x
          rm -rf Company-Project
      - name: Run cookiecutter
        run: |
          cookiecutter . --no-input experimental_use_app_router=${{ matrix.experimental_use_app_router.value }}
      - name: Create docker-compose config for running boilerplate tests
        run: |
          cp docker-compose-ci.yml Company-Project/docker-compose-ci.yml
      - name: Build image
        run: |
          cd Company-Project
          chmod +x src/docker-entrypoint.sh
          docker-compose -f ../docker-compose-ci.yml build
      - name: Verify backend scaffolder
        run: |
          cd Company-Project
          set -x
          docker-compose -f ../docker-compose-ci.yml run --rm python python manage.py new_page --name=Article
      - name: Run tests on container
        run: |
          cd Company-Project
          docker-compose -f ../docker-compose-ci.yml run --rm python test
          docker-compose -f ../docker-compose-ci.yml run --rm python typecheck
          docker-compose -f ../docker-compose-ci.yml run --rm python lint
      - name: Run frontend tests
        run: |
          cd Company-Project/frontend
          npm ci
          npm run test:ci
          IGNORE_SENTRY=1 npm run build
          npm run build-storybook
```
4. sync.sh should be like:
```
#!/bin/bash
# sync.sh
# Syncs changes from Company-Project to {{cookiecutter.project_name}} and confirms only actual content changes

echo "Starting sync process..."
pwd

SOURCE="Company-Project/"
DEST="{{cookiecutter.project_name}}/"
COOKIECUTTER_JSON="cookiecutter.json"
EXCLUDE_PATTERNS=()

# Read cookiecutter.json and exclude relevant paths
for key in $(jq -r 'keys_unsorted[]' "$COOKIECUTTER_JSON"); do
    EXCLUDE_PATTERNS+=("--exclude=*{{ cookiecutter.$key }}*")
done

# Run rsync with specified exclusions
rsync -ac --filter='merge Company-Project/.rsync-filter' "${EXCLUDE_PATTERNS[@]}" "$SOURCE" "$DEST" > /dev/null
echo "rsync completed."

# Log recently modified files to verify sync
echo "Files recently modified in {{cookiecutter.project_name}}:"
find "$DEST" -type f -printf '%T+ %p\n' | sort -r | head -20

```
Explanation of Structure

    main.yml: Acts as the dispatcher. It triggers both sync.yml and test.yml workflows sequentially.
    sync.yml: Manages the synchronization of Company-Project to {{cookiecutter.project_name}} and pushes changes if necessary.
    test.yml: Executes the tests after the sync job finishes.
