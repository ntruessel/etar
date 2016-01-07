note
	description: "[
		Simple directory unarchiver that creates a new directory on disk (if it does not exist)
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	DIRECTORY_UNARCHIVER

inherit
	UNARCHIVER
		redefine
			default_create
		end

feature {NONE} -- Initialization

	default_create
			-- Create new instance
		do
			name := "directory to disk unarchiver"

			Precursor
		end

feature -- Status

	can_unarchive (a_header: TAR_HEADER): BOOLEAN
			-- Instances of this class can unarchive every header that belongs to a directory
		do
			Result := a_header.typeflag = {TAR_CONST}.tar_typeflag_directory
		end

	required_blocks: INTEGER
			-- Indicate how many blocks are required to unarchive the payload that belongs to `active_header'
		do
--			Result := 0
		end

feature -- Output

	unarchive_block (p: MANAGED_POINTER; a_pos: INTEGER)
			-- Unarchive block `p' starting at `a_pos'
			-- Since directories are header only entries, there is nothing to do
		do
			-- do_nothing
		end

feature {NONE} -- Implementation

	do_internal_initialization
			-- Setup internal structures after initialize has run
		local
			l_directory: DIRECTORY
		do
			if attached active_header as header then
				create l_directory.make_with_path (header.filename)
				if not l_directory.exists then
					l_directory.recursive_create_dir
				end
				set_metadata (l_directory)
			end
		end

	set_metadata (a_directory: DIRECTORY)
			-- Set the correct metadata for `a_directory' according to `header'
		require
			directory_exists: a_directory.exists
		local
			l_file: FILE -- Since DIRECTORY does not support metadata setting
		do
			if attached active_header as l_header then
				create {RAW_FILE} l_file.make_with_path (a_directory.path)
				file_set_metadata (l_file, l_header)
			else
				check false end -- Unreachable
				-- FIXME: Better error handling
			end
		end
end
