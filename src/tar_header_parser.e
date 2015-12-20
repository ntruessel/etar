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


feature {NONE} -- Initialization

	make
			-- Create a TAR_HEADER_PARSER
		do
			parsing_finished := False
			create current_header.make
		end

feature -- Status

	parsing_finished: BOOLEAN
			-- Indicates whether the current parsing step has finished

feature -- Parsing

	parse_block (block: MANAGED_POINTER; pos: INTEGER)
			-- parse `block' (starting from `pos')
		require
			block_size_large_enough: pos + {TAR_CONST}.tar_block_size <= block.count
			non_negative_length: pos >= 0
		deferred
		end

feature -- Result query

	parsed_header: TAR_HEADER
		require
			completely_parsed: parsing_finished
		do
			Result := current_header
		end

feature {NONE} -- Implementation

	current_header: TAR_HEADER
			-- The current header (based on the parsed blocks)

feature {NONE} -- Utilities

	parse_string (block: MANAGED_POINTER; pos, length: INTEGER): STRING
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
			create Result.make_empty -- Might be inefficient due to many resizes
			from
				i := 0
				c := block.read_character (pos + i)
			until
				i >= length or c = '%U'
			loop
				c := block.read_character (pos + i)
				if (c /= '%U') then
					Result.append_character (c)
				end
				i := i + 1
			end
		end

end
