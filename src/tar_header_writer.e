note
	description: "[
		Abstract parent class for all classes that write tar headers
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	TAR_HEADER_WRITER

feature -- Status

	required_space (a_header: TAR_HEADER): INTEGER
			-- Required space in bytes to write `a_header'
		deferred
		ensure
			valid_size: Result \\ {TAR_CONST}.tar_block_size = 0
		end

	can_write (a_header: TAR_HEADER): BOOLEAN
			-- Can `a_header' be written?
		deferred
		end

feature -- Output

	write_to_managed_pointer (a_header: TAR_HEADER; p: MANAGED_POINTER; a_pos: INTEGER)
			-- Write `a_header' to `p', starting at position `a_pos'
		require
			valid_position: a_pos >= 0
			enough_space: p.count - a_pos <= required_space (a_header)
			writable: can_write (a_header)
		deferred
		end

	write_to_new_managed_pointer (a_header: TAR_HEADER): MANAGED_POINTER
			-- Write `a_header' to a new managed pointer with exactly the right size
		require
			writable: can_write (a_header)
		do
			create Result.make (required_space (a_header))
			write_to_managed_pointer (a_header, Result, 0)
		ensure
			minimal_size: Result.count = required_space (a_header)
		end

end
