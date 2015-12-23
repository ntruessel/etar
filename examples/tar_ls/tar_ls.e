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

	OCTAL_UTILS
		export
			{NONE} all
		end

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
			i: NATURAL_64
			l_needed_blocks: NATURAL_64
		do
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

					-- Skip payload
					from
						i := 0
						l_needed_blocks := needed_blocks (header.size)
					until
						i >= l_needed_blocks
					loop
						tar_file.move ({TAR_CONST}.tar_block_size)
						i := i + 1
					end
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
			print_typeflag (header)
			print_permissions (header)
			localized_print (" ")
			print_user (header)
			localized_print (" ")
			print_group (header)
			localized_print (" ")
			print_size (header)
			localized_print (" ")
			print_mtime (header)
			localized_print (" ")
			localized_print (header.filename.name)
			localized_print ("%N")
		end

	print_typeflag (header: TAR_HEADER)
			-- Prettyprint `header's typeflag
		do
			inspect header.typeflag
			when {TAR_CONST}.tar_typeflag_directory then
				localized_print ("d")
			when {TAR_CONST}.tar_typeflag_block_special then
				localized_print ("b")
			when {TAR_CONST}.tar_typeflag_character_special then
				localized_print ("c")
			when {TAR_CONST}.tar_typeflag_fifo then
				localized_print ("p")
			when {TAR_CONST}.tar_typeflag_symlink then
				localized_print ("l")
			else
				localized_print ("-")
			end
		end

	print_permissions (header: TAR_HEADER)
			-- Prettyprint `header's permissions/mode
		do
			-- User
			if header.is_user_readable then
				localized_print ("r")
			else
				localized_print ("-")
			end
			if header.is_user_writable then
				localized_print ("w")
			else
				localized_print ("-")
			end
			if header.is_user_executable and header.is_setuid then
				localized_print ("s")
			elseif header.is_user_executable and not header.is_setuid then
				localized_print ("x")
			elseif not header.is_user_executable and header.is_setuid then
				localized_print ("S")
			else
				localized_print ("-")
			end

			-- Group
			if header.is_group_readable then
				localized_print ("r")
			else
				localized_print ("-")
			end
			if header.is_group_writable then
				localized_print ("w")
			else
				localized_print ("-")
			end
			if header.is_group_executable and header.is_setgid then
				localized_print ("s")
			elseif header.is_group_executable and not header.is_setgid then
				localized_print ("x")
			elseif not header.is_group_executable and header.is_setgid then
				localized_print ("S")
			else
				localized_print ("-")
			end

			-- Other
			if header.is_other_readable then
				localized_print ("r")
			else
				localized_print ("-")
			end
			if header.is_other_writable then
				localized_print ("w")
			else
				localized_print ("-")
			end
			if header.is_other_executable then
				localized_print ("x")
			else
				localized_print ("-")
			end
		end

	user_width_memo: INTEGER
			-- Stores the length of the longest username printed so far

	print_user (a_header: TAR_HEADER)
			-- Prettyprint `a_header's username if set, uid otherwise
		local
			l_username: STRING
			l_padding: STRING
		do
			if not a_header.user_name.is_whitespace then
				l_username := a_header.user_name.twin
			else
				l_username := a_header.user_id.out
			end

			-- Pad
			if l_username.count < user_width_memo then
				l_padding := " "
				l_padding.multiply (user_width_memo - l_username.count)
				l_username.prepend (l_padding)
			end
			localized_print (l_username)
			user_width_memo := l_username.count
		end

	group_width_memo: INTEGER
			-- Stores the length of the longest groupname printed so far

	print_group (a_header: TAR_HEADER)
			-- Prettyprint `a_header's groupname if set, gid otherwise
		local
			l_groupname: STRING
			l_padding: STRING
		do
			if not a_header.user_name.is_whitespace then
				l_groupname := a_header.group_name.twin
			else
				l_groupname := a_header.group_id.out
			end

			-- Pad
			if l_groupname.count < group_width_memo then
				l_padding := " "
				l_padding.multiply (group_width_memo - l_groupname.count)
				l_groupname.prepend (l_padding)
			end
			localized_print (l_groupname)
			group_width_memo := l_groupname.count
		end

	print_size (a_header: TAR_HEADER)
			-- Prettyprint `a_header's size
		local
			l_size: NATURAL_64
			i: INTEGER
			l_output: STRING
		do
			from
				l_size := a_header.size
				i := 0
			until
				l_size < 1024
			loop
				l_size := (l_size / 1024).rounded.as_natural_64
				i := i + 1
			end
			if l_size >= 1000 then
				l_size := 1
			end

			-- Fix width to 3 characters
			l_output := " "
			l_output.multiply (4 - l_size.out.count)
			l_output.remove (1)
			l_output.append (l_size.out)

			-- Unit
			inspect i
			when 0 then
				l_output.prepend (" ")
			when 1 then
				l_output.append ("K")
			when 2 then
				l_output.append ("M")
			when 3 then
				l_output.append ("G")
			else
				l_output.append ("T")
			end

			localized_print (l_output)
		end

	print_mtime (a_header: TAR_HEADER)
			-- Prettyprint `a_header's timestamp
		local
			l_mtime: DATE_TIME
		do
			create l_mtime.make_from_epoch (a_header.mtime.as_integer_32) -- Will fail in 2038
			localized_print (l_mtime.formatted_out ("yyyy-[0]mm-[0]dd [0]hh:[0]mi"))
		end


feature {NONE} -- Utilites

	needed_blocks (n: NATURAL_64): NATURAL_64
			-- Indicate how many blocks are needed to represent `n' bytes
		do
			Result := (n + {TAR_CONST}.tar_block_size.as_natural_64 - 1) // {TAR_CONST}.tar_block_size.as_natural_64
		ensure
			bytes_fit: n <= Result * {TAR_CONST}.tar_block_size.as_natural_64
			smallest_fit: Result * {TAR_CONST}.tar_block_size.as_natural_64 < n + {TAR_CONST}.tar_block_size.as_natural_64
		end

end
