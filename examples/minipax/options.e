note
	description: "[
		Container for program options
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	OPTIONS

inherit
	ANY
		redefine
			default_create
		end

feature {NONE} -- Initialization

	default_create
			-- New instance
		do
			create archive_name.make_empty
			create file_list.make_empty
--			absolute_paths := False
--			mode := mode_usage
		end

feature -- Mode

	mode: INTEGER
			-- Program mode

	mode_usage: INTEGER = 0
			-- Usage printing

	mode_list: INTEGER = 1
			-- List archive contents

	mode_unarchive: INTEGER = 2
			-- Unarchive given archive

	mode_archive: INTEGER = 3
			-- Archive given files

	absolute_paths: BOOLEAN
			-- Keep absolute paths?

	archive_name: IMMUTABLE_STRING_32
			-- archive name

	file_list: ARRAY [IMMUTABLE_STRING_32]
			-- given files

feature -- Parsing

	parse (args: ARGUMENTS_32)
			-- Parse `args'
		local
			i, n: INTEGER
			optional_args_finished: BOOLEAN
		do
				-- optional arguments
			from
				n := args.argument_count
				i := 1
				optional_args_finished := False
			until
				i > n or optional_args_finished
			loop
				if args.argument (i) ~ "-A" then
					absolute_paths := True
				else
					optional_args_finished := True
				end
				i := i + 1
			end

			if optional_args_finished then
				i := i - 1
			end

				-- Now for the remaining arguments
			if n - i = 1 and then args.argument (i) ~ "-f" then
				mode := mode_list
				archive_name := args.argument (n)
			elseif n - i = 2 and then (args.argument (i) ~ "-r" and args.argument (i + 1) ~ "-f") then
				mode := mode_unarchive
				archive_name := args.argument (n)
			elseif n - i >= 3 and then (args.argument (i) ~ "-w" and args.argument (i + 1) ~ "-f") then
				mode := mode_archive
				archive_name := args.argument (i + 2)
				file_list := args.argument_array.subarray (i + 3, n)
			end
		end


invariant
	correct_mode: mode = mode_usage or mode = mode_list or mode = mode_unarchive or mode = mode_archive
	empty_name_implies_usage: archive_name.is_empty implies mode = mode_usage
	non_empty_file_list_implies_archive: not file_list.is_empty implies mode = mode_archive
end
