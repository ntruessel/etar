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

	required_blocks: INTEGER
			-- Indicates how much space this archivable requires in blocks
		deferred
		ensure
			at_least_header: Result >= header_writer.required_blocks
		end

feature -- Output

	write_block_to_managed_pointer (p: MANAGED_POINTER; pos: INTEGER)
			-- Write next block to `p' starting from `pos'
		require
			non_negative_position: pos >= 0
			enough_space: p.count >= pos + {TAR_CONST}.tar_block_size
			not_finished: not finished_writing
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
			enough_space: p.count >= pos + required_blocks * {TAR_CONST}.tar_block_size
		deferred
		end

	write_to_new_managed_pointer: MANAGED_POINTER
			-- Write the whole object to a new managed pointer
			-- This will not change the position used for block based writing
			-- keep in mind that this might use quite a lot of memory for large objects
		do
			create Result.make (required_blocks * {TAR_CONST}.tar_block_size)
			write_to_managed_pointer (Result, 0)
		end

feature {NONE} -- Implemenation

	header_writer: TAR_HEADER_WRITER
			-- The header writer to use

	header: TAR_HEADER
			-- Header that belongs to the payload

feature {NONE} -- Utilites

	write_header_block (p: MANAGED_POINTER; a_pos: INTEGER)
			-- Writes a block of the header
		require
			non_negative_position: a_pos >= 0
			enough_space: p.count >= a_pos + {TAR_CONST}.tar_block_size
			not_written: not header_writer.finished_writing
		do
			header_writer.write_block_to_managed_pointer (p, a_pos)
		end


	needed_blocks (n: INTEGER): INTEGER
			-- Indicate how many blocks are needed to represent `n' bytes
		require
			non_negative_bytes: n >= 0
		do
			Result := (n + {TAR_CONST}.tar_block_size - 1) // {TAR_CONST}.tar_block_size
		ensure
			bytes_fit: n <= Result * {TAR_CONST}.tar_block_size
			smallest_fit: (Result - 1) * {TAR_CONST}.tar_block_size < n
		end

	pad (p: MANAGED_POINTER; pos: INTEGER; n: INTEGER)
			-- pad `p' with `n' NUL-bytes starting at `pos'
		require
			non_negative_position: pos >= 0
			non_negative_length: n >= 0
			enough_space: p.count >= pos + n
		local
			l_padding: SPECIAL[CHARACTER_8]
		do
			create l_padding.make_filled ('%U', n)
			p.put_special_character_8 (l_padding, 0, pos, n)
		end

end
