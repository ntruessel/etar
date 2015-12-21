note
	description : "[
		ls for tar files
		
		This demo program lists the contents of a tar
		compressed file.
	]"
	date        : "$Date$"
	revision    : "$Revision$"

class
	TAR_LS

inherit
	ARGUMENTS

create
	make

feature {NONE} -- Initialization

	make
			-- List contents of all files given as arguments
		local
			argument_cursor: ITERATION_CURSOR [STRING]
			current_file: FILE
		do
			from
				argument_cursor := new_cursor
				argument_cursor.forth 			-- The first element is the program name
			until
				argument_cursor.after
			loop
				create {RAW_FILE} current_file.make_with_name (argument_cursor.item)
				if (current_file.exists and current_file.is_readable) then
					current_file.open_read
					list_contents (current_file)
				else
					if (not current_file.exists) then
						print_error ("File " + argument_cursor.item + " does not exist.")
					elseif (not current_file.is_readable) then
						print_error ("File " + argument_cursor.item + " is not readable.")
					else
						print_error ("Unknown error.")
					end
				end
				argument_cursor.forth
			end
		end

feature {NONE} -- Implementation

	list_contents (tar_file: FILE)
			-- List the contents of `file'
		local
			block: MANAGED_POINTER
			parser: USTAR_HEADER_PARSER
		do
			-- Filename
			io.put_string (tar_file.path.utf_8_name + ":%N")

			-- Parse all headers
			from
				create block.make ({TAR_CONST}.tar_block_size)
				create parser
			until
				tar_file.off
			loop
				tar_file.read_to_managed_pointer (block, 0, block.count)

				-- This one is a header
				parser.parse_block (block, 0)
				if (parser.parsing_finished and attached parser.parsed_header as header) then
					print_header (header)
				end
			end
			tar_file.close
		end

feature {NONE} -- Pretty printing

	print_error (msg: STRING)
			-- Put `msg' to stderr
		do
			io.error.put_string ("ERROR: " + msg + "%N")
		end

	print_header (header: TAR_HEADER)
			-- Prettyprint `header' to stdout
		do
			io.put_string (header.filename.utf_8_name + "%N")
		end

end
