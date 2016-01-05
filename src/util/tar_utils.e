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

end
