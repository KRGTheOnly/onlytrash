module main

import os

// ===================================================================
// Moves a file from the trash to a given path
// ===================================================================

fn restore(app App) {
	if app.arg_f_path == '' {
		print('Choose a file to restore. "list" to list the files in trash.\n')
		return
	}

	mut tests := 0
	for trash_path in app.trash_paths {
		if os.exists('${trash_path}/files/${app.arg_f_path}') == false {
			tests += 1
		}
	}
	if tests >= app.trash_paths.len {
		print('File ${app.arg_f_path} not found.')
		return
	}

	for trash_path in app.trash_paths {
		if os.exists('${trash_path}/files/${app.arg_f_path}') == true {
			os.mv('${trash_path}/files/${app.arg_f_path}', app.arg_s_path) or {
				print('Cant restore file ${app.arg_f_path} to ${os.abs_path(app.arg_s_path)}.')
			}
			break
		}
	}
}
