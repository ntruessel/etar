note
	description: "[
		Common ancestor for storage backends usable by ARCHIVE
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	STORAGE_BACKEND

inherit
	ERROR_UTILS

feature -- Status setting

	open_read
			-- Open storage backend for reading
		deferred
		ensure
			error_or_readable: has_error or else is_readable
		end

	open_write
			-- Open storage backend for writing
		deferred
		ensure
			error_or_writable: has_error or else is_writable
		end

	close
			-- Close storage backend
		deferred
		ensure
			closed: is_closed
		end

feature -- Status

	archive_finished: BOOLEAN
			-- Indicates whether the next two blocks only contain NUL bytes
			-- This denotes the end of an archive, if not occuring in some payload
		require
			readable: is_readable
		deferred
		end

	block_ready: BOOLEAN
			-- Indicate whether there is a block ready
		require
			readable: is_readable
		deferred
		ensure
			no_blocks_on_error: Result implies not has_error
		end

	is_readable: BOOLEAN
			-- Indicate whether this instance can be read from
		deferred
		ensure
			no_error_if_readable: Result implies not has_error
		end

	is_writable: BOOLEAN
			-- Indicate whether blocks can be written to this instance
		deferred
		ensure
			no_error_if_writable: Result implies not has_error
		end

	is_closed: BOOLEAN
			-- Indicate whether backend is closed
		deferred
		end

feature -- Reading

	last_block: MANAGED_POINTER
			-- Last block that was read
		require
			has_block: block_ready
		deferred
		ensure
			correct_size: Result.count = {TAR_CONST}.tar_block_size
		end

	read_block
			-- Try to read next block
		require
			readable: is_readable
		deferred
		ensure
			error_or_ready: has_error or block_ready
		end

feature -- Writing

	write_block (a_block: MANAGED_POINTER)
			-- Write `a_block'
		require
			writable: is_writable
			correct_size: a_block.count = {TAR_CONST}.tar_block_size
		deferred
		end

	finalize
			-- Finalize archive (write two 0 blocks and close)
		require
			writable: is_writable
		deferred
		ensure
			closed: is_closed
		end

invariant
	not_readable_on_error: has_error implies not is_readable
	not_writable_on_error: has_error implies not is_writable
	closed_on_error: has_error implies is_closed

end
