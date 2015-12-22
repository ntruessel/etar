note
	description: "[
		Header related constants used by tar
	]"
	date: "$Date$"
	revision: "$Revision$"

class
	TAR_HEADER_CONST

feature -- ustar field offsets and lengths (bytes)
		-- FIXME: Group this constants logically (TUPLE?)
		-- FIXME: Contains a lot of redundancy

	name_offset: 		INTEGER =   0 	-- filename field offset
	name_length: 		INTEGER = 100 	-- filename field length

	mode_offset: 		INTEGER = 100 	-- mode field offset
	mode_length: 		INTEGER =   8 	-- mode field length

	uid_offset: 		INTEGER = 108 	-- user-id field offset
	uid_length: 		INTEGER =   8 	-- user-id field length

	gid_offset: 		INTEGER = 116 	-- group-id field offset
	gid_length: 		INTEGER =   8 	-- group-id field length

	size_offset: 		INTEGER = 124 	-- filesize field offset
	size_length: 		INTEGER =  12 	-- filesize field length

	mtime_offset: 		INTEGER = 136 	-- last modified field offset
	mtime_length: 		INTEGER =  12 	-- last modified field length

	chksum_offset: 		INTEGER = 148 	-- checksum field offset
	chksum_length: 		INTEGER =   8 	-- checksum field length

	typeflag_offset: 	INTEGER = 156 	-- typeflag field offset
	typeflag_length: 	INTEGER =   1 	-- typeflag field length

	linkname_offset: 	INTEGER = 157 	-- linkname (pointee of link) field offset
	linkname_length: 	INTEGER = 100 	-- linkname (pointee of link) field length

	magic_offset: 		INTEGER = 257 	-- magic field offset
	magic_length: 		INTEGER =   6 	-- magic field length

	version_offset: 	INTEGER = 263 	-- version field offset
	version_length: 	INTEGER =   2 	-- version field length

	uname_offset: 		INTEGER = 265 	-- username field offset
	uname_length: 		INTEGER =  32 	-- username field length

	gname_offset: 		INTEGER = 297 	-- groupname field offset
	gname_length: 		INTEGER =  32 	-- groupname field length

	devmajor_offset: 	INTEGER = 329 	-- device major field offset
	devmajor_length: 	INTEGER =   8 	-- device major field length

	devminor_offset: 	INTEGER = 337 	-- device minor field offset
	devminor_length: 	INTEGER =   8 	-- device minor field length

	prefix_offset: 		INTEGER = 345 	-- filename prefix field offset
	prefix_length: 		INTEGER = 155 	-- filename prefix field length	

end
