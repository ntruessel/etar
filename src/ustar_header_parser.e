note
	description: "[
		Header parser for the ustar header format
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	USTAR_HEADER_PARSER

inherit
	TAR_HEADER_PARSER

	OCTAL_UTILS
		export
			{NONE} all
		end

feature -- Parsing

	parse_block (block: MANAGED_POINTER; pos: INTEGER)
			-- Parse ustar-header in `block' starting at position `pos'.
		local
			l_field: detachable STRING_8
			l_header: like last_parsed_header
			err: BOOLEAN
		do
			create l_header.make

				-- parse "filename"
				-- FIXME: Implement filename splitting
			if not err then
				l_field := next_block_string (block, pos + {TAR_CONST}.tar_header_name_offset, {TAR_CONST}.tar_header_name_length)
				if not l_field.is_whitespace then
					l_header.set_filename (create {PATH}.make_from_string (l_field))
				else
					err := True
				end
			end

				-- parse mode
			if not err then
				l_field := next_block_octal_natural_16_string (block, pos + {TAR_CONST}.tar_header_mode_offset, {TAR_CONST}.tar_header_mode_length)
				if l_field /= Void then
					l_header.set_mode (octal_string_to_natural_16 (l_field))
				else
					err := True
				end
			end

				-- parse uid
			if not err then
				l_field := next_block_octal_natural_32_string (block, pos + {TAR_CONST}.tar_header_uid_offset, {TAR_CONST}.tar_header_uid_length)
				if l_field /= Void then
					l_header.set_user_id (octal_string_to_natural_32 (l_field))
				else
					err := True
				end
			end

				-- parse gid
			if not err then
				l_field := next_block_octal_natural_32_string (block, pos + {TAR_CONST}.tar_header_gid_offset, {TAR_CONST}.tar_header_gid_length)
				if l_field /= Void then
					l_header.set_group_id (octal_string_to_natural_32 (l_field))
				else
					err := True
				end
			end

				-- parse size
			if not err then
				l_field := next_block_octal_natural_64_string (block, pos + {TAR_CONST}.tar_header_size_offset, {TAR_CONST}.tar_header_size_length)
				if l_field /= Void then
					l_header.set_size (octal_string_to_natural_64 (l_field))
				else
					err := True
				end
			end

				-- parse mtime
			if not err then
				l_field := next_block_octal_natural_64_string (block, pos + {TAR_CONST}.tar_header_mtime_offset, {TAR_CONST}.tar_header_mtime_length)
				if l_field /= Void then
					l_header.set_mtime (octal_string_to_natural_64 (l_field))
				else
					err := True
				end
			end


				-- verify checksum
			if not err then
				err := not is_checksum_verified (block, pos)
			end

				-- parse typeflag
			if not err then
				l_header.set_typeflag (block.read_character (pos + {TAR_CONST}.tar_header_typeflag_offset))
			end

				-- parse linkname
			if not err then
				l_field := next_block_string (block, pos + {TAR_CONST}.tar_header_linkname_offset, {TAR_CONST}.tar_header_linkname_length)
				if not l_field.is_whitespace then
					l_header.set_linkname (create {PATH}.make_from_string (l_field))
				else
--					err := True
				end
			end

				-- parse and check magic
			if not err then
				l_field := next_block_string (block, pos + {TAR_CONST}.tar_header_magic_offset, {TAR_CONST}.tar_header_magic_length)
				err := l_field /~ {TAR_CONST}.ustar_magic
			end


				-- parse and check version
			if not err then
				l_field := next_block_string (block, pos + {TAR_CONST}.tar_header_version_offset, {TAR_CONST}.tar_header_version_length)
				err := l_field /~ {TAR_CONST}.ustar_version
			end

				-- parse uname
			if not err then
				l_field := next_block_string (block, pos + {TAR_CONST}.tar_header_uname_offset, {TAR_CONST}.tar_header_uname_length)
				if not l_field.is_whitespace then
					l_header.set_user_name (l_field)
				else
--					err := True
				end
			end

				-- parse gname
			if not err then
				l_field := next_block_string (block, pos + {TAR_CONST}.tar_header_gname_offset, {TAR_CONST}.tar_header_gname_length)
				if not l_field.is_whitespace then
					l_header.set_group_name (l_field)
				else
--					err := True
				end
			end

				-- parse devmajor
			if not err then
				l_field := next_block_octal_natural_32_string (block, pos + {TAR_CONST}.tar_header_devmajor_offset, {TAR_CONST}.tar_header_devmajor_length)
				if l_field /= Void then
					l_header.set_device_major (octal_string_to_natural_32 (l_field))
				else
					err := True
				end
			end

				-- parse devminor
			if not err then
				l_field := next_block_octal_natural_32_string (block, pos + {TAR_CONST}.tar_header_devminor_offset, {TAR_CONST}.tar_header_devminor_length)
				if l_field /= Void then
					l_header.set_device_minor (octal_string_to_natural_32 (l_field))
				else
					err := True
				end
			end

				-- TODO: parse prefix
				-- FIXME: Implement filename splitting

			if not err then
				last_parsed_header := l_header
			else
				last_parsed_header := Void
			end
			parsing_finished := True
		end

feature {NONE} -- Implementation

	next_block_octal_natural_16_string (block: MANAGED_POINTER; pos, length: INTEGER): detachable STRING
			-- Next block ocatl string in `block' at position `pos' with at most `lenght' characters.
		do
			Result := next_block_string (block, pos, length)
			if not is_octal_natural_16_string (Result) then
				Result := Void
			end
		ensure
			is_octal_natural_16_string: Result /= Void implies is_octal_natural_16_string (Result)
		end

	next_block_octal_natural_32_string (block: MANAGED_POINTER; pos, length: INTEGER): detachable STRING
			-- Next block octal string in `block' at position `pos' with at most `length' characters.
		do
			Result := next_block_string (block, pos, length)
			if not is_octal_natural_32_string (Result) then
				Result := Void
			end
		ensure
			is_octal_natural_32_string: Result /= Void implies is_octal_natural_32_string (Result)
		end

	next_block_octal_natural_64_string (block: MANAGED_POINTER; pos, length: INTEGER): detachable STRING
			-- Next block octal string in `block' at position `pos' with at most `length' characters.
		do
			Result := next_block_string (block, pos, length)
			if not is_octal_natural_64_string (Result) then
				Result := Void
			end
		ensure
			is_octal_natural_64_string: Result /= Void implies is_octal_natural_64_string (Result)
		end

	is_checksum_verified (block: MANAGED_POINTER; pos: INTEGER): BOOLEAN
			-- Verify the checksum of `block' (block starting at `pos')
		local
			checksum: NATURAL_64
			i: INTEGER
			l_space_code: NATURAL_8
			l_lower, l_upper: INTEGER
		do
				-- Sum all bytes
			l_space_code := (' ').natural_32_code.as_natural_8
			l_lower := {TAR_CONST}.tar_header_chksum_offset
			l_upper := l_lower + {TAR_CONST}.tar_header_chksum_length
			from
				i := 0
				checksum := 0
			until
				i >= {TAR_CONST}.tar_block_size
			loop
				if
					i < l_lower or l_upper <= i
				then
					checksum := checksum + block.read_natural_8 (pos + i)
				else
					checksum := checksum + l_space_code
				end
				i := i + 1
			end

				--| Parse checksum
			Result := attached next_block_octal_natural_64_string (block, pos + {TAR_CONST}.tar_header_chksum_offset, {TAR_CONST}.tar_header_chksum_length) as checksum_string and then
					octal_string_to_natural_64 (checksum_string) = checksum
		end
end
