note
	description: "[
		Header writer for the ustar format
		
		Everything that is too large will be truncated
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	USTAR_HEADER_WRITER

inherit
	TAR_HEADER_WRITER

	OCTAL_UTILS
		export
			{NONE} all
		end

feature -- Status

	required_space (a_header: TAR_HEADER): INTEGER
			-- Space required to write `a_header'
		once
			Result := {TAR_CONST}.tar_block_size
		end

	can_write (a_header: TAR_HEADER): BOOLEAN
			-- Can `a_header' be written?
		do
			-- TODO: Copy over from TAR_HEADER
			Result := false
		end

feature -- Output

	write_to_managed_pointer (a_header: TAR_HEADER; p: MANAGED_POINTER; a_pos: INTEGER)
			-- Write `a_header' to `p' starting at `a_pos'
		local
			s: STRING_8
		do
			-- Pad with all '%U'
			p.put_special_character_8 (
					create {SPECIAL[CHARACTER_8]}.make_filled ('%U', {TAR_CONST}.tar_block_size),
					0, a_pos, {TAR_CONST}.tar_block_size)

			-- Put filename
			-- FIXME: Implement filename splitting
			s := unify_path (a_header.filename)
			p.put_special_character_8 (
					s.area,
					0, a_pos + {TAR_CONST}.tar_header_name_offset,
					s.count.min ({TAR_CONST}.tar_header_name_length - 1))

			-- Put prefix
			-- FIXME: Implement filename splitting

			-- Put mode
			s := natural_16_to_octal_string (a_header.mode)
			pad (s, {TAR_CONST}.tar_header_mode_length - s.count - 1)
			p.put_special_character_8 (s.area,
					0, a_pos + {TAR_CONST}.tar_header_mode_offset,
					{TAR_CONST}.tar_header_mode_length)

			-- Put userid
			s := natural_32_to_octal_string (a_header.user_id)
			pad (s, {TAR_CONST}.tar_header_uid_length - s.count - 1)
			p.put_special_character_8 (s.area,
					0, a_pos + {TAR_CONST}.tar_header_uid_offset,
					{TAR_CONST}.tar_header_uid_length)

			-- Put groupid
			s := natural_32_to_octal_string (a_header.group_id)
			pad (s, {TAR_CONST}.tar_header_gid_length - s.count - 1)
			p.put_special_character_8 (s.area,
					0, a_pos + {TAR_CONST}.tar_header_gid_offset,
					{TAR_CONST}.tar_header_gid_length)

			-- Put size
			s := natural_64_to_octal_string (a_header.size)
			pad (s, {TAR_CONST}.tar_header_size_length - s.count - 1)
			p.put_special_character_8 (s.area,
					0, a_pos + {TAR_CONST}.tar_header_size_offset,
					{TAR_CONST}.tar_header_size_length)

			-- Put mtime
			s := natural_64_to_octal_string (a_header.mtime)
			pad (s, {TAR_CONST}.tar_header_mtime_length - s.count - 1)
			p.put_special_character_8 (s.area,
					0, a_pos + {TAR_CONST}.tar_header_mtime_offset,
					{TAR_CONST}.tar_header_mtime_length)

			-- Put typeflag
			p.put_character (a_header.typeflag,
					a_pos + {TAR_CONST}.tar_header_typeflag_offset)

			-- Put linkname
			s := unify_path (a_header.linkname)
			p.put_special_character_8 (s.area,
					0, a_pos + {TAR_CONST}.tar_header_linkname_offset,
					s.count.min ({TAR_CONST}.tar_header_linkname_length - 1))

			-- Put magic
			p.put_special_character_8 (magic.area,
					0, a_pos + {TAR_CONST}.tar_header_magic_offset,
					{TAR_CONST}.tar_header_magic_length)

			-- Put version
			p.put_special_character_8 (version.area,
					0, a_pos + {TAR_CONST}.tar_header_version_offset,
					{TAR_CONST}.tar_header_version_length)

			-- Put username
			p.put_special_character_8 (a_header.user_name.as_string_8.area,
					0, a_pos + {TAR_CONST}.tar_header_uname_offset,
					a_header.user_name.count.min ({TAR_CONST}.tar_header_uname_length - 1))

			-- Put groupname
			p.put_special_character_8 (a_header.group_name.as_string_8.area,
					0, a_pos + {TAR_CONST}.tar_header_gname_offset,
					a_header.group_name.count.min ({TAR_CONST}.tar_header_gname_length - 1))

			-- Put devmajor
			s := natural_32_to_octal_string (a_header.device_major)
			pad (s, {TAR_CONST}.tar_header_devmajor_length - s.count - 1)
			p.put_special_character_8 (s.area,
					0, a_pos + {TAR_CONST}.tar_header_devmajor_offset,
					{TAR_CONST}.tar_header_devmajor_length)

			-- Put devminor
			s := natural_32_to_octal_string (a_header.device_minor)
			pad (s, {TAR_CONST}.tar_header_devminor_length - s.count - 1)
			p.put_special_character_8 (s.area,
					0, a_pos + {TAR_CONST}.tar_header_devminor_offset,
					{TAR_CONST}.tar_header_devminor_length)

			put_checksum (p, a_pos)
		end

feature {NONE} -- Utilities

	put_checksum (p: MANAGED_POINTER; a_pos: INTEGER)
			-- Calculate the checksum for the ustar header in `p' starting at `a_pos'
		local
			checksum: NATURAL_64
			s: STRING_8
			i: INTEGER
		do
			-- Put all spaces in checksum
			create s.make_filled (' ', {TAR_CONST}.tar_header_chksum_length)
			p.put_special_character_8 (s.area,
					0, a_pos + {TAR_CONST}.tar_header_chksum_offset,
					{TAR_CONST}.tar_header_chksum_length)

			-- Sum all bytes
			from
				i := 0
				checksum := 0
			until
				i >= {TAR_CONST}.tar_block_size
			loop
				checksum := checksum + p.read_natural_8 (a_pos + i)
			end

			-- Write checksum
			s := natural_64_to_octal_string (checksum)
			pad (s, {TAR_CONST}.tar_header_chksum_length - s.count - 1)
			p.put_special_character_8 (s.area,
					0, a_pos + {TAR_CONST}.tar_header_chksum_offset,
					{TAR_CONST}.tar_header_chksum_length)
		end

	unfiy_path (a_path: PATH): STRING_8
			-- Turns `a_path' into a UTF-8 string using unix directory separators
		do
			Result := a_path.utf_8_name
			if (a_path.directory_separator = {PATH}.windows_separator) then
				-- Windows prohibits unix directory separators in paths so this is a simple replacement operation
				Result.replace_substring_all({PATH}.windows_separator.out, {PATH}.unix_separator.out)
			end
		end

feature {NONE} -- Constants

	magic: STRING_8 = "ustar"
			-- Header magic, we only support ustar.

	version: STRING_8 = "00"
			-- Header version

end
