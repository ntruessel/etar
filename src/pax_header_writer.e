note
	description: "[
		Header writer for the pax format
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=Further information about the PAX format", "src=http://pubs.opengroup.org/onlinepubs/9699919799/utilities/pax.html#tag_20_92_13_01", "tag=pax"

class
	PAX_HEADER_WRITER

inherit
	TAR_HEADER_WRITER
	redefine
		default_create
	end

	ANY
	redefine
		default_create
	end

feature {NONE} -- Initialization

	default_create
			-- Create new PAX_HEADER_WRITER object
		do
			create ustar_writer
		end

feature -- Status

	required_blocks: INTEGER
			-- Indicates how many blocks are needed to write `active_header'
		do
			if attached pax_payload as l_pax_payload then
				Result := 2 + needed_blocks (l_pax_payload.count)
			else
				Result := ustar_writer.required_blocks
			end
		end

	can_write (a_header: TAR_HEADER): BOOLEAN
			-- Whether `a_header' can be written
		once
			Result := True
		end

feature -- Output

	write_to_managed_pointer (p: MANAGED_POINTER; a_pos: INTEGER)
			-- Write the whole `active_header' to `p', starting at `pos'
			-- Does not modify blockwise writing state
		local
			i: INTEGER
			l_ustar_writer: USTAR_HEADER_WRITER
		do
			if attached active_header as l_ustar_header then
				if attached pax_header as l_pax_header and attached pax_payload as l_pax_payload then

				end
			else
				-- Unreachable (precondition)
			end
		end

	write_block_to_managed_pointer (p: MANAGED_POINTER; a_pos: INTEGER)
			-- Write next block to `p', starting at `pos'
		do
			if attached pax_header as l_pax_header and attached pax_payload as l_pax_payload then
				if written_blocks = 0 then
					-- write pax header
					ustar_writer.set_active_header (l_pax_header)
					ustar_writer.write_block_to_managed_pointer (p, a_pos)
				elseif written_blocks = required_blocks - 2 then
					-- write (modified) ustar header
					if attached active_header as l_ustar_header then
						ustar_writer.set_active_header (l_ustar_header)
						ustar_writer.write_block_to_managed_pointer (p, a_pos)
					else
						-- Unreachable (precondition)
					end
				else
					-- write pax payload

						-- fill with NUL
					p.put_special_character_8 (create {SPECIAL [CHARACTER_8]}.make_filled ('%U', {TAR_CONST}.tar_block_size), 0, a_pos, {TAR_CONST}.tar_block_size)

						-- put next payload block
					p.put_special_character_8 (l_pax_payload.area, (written_blocks - 1) * {TAR_CONST}.tar_block_size, a_pos,
								{TAR_CONST}.tar_block_size.min (l_pax_payload.count - (written_blocks - 1) * {TAR_CONST}.tar_block_size))
				end
			else
				if attached active_header as l_ustar_header then
					ustar_writer.write_block_to_managed_pointer (p, a_pos)
				end

			end
			written_blocks := written_blocks + 1
		end

feature {NONE} -- Implementation

	ustar_writer: USTAR_HEADER_WRITER
			-- used to write headers that fit in ustar headers

	prepare_header
			-- Prepare `active_header' after it was set
		local
			l_pax_payload: STRING_8
			l_pax_header: TAR_HEADER
		do
			if attached active_header as l_ustar_header then
				if not ustar_writer.can_write (l_ustar_header) then
					create l_pax_payload.make_empty
					pax_payload := l_pax_payload

						-- Identify problem fields, write them to payload and simplify ustar header
					if not ustar_writer.filename_fits (l_ustar_header) then
							-- put filename in pax header
						pax_payload_put ({TAR_HEADER_CONST}.name_pax_key, unify_utf_8_path (l_ustar_header.filename))

							-- simplify filename
						l_ustar_header.set_filename (create {PATH}.make_from_string (
								unify_utf_8_path (l_ustar_header.filename).head ({TAR_HEADER_CONST}.name_length)))

					end

					if not ustar_writer.user_id_fits (l_ustar_header) then
							-- put userid in pax header
						pax_payload_put ({TAR_HEADER_CONST}.uid_pax_key, l_ustar_header.user_id.out)	-- pax takes decimal numbers

							-- simplify userid
						l_ustar_header.set_user_id (0)
					end

					if not ustar_writer.group_id_fits (l_ustar_header) then
							-- put groupid in pax header
						pax_payload_put ({TAR_HEADER_CONST}.gid_pax_key, l_ustar_header.group_id.out)	-- pax takes decimal numbers

							-- simplify groupid
						l_ustar_header.set_group_id (0)
					end

					if not ustar_writer.size_fits (l_ustar_header) then
							-- put size in pax header
						pax_payload_put ({TAR_HEADER_CONST}.size_pax_key, l_ustar_header.size.out) 		-- pax takes decimal numbers

							-- simplify size
						l_ustar_header.set_size (0)
					end

					if not ustar_writer.mtime_fits (l_ustar_header) then
							-- put mtime in pax header
						pax_payload_put ({TAR_HEADER_CONST}.mtime_pax_key, l_ustar_header.mtime.out)	-- pax takes decimal numbers

							-- simplify mtime
						l_ustar_header.set_mtime (0)
					end

					if not ustar_writer.linkname_fits (l_ustar_header) then
							-- put linkname in pax header
						pax_payload_put ({TAR_HEADER_CONST}.linkname_pax_key, unify_utf_8_path (l_ustar_header.linkname))

							-- simplify linkname
						l_ustar_header.set_linkname (create {PATH}.make_from_string (
								unify_utf_8_path (l_ustar_header.linkname).head ({TAR_HEADER_CONST}.linkname_length)))
					end

					if not ustar_writer.user_name_fits (l_ustar_header) then
							-- put username in pax header
						pax_payload_put ({TAR_HEADER_CONST}.uname_pax_key, l_ustar_header.user_name)

							-- simplify username
						l_ustar_header.set_user_name (l_ustar_header.user_name.head ({TAR_HEADER_CONST}.uname_length))
					end

					if not ustar_writer.group_name_fits (l_ustar_header) then
							-- put groupname in pax header
						pax_payload_put ({TAR_HEADER_CONST}.gname_pax_key, l_ustar_header.group_name)

							-- simplify groupname
						l_ustar_header.set_group_name (l_ustar_header.group_name.head ({TAR_HEADER_CONST}.gname_length))
					end

						-- Generate pax header
					create l_pax_header.make

					l_pax_header.set_filename (create {PATH}.make_from_string ({TAR_CONST}.pax_header_filename))
					l_pax_header.set_user_id ({TAR_CONST}.pax_header_uid)
					l_pax_header.set_group_id ({TAR_CONST}.pax_header_gid)
					l_pax_header.set_mode ({TAR_CONST}.pax_header_mode)
					l_pax_header.set_size (l_pax_payload.count.as_natural_64)

					pax_header := l_pax_header

				else
					pax_header := Void
					pax_payload := Void
					ustar_writer.set_active_header (l_ustar_header)
				end
			else
				-- Unreachable (precondition)
			end
		end

	pax_payload_put (a_key: STRING_8; a_value: STRING_8)
			-- Put `a_entry' in `pax_payload'
			-- Entries are of the form: length key=value%N
			-- where length denotes the length of the whole entry including length itself and %N

		require
			has_pax_payload: attached pax_payload
		local
			l_entry_length: INTEGER
		do
			if attached pax_payload as l_pax_payload then

					-- Calculate the length part of the entry
				from
					l_entry_length := a_key.count + a_value.count + 3	-- Three extra characters
				until
					l_entry_length = a_key.count + a_value.count + 3 + l_entry_length.out.count
				loop
					l_entry_length := a_key.count + a_value.count + 3 + l_entry_length.out.count
				end

					-- Put entry
				l_pax_payload.append (l_entry_length.out)
				l_pax_payload.append_character (' ')
				l_pax_payload.append (a_key)
				l_pax_payload.append_character ('=')
				l_pax_payload.append (a_value)
				l_pax_payload.append_character ('%N')

			end
		end

	pax_payload: detachable STRING_8
			-- If `active_header' does not fit in a single ustar header, this contains
			-- the additional payload for the pax header.
			-- These are entries of the form: length key=value%N
			-- where length denotes the length of the whole entry including length itself and %N

	pax_header: detachable TAR_HEADER
			-- The header for the pax payload

	needed_blocks (n: INTEGER): INTEGER
			-- Indicate how many blocks are needed to represent `n' bytes
		require
			non_negative_bytes: n >= 0
		do
			Result := (n + {TAR_CONST}.tar_block_size - 1) // {TAR_CONST}.tar_block_size
		ensure
			bytes_fit: n <= Result * {TAR_CONST}.tar_block_size
			smallest_fit: (Result - 1) * {TAR_CONST}.tar_block_size < n
		end

invariant
	both_pax_header_and_payload: attached pax_header = attached pax_payload
	pax_header_writable: attached pax_header as l_header implies ustar_writer.can_write (l_header)
	active_header_writable: attached active_header as l_header implies ustar_writer.can_write (l_header)

end
