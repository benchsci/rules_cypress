const {join, dirname, basename} = require('path');
const [cypressBin, entryModule] = process.argv.slice(2);

process.env.HOME = process.env['TEST_TMPDIR'];
process.env.CYPRESS_RUN_BINARY = join(process.cwd(), cypressBin);
process.env.ELECTRON_EXTRA_LAUNCH_ARGS = "--disk-cache-dir=/dev/null --disk-cache-size=0" 

process.chdir(dirname(entryModule))
require(join(process.cwd(), basename(entryModule)))