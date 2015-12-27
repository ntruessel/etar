note
	description: "[
		Header writer for the ustar format

		Everything that is too large will be truncated
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"
	EIS: "name=Further information about the USTAR format", "src=http://pubs.opengroup.org/onlinepubs/9699919799/utilities/pax.html#tag_20_92_13_06", "tag=ustar"

class
	USTAR_HEADER_WRITER

inherit
	TAR_HEADER_WRITER

	OCTAL_UTILS
		export
			{NONE} all
		end

feature -- Status

	required_blocks: INTEGER
			-- Space required to write `active_header' in blocks
		once
			Result := 1
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

	write_to_managed_pointer (p: MANAGED_POINTER; a_pos: INTEGER)
			-- Write `active_header' to `p' starting at `a_pos'
		local
			l_split_filename: TUPLE [filename_prefix: STRING_8; filename: STRING_8]
		do
			if attached active_header as header then
					-- Fill with all '%U'
				p.put_special_character_8 (
						create {SPECIAL[CHARACTER_8]}.make_filled ('%U', {TAR_CONST}.tar_block_size),
						0, a_pos, {TAR_CONST}.tar_block_size)

					-- Put filename
					-- FIXME: Implement filename splitting
				l_split_filename := unify_and_split_filename (header.filename)
				put_string (l_split_filename.filename,
						p, a_pos + {TAR_HEADER_CONST}.name_offset);

					-- Put prefix
				put_string (l_split_filename.filename_prefix,
						p, a_pos + {TAR_HEADER_CONST}.prefix_offset);

					-- Put mode
					-- MASK ISVTX flag: tar does not support it (reserved)
				put_natural (header.mode & 0c6777,
						{TAR_HEADER_CONST}.mode_length,
						p, a_pos + {TAR_HEADER_CONST}.mode_offset)

					-- Put userid
				put_natural (header.user_id,
						{TAR_HEADER_CONST}.uid_length,
						p, a_pos + {TAR_HEADER_CONST}.uid_offset)

					-- Put groupid
				put_natural (header.group_id,
						{TAR_HEADER_CONST}.gid_length,
						p, a_pos + {TAR_HEADER_CONST}.gid_offset)

					-- Put size
				put_natural (header.size,
						{TAR_HEADER_CONST}.size_length,
						p, a_pos + {TAR_HEADER_CONST}.size_offset)

					-- Put mtime
				put_natural (header.mtime,
						{TAR_HEADER_CONST}.mtime_length,
						p, a_pos + {TAR_HEADER_CONST}.mtime_offset)

					-- Put typeflag
				p.put_character (header.typeflag,
						a_pos + {TAR_HEADER_CONST}.typeflag_offset)

					-- Put linkname
				put_string (unify_utf_8_path (header.linkname),
						p, a_pos + {TAR_HEADER_CONST}.linkname_offset)

					-- Put magic
				put_string ({TAR_CONST}.ustar_magic, p, a_pos + {TAR_HEADER_CONST}.magic_offset)

					-- Put version
				put_string ({TAR_CONST}.ustar_version, p, a_pos + {TAR_HEADER_CONST}.version_offset)

					-- Put username
				put_string (header.user_name.as_string_8,
						p, a_pos + {TAR_HEADER_CONST}.uname_offset)

					-- Put groupname
				put_string (header.group_name.as_string_8,
						p, a_pos + {TAR_HEADER_CONST}.gname_offset)

					-- Put devmajor
				put_natural (header.device_major,
						{TAR_HEADER_CONST}.devmajor_length,
						p, a_pos + {TAR_HEADER_CONST}.devmajor_offset)

					-- Put devminor
				put_natural (header.device_minor,
						{TAR_HEADER_CONST}.devminor_length,
						p, a_pos + {TAR_HEADER_CONST}.devminor_offset)

					-- Put checksum
				put_checksum (p, a_pos)
			else
				check false end -- Unreachable (see precondition)
			end

		end

	write_block_to_managed_pointer (p: MANAGED_POINTER; a_pos: INTEGER)
			-- Write next block to `p' starting at `a_pos'
		do
			write_to_managed_pointer (p, a_pos)
			written_blocks := written_blocks + 1
		end

feature {NONE} -- Fitting

	filename_fits (a_header: TAR_HEADER): BOOLEAN
			-- Indicates whether `filename' of `a_header' fits in a ustar header
		local
			l_split_filename: TUPLE [filename_prefix: STRING_8; filename: STRING_8]
		do
				-- No need for terminating '%U'
			l_split_filename := unify_and_split_filename (a_header.filename)
			Result := l_split_filename.filename_prefix.count <= {TAR_HEADER_CONST}.prefix_length and not l_split_filename.filename.is_empty
		end

	user_id_fits (a_header: TAR_HEADER): BOOLEAN
			-- Indicates whether `user_id' of `a_header' fits in ustar header
		do
				-- Strictly less: terminating '%U'
			Result := natural_32_to_octal_string (a_header.user_id).count < {TAR_HEADER_CONST}.uid_length
		end

	group_id_fits (a_header: TAR_HEADER): BOOLEAN
			-- Indicates whether `group_id' of `a_header' fits in ustar header
		do
				-- Strictly less: terminating '%U'
			Result := natural_32_to_octal_string (a_header.group_id).count < {TAR_HEADER_CONST}.gid_length
		end

	size_fits (a_header: TAR_HEADER): BOOLEAN
			-- Indicates whether `size' of `a_header' fits in a ustar header
		do
				-- Strictly less: terminating '%U'
			Result := natural_64_to_octal_string (a_header.size).count < {TAR_HEADER_CONST}.size_length
		end

	user_name_fits (a_header: TAR_HEADER): BOOLEAN
			-- Indicates whether `user_name' of `a_header' fits in a ustar header
		do
				-- No need for terminating '%U'
			Result := a_header.user_name.count <= {TAR_HEADER_CONST}.uname_length
		end

	group_name_fits (a_header: TAR_HEADER): BOOLEAN
			-- Indicates whether `group_name' of `a_header' fits in a ustar header
		do
				-- No need for terminating '%U'
			Result := a_header.group_name.count <= {TAR_HEADER_CONST}.gname_length
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
			create s.make_filled (' ', {TAR_HEADER_CONST}.chksum_length)
			p.put_special_character_8 (s.area,
					0, a_pos + {TAR_HEADER_CONST}.chksum_offset,
					{TAR_HEADER_CONST}.chksum_length)

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
			pad (s, {TAR_HEADER_CONST}.chksum_length - s.count - 1)
			p.put_special_character_8 (s.area,
					0, a_pos + {TAR_HEADER_CONST}.chksum_offset,
					{TAR_HEADER_CONST}.chksum_length)
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

	unify_and_split_filename (a_path: PATH): TUPLE [filename_prefix: STRING_8; filename: STRING_8]
			-- Split `a_path' into filename and prefix, such that prefix + '/' + filename equals the UTF-8
			-- representation of `a_path' using unix directory separator
		local
			l_filename: STRING_8
			l_filename_prefix: STRING_8
			l_components_cursor: INDEXABLE_ITERATION_CURSOR [PATH] -- like a_path.components.new_cursor
		do
			create l_filename_prefix.make ((a_path.utf_8_name.count - {TAR_HEADER_CONST}.name_length).max (0))
			create l_filename.make ({TAR_HEADER_CONST}.name_length)

			-- filename
			from
				l_components_cursor := a_path.components.new_cursor
				l_components_cursor.reverse
				l_components_cursor.start
			until
				l_components_cursor.after or else 																											-- whole path processed
					((l_filename.is_empty and l_filename.count + l_components_cursor.item.utf_8_name.count > {TAR_HEADER_CONST}.name_length) or				-- no space for first entry   (error case)
					(not l_filename.is_empty and l_filename.count + l_components_cursor.item.utf_8_name.count >= {TAR_HEADER_CONST}.name_length))			-- no space for other entries
			loop
				if not l_filename.is_empty then
					l_filename.precede ('/')
				end
				l_filename.prepend (l_components_cursor.item.utf_8_name)
				l_components_cursor.forth
			end

			-- prefix
			from

			until
				l_components_cursor.after
			loop
				if not l_filename_prefix.is_empty then
					l_filename_prefix.precede ('/')
				end
				l_filename_prefix.prepend (l_components_cursor.item.utf_8_name)
				l_components_cursor.forth
			end

			Result := [l_filename_prefix, l_filename]
		ensure
			correct_length: Result.filename.count <= {TAR_HEADER_CONST}.name_length
			correct_result_without_prefix: Result.filename_prefix.is_empty implies (Result.filename ~ unify_utf_8_path (a_path))
			correct_result_with_prefix: (not Result.filename_prefix.is_empty and not Result.filename.is_empty) implies (Result.filename_prefix + "/" + Result.filename ~ unify_utf_8_path (a_path))
			correct_result_with_prefix_without_filename: (not Result.filename_prefix.is_empty and Result.filename.is_empty) implies (Result.filename_prefix ~ unify_utf_8_path (a_path))
		end

end
