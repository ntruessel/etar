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
			header_written := false
		end

feature -- Status

	finished_writing: BOOLEAN
			-- Indicates whether the whole file was written
		do
			Result := file.is_closed
		end

	required_space: INTEGER
			-- Indicate how much space is needed to represent this ARCHIVABLE
		do
			Result := (1 + needed_blocks (file.file_info.size)) * {TAR_CONST}.tar_block_size
		end

feature -- Output

	write_block_to_managed_pointer (p: MANAGED_POINTER; pos: INTEGER)
			-- Write the next block to `p' starting at `pos'
		do
			if (not header_written) then
				-- Write header
				write_header (p, pos)
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
			l_old_header_written: BOOLEAN
			l_file: FILE
			i: INTEGER
			padding: SPECIAL[CHARACTER_8]
		do
			l_old_header_written := header_written
			write_header (p, pos)
			header_written := l_old_header_written

			-- Write blocks until there are no more blocks to write
			from
				create {RAW_FILE} l_file.make_with_path (file.path)
				l_file.open_read
				i := 1
			until
				i /= 1 and l_file.bytes_read /= {TAR_CONST}.tar_block_size
			loop
				l_file.read_to_managed_pointer (p, pos + {TAR_CONST}.tar_block_size * i, {TAR_CONST}.tar_block_size)
				i := i + 1
			end

			-- Fill with '%U'
			i := i - 1
			pad (p, pos + {TAR_CONST}.tar_block_size * i + l_file.bytes_read, {TAR_CONST}.tar_block_size - l_file.bytes_read)

			-- Close file
			l_file.close
		ensure then
			header_state_unchanged: (old header_written) = header_written
			file_pointer_unchanged: (old file.file_pointer) = file.file_pointer
		end

feature {NONE} -- Implementation

	file: FILE
			-- The file this ARCHIVABLE represents

	header_writer: TAR_HEADER_WRITER
			-- The header writer to use

	header_written: BOOLEAN
			-- Indicates whether the header was already written

	write_header (p: MANAGED_POINTER; pos: INTEGER)
			-- Write header for `file' to `p' starting at `pos'
		require
			not_written_yet: not header_written
			enough_space: p.count >= pos + {TAR_CONST}.tar_block_size
		local
			header: TAR_HEADER
		do
			create header.make
			header.set_from_fileinfo (file.file_info)
			header_writer.write_to_managed_pointer (header, p, pos)
			header_written := True
		end

end
