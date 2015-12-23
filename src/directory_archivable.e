note
	description: "[
		ARCHIVABLE wrapper for DIRECTORY
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	DIRECTORY_ARCHIVABLE

inherit
	ARCHIVABLE

create
	make

feature {NONE} -- Initialization

	make (a_directory: FILE; a_header_writer: TAR_HEADER_WRITER)
			-- Create new DIRECTORY_ARCHIVABLE for `a_directory'
		require
			directory_exists: a_directory.exists
			is_directory: a_directory.is_directory
		do
			create {RAW_FILE} directory.make_with_path (a_directory.path)
			header_writer := a_header_writer

			generate_header
		end

feature -- Status

	required_blocks: INTEGER
			-- Indicates how many blocks are required to store this instance
		do
			Result := header_writer.required_blocks
		end

	finished_writing: BOOLEAN
			-- Indicate whether everything has been written
		do
			Result := header_writer.finished_writing
		end

feature -- Output

	write_block_to_managed_pointer (p: MANAGED_POINTER; a_pos: INTEGER)
			-- Write the next block to `p', starting at `a_pos'
		do
			header_writer.write_block_to_managed_pointer (p, a_pos)
		end

	write_to_managed_pointer (p: MANAGED_POINTER; a_pos: INTEGER)
			-- Write the whole representation to `p', starting at `a_pos'
		do
			header_writer.write_to_managed_pointer (p, a_pos)
		end

feature {NONE} -- Implementation

	directory: FILE
			-- the directory this instance represents/wraps
			-- unfortunately, DIRECTORY does not provide enough metadata to use it

	generate_header
			-- Generate `header' once `directory' is set correctly
		do
			create header.make
			header.set_from_fileinfo (directory.file_info)
		end

end
