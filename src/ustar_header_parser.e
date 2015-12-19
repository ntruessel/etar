note
	description: "Summary description for {USTAR_HEADER_PARSER}."
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
			-- TODO: parse filename
			-- TODO: parse mode
			-- TODO: parse uid
			-- TODO: parse gid
			-- TODO: parse size
			-- TODO: parse mtime
			-- TODO: parse chksum
			-- TODO: parse typeflag
			-- TODO: parse linkname
			-- TODO: parse magic
			-- TODO: parse version
			-- TODO: parse uname
			-- TODO: parse gname
			-- TODO: parse devmajor
			-- TODO: parse devminor
			-- TODO: parse prefix
		end

end
