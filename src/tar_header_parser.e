note
	description: "Summary description for {TAR_HEADER_PARSER}."
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


end
