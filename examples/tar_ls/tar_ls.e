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
	SHARED_EXECUTION_ENVIRONMENT

	LOCALIZED_PRINTER

	USTAR_HEADER_WRITER

create
	make

feature {NONE} -- Initialization

	make
			-- List contents of all files given as arguments
		local
			f: FILE
			i,n: INTEGER
			args: ARGUMENTS_32
		do
			args := execution_environment.arguments
			from
				i := 1
				n := args.argument_count
			until
				i > n
			loop
				create {RAW_FILE} f.make_with_name (args.argument (i))
				if (f.exists and f.is_readable) then
					list_contents (f)
				else
					if (not f.exists) then
						print_error ({STRING_32} "File %"" + f.path.name + "%" does not exist.")
					elseif (not f.is_readable) then
						print_error ({STRING_32} "File %"" + f.path.name + "%" is not readable.")
					else
						print_error ("Unknown error.")
					end
				end
				i := i + 1

			end
		end

feature {NONE} -- Implementation

	list_contents (tar_file: FILE)
			-- List the contents of `file'
		local
			block: MANAGED_POINTER
			l_parser: USTAR_HEADER_PARSER
			hw: USTAR_HEADER_WRITER
		do
			create hw
			print (unify_utf_8_path (tar_file.path))

			tar_file.open_read

				-- Filename
			localized_print (tar_file.path.name)
			io.put_string (":%N")

				-- Parse all headers
			from
				create block.make ({TAR_CONST}.tar_block_size)
				create l_parser
			until
				tar_file.off
			loop
				tar_file.read_to_managed_pointer (block, 0, block.count)

					-- This one is a header
				l_parser.parse_block (block, 0)
				if (l_parser.parsing_finished and attached l_parser.parsed_header as header) then
					print_header (header)
				end
			end
			tar_file.close
		end

feature {NONE} -- Pretty printing

	print_error (msg: READABLE_STRING_GENERAL)
			-- Put `msg' to stderr
		do
			localized_print_error ("ERROR: ")
			localized_print_error (msg)
			localized_print_error ("%N")
		end

	print_header (header: TAR_HEADER)
			-- Prettyprint `header' to stdout
		do
			localized_print (header.filename.name)
			localized_print ("%N")
		end

end
