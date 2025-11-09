// From https://github.com/bwireman/delay
export function delay(milliseconds) {
	const fin = Date.now() + milliseconds;

	while (Date.now() < fin) {
		// busy wait
	}
}
