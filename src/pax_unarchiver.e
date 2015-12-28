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
			create entries.make_equal (3)	-- pax provides atime, mtime and ctime
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

	get_value (a_key: STRING_8): detachable READABLE_STRING_8
			-- Get value corresponding to `a_key'
			-- Returns void if there is none
		do
			Result := entries.item (a_key)
		end

feature -- Unarchiving

	unarchive_block (p: MANAGED_POINTER; a_pos: INTEGER)
			-- Unarchive next block, stored in `p' starting at `a_pos'
			-- the payload has the form
			-- length key=value%N
		local
			i: INTEGER
			c: CHARACTER_8
		do
			if attached active_header as l_header then
				from
					i := 0
				until
					i >= {TAR_CONST}.tar_block_size or
					i.as_natural_64 >= l_header.size - (unarchived_blocks * {TAR_CONST}.tar_block_size).as_natural_64
				loop
					c := p.read_character (a_pos + 1)
					inspect c
					when ' ' then
							-- whitespace separates length from key and value
							-- -> resize active_entry
						if active_entry.is_integer then
							active_entry.grow (active_entry.to_integer)
							active_entry.wipe_out
						else
							-- Report error
						end
					when '%N' then
							-- newline separates entry from next entry
						add_entry (active_entry)
						active_entry.wipe_out
					else
						active_entry.append_character (c)
					end
					i := i + 1
				end
			else
				-- Unreachable (precondition)
			end
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

	add_entry (a_entry: STRING_8)
			-- Add `a_entry' to entries (have to split it at '=' character)
		local
			l_first_equals_position: INTEGER
		do
			l_first_equals_position := a_entry.index_of ('=', 1)
			if (l_first_equals_position > 1 and l_first_equals_position < a_entry.count) then
				entries.put (a_entry.substring (l_first_equals_position + 1, a_entry.count), a_entry.substring (1, l_first_equals_position - 1))
			else
				-- Report error
			end
		end

invariant
	use_object_comparison: entries.object_comparison

end
