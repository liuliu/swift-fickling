load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository", "new_git_repository")

def _maybe(repo_rule, name, **kwargs):
    """Executes the given repository rule if it hasn't been executed already.
    Args:
      repo_rule: The repository rule to be executed (e.g., `http_archive`.)
      name: The name of the repository to be defined by the rule.
      **kwargs: Additional arguments passed directly to the repository rule.
    """
    if not native.existing_rule(name):
        repo_rule(name = name, **kwargs)

def swift_fickling_deps():
    """Loads common dependencies needed to compile the swift-fickling library."""

    _maybe(
        new_git_repository,
        name = "SwiftCollections",
        build_file = "@swift-fickling//:external/swift-collections.BUILD",
        commit = "9bf03ff58ce34478e66aaee630e491823326fd06",
        remote = "https://github.com/apple/swift-collections.git",
    )

