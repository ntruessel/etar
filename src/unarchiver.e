note
	description: "[
		Common ancestor for classes that allow to unarchive payload parts of archives
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	UNARCHIVER

inherit
	ANY
	redefine
		default_create
	end

feature {NONE} -- Initialization

	default_create
				-- Default initialization for UNARCHIVER
		do
			unarchiving_finished := True
--			active_header := Void
--			unarchived_blocks := 0
		ensure then
			no_unarchiving_in_progress: unarchiving_finished
		end

feature -- Status

	unarchiving_finished: BOOLEAN
			-- Flag that indicates whether unarchiving finished

	active_header: detachable TAR_HEADER
			-- The header for which unarchiving is in progress

	unarchived_blocks: INTEGER
			-- How many blocks have been unarchived so far

	can_unarchive (a_header: TAR_HEADER): BOOLEAN
			-- Indicate whether this type of unarchiver can unarchive payload with
			-- header `a_header'
		deferred
		end

feature -- Unarchiving

	frozen initialize (a_header: TAR_HEADER)
			-- Initialize for unarchiving payload for `a_header'
		require
			can_handle: can_unarchive (a_header)
			no_unarchiving_in_progress: unarchiving_finished
		do
			active_header := a_header
			unarchiving_finished := False
			unarchived_blocks := 0
			do_internal_initialization
		ensure
			header_attached: attached active_header
			nothing_unarchived: unarchived_blocks = 0
			unarchiving_in_progress: not unarchiving_finished
		end

	unarchive_block (p: MANAGED_POINTER; pos: INTEGER)
			-- Unarchive next block, stored in `p' starting at `pos'
		require
			non_negative_position: pos >= 0
			enough_payload: p.count >= pos + {TAR_CONST}.tar_block_size
			header_attached: attached active_header
			not_finished: not unarchiving_finished
		deferred
		ensure
			another_block_unarchived: unarchived_blocks = old unarchived_blocks + 1
			still_attached: attached active_header
			last_block_unarchived_iff_finished: attached active_header as header and then ((unarchived_blocks = needed_blocks (header.size)) = unarchiving_finished)
		end

feature {NONE} -- Implementation

	do_internal_initialization
			-- Initialize subclass specific internals after initialize has done its job
		deferred
		end

feature {NONE} -- Utilites

	needed_blocks (n: NATURAL_64): NATURAL_64
			-- Indicate how many blocks are needed to represent `n' bytes
		do
			Result := (n + {TAR_CONST}.tar_block_size.as_natural_64 - 1) // {TAR_CONST}.tar_block_size.as_natural_64
		ensure
			bytes_fit: n <= Result * {TAR_CONST}.tar_block_size.as_natural_64
			smallest_fit: Result * {TAR_CONST}.tar_block_size.as_natural_64 < n + {TAR_CONST}.tar_block_size.as_natural_64
		end

feature {NONE} -- Utilities stolen from file_info

	file_owner (uid: INTEGER): STRING
			-- Convert UID to login name if possible
		external
			"C signature (int): EIF_REFERENCE use %"eif_file.h%""
		alias
			"eif_file_owner"
		end

	file_group (gid: INTEGER): STRING
			-- Convert GID to group name if possible
		external
			"C signature (int): EIF_REFERENCE use %"eif_file.h%""
		alias
			"eif_file_group"
		end

invariant
	unarchiving_in_progress_needs_header: not unarchiving_finished implies attached active_header
	unarchived_blocks_needs_header: unarchived_blocks > 0 implies attached active_header
	non_negative_number_of_blocks: unarchived_blocks >= 0

end
