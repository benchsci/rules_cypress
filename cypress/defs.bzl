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
    """cypress_test creates a node environment which is hooked up to the cypress toolchain.

    The environment is bootstrapped by first setting the environment variable `CYPRESS_RUN_BINARY` to the binary downloaded by the cypress toolchain. See https://docs.cypress.io/guides/references/advanced-installation#Run-binary

    After the setting up environment variables, the node program then calls `require` on the `.js` test runner you provide as an attribute. That test runner is expected to call into cypress's module API to bootstrap testing.

    Example `runner.js`:
    ```
    const cypress = require('cypress')

    cypress.run({
    headless: true,
    }).then(result => {
    if (result.status === 'failed') {
        process.exit(1);
    }
    })
    ```

    Args:
        name: The name used for this rule and output files
        runner: JS file to call into the cypress module api
            See https://docs.cypress.io/guides/guides/module-api
        **kwargs: All other args from `js_test`. See https://github.com/aspect-build/rules_js/blob/main/docs/js_binary.md#js_test
    """
    _cypress_test(
        name = name,
        enable_runfiles = select({
            "@aspect_rules_js//js/private:enable_runfiles": True,
            "//conditions:default": False,
        }),
        entry_point = "@aspect_rules_cypress//cypress/private:runner",
        data = kwargs.pop("data", []) + [
            runner,
        ],
        runner = runner,
        **kwargs
    )
