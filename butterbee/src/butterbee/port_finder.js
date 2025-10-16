import { Ok, Error } from "./gleam.mjs";
import * as net from "net";

export function new_port() {
	return new Promise((resolve) => {
		const server = net.createServer();

		server.listen(0, "127.0.0.1", () => {
			const port = server.address().port;
			server.close(() => {
				resolve(new Ok(port));
			});
		});

		server.on("error", (err) => {
			resolve(new Error(new BindError(err.message)));
		});
	});
}
