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
			file.close
			header_writer := a_header_writer
		end

feature -- Status

	finished_writing: BOOLEAN
			-- Indicates whether the whole file was written
		do
			Result := file.off
		end

	required_space: INTEGER
			-- Indicate how much space is needed to represent this ARCHIVABLE
		do
			Result := {TAR_CONST}.tar_block_size
		end

feature -- Output

	write_block_to_managed_pointer (p: MANAGED_POINTER; pos: INTEGER)
			-- Write the next block to `p' starting at `pos'
		do
			if (file.is_closed) then
				-- Write header and open
				write_header (p, pos)
				file.open_read
			else
				-- Write next block
				file.read_to_managed_pointer (p, pos, {TAR_CONST}.tar_block_size)
			end
		end

	write_to_managed_pointer (p: MANAGED_POINTER; pos: INTEGER)
			-- Write the whole file to `p' starting at `pos'
		do
		end

feature {NONE} -- Implementation

	file: FILE
			-- The file this ARCHIVABLE represents

	header_writer: TAR_HEADER_WRITER
			-- The header writer to use

	write_header (p: MANAGED_POINTER; pos: INTEGER)
			-- Write header for `file' to `p' starting at `pos'
		require
			not_written_yet: file.is_closed
		local
			header: TAR_HEADER
		do
			create header.make
			header.set_from_fileinfo (file.file_info)
			header_writer.write_to_managed_pointer (header, p, pos)
		end

end
