note
	description : "[
		minimal pax implementation (lacking many features, slightly different usage)
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
			n: INTEGER
			l_archive_filename: IMMUTABLE_STRING_32
			l_filenames: ARRAY [IMMUTABLE_STRING_32]
		do
				-- Parse arguments
			args := execution_environment.arguments
			n := args.argument_count

			if n = 2 and then args.argument (1) ~ "-f" then
					-- List mode
				l_archive_filename := args.argument (2)
			elseif n = 3 and then args.argument (1) ~ "-r" then
					-- Read mode (unarchiving)
				if args.argument (2) ~ "-f" then
					l_archive_filename := args.argument (3)

					unarchive (l_archive_filename)
				else
					print_usage
				end
			elseif n >= 4 and then args.argument (1) ~ "-w" then
					-- Write mode
				if args.argument (2) ~ "-f" then
					l_archive_filename := args.argument (3)
					l_filenames := args.argument_array.subarray (4, n)

					archive (l_archive_filename, l_filenames)
				else
					print_usage
				end
			else
				print_usage
			end
		end

feature {NONE} -- Implementation

	list (a_archive_filename: IMMUTABLE_STRING_32)
			-- List contents of the archive stored at `a_archive_filename'
		do
			localized_print ("Not implemented%N")
		end

	archive (a_archive_filename: IMMUTABLE_STRING_32; a_filenames: ARRAY [IMMUTABLE_STRING_32])
			-- Archive `a_filenames' to the archive stored at `a_archive_filename' (creating it if it does not exist)
		do
			localized_print ("Not implemented%N")
		end

	unarchive (a_archive_filename: IMMUTABLE_STRING_32)
			-- Unarchive contents of the archive stored at `a_archive_filename'
		do
			localized_print ("Not implemented%N")
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
        Write mode: minipax archives the given list of files, creating the
                    archive if it does not exist, appending to it otherwise

			]")
		end

end
