#!/usr/bin/env bash
# This script doesn't support inviting children of fork-ed repository as collaborators

if [ -z "$GITHUB_ACCESS_TOKEN" ]; then
  echo "Please set 'GITHUB_ACCESS_TOKEN' and give 'repo:invite'"
  exit 1
fi

if ! command -v jq &> /dev/null
then
  echo "Please install 'jq'"
  exit 1
fi

GITHUB_OWNER=${OWNER:=jongyoul}
GITHUB_REPO=${REPO:=cnu-lab}

GITHUB_API='https://api.github.com'
GITHUB_API_REPO="${GITHUB_API}/repos/${GITHUB_OWNER}/${GITHUB_REPO}"

FORKS=$( curl -s ${GITHUB_API_REPO}/forks?per_page=100 | jq '.[] | .owner.login' )

for fork in $FORKS
do
  user=$( echo $fork | sed -e 's/"//g' )
  echo -n "${user}: "
  curl -s -o /dev/null -w "%{http_code}\n" -X PUT -H "Accept: application/vnd.github.v3+json" -H "Authorization: token ${GITHUB_ACCESS_TOKEN}" ${GITHUB_API_REPO}/collaborators/${user} -d '{"permission":"permission"}' 
done
