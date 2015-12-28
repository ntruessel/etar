note
	description: "[
		ARCHIVABLE for pax headers, mainly used by PAX_HEADER_WRITER
		
		A pax archivable models the pax extended header payload
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PAX_ARCHIVABLE

inherit
	ARCHIVABLE

create
	make_empty,
	make_from_payload

feature {NONE} -- Initialization

	make_empty
			-- Create new pax archivable with empty payload
		do
			create payload.make_empty
		end

	make_from_payload (a_payload: STRING_8)
			-- Create new pax archivable with `a_payload' as payload
		do
			make_empty
			payload := a_payload
		end

feature -- Status

	required_blocks: INTEGER
			-- Indicates how many payload blocks this instance needs
		do
			Result := needed_blocks (payload.count)
		end

	header: TAR_HEADER
			-- Header that belongs to the payload
		do
			create Result.make

			Result.set_filename (create {PATH}.make_from_string ({TAR_CONST}.pax_header_filename))
			Result.set_user_id ({TAR_CONST}.pax_header_uid)
			Result.set_group_id ({TAR_CONST}.pax_header_gid)
			Result.set_mode ({TAR_CONST}.pax_header_mode)
			Result.set_size (payload.count.as_natural_64)
		end

feature -- Output

	write_block_to_managed_pointer (p: MANAGED_POINTER; a_pos: INTEGER)
			-- Writes next payload block to `p', starting at `a_pos'
		do
			-- TODO
		end

	write_to_managed_pointer (p: MANAGED_POINTER; a_pos: INTEGER)
			-- Writes whole payload to `p', starting at `a_pos'
		do
			-- TODO
		end

feature {NONE} -- Implementation

	payload: STRING_8
			-- pax payload
			-- one line per entry, each entry has the form
			-- length key=value%N
			-- where length is the length of the whole line including
			-- length itself and the %N character

end
