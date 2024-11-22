# git action with rsync and test


the test action remain intact. 

the rest modify the main.yml to dispach sync and test
where the sycn calls sync.sh

these scripts wre used to base test for rsync. mainly they failed

**main.yml**

```
name: Main Workflow Dispatcher

on: [push, pull_request]

jobs:
  setup_docker:
    runs-on: ubuntu-latest
    steps:
      - name: Install Docker Compose
        run: |
          sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.tag_name')/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
          sudo chmod +x /usr/local/bin/docker-compose
          docker-compose --version

  sync_job:
    needs: setup_docker
    uses: ./.github/workflows/sync.yml  # References sync.yml in the workflows directory

  test_job:
    needs: sync_job  # Runs after sync_job completes
    uses: ./.github/workflows/test.yml  # References test.yml in the workflows directory

```

**sync.yml**

this only rsync it doesn't keep the cookiecutter vars so 
there's a need for jq if at all read the cookiecutter_sync.md

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

      - name: Commit and Push Changes to Main
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          git config user.name "github-actions"
          git config user.email "github-actions@github.com"
          git add {{cookiecutter.project_name}}/
          if git diff --cached --quiet; then
            echo "No changes to commit."
            exit 0
          fi
          git commit -m "Sync updates from Company-Project to {{cookiecutter.project_name}}"
          git push origin main
 
```


**test.yml**
remain intact as the current main


**sync.sh**
again, doesn't exclude cookiecutter vars

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

**.rsync-filter**

just updated :

```
# Exclude specific directories
- src/media/
- frontend/.next/
- frontend/node_modules/
- src/static/django_extensions/
- src/static/wagtail_localize/
- deploy/deploy_keys/
- deploy/group_vars/

# Exclude Python compiled files and cache
- src/**/__pycache__/
- src/**/*.pyc

# Exclude sensitive files
- **/.env
- **/.env.local

# Exclude specific templates
- src/main/templates/500.html
- src/main/templates/email/test_send.txt
- src/main/templates/partials/sentry.html
- src/pipit/templates/commands/new-page/

# Exclude specific deploy files
- deploy/files/uwsgi.ini.j2

# Exclude specific file types
- **/*.tpi

# Exclude the .rsync-filter file itself
- .rsync-filter

```


current gaol is to:
I want to test the retrocookie. to verify explore how feasable is this attitude. mai9nly, I wish to figure out, if this is a. quick and simple to set up and apply. I have a Company-Project, and a cookiecutter template under the same root. I have cookiecutter.json also under the root. currently the project it up and running I can push it and modify the company-project to test changes in the template. What i need here is to understand. what is the workflow, how to set it up, and time estimation to make it functional. I have never used Retrocookie. 
