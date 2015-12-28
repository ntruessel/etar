note
	description: "[
		Common ancestor for tar header parsers
		
		Additionally provides a string parsing utility
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	TAR_HEADER_PARSER

feature -- Status

	parsing_finished: BOOLEAN
			-- Indicates whether the current parsing step has finished
			-- On parse failure this is True as well.

feature -- Parsing

	parse_block (block: MANAGED_POINTER; pos: INTEGER)
			-- parse `block' (starting from `pos')
		require
			block_size_large_enough: pos + {TAR_CONST}.tar_block_size <= block.count
			non_negative_length: pos >= 0
		deferred
		end

feature -- Result query

	parsed_header: detachable TAR_HEADER
			-- Return the last parsed header if no error occured
		require
			completely_parsed: parsing_finished
		do
			if not has_error then
				Result := last_parsed_header
			else
				Result := Void
			end
		end

feature -- Access: error

	has_error: BOOLEAN
			-- Error occurred?
		do
				--| Dbg Hint: comment next line to see all error messages.
			Result := attached error_messages as lst and then not lst.is_empty
			if not Result and parsing_finished then
				Result := last_parsed_header = Void
			end
		end

	reset_error
			-- Reset errors.
		do
			error_messages := Void
		ensure
			has_no_error: not has_error
		end

	report_error (a_message: READABLE_STRING_GENERAL)
			-- Report error message `a_message'.
		local
			lst: like error_messages
		do
			lst := error_messages
			if lst = Void then
				create {ARRAYED_LIST [READABLE_STRING_32]} lst.make (1)
				error_messages := lst
			end
			lst.force (a_message.as_string_32)
		ensure
			has_error: has_error
		end

	error_messages: detachable LIST [READABLE_STRING_32]
			-- Error messages.		

feature {NONE} -- Implementation

	last_parsed_header: detachable TAR_HEADER
			-- The current header (based on the parsed blocks)
			-- Void in case of parse failures

feature {NONE} -- Utilities

	next_block_string (block: MANAGED_POINTER; pos, length: INTEGER): STRING
			-- Parse a string in `block' from `pos' with length at most `length'
			-- A string is a sequence of characters, stopping at the first '%U'
			-- that occurs. In case no '%U' occurs, it ends after at `length'
			-- characters
			-- FIXME: Slow implementation
		require
			enough_characters: pos + length <= block.count
			non_negative_pos: pos >= 0
			positive_length: length > 0
		local
			c: CHARACTER_8
			i: INTEGER
		do
			create Result.make (length) -- Might be inefficient due to many resizes
			from
				i := 0
				c := ' ' -- dummy character different from %U
			until
				i >= length or c = '%U'
			loop
				c := block.read_character (pos + i)
				if c /= '%U' then
					Result.append_character (c)
				end
				i := i + 1
			end
		end

end
