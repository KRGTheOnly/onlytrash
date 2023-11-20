module main

// ===================================================================
// Prints help :)
// ===================================================================

fn print_help() {
	print('
Trash a file
    can path/to/file

Restore a file
    can restore path/to/file target/path

List canned files
    can list page-num

Purge items from trashcan
    can purge file

Get trash directory
    can dir
')
}
