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

create
	make

feature -- Parsing

	parse_block (block: MANAGED_POINTER; pos: INTEGER)
			-- Parse ustar-header in `block' starting at position `pos'
		do
			create current_header.make

			-- parse filename
			-- FIXME: Implement filename splitting
			current_header.set_filename (
						create {PATH}.make_from_string (
									parse_string (block, pos + {TAR_CONST}.tar_header_name_offset, {TAR_CONST}.tar_header_name_length)))

			-- parse mode
			current_header.set_mode (
						octal_string_to_natural_16 (
									parse_string (block, pos + {TAR_CONST}.tar_header_mode_offset, {TAR_CONST}.tar_header_mode_length)))

			-- parse uid
			current_header.set_user_id (
						octal_string_to_natural_32 (
									parse_string (block, pos + {TAR_CONST}.tar_header_uid_offset, {TAR_CONST}.tar_header_uid_length)))

			-- parse gid
			current_header.set_group_id (
						octal_string_to_natural_32 (
									parse_string (block, pos + {TAR_CONST}.tar_header_gid_offset, {TAR_CONST}.tar_header_gid_length)))

			-- parse size
			current_header.set_size (
						octal_string_to_natural_64 (
									parse_string (block, pos + {TAR_CONST}.tar_header_size_offset, {TAR_CONST}.tar_header_size_length)))

			-- TODO: parse mtime
			current_header.set_mtime (
						octal_string_to_natural_64 (
									parse_string (block, pos + {TAR_CONST}.tar_header_mtime_offset, {TAR_CONST}.tar_header_mtime_length)))

			-- TODO: parse and verify checksum

			-- TODO: parse typeflag
			current_header.set_typeflag (
						block.read_character (pos + {TAR_CONST}.tar_header_typeflag_offset))

			-- TODO: parse linkname
			current_header.set_linkname (
						create {PATH}.make_from_string (
									parse_string (block, pos + {TAR_CONST}.tar_header_linkname_offset, {TAR_CONST}.tar_header_linkname_length)))

			-- TODO: parse magic (and compare it)

			-- TODO: parse version (and compare)

			-- TODO: parse uname
			current_header.set_user_name (
						parse_string (block, pos + {TAR_CONST}.tar_header_uname_offset, {TAR_CONST}.tar_header_uname_length))

			-- TODO: parse gname
			current_header.set_group_name (
						parse_string (block, pos + {TAR_CONST}.tar_header_gname_offset, {TAR_CONST}.tar_header_gname_length))

			-- TODO: parse devmajor
			current_header.set_device_major (
						octal_string_to_natural_32 (
									parse_string (block, pos + {TAR_CONST}.tar_header_devmajor_offset, {TAR_CONST}.tar_header_devmajor_length)))

			-- TODO: parse devminor
			current_header.set_device_minor (
						octal_string_to_natural_32 (
									parse_string (block, pos + {TAR_CONST}.tar_header_devminor_offset, {TAR_CONST}.tar_header_devminor_length)))

			-- TODO: parse prefix
			-- FIXME: Implement filename splitting

			parsing_finished := True;
		end

end
