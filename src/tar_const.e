note
	description: "[
		Constans used by tar
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TAR_CONST

feature -- ustar field offsets and lengths (bytes)
		-- FIXME: Group this constants logically (TUPLE?)
		-- FIXME: Contains a lot of redundancy

	tar_header_name_offset: 		INTEGER =   0 	-- filename field offset
	tar_header_name_length: 		INTEGER = 100 	-- filename field length

	tar_header_mode_offset: 		INTEGER = 100 	-- mode field offset
	tar_header_mode_length: 		INTEGER =   8 	-- mode field length

	tar_header_uid_offset: 			INTEGER = 108 	-- user-id field offset
	tar_header_uid_length: 			INTEGER =   8 	-- user-id field length

	tar_header_gid_offset: 			INTEGER = 116 	-- group-id field offset
	tar_header_gid_length: 			INTEGER =   8 	-- group-id field length

	tar_header_size_offset: 		INTEGER = 124 	-- filesize field offset
	tar_header_size_length: 		INTEGER =  12 	-- filesize field length

	tar_header_mtime_offset: 		INTEGER = 136 	-- last modified field offset
	tar_header_mtime_length: 		INTEGER =  12 	-- last modified field length

	tar_header_chksum_offset: 		INTEGER = 148 	-- checksum field offset
	tar_header_chksum_length: 		INTEGER =   8 	-- checksum field length

	tar_header_typeflag_offset: 	INTEGER = 156 	-- typeflag field offset
	tar_header_typeflag_length: 	INTEGER =   1 	-- typeflag field length

	tar_header_linkname_offset: 	INTEGER = 157 	-- linkname (pointee of link) field offset
	tar_header_linkname_length: 	INTEGER = 100 	-- linkname (pointee of link) field length

	tar_header_magic_offset: 		INTEGER = 257 	-- magic field offset
	tar_header_magic_length: 		INTEGER =   6 	-- magic field length

	tar_header_version_offset: 		INTEGER = 263 	-- version field offset
	tar_header_version_length: 		INTEGER =   2 	-- version field length

	tar_header_uname_offset: 		INTEGER = 265 	-- username field offset
	tar_header_uname_length: 		INTEGER =  32 	-- username field length

	tar_header_gname_offset: 		INTEGER = 297 	-- groupname field offset
	tar_header_gname_length: 		INTEGER =  32 	-- groupname field length

	tar_header_devmajor_offset: 	INTEGER = 329 	-- device major field offset
	tar_header_devmajor_length: 	INTEGER =   8 	-- device major field length

	tar_header_devminor_offset: 	INTEGER = 337 	-- device minor field offset
	tar_header_devminor_length: 	INTEGER =   8 	-- device minor field length

	tar_header_prefix_offset: 		INTEGER = 345 	-- filename prefix field offset
	tar_header_prefix_length: 		INTEGER = 155 	-- filename prefix field length

feature -- Mode/Permission masks

	setuid_mask: NATURAL_16 = 0c04000 -- Setuid bitmask

	setgid_mask: NATURAL_16 = 0c02000 -- Setgid bitmask

	uread_mask: NATURAL_16 = 0c00400 -- User readable bitmask

	uwrite_mask: NATURAL_16 = 0c00200 -- User writable bitmask

	uexec_mask: NATURAL_16 = 0c00100 -- User executable bitmask

	gread_mask: NATURAL_16 = 0c00040 -- Group readable bitmask

	gwrite_mask: NATURAL_16 = 0c00020 -- Group writable bitmask

	gexec_mask: NATURAL_16 = 0c00010 -- Group executable bitmask

	oread_mask: NATURAL_16 = 0c00004 -- Other readable bitmask

	owrite_mask: NATURAL_16 = 0c00002 -- Other writable bitmask

	oexec_mask: NATURAL_16 = 0c00001 -- Other executable bitmask

feature -- Typeflags

	tar_typeflag_regular_file:		CHARACTER_8 = '0' -- Typeflag for regular files

	tar_typeflag_regular_file_old:	CHARACTER_8 = '%U' -- Typeflag for regular files (deprecated)

	tar_typeflag_hardlink:			CHARACTER_8 = '1' -- Typeflag for hardlinks

	tar_typeflag_symlink:			CHARACTER_8 = '2' -- Typeflag for symlinks

	tar_typeflag_character_special: CHARACTER_8 = '3' -- Typeflag for character device nodes

	tar_typeflag_block_special:		CHARACTER_8 = '4' -- Typeflag for block device nodes

	tar_typeflag_directory:			CHARACTER_8 = '5' -- Typeflag for directories

	tar_typeflag_fifo:				CHARACTER_8 = '6' -- Typeflag for named pipes

	tar_typeflag_contiguous:		CHARACTER_8 = '7' -- Typeflag for contigeous files

	tar_typeflag_pax_extended:		CHARACTER_8 = 'x' -- Typeflag for pax extended header

	tar_typeflag_pax_global:		CHARACTER_8 = 'g' -- Typeflag for pax global header

feature -- Miscellaneous
	tar_block_size:	INTEGER = 512 -- Block size in tar

end
