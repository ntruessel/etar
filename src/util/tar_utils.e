note
	description: "[
		Utility functions for tar archives
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TAR_UTILS

inherit
	OCTAL_UTILS

feature -- Bytes to Blocks

	needed_blocks (n: NATURAL_64): NATURAL_64
			-- How many blocks are needed to store `n' bytes
		do
			Result := (n + {TAR_CONST}.tar_block_size.as_natural_64 - 1) // {TAR_CONST}.tar_block_size.as_natural_64
		ensure
			bytes_fit: n <= Result * {TAR_CONST}.tar_block_size.as_natural_64
			smallest_fit: Result * {TAR_CONST}.tar_block_size.as_natural_64 < n + {TAR_CONST}.tar_block_size.as_natural_64
		end

feature -- Block Padding

	pad_block (p: MANAGED_POINTER; a_pos, n: INTEGER)
			-- pad `p' with `n' NUL-bytes starting at `a_pos'
		require
			non_negative_position: a_pos >= 0
			non_negative_length: n >= 0
			enough_space: p.count >= a_pos + n
		local
			l_padding: SPECIAL[CHARACTER_8]
		do
			if n > 0 then
				create l_padding.make_filled ('%U', n)
				p.put_special_character_8 (l_padding, 0, a_pos, n)
			end
		end


feature -- Header Checksum

	checksum (block: MANAGED_POINTER; a_pos: INTEGER): NATURAL_64
			-- Calcualte checksum of `block' (starting at `a_pos')
		require
			non_negative_pos: a_pos >= 0
			enough_space: block.count >= a_pos + {TAR_CONST}.tar_block_size
		local
			i: INTEGER
			l_space_code: NATURAL_8
			l_lower, l_upper: INTEGER
		do
				-- Sum all bytes
			l_space_code := (' ').natural_32_code.as_natural_8
			l_lower := {TAR_HEADER_CONST}.chksum_offset
			l_upper := l_lower + {TAR_HEADER_CONST}.chksum_length
			from
				i := 0
				Result := 0
			until
				i >= {TAR_CONST}.tar_block_size
			loop
				if
					i < l_lower or l_upper <= i
				then
					Result := Result + block.read_natural_8 (a_pos + i)
				else
					Result := Result + l_space_code
				end
				i := i + 1
			end
		end

feature -- Metadata

	get_uid_from_username (a_username: STRING): INTEGER
			-- Return the uid that belongs to `a_username'
		do
			Result := c_get_uid_from_username (a_username.plus ("%U").area.base_address)
		end

	get_gid_from_groupname (a_groupname: STRING): INTEGER
			-- Return the gid that belongs to `a_username'
		do
			Result := c_get_gid_from_groupname (a_groupname.plus ("%U").area.base_address)
		end

feature {NONE} -- external

	c_get_uid_from_username (a_username: POINTER): INTEGER
			-- Return the uid that belongs to `a_username'
		external
			"C inline use <pwd.h>, <sys/types.h>"
		alias
			"{
				struct passwd *pw = getpwnam($a_username);
				if (pw != (struct passwd *) 0) {
					return (EIF_INTEGER) pw->pw_uid;
				} else {
					return (EIF_INTEGER) -1;
				}
			}"
		end

	c_get_gid_from_groupname (a_groupname: POINTER): INTEGER
			-- Return the gid that belongs to `a_groupname'
		external
			"C inline use <grp.h>, <sys/types.h>"
		alias
			"{
				struct group *gr = getgrnam($a_groupname);
				if (gr != (struct group *) 0) {
					return (EIF_INTEGER) gr->gr_gid;
				} else {
					return (EIF_INTEGER) -1;
				}
			}"
		end

end
