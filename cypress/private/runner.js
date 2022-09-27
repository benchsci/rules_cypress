const {join, dirname, basename} = require('path');
const [cypressBin, entryModule] = process.argv.slice(2);

process.env.HOME = process.env['TEST_TMPDIR'];
process.env.CYPRESS_RUN_BINARY = join(process.cwd(), cypressBin);

process.chdir(dirname(entryModule))
require(join(process.cwd(), basename(entryModule)))