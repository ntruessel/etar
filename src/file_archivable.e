note
	description: "Summary description for {FILE_ARCHIVABLE}."
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
			file := a_file.twin
			file.open_read
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
		local
			header: TAR_HEADER
			padding: SPECIAL[CHARACTER_8]
		do
			if (not header_written) then
				-- Write header
				write_header (p, pos)
			else
				-- Write next block
				file.read_to_managed_pointer (p, pos, {TAR_CONST}.tar_block_size)
				if (file.end_of_file) then
					-- Fill with '%U'
					create padding.make_filled ('%U', {TAR_CONST}.tar_block_size - file.bytes_read)
					p.put_special_character_8 (padding, 0, pos + file.bytes_read, padding.count)

					-- Close file
					file.close
				end
			end
		end

	write_to_managed_pointer (p: MANAGED_POINTER; pos: INTEGER)
			-- Write the whole file to `p' starting at `pos'
			-- Does not change the state of blockwise writing
		do
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
		local
			header: TAR_HEADER
		do
			create header.make
			header.set_from_fileinfo (file.file_info)
			header_writer.write_to_managed_pointer (header, p, pos)
			header_written := True
		end

end
