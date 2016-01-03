note
	description: "[
		ARCHIVABLE wrapper for files
		
		This version only accepts plain files
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	FILE_ARCHIVABLE
inherit
	ARCHIVABLE

create
	make

feature {NONE} -- Initialization

	make (a_file: FILE)
			-- Create a new FILE_ARCHIVABLE for `a_file'
		require
			file_existis: a_file.exists
			file_is_readable: a_file.is_readable
			file_is_plain: a_file.is_plain
		do
			create {RAW_FILE} file.make_with_path (a_file.path)
			file.open_read
		end

feature -- Status

	required_blocks: INTEGER
			-- Indicate how much space is needed to represent this ARCHIVABLE
		do
			Result := needed_blocks (file.file_info.size)
		end

	header: TAR_HEADER
			-- Header that belongs to the payload
		once
			create Result.make

			Result.set_filename (file.path)
			Result.set_mode (file.protection.as_natural_16)
			Result.set_user_id (file.user_id.as_natural_32)
			Result.set_group_id (file.group_id.as_natural_32)
			Result.set_size (file.file_info.size.as_natural_64)
			Result.set_mtime (file.date.as_natural_64)
			Result.set_typeflag ({TAR_CONST}.tar_typeflag_regular_file)
			Result.set_user_name (file.owner_name)
			Result.set_group_name (file.file_info.group_name)
		end

feature -- Output

	write_block_to_managed_pointer (p: MANAGED_POINTER; pos: INTEGER)
			-- Write the next block to `p' starting at `pos'
		do
			-- Write next block
			file.read_to_managed_pointer (p, pos, {TAR_CONST}.tar_block_size)
			if (file.end_of_file) then
				-- Fill with '%U'
				pad (p, pos + file.bytes_read, {TAR_CONST}.tar_block_size - file.bytes_read)

				-- Close file
				file.close
			end
			written_blocks := written_blocks + 1
		end

	write_to_managed_pointer (p: MANAGED_POINTER; pos: INTEGER)
			-- Write the whole file to `p' starting at `pos'
			-- Does not change the state of blockwise writing
		local
			l_file: FILE
			i: INTEGER
		do
			-- Write blocks until there are no more blocks to write
			from
				create {RAW_FILE} l_file.make_with_path (file.path)
				l_file.open_read
				i := 0
			until
				i >= required_blocks and l_file.bytes_read /= {TAR_CONST}.tar_block_size
			loop
				l_file.read_to_managed_pointer (p, pos + {TAR_CONST}.tar_block_size * i, {TAR_CONST}.tar_block_size)
				i := i + 1
			end

			-- Fill with '%U'
			if (i /= required_blocks) then
				i := i - 1
				pad (p, pos + {TAR_CONST}.tar_block_size * i + l_file.bytes_read, {TAR_CONST}.tar_block_size - l_file.bytes_read)
			end

			-- Close file
			l_file.close
		ensure then
			file_pointer_unchanged: (old file.file_pointer) = file.file_pointer
		end

feature {NONE} -- Implementation

	file: FILE
			-- The file this ARCHIVABLE represents

end
