# Declare the local Bazel workspace.
workspace(name = "aspect_rules_cypress")

load(":internal_deps.bzl", "rules_cypress_internal_deps")

# Fetch deps needed only locally for development
rules_cypress_internal_deps()

load("@aspect_rules_cypress//cypress:dependencies.bzl", "rules_cypress_dependencies")

# Fetch dependencies which users need as well
rules_cypress_dependencies()

load("@aspect_bazel_lib//lib:repositories.bzl", "aspect_bazel_lib_dependencies")

aspect_bazel_lib_dependencies()

load("@rules_nodejs//nodejs:repositories.bzl", "DEFAULT_NODE_VERSION", "nodejs_register_toolchains")

nodejs_register_toolchains(
    name = "nodejs",
    node_version = DEFAULT_NODE_VERSION,
)

load("@aspect_rules_cypress//cypress:repositories.bzl", "cypress_register_toolchains")

cypress_register_toolchains(
    name = "cypress",
    cypress_version = "10.8.0",
)

# For running our own unit tests
load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

############################################
# Gazelle, for generating bzl_library targets
load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")
load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")

go_rules_dependencies()

go_register_toolchains(version = "1.17.2")

gazelle_dependencies()

load("@aspect_rules_js//npm:npm_import.bzl", "npm_translate_lock")

npm_translate_lock(
    name = "npm",
    pnpm_lock = "@aspect_rules_cypress//cypress/tests:pnpm-lock.yaml",
    pnpm_version = "6.32.19",
    verify_node_modules_ignored = "@aspect_rules_cypress//:.bazelignore",
)

load("@npm//:repositories.bzl", "npm_repositories")

npm_repositories()
