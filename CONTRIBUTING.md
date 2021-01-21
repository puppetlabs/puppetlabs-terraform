# Contributing to Puppet modules

So you want to contribute to a Puppet module? Great! Follow our guidelines
to familiarize yourself with our expectations around code quality, and learn some tips
to make the contribution process as easy as possible.

## Community Slack channels

Join the `#bolt` channel in the [Puppet community
Slack](https://slack.puppet.com/) where Bolt developers and community members
who use and contribute to Bolt discuss the tool.

## Getting started

- Fork the module repository on GitHub and clone to your workspace.
- Make your changes!

## Commit checklist

### The basics

- My commit is a single logical unit of work.
- I have checked for unnecessary whitespace with `git diff --check`.
- My commit does not include commented out code or unneeded files.

### The content

- My commit includes tests for the bug I fixed or feature I added.
- My commit includes appropriate documentation changes if it is introducing a
  new feature or changing existing functionality.
- My code passes existing test suites.

### The commit message

- The first line of my commit message includes:
  - An issue number (if applicable). For example, `(GH-xxxx) This is the first line`.
  - A short description (50 characters is the soft limit, excluding ticket
    number(s)).
- The body of my commit message:
  - Is meaningful.
  - Uses the imperative, present tense: "change", not "changed" or "changes".
  - Includes motivation for the change, and contrasts its implementation with
    the previous behavior.

## Testing

### Getting started

Our Puppet modules provide [`Gemfile`](./Gemfile)s, which can tell a Ruby
package manager such as [bundler](http://bundler.io/) what Ruby packages, or
gems, are required to build, develop, and test this software.

Please make sure you have [bundler
installed](http://bundler.io/#getting-started) on your system, and use it
to install all dependencies needed for this project in the project root by
running:

```shell
$ bundle install --path .bundle/gems
```

> **NOTE:** some systems may require you to run this command with sudo.

If you already have those gems installed, make sure they are up to date:

```shell
$ bundle update
```

### Running tests

With all dependencies in place and up to date, run the tests:

```shell
$ bundle exec rake spec
```

This executes all the [RSpec tests](http://rspec-puppet.com/) in the directories
defined
[here](https://github.com/puppetlabs/puppetlabs_spec_helper/blob/699d9fbca1d2489bff1736bb254bb7b7edb32c74/lib/puppetlabs_spec_helper/rake_tasks.rb#L17)
and so on. RSpec tests may have the same kind of dependencies as the module they
are testing. Although the module defines these dependencies in its
[metadata.json](./metadata.json), RSpec tests define them in
[.fixtures.yml](./fixtures.yml).

## Submission

### Pre-requisites

- Make sure you have a [GitHub account](https://github.com/join).
- [Open an
  issue](https://github.com/puppetlabs/puppetlabs-terraform/issues/new/choose)
  or [track an
  issue](https://github.com/puppetlabs/puppetlabs-terraform/issues) you are
  patching.

### Push and pull request

- Push your changes to your fork.
- [Open a Pull
  Request](https://github.com/puppetlabs/puppetlabs-terraform/compare)
  against the repository.

## More about commits 

### Make separate commits for logically separate changes.

Please break your commits down into logically consistent units which include new
or changed tests relevant to the rest of the change. The goal of doing this is
to make the diff easier to read for whoever is reviewing your code. In general,
the easier your diff is to read, the more likely someone will be happy to review
it and get it into the code base.

If you are going to refactor a piece of code, please do so as a separate commit
from your feature or bug fix changes.

We also really appreciate changes that include tests to make sure the bug is not
re-introduced, and that the feature is not accidentally broken in a future change.

Describe the technical detail of the change(s). If your description starts to
get too long, that is a good sign that you probably need to split up your commit
into more finely grained pieces.

A commit is much more likely to be merged with a minimum of 
bike-shedding or requested changes if you:
- Plainly describe the feature or patch that you're introducing
  with the intention of helping reviewers and future developers understand
  the code.
- Include information that will help reviewers to check and test your code.
- Include information in your commit message that would be suitable for 
  inclusion in the release notes for the version of Puppet that includes the 
  change.

Please also check that you are not introducing any trailing whitespace or other
"whitespace errors". You can do this by running `git diff --check` on your
changes before you commit.

### Sending your patches

To submit your changes via a GitHub pull request, we _highly_ recommend that you
have them on a topic branch, instead of directly on the `main` branch. It makes things much
easier to keep track of, especially if you decide to work on another thing
before your first change is merged in.

GitHub has some pretty good [general documentation](http://help.github.com/) on
using their site. They also have documentation on [creating pull
requests](https://help.github.com/articles/creating-a-pull-request-from-a-fork/).

In general, after pushing your topic branch up to your repository on GitHub, you
can switch to the branch in the GitHub UI and click "Pull Request" towards the
top of the page in order to open a pull request.

### Update the related GitHub issue.

If there is a GitHub issue associated with the change you submitted, link the
issue to your pull request.

## If you have commit access to the repository

Even if you have commit access to the repository, you still need to go through
the process above, and have someone else review and merge in your changes. The
rule is that _all changes must be reviewed by a project developer that did not
write the code to ensure that all changes go through a code review process._

The record of someone performing the merge is the record that they performed the
code review. Again, this should be someone other than the author of the topic
branch.

## Github resources

- [General GitHub documentation](http://help.github.com/)
- [GitHub pull request
  documentation](http://help.github.com/send-pull-requests/)
