const cypress = require('cypress')

cypress.run({
  spec: "basic.cy.js",
  headless: true,
}).then(result => {
  if (result.status === 'failed') {
    process.exit(1);
  }
})