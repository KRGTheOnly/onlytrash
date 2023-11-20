module main

import os

// ===================================================================
// Cd into and writes its paths to the terminal
// ===================================================================

fn tdir(app App) {
	for trash_path in app.trash_paths {
		os.chdir(trash_path) or { print('Could not cd into ${trash_path}.') }
		print(os.abs_path('\n'))
	}
}
