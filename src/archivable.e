note
	description: "[
		Common ancestor for all ARCHIVABLES
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	ARCHIVABLE

feature -- Status

	finished_writing: BOOLEAN
			-- Indicates whether everything is written (usefull when using blockwise writing)
		deferred
		end

	required_space: INTEGER
			-- Indicates how much space this archivable requires
		deferred
		ensure
			at_least_header: Result >= {TAR_CONST}.tar_block_size
		end

feature -- Output

	write_block_to_managed_pointer (p: MANAGED_POINTER; pos: INTEGER)
			-- Write next block to `p' starting from `pos'
		require
			non_negative_position: pos >= 0
			enough_space: p.count >= pos + {TAR_CONST}.tar_block_size
		deferred
		end

	write_block_to_new_managed_pointer: MANAGED_POINTER
			-- Write next block to a new managed pointer
		do
			create Result.make ({TAR_CONST}.tar_block_size)
			write_block_to_managed_pointer (Result, 0)
		ensure
			block_size: Result.count = {TAR_CONST}.tar_block_size
		end

	write_to_managed_pointer (p: MANAGED_POINTER; pos: INTEGER)
			-- Write the whole object to `p' (starting from `pos')
			-- This will not change the position used for block based writing
			-- keep in mind that this might use quite a lot of memory for large objects
		require
			non_negative_position: pos >= 0
			enough_space: p.count >= pos + required_space
		deferred
		end

	write_to_new_managed_pointer: MANAGED_POINTER
			-- Write the whole object to a new managed pointer
			-- This will not change the position used for block based writing
			-- keep in mind that this might use quite a lot of memory for large objects
		do
			create Result.make ({TAR_CONST}.tar_block_size)
			write_to_managed_pointer (Result, 0)
		end

feature {NONE} -- Utilites

	needed_blocks (n: INTEGER): INTEGER
			-- Indicate how many blocks are needed to represent `n' bytes
		do
			Result := (n + {TAR_CONST}.tar_block_size - 1) // {TAR_CONST}.tar_block_size
		end

end
