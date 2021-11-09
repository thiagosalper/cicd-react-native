# Doc
# https://developer.github.com/v3/pulls/reviews/#list-reviews-on-a-pull-request

set -e

# VERIFICACAO DE AMBIENTE 

if [[ -z "$GITHUB_TOKEN" ]]; then
  echo "Configure GITHUB_TOKEN."
  exit 1
fi

if [[ -z "$GITHUB_REPOSITORY" ]]; then
  echo "Configure GITHUB_REPOSITORY."
  exit 1
fi

if [[ -z "$GITHUB_EVENT_PATH" ]]; then
  echo "Configure GITHUB_EVENT_PATH."
  exit 1
fi

# CONSTS REQUEST

URI="https://api.github.com"
API_HEADER="Accept: application/vnd.github.v3+json"
AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"
action=$(jq --raw-output .action "$GITHUB_EVENT_PATH")
state=$(jq --raw-output .review.state "$GITHUB_EVENT_PATH")
number=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")

# METODO 

approves_count() {
  body=$(curl -sSL -H "${AUTH_HEADER}" -H "${API_HEADER}" "${URI}/repos/${GITHUB_REPOSITORY}/pulls/${number}/reviews?per_page=100")
  reviews=$(echo "$body" | jq --raw-output '.[] | {state: .state} | @base64')

  approvals=0

  for r in $reviews; do
    review="$(echo "$r" | base64 -d)"
    rState=$(echo "$review" | jq --raw-output '.state')

    if [[ "$rState" == "APPROVED" ]]; then
      approvals=$((approvals+1))
    fi
  done
  
  echo "approvals_count=$approvals" >> $GITHUB_ENV
}

# INICIALIZA

if [[ "$action" == "submitted" ]] && [[ "$state" == "approved" ]]; then
  approves_count
else
  echo "Evento ignorado ${action}/${state}"
fi