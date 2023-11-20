module main

import os
import strconv

enum Command {
	list
	restore
	help
	can
	purge
	dir
}

struct App {
mut:
	trash_paths  []string
	trash_path   string
	dir_color    string
	file_color   string
	sep_color    string
	l_sep_symbol string
	r_sep_symbol string
	// TODO Add single column
	single_column  bool
	items_per_page int
	arg_command    Command
	arg_f_path     string
	arg_s_path     string
	arg_page_n     int
}

fn main() {
	mut app := App{}

	config_app(mut app)

	for trash_path in app.trash_paths {
		if os.is_dir(trash_path) == false {
			os.mkdir(trash_path, mode: 0o777) or { print('Cant make trash directory.\n') }
		}
		if os.is_dir('${trash_path}/files') == false {
			os.mkdir('${trash_path}/files', mode: 0o777) or {
				print('Cant make trash files directory.\n')
			}
		}
	}

	args := os.args.clone()

	// Set the proper command
	if args.len > 1 {
		match args[1] {
			'list' {
				app.arg_command = .list
			}
			'restore' {
				app.arg_command = .restore
			}
			'help' {
				app.arg_command = .help
			}
			'purge' {
				app.arg_command = .purge
			}
			'dir' {
				app.arg_command = .dir
			}
			else {
				app.arg_command = .can
			}
		}
	} else {
		app.arg_command = .help
	}

	// Sets the command other parameters
	match app.arg_command {
		.list {
			if args.len >= 3 {
				app.arg_page_n = strconv.atoi(args[2]) or { 0 }
				if app.arg_page_n > 0 {
					app.arg_page_n -= 1
				}
			}
		}
		.can {
			app.arg_f_path = args[1]
		}
		.restore {
			if args.len >= 3 {
				app.arg_f_path = args[2]
			}
			if args.len >= 4 {
				app.arg_s_path = args[3]
			} else {
				app.arg_s_path = '.'
			}
		}
		.purge {
			if args.len >= 3 {
				app.arg_f_path = args[2]
			}
		}
		else {}
	}

	// Call's the command
	match app.arg_command {
		.list { list(app) }
		.restore { restore(app) }
		.help { print_help() }
		.purge { purge(app) }
		.dir { tdir(app) }
		.can { can(app) }
	}
}
