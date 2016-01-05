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

	make (a_directory: FILE)
			-- Create new DIRECTORY_ARCHIVABLE for `a_directory'
		require
			directory_exists: a_directory.exists
			is_directory: a_directory.is_directory
		do
			create {RAW_FILE} directory.make_with_path (a_directory.path)
		end

feature -- Status

	required_blocks: INTEGER
			-- Indicates how many blocks are required to store this instance
		do
			Result := 0
		end

	header: TAR_HEADER
			-- Header that belongs to the payload
		do
			create Result
			Result.set_filename (directory.path)
			Result.set_mode (directory.protection.to_natural_16)
			Result.set_user_id (directory.user_id.to_natural_32)
			Result.set_group_id (directory.group_id.to_natural_32)
			Result.set_mtime (directory.date.to_natural_64)
			Result.set_user_name (directory.owner_name)
			Result.set_group_name (directory.file_info.group_name)
			Result.set_typeflag ({TAR_CONST}.tar_typeflag_directory)
		end

feature -- Output

	write_block_to_managed_pointer (p: MANAGED_POINTER; a_pos: INTEGER)
			-- Write the next block to `p', starting at `a_pos'
		do
			-- do_nothing (impossible to call)
		end

feature {NONE} -- Implementation

	directory: FILE
			-- the directory this instance represents/wraps
			-- unfortunately, DIRECTORY does not provide enough metadata to use it

invariant
	no_payload: required_blocks = 0

end
