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

feature -- Access: error

	has_error: BOOLEAN
			-- Error occurred?
		do
			Result := attached error_messages as lst and then not lst.is_empty
		end

	reset_error
			-- Reset errors.
		do
			error_messages := Void
		ensure
			has_no_error: not has_error
		end

	report_error (a_message: READABLE_STRING_GENERAL)
			-- Report error message `a_message'.
		local
			lst: like error_messages
		do
			lst := error_messages
			if lst = Void then
				create {ARRAYED_LIST [READABLE_STRING_32]} lst.make (1)
				error_messages := lst
			end
			lst.force (a_message.as_string_32)
		ensure
			has_error: has_error
		end

	error_messages: detachable LIST [READABLE_STRING_32]
			-- Error messages.

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

							-- must be natural and number of remaining characters must be non-negative
						if active_entry.is_natural and then active_entry.to_integer - active_entry.count - 2 >= 0 then
								-- Set expected length: parsed length - length of length-representation - space - newline
							active_entry_expected_length := active_entry.to_integer - active_entry.count - 2
							active_entry.grow (active_entry.to_integer)
							active_entry.wipe_out
						else
							report_error ("Invalid length field: " + active_entry)
							active_entry_expected_length := -1
						end
					when '%N' then
							-- newline separates entry from next entry
						if i = active_entry_expected_length then
							add_entry (active_entry)
						elseif active_entry_expected_length >= 0 then
							report_error ("Entry with wrong length. Expected: " + active_entry_expected_length.out + ". Actual: " + active_entry.count.out + ". Entry: " + active_entry)
						end
						active_entry.wipe_out
						active_entry_expected_length := 0
					else
						if active_entry_expected_length >= 0 then
							active_entry.append_character (c)
						end
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

	active_entry_expected_length: INTEGER
			-- Indicates what length the active entry should have
			-- negative on error

	add_entry (a_entry: STRING_8)
			-- Add `a_entry' to entries (have to split it at '=' character)
		local
			l_first_equals_position: INTEGER
		do
			l_first_equals_position := a_entry.index_of ('=', 1)
			if (l_first_equals_position > 1 and l_first_equals_position < a_entry.count) then
				entries.put (a_entry.substring (l_first_equals_position + 1, a_entry.count), a_entry.substring (1, l_first_equals_position - 1))
			else
				if (l_first_equals_position = 0) then
					report_error ("Entry without equals sign: " + a_entry)
				elseif (l_first_equals_position = 1) then
					report_error ("Entry without key: " + a_entry)
				elseif (l_first_equals_position = a_entry.count) then
					report_error ("Entry without value: " + a_entry)
				end
			end
		end

invariant
	use_object_comparison: entries.object_comparison

end
