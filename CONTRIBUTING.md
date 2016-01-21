# Release Process

This release process applies to all Test Kitchen projects, but each project may have additional requirements.

1. Perform a Github diff between master and the last released version.  Determine whether included PRs justify a patch, minor or major version release.
2. Check out the master branch of the project being prepared for release.
3. Branch into a release-branch of the form `150_release_prep`.
4. Modify the `version.rb` file to specify the version for releasing.
5. Update the changelog to include what is being released.
  1. For these projects we use [PimpMyChangelog](https://github.com/pcreux/pimpmychangelog).  All this does is make the CHANGELOG look pretty - for now we manually import the PRs / Issues and categorize them.
  2. Start a [diff](https://github.com/test-kitchen/test-kitchen/compare/v1.4.2...master) in Github between master and the last release
  3. Look for all the merged PRs and add them to the CHANGELOG.md under the appropriate category.  They should have the form `* PR #999: PR Description (@author)`.
  4. Install and run `pimpmychangelog`.  This should change all the PR numbers and @ mentions into links.
6. `git commit` the `version.rb` and `CHANGELOG.md` changes to the branch and setup a PR for them.  Allow the PR to run any automated tests and review the CHANGELOG for accuracy.
7. Merge the PR to master after review.
8. Switch your local copy to the master branch and `git pull` to pull in the release preperation changes.
9. Run `rake release` on the master branch.
