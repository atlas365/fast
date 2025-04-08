#!/bin/sh

NC='\033[0m'        # No Color
RED='\033[0;31m'    # Red
GREEN='\033[0;32m'  # Green
YELLOW='\033[0;33m' # Yellow
BLUE='\033[0;34m'   # Blue

subcommand=$1

sub_help() {
    echo "Usage: fast <command>"
    echo "Commands:"
    echo "  commit: Commit changes"
    echo "  push: Commit and push changes"
    echo "  fpush: Force push changes"
    echo "  cp: Cherry pick a commit"
    echo "  gateway: Start local gateway"
    echo "  ios_reset: Reset iOS"
    echo "  deep_link: Deep link to booted sim"
    echo "  mark_personal: mark this git repo as personal"
}

sub_commit() {
    branch=$(git branch --show-current)

    echo -e "${YELLOW}Commiting to branch ${BLUE}$branch${NC}"

    read -p $'\e[33mEnter commit message: \e[0m' message

    git add .

    git commit -m "$message"
}

sub_push() {
    branch=$(git branch --show-current)

    echo -e "${YELLOW}Pushing to branch ${BLUE}$branch${NC}"

    read -p $'\e[33mEnter commit message: \e[0m' message

    git add .

    git commit -m "$message"

    git push origin $branch --no-verify
}

sub_fpush() {
    branch=$(git branch --show-current)

    echo -e "${YELLOW}Pushing to branch ${BLUE}$branch${NC}"

    read -p $'\e[33mEnter commit message: \e[0m' message

    git add .

    git commit -m "$message"

    git push origin $branch --no-verify -f
}

sub_cp() {
    echo -e "${BLUE}Lets cherry pick!${NC}"

    read -p $'\e[33mEnter OTA version (eg: 10.10.10): \e[0m' version

    git fetch --prune
    git checkout "release/v$version"
    git pull

    read -p $'\e[33mEnter commit hash: \e[0m' commit

    git checkout -b "cherry-pick-$commit"

    git cherry-pick -x -s $commit

    git push --no-verify --set-upstream origin "cherry-pick-$commit"

    open "https://github.com/gopuff/theseus/compare/release/v$version...cherry-pick-$commit?expand=1"

}

sub_gateway() {
    echo -e "${BLUE}Starting local gateway${NC}"
    npx @gopuff/gateway start
}

sub_ios_reset() {
    nvm use && yarn clean && yarn install && yarn reset:ios && yarn start
}

sub_deep_link() {
    echo -e "${BLUE}Deep linking${NC}"
    read -p $'\e[33mEnter deep link: \e[0m' link
    xcrun simctl openurl booted "gopuff://$link"
}

sub_mark_personal() {
    echo -e "${BLUE}Marking repo as personal${NC}"
    git config core.sshCommand "ssh -F ~/.ssh/config-personal"
}

case $subcommand in
"" | "-h" | "--help")
    sub_help
    ;;
*)
    shift
    sub_${subcommand} $@
    if [ $? = 127 ]; then
        echo "Error: '$subcommand' is not a known subcommand." >&2
        exit 1
    fi
    ;;
esac
