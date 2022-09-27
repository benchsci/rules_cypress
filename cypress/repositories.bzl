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
    """Convenience macro for users which does typical setup.

    - create a repository for each built-in platform like "cypress_linux_amd64" -
      this repository is lazily fetched when node is needed for that platform.
    - TODO: create a convenience repository for the host platform like "cypress_host"
    - create a repository exposing toolchains for each platform like "cypress_platforms"
    - register a toolchain pointing at each platform
    Users can avoid this macro and do these steps themselves, if they want more control.
    Args:
        name: base name for all created repos, like "cypress1_14"
        platform_to_integrity_hash: mapping from platform to integrity hash. 
          Platforms names are within cypress/private/toolchains_repo.bzl
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
