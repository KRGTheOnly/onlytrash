module main

import os
import readline

// ===================================================================
// Purges file if a parameter is given, otherwise it asks to purge everything
// ===================================================================

fn purge(app App) {
	if app.arg_f_path != '' {
		purge_file(app)
	} else {
		purge_all(app)
	}
}

fn purge_all(app App) {
	confirmation := readline.read_line('Purge all the files?? (y/n):') or { return }
	if confirmation != 'y' {
		return
	}

	print('Purging all files...\n')

	mut files_paths := []string{}

	for trash_path in app.trash_paths {
		files := os.ls('${trash_path}/files') or { panic(err) }

		for file in files {
			files_paths << ['${trash_path}/files/${file}']
		}
	}

	for file_path in files_paths {
		os.rm(file_path) or { print('Failed removing ${file_path}.\n') }
	}

	print('Purge complete.\n')
}

fn purge_file(app App) {
	mut trash := ''

	for trash_path in app.trash_paths {
		res := os.exists('${trash_path}/files/${app.arg_f_path}')

		if res == true {
			trash = trash_path
			break
		}
	}

	if trash == '' {
		print('Was not able to purge the file or the file was not found.')
		return
	}

	os.rm('${trash}/files/${app.arg_f_path}') or { print('Failed removing ${app.arg_f_path}.\n') }
	print('Purged ${app.arg_f_path}.\n')
}
