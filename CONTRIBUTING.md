# Contributing

## Running the tests

Unit tests need only the `test` group, so you can skip the `integration` group
and its git and third-party gem sources:

```shell
bundle config set --local without integration
bundle install
```

| Command | What it does |
| --- | --- |
| `bundle exec rake unit` | The unit suite, all spec files in one process |
| `bundle exec rake unit:isolated` | Every spec file in its own process |
| `bundle exec rake unit:coverage` | The unit suite with a coverage report in `coverage/` |
| `bundle exec rake style` | Cookstyle |
| `bundle exec rake verify` | The three checks that gate a merge: `unit`, `unit:isolated`, `style` |
| `bundle exec rake features` | The Cucumber acceptance suite, which is slower and needs more setup |

### Why `unit:isolated` exists

`rake unit` loads every spec file into a single process, so a spec can use a
constant that a *different* spec happened to require first. That hides missing
requires in the library itself: plugins routinely do `require "kitchen/shell_out"`
rather than requiring all of `kitchen`, and they hit errors we never see.

`rake unit:isolated` runs each spec file on its own and fails if any of them
cannot stand alone. If it fails, the fix is almost always a missing `require`
in `lib/`, not in the spec.

### Coverage

`rake unit:coverage` writes an HTML report to `coverage/` and fails if coverage
falls below the minimum set in `spec/spec_helper.rb`. That minimum is a
ratchet: raise it as coverage improves, and don't lower it to make a build
pass.

## Release Process

This release process applies to all Test Kitchen projects, but each project may have additional requirements.

1. Perform a GitHub diff between main and the last released version. Determine whether included PRs justify a patch, minor or major version release.
2. Check out the main branch of the project being prepared for release.
3. Branch into a release-branch of the form `150_release_prep`.
4. Modify the `version.rb` file to specify the version for releasing.
5. Run `rake changelog` to regenerate the changelog.
6. `git commit` the `version.rb` and `CHANGELOG.md` changes to the branch and setup a PR for them. Allow the PR to run any automated tests and review the CHANGELOG for accuracy.
7. Merge the PR to main after review.
8. Switch your local copy to the main branch and `git pull` to pull in the release preparation changes.
9. Run `rake release` on the main branch.
10. Modify the `version.rb` file and bump the patch or minor version, and commit/push.
