# Contribution Rules

## General Help/Support

If you're struggling to use JSONModel, the following options are available to
you:

- read the [readme](README.md) in detail
- check out [StackOverflow](https://stackoverflow.com/questions/tagged/jsonmodel)

You should not open an issue on GitHub if you are simply struggling to
understand JSONModel. Issues are only for bugs and feature requests.

## Issues

### Bugs

First and foremost - you must be running the latest version of JSONModel. No
support will be offered if you are running anything other than the latest.
Even if you think you're on the latest version, please quickly check for any new
releases.

First, create the smallest/simplest possible example which exhibits the bug.

Then open an issue providing the following code:

- the JSON you're (de)serializing
- your model class(es) - both interface and implementation
- the code you're running

Then explain:

- what you expected to happen
- what actually happened
- what debugging steps you have taken
- any additional context/details

Remember: if we can't reproduce the problem, we can't fix it. If we aren't able
to replicate, your issue will be closed.

Please also consider opening a pull request with the fix, if you are able.

### Improvements

Feel free to open an issue requesting a change. Provide the following details:

- what JSONModel should do
- why this would be helpful (use cases, etc.)
- why the existing code is insufficient
- an example of how it could work

The maintainers are quite opinionated about what JSONModel should/shouldn't do,
so be aware that we may not agree with you.

Assuming we agree on a way forward for the change, please consider opening a
pull request with the implementation.

## Pull Requests

### Bugs

Before fixing the bug, you must write a unit test which fails, but should pass.
After that, write the relevant code to fix the bug. Ensure that all tests pass
on **all** platforms.

Then please open a pull request with the changes. If you haven't added unit
any tests to cover the bug, or the tests don't pass, your PR _will not_ be
merged.

Please also provide the same details as above.

### Improvements

For any complex changes, please open an issue to discuss the changes before
implementing them. If you implement before discussion, there is a chance that
we will disagree and decide not to merge.

Please also provide the same details as above.
