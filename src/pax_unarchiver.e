note
	description: "[
		UNARCHIVER for pax payload
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PAX_UNARCHIVER

inherit
	UNARCHIVER
	redefine
		default_create
	end

feature -- Initialization

	default_create
			-- Initialize unarchiver
		do
			Precursor

				-- Initialize internals. Capacities chosen from gnutar's default pax entries
			create entries.make (3)			-- pax provides atime, mtime and ctime
			create active_entry.make_empty  -- we read length field first, then adjust size appropriately
		end

feature -- Status

	can_unarchive (a_header: TAR_HEADER): BOOLEAN
			-- Indicate whether this type of unarchiver can unarchive payload with
			-- header `a_header'
		do
			Result := a_header.typeflag = {TAR_CONST}.tar_typeflag_pax_extended or
						a_header.typeflag = {TAR_CONST}.tar_typeflag_pax_global
		end

feature -- Status

	unarchive_block (p: MANAGED_POINTER; pos: INTEGER)
			-- Unarchive next block, stored in `p' starting at `pos'
		do
			-- TODO
		end

feature {NONE} -- Implementation

	do_internal_initialization
			-- Initialize subclass specific internals after initialize has done its job
		do
			entries.wipe_out
			active_entry.wipe_out
		end

	entries: HASH_TABLE [STRING_8, STRING_8]
			-- The entries in the current payload

	active_entry: STRING_8
			-- The entry for which reading is in progress

end
