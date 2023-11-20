module main

import os
import term
import strconv

// ===================================================================
// Formats and show a set of items from the trash directory
// ===================================================================

// Used to tokenize each entry/item
struct Token {
mut:
	chars     string
	color     string
	l_sep     string
	r_sep     string
	sep_color string
	len       int
}

enum ItemType {
	dir
	file
}

// Read's the trash directory, sort it, select a "page" just a
// specific range of entries/items, formats and print it to the terminal
fn list(app App) {
	mut all_items := []string{}
	for trash_path in app.trash_paths {
		all_items << os.ls('${trash_path}/files') or { ['Failed to read ${trash_path}.\n'] }
	}

	if all_items.len <= 0 {
		print('Empty\n')
		return
	}

	all_items.sort_with_compare(fn (a &string, b &string) int {
		return sort_items(a, b)
	})

	total_pages := get_total_pages(app, all_items)
	mut selected_page := app.arg_page_n
	if app.arg_page_n + 1 > total_pages {
		selected_page = total_pages - 1
	}
	selected_items := get_items_in_page(app, all_items, selected_page)

	tokens := tokenize_items(selected_items, app)
	list := format_tokens(tokens)
	print(list)
	print('\nPage:${'${selected_page + 1}/${total_pages}\n'}')
}

// Tokenizes the received list of items
fn tokenize_items(items []string, app App) []Token {
	mut token_list := []Token{}

	for item in items {
		mut color := ''
		item_type := test_item_type(app, item)
		match item_type {
			.dir {
				color = app.dir_color
			}
			.file {
				color = app.file_color
			}
		}

		new_token := Token{
			chars: item
			color: color
			l_sep: app.l_sep_symbol
			r_sep: app.r_sep_symbol
			sep_color: app.sep_color
			len: item.len + app.l_sep_symbol.len + app.r_sep_symbol.len
		}

		token_list << new_token
	}

	return token_list
}

fn test_item_type(app App, item string) ItemType {
	for trash_path in app.trash_paths {
		if os.is_dir('${trash_path}/files/${item}') {
			return ItemType.dir
		}
	}

	return ItemType.file
}

// Formats the token list into a string
fn format_tokens(tokens []Token) string {
	mut list := ''

	width, height := term.get_terminal_size()
	_ = height
	token_len := get_max_token_len(tokens)
	num_columns := width / token_len
	mut cur_column_size := 0
	for token in tokens {
		mut f_token := ''

		mut spaces := ''
		for spaces.len < token_len - token.len {
			spaces += ' '
		}
		f_token = '\u001b[${token.sep_color}m${token.l_sep}\u001b[${token.color}m${token.chars}${spaces}\u001b[${token.sep_color}m${token.r_sep}'
		list += f_token
		cur_column_size += 1
		if cur_column_size >= num_columns {
			list += '\n'
			cur_column_size = 0
		}
	}

	return list
}

// Gets total "pages" based on the configured items per page
fn get_total_pages(app App, items []string) int {
	mut total_pages := 0
	total_pages = items.len / app.items_per_page
	if items.len % app.items_per_page > 0 {
		total_pages += 1
	}

	return total_pages
}

// Gets a range of items from the received list of items
// it's used to receive all items inside the trash directory and a "page"
// so it can return only a portion of it
fn get_items_in_page(app App, all_items []string, page int) []string {
	from_item := page * app.items_per_page
	to_item := (page * app.items_per_page) + app.items_per_page

	mut items := []string{}
	for i in from_item .. to_item {
		if i >= all_items.len {
			break
		}

		items << all_items[i]
	}

	return items
}

// Returns the token with the highest length from the received tokens
fn get_max_token_len(tokens []Token) int {
	mut max_len := 0
	for token in tokens {
		if token.len > max_len {
			max_len = token.len
		}
	}

	return max_len
}

// Sorting conditions
// That gets worse the more you look at it. it needs to be remade
fn sort_items(a &string, b &string) int {
	mut a1 := ''
	mut b1 := ''
	mut a_has_letter := false
	mut b_has_letter := false
	s1 := a.split('')
	s2 := b.split('')
	for i in s1 {
		res := strconv.atoi(i) or { 69 }
		if res != 69 {
			a1 += res.str()
		} else {
			a_has_letter = true
		}
	}
	for i in s2 {
		res := strconv.atoi(i) or { 69 }
		if res != 69 {
			b1 += res.str()
		} else {
			b_has_letter = true
		}
	}
	a2 := strconv.atoi(a1) or { -1 }
	b2 := strconv.atoi(b1) or { -1 }
	if a2 == -1 && b2 != -1 {
		return -1
	}
	if b2 == -1 && a2 != -1 {
		return 1
	}
	if a2 == -1 && b2 == -1 {
		if a < b {
			return -1
		}
		if a > b {
			return 1
		}
		return 0
	}
	if a_has_letter == true && b_has_letter == false {
		return 1
	}
	if b_has_letter == true && a_has_letter == false {
		return -1
	}
	if a2 < b2 {
		return -1
	}
	if a2 > b2 {
		return 1
	}
	return 0
}
