# Dev workflow
Build with build.sh
Run with run.sh

# Release Workflow
Merge a branch to playtechnique/websites, it'll build and deploy. Sweet.

# Generate a new post
`hugo new content/projects/<project>/<article>.md`

For example:
`hugo new content/projects/github-actions-controller/investigating-the-codebase.md`

# CI Setup
* git-crypt secret is base64 encoded. If you generate a new one, add it to this repo's secrets with 
`git-crypt export-key - | base64 | pbcopy`
