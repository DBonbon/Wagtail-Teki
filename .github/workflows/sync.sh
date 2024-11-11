# sync.sh
# Syncs changes from Company-Project to cookiecutter while excluding placeholders

# Parse variables from cookiecutter.json
COOKIECUTTER_JSON="cookiecutter.json"
EXCLUDE_PATTERNS=()

# Read each key from cookiecutter.json and add to exclusion list
for key in $(jq -r 'keys_unsorted[]' "$COOKIECUTTER_JSON"); do
    EXCLUDE_PATTERNS+=("--exclude=*{{ cookiecutter.$key }}*")
done

# Sync with dynamic exclusions
rsync -av "${EXCLUDE_PATTERNS[@]}" Company-Project/ cookiecutter/
