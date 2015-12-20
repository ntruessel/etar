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
			-- Parse ustar-header in `block' starting at position `pos'
		local
			current_field: STRING_8
		do
			create current_header.make

			-- parse filename
			-- FIXME: Implement filename splitting
			current_field := parse_string (block, pos + {TAR_CONST}.tar_header_name_offset, {TAR_CONST}.tar_header_name_length)
			if (current_field.is_empty) then
				current_header := Void
			end

			if (attached current_header as header) then
				header.set_filename (create {PATH}.make_from_string (current_field))
			end

			-- parse mode
			current_field := parse_string (block, pos + {TAR_CONST}.tar_header_mode_offset, {TAR_CONST}.tar_header_mode_length)
			if (not is_octal_natural_16_string (current_field)) then
				current_header := Void
			end

			if (attached current_header as header) then
				header.set_mode (octal_string_to_natural_16 (current_field))
			end

			-- parse uid
			current_field := parse_string (block, pos + {TAR_CONST}.tar_header_uid_offset, {TAR_CONST}.tar_header_uid_length)
			if (not is_octal_natural_32_string (current_field)) then
				current_header := Void
			end

			if (attached current_header as header) then
				header.set_user_id (octal_string_to_natural_32 (current_field))
			end


			-- parse gid
			current_field := parse_string (block, pos + {TAR_CONST}.tar_header_gid_offset, {TAR_CONST}.tar_header_gid_length)
			if (not is_octal_natural_32_string (current_field)) then
				current_header := Void
			end

			if (attached current_header as header) then
				header.set_group_id (octal_string_to_natural_32 (current_field))
			end

			-- parse size
			current_field := parse_string (block, pos + {TAR_CONST}.tar_header_size_offset, {TAR_CONST}.tar_header_size_length)
			if (not is_octal_natural_64_string (current_field)) then
				current_header := Void
			end

			if (attached current_header as header) then
				header.set_size (octal_string_to_natural_64 (current_field))
			end

			-- parse mtime
			current_field := parse_string (block, pos + {TAR_CONST}.tar_header_mtime_offset, {TAR_CONST}.tar_header_mtime_length)
			if (not is_octal_natural_64_string (current_field)) then
				current_header := Void
			end

			if (attached current_header as header) then
				header.set_mtime (octal_string_to_natural_64 (current_field))
			end


			-- verify checksum
			if (not verify_checksum (block, pos)) then
				current_header := Void
			end

			-- parse typeflag
			if (attached current_header as header) then
				header.set_typeflag (block.read_character (pos + {TAR_CONST}.tar_header_typeflag_offset))
			end

			-- parse linkname
			current_field := parse_string (block, pos + {TAR_CONST}.tar_header_linkname_offset, {TAR_CONST}.tar_header_linkname_length)
			if (attached current_header as header and not current_field.is_empty) then
				header.set_linkname (create {PATH}.make_from_string (current_field))
			end

			-- parse and check magic
			current_field := parse_string (block, pos + {TAR_CONST}.tar_header_magic_offset, {TAR_CONST}.tar_header_magic_length)
			if (not (current_field ~ {TAR_CONST}.ustar_magic)) then
				current_header := Void
			end


			-- parse and check version
			current_field := parse_string (block, pos + {TAR_CONST}.tar_header_version_offset, {TAR_CONST}.tar_header_version_length)
			if (not (current_field ~ {TAR_CONST}.ustar_version)) then
				current_header := Void
			end

			-- parse uname
			current_field := parse_string (block, pos + {TAR_CONST}.tar_header_uname_offset, {TAR_CONST}.tar_header_uname_length)
			if (attached current_header as header and not current_field.is_empty) then
				header.set_user_name (current_field)
			end

			-- parse gname
			current_field := parse_string (block, pos + {TAR_CONST}.tar_header_gname_offset, {TAR_CONST}.tar_header_gname_length)
			if (attached current_header as header and not current_field.is_empty) then
				header.set_group_name (current_field)
			end

			-- parse devmajor
			current_field := parse_string (block, pos + {TAR_CONST}.tar_header_devmajor_offset, {TAR_CONST}.tar_header_devmajor_length)
			if (not is_octal_natural_32_string (current_field)) then
				current_header := Void
			end

			if (attached current_header as header) then
				header.set_device_major (octal_string_to_natural_32 (current_field))
			end

			-- parse devminor
			current_field := parse_string (block, pos + {TAR_CONST}.tar_header_devminor_offset, {TAR_CONST}.tar_header_devminor_length)
			if (not is_octal_natural_32_string (current_field)) then
				current_header := Void
			end

			if (attached current_header as header) then
				header.set_device_minor (octal_string_to_natural_32 (current_field))
			end

			-- TODO: parse prefix
			-- FIXME: Implement filename splitting

			parsing_finished := True;
		end

feature {NONE} -- Implementation

	verify_checksum (block: MANAGED_POINTER; pos: INTEGER): BOOLEAN
			-- Verify the checksum of `block' (block starting at `pos')
		local
			checksum_string: STRING_8
			checksum: NATURAL_64
			s: STRING_8
			i: INTEGER
		do
			-- Sum all bytes
			from
				i := 0
				checksum := 0
			until
				i >= {TAR_CONST}.tar_block_size
			loop
				if (i < {TAR_CONST}.tar_header_chksum_offset or i >= {TAR_CONST}.tar_header_chksum_offset + {TAR_CONST}.tar_header_chksum_length) then
					checksum := checksum + block.read_natural_8 (pos + i)
				else
					checksum := checksum + (' ').natural_32_code.as_natural_8
				end
				i := i + 1
			end

			-- Parse checksum
			checksum_string := parse_string (block, pos + {TAR_CONST}.tar_header_chksum_offset, {TAR_CONST}.tar_header_chksum_length)
			Result := is_octal_natural_64_string (checksum_string) and then (octal_string_to_natural_64 (checksum_string) = checksum)
		end
end
