const {join, dirname, basename} = require('path');
const [cypressBin, entryModule] = process.argv.slice(2);

// Cypress attempts to create files in the HOME directory on OS X. Set HOME to a writable directory.
process.env.HOME = process.env['TEST_TMPDIR'];
process.env.CYPRESS_RUN_BINARY = join(process.cwd(), cypressBin);

process.chdir(dirname(entryModule))
require(join(process.cwd(), basename(entryModule)))