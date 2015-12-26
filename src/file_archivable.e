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

	make (a_file: FILE; a_header_writer: TAR_HEADER_WRITER)
			-- Create a new FILE_ARCHIVABLE for `a_file' using `a_header_writer' to write the headers
		require
			file_existis: a_file.exists
			file_is_readable: a_file.is_readable
			file_is_plain: a_file.is_plain
		do
			create {RAW_FILE} file.make_with_path (a_file.path)
			file.open_read

			if (file.is_closed) then
				file.open_read
			else
				file.start
			end

			header_writer := a_header_writer

			generate_header

			header_writer.set_active_header (header)
		end

feature -- Status

	finished_writing: BOOLEAN
			-- Indicates whether the whole file was written
		do
			Result := file.is_closed
		end

	required_blocks: INTEGER
			-- Indicate how much space is needed to represent this ARCHIVABLE
		do
			Result := (header_writer.required_blocks + needed_blocks (file.file_info.size))
		end

feature -- Output

	write_block_to_managed_pointer (p: MANAGED_POINTER; pos: INTEGER)
			-- Write the next block to `p' starting at `pos'
		do
			if (not header_writer.finished_writing) then
				-- Write header
				write_header_block (p, pos)
			else
				-- Write next block
				file.read_to_managed_pointer (p, pos, {TAR_CONST}.tar_block_size)
				if (file.end_of_file) then
					-- Fill with '%U'
					pad (p, pos + file.bytes_read, {TAR_CONST}.tar_block_size - file.bytes_read)

					-- Close file
					file.close
				end
			end
		end

	write_to_managed_pointer (p: MANAGED_POINTER; pos: INTEGER)
			-- Write the whole file to `p' starting at `pos'
			-- Does not change the state of blockwise writing
		local
			l_file: FILE
			i: INTEGER
		do
			header_writer.write_to_managed_pointer (p, pos)

			-- Write blocks until there are no more blocks to write
			from
				create {RAW_FILE} l_file.make_with_path (file.path)
				l_file.open_read
				i := header_writer.required_blocks
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
			header_state_unchanged: (old header_writer.finished_writing) = header_writer.finished_writing
			file_pointer_unchanged: (old file.file_pointer) = file.file_pointer
		end

feature {NONE} -- Implementation

	generate_header
			-- Generate header once file is set up properly
		require
			file_attached: file /= Void
		do
			create header.make
			header.set_filename (file.path)
			header.set_mode (file.protection.as_natural_16)
			header.set_user_id (file.user_id.as_natural_32)
			header.set_group_id (file.group_id.as_natural_32)
			header.set_size (file.file_info.size.as_natural_64)
			header.set_mtime (file.date.as_natural_64)
			header.set_typeflag ({TAR_CONST}.tar_typeflag_regular_file)
			header.set_user_name (file.owner_name)
			header.set_group_name (file.file_info.group_name)
		end

	file: FILE
			-- The file this ARCHIVABLE represents

end
