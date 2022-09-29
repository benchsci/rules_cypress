"""Declare runtime dependencies

These are needed for local dev, and users must install them as well.
See https://docs.bazel.build/versions/main/skylark/deploying.html#dependencies
"""

load("//cypress/private:toolchains_repo.bzl", "PLATFORMS", "toolchains_repo")

########
# Remaining content of the file is only used to support toolchains.
########
_DOC = "Fetch external tools needed for cypress toolchain"
_ATTRS = {
    "cypress_version": attr.string(mandatory = True),
    "platform": attr.string(mandatory = True, values = PLATFORMS.keys()),
    "integrity": attr.string(),
}

def _cypress_repo_impl(repository_ctx):
    url = "https://cdn.cypress.io/desktop/{0}/{1}/cypress.zip".format(
        repository_ctx.attr.cypress_version,
        repository_ctx.attr.platform,
    )
    repository_ctx.download_and_extract(
        url = url,
        integrity = repository_ctx.attr.integrity,
    )
    binary_state_json_contents = '{"verified": true}'
    repository_ctx.file("binary_state.json", binary_state_json_contents)

    build_content = """#Generated by cypress/repositories.bzl
load("@aspect_rules_cypress//cypress:toolchain.bzl", "cypress_toolchain")

filegroup(
    name = "files",
    srcs = select({
        "@bazel_tools//src/conditions:darwin": ["Cypress.app"],
        "//conditions:default": ["Cypress"],
    }) + ["binary_state.json"],
    visibility = ["//visibility:public"],
)

cypress_toolchain(
    name = "cypress_toolchain", 
    target_tool = select({
        "@bazel_tools//src/conditions:darwin": "Cypress.app/Contents/MacOS/Cypress",
        "//conditions:default": "Cypress/Cypress",
    }),
    target_tool_files = ":files",
)
"""

    # Base BUILD file for this repository
    repository_ctx.file("BUILD.bazel", build_content)

cypress_repositories = repository_rule(
    _cypress_repo_impl,
    doc = _DOC,
    attrs = _ATTRS,
)

# Wrapper macro around everything above, this is the primary API
def cypress_register_toolchains(name, platform_to_integrity_hash = {}, **kwargs):
    """
    Convenience macro for setting up cypress toolchain for all supported platforms.

    - create a repository for each built-in platform like "cypress_linux-x64" -
      this repository is lazily fetched when node is needed for that platform.

    Args:
        name: base name for all created repos, like `cypress` or `cypress_10_1`
        platform_to_integrity_hash: Mapping from platform to integrity file hash

            Valid platform values are: darwin-x64, darwin-arm64, linux-x64 and linux-arm64. See @aspect_rules_cypress//cypress/private:toolchains_repo.bzl

            To download a binary to compute its integrity hash, see https://docs.cypress.io/guides/references/advanced-installation#Download-URLs

            Once downloaded, run `shasum -a 256` to get the integrity hash
        **kwargs: passed to each node_repositories call
    """
    for platform in PLATFORMS.keys():
        cypress_repositories(
            name = name + "_" + platform,
            platform = platform,
            **kwargs
        )
        native.register_toolchains("@%s_toolchains//:%s_toolchain" % (name, platform))

    toolchains_repo(
        name = name + "_toolchains",
        user_repository_name = name,
    )
