note
	description: "[
		Interface for all archivable objects
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	ARCHIVABLE

convert
	to_managed_pointer: {MANAGED_POINTER}

feature -- Conversion
	-- Maybe add more features here, but for now I think this suffices

	to_managed_pointer: MANAGED_POINTER
			-- Convert `Current' to a newly allocated MANAGED_POINTER
		do
			create Result.make (size)
			store_to_managed_pointer (Result, 0)
		ensure
			minimal_size: Result.count = size
		end

feature -- Size

	size: INTEGER
			-- What size does `Current' need?
		deferred
		ensure
			multiple_of_blocksize: Result \\ {TAR_CONST}.tar_block_size = 0
		end

feature -- Output

	store_to_managed_pointer (p: MANAGED_POINTER; start_pos: INTEGER)
			-- Store `Current' to `p' at `start_pos'
		require
			sufficient_size: p.count - start_pos <= size
		deferred
		end

	store_to_file (a_file: FILE)
			-- Store `Current' to `a_file'
		require
			file_open_writable: a_file.is_open_write
		local
			l_managed_pointer: MANAGED_POINTER
		do
			l_managed_pointer := Current
			a_file.put_managed_pointer (l_managed_pointer, 0, l_managed_pointer.count)
		end
end
