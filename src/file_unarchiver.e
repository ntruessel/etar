note
	description: "[
		Simple file unarchiver that creates a new file on disk
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	FILE_UNARCHIVER

inherit
	UNARCHIVER

feature -- Status

	can_unarchive (a_header: TAR_HEADER): BOOLEAN
			-- Instances of this class can unarchive every header that belongs to a basic file
		do
			Result := a_header.typeflag = {TAR_CONST}.tar_typeflag_regular_file or a_header.typeflag = {TAR_CONST}.tar_typeflag_regular_file_old
		end

feature -- Output

	unarchive_block (p: MANAGED_POINTER; pos: INTEGER)
			-- Unarchive block `p' starting at `pos'
		local
			remaining_bytes: NATURAL_64
		do
			if attached active_file as l_file and attached active_header as l_header then
				-- Check whether this is the last block
				remaining_bytes := l_header.size - (unarchived_blocks * {TAR_CONST}.tar_block_size).as_natural_64
				if remaining_bytes <= {TAR_CONST}.tar_block_size.as_natural_64 then
					-- Last block
					l_file.put_managed_pointer (p, pos, remaining_bytes.as_integer_32)
					unarchiving_finished := True
					finalize_file
				else
					-- Standard block
					l_file.put_managed_pointer (p, pos, {TAR_CONST}.tar_block_size)
				end
				unarchived_blocks := unarchived_blocks + 1
			else
				check false end -- Unreachable
				-- FIXME: Better error handling
			end
		end

feature {NONE} -- Implementation

	do_internal_initialization
			-- Setup internal structures after initialize has run
		local
			l_file: FILE
		do
			if attached active_header as l_header then
				create {RAW_FILE} l_file.make_with_path (l_header.filename)
				l_file.open_write
				active_file := l_file
			else
				check false end -- Unreachable, when do_internal_initialization is called, active_header references an attached TAR_HEADER object
				-- FIXME: Better error handling
			end
		end

	finalize_file
			-- Do final changes to the active file (called after the last block was written)
		do
			if attached active_file as l_file and attached active_header as l_header then
				l_file.change_mode (l_header.mode)
				l_file.set_date (l_header.mtime.as_integer_32)

				-- Check username with id first
				if (file_owner (l_header.user_id.as_integer_32) ~ l_header.user_name) then
					l_file.change_owner (l_header.user_id.as_integer_32)
				end
				-- Check groupname with id first
				if (file_group (l_header.group_id.as_integer_32) ~ l_header.group_name) then
					l_file.change_group (l_header.group_id.as_integer_32)
				end

				l_file.flush
				l_file.close
			else
				check false end -- Unreachable
				-- FIXME: Better error handling
			end
		end

	active_file: detachable FILE
			-- File that is currently unarchived	

end
