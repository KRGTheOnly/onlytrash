module main

import os

// ===================================================================
// Moves given file to one of the available trash paths
// ===================================================================

fn can(app App) {
	mut attempts := 0

	for trash_path in app.trash_paths {
		os.mv(app.arg_f_path, '${trash_path}/files') or { attempts += 1 }
	}

	if attempts >= app.trash_paths.len {
		print('Was not able to move the file to any of the trash paths or the file was not found.')
	}
}
