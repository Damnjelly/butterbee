import { spawn } from 'child_process';

export function runBrowser(cmd, flags, profileDir) {
	spawn(cmd, flags, {
		cwd: profileDir,
		detached: true,
		stdio: 'ignore',
		shell: false,
		windowsHide: true
	}).unref();
}
