#!/usr/bin/env python3
"""
Manage pull request reviewers for Home Manager.

This script handles the reviewer management logic from the tag-maintainers workflow,
including checking for manually requested reviewers and managing removals.
"""

import argparse
import json
import subprocess
import sys


def run_gh_command(args: list[str]) -> str:
    """Run a GitHub CLI command and return the result."""
    try:
        result = subprocess.run(
            ["gh"] + args,
            capture_output=True,
            text=True,
            check=True,
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print(f"Error running gh command: {e}", file=sys.stderr)
        print(f"Stderr: {e.stderr}", file=sys.stderr)
        return ""


def get_manually_requested_reviewers(owner: str, repo: str, pr_number: int) -> list[str]:
    """Get reviewers who were manually requested by human users."""
    query = """
    query($owner: String!, $repo: String!, $prNumber: Int!) {
      repository(owner: $owner, name: $repo) {
        pullRequest(number: $prNumber) {
          timelineItems(first: 100, itemTypes: [REVIEW_REQUESTED_EVENT]) {
            nodes {
              ... on ReviewRequestedEvent {
                actor {
                  __typename
                  login
                }
                requestedReviewer {
                  ... on User {
                    login
                  }
                  ... on Bot {
                    login
                  }
                }
              }
            }
          }
        }
      }
    }
    """

    try:
        result = run_gh_command([
            "api", "graphql",
            "-f", f"query={query}",
            "-F", f"owner={owner}",
            "-F", f"repo={repo}",
            "-F", f"prNumber={pr_number}"
        ])

        if not result:
            return []

        data = json.loads(result)

        # Extract manually requested reviewers (exclude bots)
        manually_requested = []
        for node in data.get("data", {}).get("repository", {}).get("pullRequest", {}).get("timelineItems", {}).get("nodes", []):
            if not node or not node.get("actor", {}).get("login") or not node.get("requestedReviewer", {}).get("login"):
                continue

            actor_type = node["actor"]["__typename"]
            actor_login = node["actor"]["login"]
            reviewer = node["requestedReviewer"]["login"]

            # Only keep requests from User types (humans), skip all Bot types
            if actor_type == "User":
                manually_requested.append(reviewer)

        return sorted(set(manually_requested))

    except (json.JSONDecodeError, KeyError) as e:
        print(f"Error parsing GraphQL response: {e}", file=sys.stderr)
        return []


def get_pending_reviewers(pr_number: int) -> list[str]:
    """Get current pending reviewers for a PR."""
    try:
        result = run_gh_command([
            "pr", "view", str(pr_number),
            "--json", "reviewRequests",
            "--jq", ".reviewRequests[].login"
        ])
        return [r.strip() for r in result.split("\n") if r.strip()]
    except Exception as e:
        print(f"Error getting pending reviewers: {e}", file=sys.stderr)
        return []


def get_past_reviewers(owner: str, repo: str, pr_number: int) -> list[str]:
    """Get users who have already reviewed the PR."""
    try:
        result = run_gh_command([
            "api", f"repos/{owner}/{repo}/pulls/{pr_number}/reviews",
            "--jq", ".[].user.login"
        ])
        return sorted(set(r.strip() for r in result.split("\n") if r.strip()))
    except Exception as e:
        print(f"Error getting past reviewers: {e}", file=sys.stderr)
        return []


def remove_reviewers(owner: str, repo: str, pr_number: int, reviewers: list[str], reason: str) -> bool:
    """Remove reviewers from a PR."""
    if not reviewers:
        return True

    for reviewer in reviewers:
        print(f"Removing review request from {reviewer} ({reason})", file=sys.stderr)
        try:
            payload = json.dumps({"reviewers": [reviewer]})
            result = subprocess.run([
                "gh", "api", "--method", "DELETE",
                f"repos/{owner}/{repo}/pulls/{pr_number}/requested_reviewers",
                "--input", "-"
            ], input=payload, text=True, check=True, capture_output=True)
        except subprocess.CalledProcessError as e:
            print(f"Error removing reviewer {reviewer}: {e}", file=sys.stderr)
            return False

    return True


def is_collaborator(owner: str, repo: str, username: str) -> bool:
    """Check if a user is a collaborator on the repository."""
    try:
        result = subprocess.run([
            "gh", "api", f"repos/{owner}/{repo}/collaborators/{username}",
            "--silent"
        ], capture_output=True, check=True)
        return True
    except subprocess.CalledProcessError as e:
        # HTTP 404 means user is not a collaborator or doesn't exist
        if e.returncode == 1:
            return False
        # Other errors should be logged
        print(f"Error checking collaborator status for {username}: {e}", file=sys.stderr)
        return False


def add_reviewers(pr_number: int, reviewers: list[str]) -> bool:
    """Add reviewers to a PR."""
    if not reviewers:
        return True

    reviewers_csv = ",".join(reviewers)
    print(f"Requesting reviews from: {reviewers_csv}", file=sys.stderr)

    try:
        run_gh_command([
            "pr", "edit", str(pr_number),
            "--add-reviewer", reviewers_csv
        ])
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error adding reviewers: {e}", file=sys.stderr)
        return False


def main() -> None:
    """Main function to handle command line arguments and run reviewer management."""
    parser = argparse.ArgumentParser(
        description="Manage pull request reviewers for Home Manager"
    )
    parser.add_argument("--owner", required=True, help="Repository owner")
    parser.add_argument("--repo", required=True, help="Repository name")
    parser.add_argument("--pr-number", type=int, required=True, help="Pull request number")
    parser.add_argument("--pr-author", required=True, help="PR author username")
    parser.add_argument("--current-maintainers", help="Space-separated list of current maintainers")
    parser.add_argument("--no-module-files", action="store_true", help="No module files changed")

    args = parser.parse_args()

    current_maintainers = args.current_maintainers.split() if args.current_maintainers else []

    # Get current state
    pending_reviewers = get_pending_reviewers(args.pr_number)
    past_reviewers = get_past_reviewers(args.owner, args.repo, args.pr_number)
    manually_requested = get_manually_requested_reviewers(args.owner, args.repo, args.pr_number)

    print(f"Pending reviewers: {' '.join(pending_reviewers)}", file=sys.stderr)
    print(f"Past reviewers: {' '.join(past_reviewers)}", file=sys.stderr)
    print(f"Manually requested: {' '.join(manually_requested)}", file=sys.stderr)

    # Handle case where no module files changed
    if args.no_module_files:
        if pending_reviewers:
            # Remove only bot-requested reviewers
            reviewers_to_remove = [r for r in pending_reviewers if r not in manually_requested]
            if reviewers_to_remove:
                print(f"Removing bot-requested reviewers: {' '.join(reviewers_to_remove)}", file=sys.stderr)
                remove_reviewers(args.owner, args.repo, args.pr_number, reviewers_to_remove, "no module files changed")
            else:
                print("No reviewers to remove (all were manually requested)", file=sys.stderr)
        return

    # Remove outdated reviewers (preserve manually requested ones)
    if current_maintainers and pending_reviewers:
        outdated_reviewers = [r for r in pending_reviewers if r not in current_maintainers]
        if outdated_reviewers:
            print(f"Found outdated reviewers: {' '.join(outdated_reviewers)}", file=sys.stderr)
            # Only remove outdated reviewers that weren't manually requested
            safe_to_remove = [r for r in outdated_reviewers if r not in manually_requested]
            if safe_to_remove:
                print(f"Removing outdated bot-requested reviewers: {' '.join(safe_to_remove)}", file=sys.stderr)
                remove_reviewers(args.owner, args.repo, args.pr_number, safe_to_remove, "no longer a maintainer of changed files")
            else:
                print("No outdated reviewers to remove (all were manually requested)", file=sys.stderr)

    # Add new reviewers
    if current_maintainers:
        users_to_exclude = set(pending_reviewers + past_reviewers)
        new_reviewers = []

        for maintainer in current_maintainers:
            if maintainer in users_to_exclude or maintainer == args.pr_author:
                continue

            if is_collaborator(args.owner, args.repo, maintainer):
                new_reviewers.append(maintainer)
            else:
                print(f"User {maintainer} is not a repository collaborator, ignoring", file=sys.stderr)

        if new_reviewers:
            add_reviewers(args.pr_number, new_reviewers)
        else:
            print("No new reviewers to add", file=sys.stderr)


if __name__ == "__main__":
    main()
