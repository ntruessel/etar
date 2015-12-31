note
	description : "[
		minimal pax implementation (lacking many features, slightly different command line)
	]"
	date        : "$Date$"
	revision    : "$Revision$"

class
	MINIPAX

inherit
	SHARED_EXECUTION_ENVIRONMENT

	LOCALIZED_PRINTER

create
	make

feature {NONE} -- Initialization

	make
			-- Run minitar
		local
			args: ARGUMENTS_32
			i, n: INTEGER
			l_archive_filename: detachable IMMUTABLE_STRING_32
		do
				-- Parse arguments
			args := execution_environment.arguments

			inspect mode
			when mode_write then
				unarchive
			when mode_read then
				archive
			else
				print_usage
			end
		end

feature {NONE} -- Implementation

	mode: INTEGER
			-- What mode is active

	mode_usage: INTEGER = 0
			-- Error parsing cmdline - print usage

	mode_read: INTEGER = 1
			-- Read mode

	mode_write: INTEGER = 2
			-- Write mode

	archive
			-- Dummy
		do
			localized_print ("Not implemented")
		end

	unarchive
			-- Dummy
		do
			localized_print ("Not implemented")
		end


	print_usage
			-- Print usage of this utility
		do
			localized_print (
			"[
Usage: 
	- minipax -f archive
		List mode: minipax prints the contents of the specified archive
	- minipax -r -f archive
		Read mode: minipax unarchives the contents of the specified archive
	- minipax -w -f archive file...
		Write mode: minipax archives the given list of files

			]")
		end

end
