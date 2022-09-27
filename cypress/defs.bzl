"Public API re-exports"


load("@aspect_rules_cypress//cypress/private:cypress_test.bzl", "lib")
load("@aspect_rules_js//js:libs.bzl", "js_binary_lib")

_cypress_test = rule(
    doc = """Runs tests against the Cypress test runner.""",
    attrs = lib.attrs,
    implementation = lib.implementation,
    test = True,
    toolchains = js_binary_lib.toolchains + ["@aspect_rules_cypress//cypress:toolchain_type"],
)

def cypress_test(name, runner, **kwargs):
    _cypress_test(
        name = name,
        enable_runfiles = select({
            "@aspect_rules_js//js/private:enable_runfiles": True,
            "//conditions:default": False,
        }),
        entry_point = "@aspect_rules_cypress//cypress/private:runner",
        data = kwargs.pop("data", []) + [
            runner
        ],
        runner = runner,
        **kwargs
    )