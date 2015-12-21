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
			Result := filename_fits (a_header) and
						user_id_fits (a_header) and
						group_id_fits (a_header) and
						size_fits (a_header) and
						user_name_fits (a_header) and
						group_name_fits (a_header)
		end

feature -- Output

	write_to_managed_pointer (a_header: TAR_HEADER; p: MANAGED_POINTER; a_pos: INTEGER)
			-- Write `a_header' to `p' starting at `a_pos'
		do
			-- Fill with all '%U'
			p.put_special_character_8 (
					create {SPECIAL[CHARACTER_8]}.make_filled ('%U', {TAR_CONST}.tar_block_size),
					0, a_pos, {TAR_CONST}.tar_block_size)

			-- Put filename
			-- FIXME: Implement filename splitting
			put_string (unify_utf_8_path (a_header.filename),
					p, a_pos + {TAR_CONST}.tar_header_name_offset);

			-- Put prefix
			-- FIXME: Implement filename splitting

			-- Put mode
			-- MASK ISVTX flag: tar does not support it (reserved)
			put_natural (a_header.mode & 0c6777,
					{TAR_CONST}.tar_header_mode_length,
					p, a_pos + {TAR_CONST}.tar_header_mode_offset)

			-- Put userid
			put_natural (a_header.user_id,
					{TAR_CONST}.tar_header_uid_length,
					p, a_pos + {TAR_CONST}.tar_header_uid_offset)

			-- Put groupid
			put_natural (a_header.group_id,
					{TAR_CONST}.tar_header_gid_length,
					p, a_pos + {TAR_CONST}.tar_header_gid_offset)

			-- Put size
			put_natural (a_header.size,
					{TAR_CONST}.tar_header_size_length,
					p, a_pos + {TAR_CONST}.tar_header_size_offset)

			-- Put mtime
			put_natural (a_header.mtime,
					{TAR_CONST}.tar_header_mtime_length,
					p, a_pos + {TAR_CONST}.tar_header_mtime_offset)

			-- Put typeflag
			p.put_character (a_header.typeflag,
					a_pos + {TAR_CONST}.tar_header_typeflag_offset)

			-- Put linkname
			put_string (unify_utf_8_path (a_header.linkname),
					p, a_pos + {TAR_CONST}.tar_header_linkname_offset)

			-- Put magic
			put_string ({TAR_CONST}.ustar_magic, p, a_pos + {TAR_CONST}.tar_header_magic_offset)

			-- Put version
			put_string ({TAR_CONST}.ustar_version, p, a_pos + {TAR_CONST}.tar_header_version_offset)

			-- Put username
			put_string (a_header.user_name.as_string_8,
					p, a_pos + {TAR_CONST}.tar_header_uname_offset)

			-- Put groupname
			put_string (a_header.group_name.as_string_8,
					p, a_pos + {TAR_CONST}.tar_header_gname_offset)

			-- Put devmajor
			put_natural (a_header.device_major,
					{TAR_CONST}.tar_header_devmajor_length,
					p, a_pos + {TAR_CONST}.tar_header_devmajor_offset)

			-- Put devminor
			put_natural (a_header.device_minor,
					{TAR_CONST}.tar_header_devminor_length,
					p, a_pos + {TAR_CONST}.tar_header_devminor_offset)

			-- Put checksum
			put_checksum (p, a_pos)
		end

feature {NONE} -- Fitting

	filename_fits (a_header: TAR_HEADER): BOOLEAN
			-- Indicates whether `filename' of `a_header' fits in a ustar header
		do
				-- TODO: Implement splitting
				-- No need for terminating '%U'
			Result := a_header.filename.utf_8_name.count <= {TAR_CONST}.tar_header_name_length
		end

	user_id_fits (a_header: TAR_HEADER): BOOLEAN
			-- Indicates whether `user_id' of `a_header' fits in ustar header
		do
				-- Strictly less: terminating '%U'
			Result := natural_32_to_octal_string (a_header.user_id).count < {TAR_CONST}.tar_header_uid_length
		end

	group_id_fits (a_header: TAR_HEADER): BOOLEAN
			-- Indicates whether `group_id' of `a_header' fits in ustar header
		do
				-- Strictly less: terminating '%U'
			Result := natural_32_to_octal_string (a_header.group_id).count < {TAR_CONST}.tar_header_gid_length
		end

	size_fits (a_header: TAR_HEADER): BOOLEAN
			-- Indicates whether `size' of `a_header' fits in a ustar header
		do
				-- Strictly less: terminating '%U'
			Result := natural_64_to_octal_string (a_header.size).count < {TAR_CONST}.tar_header_size_length
		end

	user_name_fits (a_header: TAR_HEADER): BOOLEAN
			-- Indicates whether `user_name' of `a_header' fits in a ustar header
		do
				-- No need for terminating '%U'
			Result := a_header.user_name.count <= {TAR_CONST}.tar_header_uname_length
		end

	group_name_fits (a_header: TAR_HEADER): BOOLEAN
			-- Indicates whether `group_name' of `a_header' fits in a ustar header
		do
				-- No need for terminating '%U'
			Result := a_header.group_name.count <= {TAR_CONST}.tar_header_gname_length
		end

feature {NONE} -- Utilities

	put_string (s: STRING_8; p: MANAGED_POINTER; a_pos: INTEGER)
			-- Write `s' to `p' at `a_pos'
		do
			p.put_special_character_8 (s.area, 0, a_pos, s.count)
		end

	put_natural (n: NATURAL_64; length: INTEGER; p: MANAGED_POINTER; a_pos: INTEGER)
			-- Write the octal representation of `n' padded to `lenght' - 1 to `p' at `a_pos'
			-- `length' - 1 because tar requires a terminating '%U' for numeric values
		local
			s: STRING_8
		do
			s := natural_64_to_octal_string (n)
			pad (s, length - s.count - 1)
			p.put_special_character_8 (s.area, 0, a_pos, s.count)
		end

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
				i := i + 1
			end

			-- Write checksum
			s := natural_64_to_octal_string (checksum)
			pad (s, {TAR_CONST}.tar_header_chksum_length - s.count - 1)
			p.put_special_character_8 (s.area,
					0, a_pos + {TAR_CONST}.tar_header_chksum_offset,
					{TAR_CONST}.tar_header_chksum_length)
		end

feature -- Path helpers		

	unify_utf_8_path (a_path: PATH): STRING_8
			-- Turns `a_path' into a UTF-8 string using unix directory separators
		do
			create Result.make (a_path.utf_8_name.count)
			across
				a_path.components as ic
			loop
				if not Result.is_empty then
					Result.append_character ('/')
				end
				Result.append (ic.item.utf_8_name)
			end
		end

end
