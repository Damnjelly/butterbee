import { Result$Ok, Result$Error } from "../gleam.mjs";
import { spawnSync } from "child_process";

export function new_port() {
	const startPort = 3000;
	const maxPort = 60000;

	// This is very cursed
	const script = `
    const net = require('net');
    (async () => {
      function isFree(port) {
        return new Promise(r => {
          const s = net.createServer()
            .once('error', () => r(false))
            .once('listening', () => s.close(() => r(true)))
            .listen(port, '0.0.0.0');
        });
      }
      for (let p = ${startPort}; p <= ${maxPort}; p++) {
        if (await isFree(p)) {
          console.log(p);
          process.exit(0);
        }
      }
      process.exit(1);
    })();
  `;

	const result = spawnSync(process.execPath, ['-e', script], { encoding: 'utf8' });

	if (result.status !== 0) {
		return Result$Error(new Error(result.stderr || "no free port found"));
	}

	const port = parseInt(result.stdout.trim(), 10);
	if (!Number.isFinite(port)) {
		return Result$Error(new Error(`invalid output: ${result.stdout}`));
	}

	return Result$Ok(port);
}
