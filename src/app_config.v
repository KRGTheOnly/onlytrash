module main

import os
import strconv

// Generates, reads the configuration file and sets the proper configs into the app

const config_path = '${os.home_dir()}/.config/onlytrash/'

const config_file = 'onlytrash.config'

const config_example = '
trash_path: HOME/.local/share/onlytrash

dir_color: 01;37
file_color: 0
separator_color: 0

left_separator_symbol: [
right_separator_symbol: ]

items_per_page: 30
'

fn config_app(mut app App) {
	read_config_file(mut app)
}

fn gen_config_file() {
	os.mkdir(config_path) or {}
	os.write_file('${config_path}${config_file}', config_example) or {
		print('Cant write the config file.')
	}
}

// Reads and parses the parameters in the config file
// it still needs work to be proper parser
fn read_config_file(mut app App) {
	valid_params := ['trash_path', 'dir_color', 'file_color', 'separator_color',
		'left_separator_symbol', 'right_separator_symbol', 'single_column', 'items_per_page']

	mut file := ''

	file = os.read_file('${config_path}${config_file}') or { 'file_not_found' }

	if file == 'file_not_found' {
		gen_config_file()
		file = os.read_file('${config_path}${config_file}') or { 'file_not_found' }
	}

	lines := file.split('\n')
	mut clean_lines := []string{}
	for line in lines {
		if line != '' {
			clean_lines << line.trim(' ')
		}
	}

	mut parameters := [][]string{}
	for line in clean_lines {
		parameter := line.split(': ')
		if parameter.len > 1 {
			parameters << [parameter[0].trim(' '), parameter[1].trim(' ')]
		}
	}

	for param in parameters {
		// param[0] is the key, param[1] is the value
		if param[0] in valid_params {
			match param[0] {
				'trash_path' {
					// app.trash_path = param[1]
					// app.trash_path = app.trash_path.replace_once('HOME', os.home_dir())
					app.trash_paths << param[1].replace_once('HOME', os.home_dir())
				}
				'dir_color' {
					app.dir_color = param[1]
				}
				'file_color' {
					app.file_color = param[1]
				}
				'separator_color' {
					app.sep_color = param[1]
				}
				'left_separator_symbol' {
					app.l_sep_symbol = param[1]
				}
				'right_separator_symbol' {
					app.r_sep_symbol = param[1]
				}
				'single_column' {
					app.single_column = false
					if param[1] == 'true' {
						app.single_column = true
					}
				}
				'items_per_page' {
					app.items_per_page = strconv.atoi(param[1]) or { 30 }
				}
				else {
					print('Parameter ${param[0]} is invalid!\n')
				}
			}
		}
	}
}
