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
			if attached pax_archivable as l_pax_archivable then
					-- FIXME: Relies on ustar_writer implemenation (exploits that both headers are the same size)
				Result := 2 * ustar_writer.required_blocks + l_pax_archivable.required_blocks
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
			-- Write the whole `active_header' to `p', starting at `a_pos'
			-- Does not modify blockwise writing state
		local
			i: INTEGER
			l_ustar_writer: USTAR_HEADER_WRITER
		do
			create l_ustar_writer

			if attached active_header as l_ustar_header then
				i := 0

				if attached pax_archivable as l_pax_archivable then
						-- Pax header
					l_ustar_writer.set_active_header (l_pax_archivable.header)
					from
					until
						l_ustar_writer.finished_writing
					loop
						l_ustar_writer.write_block_to_managed_pointer (p, a_pos + i * {TAR_CONST}.tar_block_size)
						i := i + 1
					end

						-- Pax payload
					l_pax_archivable.write_to_managed_pointer (p, a_pos + i * {TAR_CONST}.tar_block_size)
					i := i + l_pax_archivable.required_blocks

				end
					-- Ustar header
				l_ustar_writer.set_active_header (l_ustar_header)
				l_ustar_writer.write_to_managed_pointer (p, a_pos + i * {TAR_CONST}.tar_block_size)
			else
				-- Unreachable (precondition)
			end
		end

	write_block_to_managed_pointer (p: MANAGED_POINTER; a_pos: INTEGER)
			-- Write next block to `p', starting at `a_pos'
		do
			if attached pax_archivable as l_pax_archivable then
				if written_blocks = 0 then
						-- write pax header
					ustar_writer.set_active_header (l_pax_archivable.header)
					ustar_writer.write_block_to_managed_pointer (p, a_pos)
				elseif written_blocks = required_blocks - 1 then
						-- write (modified) ustar header
					if attached active_header as l_ustar_header then
						ustar_writer.set_active_header (l_ustar_header)
						ustar_writer.write_block_to_managed_pointer (p, a_pos)
					else
						-- Unreachable (precondition)
					end
				else
						-- write pax payload
					l_pax_archivable.write_block_to_managed_pointer (p, a_pos)
				end
			else
				ustar_writer.write_block_to_managed_pointer (p, a_pos)
			end
			written_blocks := written_blocks + 1
		end

feature {NONE} -- Implementation

	ustar_writer: USTAR_HEADER_WRITER
			-- used to write headers that fit in ustar headers

	prepare_header
			-- Prepare `active_header' after it was set
		local
			l_pax_archivable: PAX_ARCHIVABLE
		do
			if attached active_header as l_ustar_header then
				if not ustar_writer.can_write (l_ustar_header) then
					create l_pax_archivable.make_empty

						-- Identify problem fields, write them to payload and simplify ustar header
					if not ustar_writer.filename_fits (l_ustar_header) then
							-- put filename in pax header
						l_pax_archivable.put ({TAR_HEADER_CONST}.name_pax_key, unify_utf_8_path (l_ustar_header.filename))

							-- simplify filename
						l_ustar_header.set_filename (create {PATH}.make_from_string (
								unify_utf_8_path (l_ustar_header.filename).head ({TAR_HEADER_CONST}.name_length)))

					end

					if not ustar_writer.user_id_fits (l_ustar_header) then
							-- put userid in pax header
						l_pax_archivable.put ({TAR_HEADER_CONST}.uid_pax_key, l_ustar_header.user_id.out)	-- pax takes decimal numbers

							-- simplify userid
						l_ustar_header.set_user_id (0)
					end

					if not ustar_writer.group_id_fits (l_ustar_header) then
							-- put groupid in pax header
						l_pax_archivable.put ({TAR_HEADER_CONST}.gid_pax_key, l_ustar_header.group_id.out)	-- pax takes decimal numbers

							-- simplify groupid
						l_ustar_header.set_group_id (0)
					end

					if not ustar_writer.size_fits (l_ustar_header) then
							-- put size in pax header
						l_pax_archivable.put ({TAR_HEADER_CONST}.size_pax_key, l_ustar_header.size.out) 		-- pax takes decimal numbers

							-- simplify size
						l_ustar_header.set_size (0)
					end

					if not ustar_writer.mtime_fits (l_ustar_header) then
							-- put mtime in pax header
						l_pax_archivable.put ({TAR_HEADER_CONST}.mtime_pax_key, l_ustar_header.mtime.out)	-- pax takes decimal numbers

							-- simplify mtime
						l_ustar_header.set_mtime (0)
					end

					if not ustar_writer.linkname_fits (l_ustar_header) then
							-- put linkname in pax header
						l_pax_archivable.put ({TAR_HEADER_CONST}.linkname_pax_key, unify_utf_8_path (l_ustar_header.linkname))

							-- simplify linkname
						l_ustar_header.set_linkname (create {PATH}.make_from_string (
								unify_utf_8_path (l_ustar_header.linkname).head ({TAR_HEADER_CONST}.linkname_length)))
					end

					if not ustar_writer.user_name_fits (l_ustar_header) then
							-- put username in pax header
						l_pax_archivable.put ({TAR_HEADER_CONST}.uname_pax_key, l_ustar_header.user_name)

							-- simplify username
						l_ustar_header.set_user_name (l_ustar_header.user_name.head ({TAR_HEADER_CONST}.uname_length))
					end

					if not ustar_writer.group_name_fits (l_ustar_header) then
							-- put groupname in pax header
						l_pax_archivable.put ({TAR_HEADER_CONST}.gname_pax_key, l_ustar_header.group_name)

							-- simplify groupname
						l_ustar_header.set_group_name (l_ustar_header.group_name.head ({TAR_HEADER_CONST}.gname_length))
					end

					pax_archivable := l_pax_archivable
					ustar_writer.set_active_header (l_pax_archivable.header)
				else
					pax_archivable := Void
					ustar_writer.set_active_header (l_ustar_header)
				end
			else
				-- Unreachable (precondition)
			end
		ensure then
			ustar_header_attached: attached ustar_writer.active_header
		end

	pax_archivable: detachable PAX_ARCHIVABLE
			-- pax payload, attached if the current header does not fit into at ustar header

invariant
	active_header_writable: attached active_header as l_header implies ustar_writer.can_write (l_header)

end
