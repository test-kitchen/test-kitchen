# Release Process

This release process applies to all Test Kitchen projects, but each project may have additional requirements.

1. Perform a Github diff between master and the last released version.  Determine whether included PRs justify a patch, minor or major version release.
2. Check out the master branch of the project being prepared for release.
3. Branch into a release-branch of the form `150_release_prep`.
4. Modify the `version.rb` file to specify the version for releasing.
5. Run `rake changelog` to regenerate the changelog.
6. `git commit` the `version.rb` and `CHANGELOG.md` changes to the branch and setup a PR for them.  Allow the PR to run any automated tests and review the CHANGELOG for accuracy.
7. Merge the PR to master after review.
8. Switch your local copy to the master branch and `git pull` to pull in the release preparation changes.
9. Run `rake release` on the master branch.
10. Modify the `version.rb` file and bump the patch or minor version, and commit/push.
