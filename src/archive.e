note
	description: "[
		This class models an archive and allows to
		create new archives and unarchive existing archives
		
		It supports the following storage backends:
			- files
		
		It supports the following modes:
			- unarchiving (reading)
			- archiving (writing)
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ARCHIVE

create
	make_archive_file,
--	make_archive_append_file,
	make_unarchive_file
--	make_archive_memory,
--	make_archive_append_memory,
--	make_unarchive_memory

feature {NONE} -- Initialization

	make_unarchive_file (a_file: FILE)
			-- Open archive for unarchiving (reading) from file `a_file'
		do
			initialize_file_unarchivers
			initialize_header_utilities

			storage_backend := a_file

			mode := mode_unarchive
		ensure
			unarchive_mode: mode = mode_unarchive
		end

	make_archive_file (a_file: FILE)
			-- Open archive for archiving (writing) to file `a_file'
		do
			initialize_file_unarchivers
			initialize_header_utilities

			storage_backend := a_file

			mode := mode_archive
		ensure
			archiving_mode: mode = mode_archive
		end

	initialize_file_unarchivers
			-- Initialize `unarchivers' with file unarchivers
		do
			create {ARRAYED_LIST [UNARCHIVER]} unarchivers.make (2)
			unarchivers.extend (create {FILE_UNARCHIVER})
			unarchivers.extend (create {DIRECTORY_UNARCHIVER})
		end

	initialize_header_utilities
			-- Initialize `header_parser' and `header_writer'
		do
			create {PAX_HEADER_WRITER} header_writer
			create {PAX_HEADER_PARSER} header_parser
		end

feature -- Status

	mode: INTEGER
			-- In what mode has this instance be created

	mode_unarchive: INTEGER = 0
			-- unarchive (read) mode

	mode_archive: INTEGER = 1
			-- archive (write) mode

feature -- Unarchiving

	add_unarchiver (a_unarchiver: UNARCHIVER)
			-- Add unarchiver `a_unarchiver' to `unarchivers'
		do
			unarchivers.force (a_unarchiver)
		end

	unarchive_next_entry
			-- Unarchives the next entry
		require
			unarchiving_mode: mode = mode_unarchive
		local
			l_unarchiver: detachable UNARCHIVER
			l_buffer: MANAGED_POINTER
		do
			create l_buffer.make ({TAR_CONST}.tar_block_size)

				-- parse header
			from
				storage_backend.read_to_managed_pointer (l_buffer, 0, l_buffer.count)
				header_parser.parse_block (l_buffer, 0)
			until
				header_parser.parsing_finished or header_parser.has_error
			loop
				storage_backend.read_to_managed_pointer (l_buffer, 0, l_buffer.count)
				header_parser.parse_block (l_buffer, 0)
			end

			if attached header_parser.parsed_header as l_header then
				l_unarchiver := matching_unarchiver (l_header)
				if l_unarchiver /= Void then
						-- Parse payload
					from
						l_unarchiver.initialize (l_header)
					until
						l_unarchiver.unarchiving_finished
					loop
						storage_backend.read_to_managed_pointer (l_buffer, 0, l_buffer.count)
						l_unarchiver.unarchive_block (l_buffer, 0)
					end
				end
			else
				-- Error
			end
		end

feature {NONE} -- Implementation

	storage_backend: FILE
			-- Storage backend to use, set on initialization

	unarchivers: LIST [UNARCHIVER]
			-- List of all registered unarchivers.

	matching_unarchiver (a_header: TAR_HEADER): detachable UNARCHIVER
			-- Return the last added unarchiver that can unarchive `a_header', Void if none
		local
			l_cursor: like unarchivers.new_cursor
		do
			from
				l_cursor := unarchivers.new_cursor
				l_cursor.reverse
				l_cursor.start
			until
				l_cursor.after or Result /= Void
			loop
				if l_cursor.item.can_unarchive (a_header) then
					Result := l_cursor.item
				end
			end
		end

	header_parser: TAR_HEADER_PARSER
			-- Parser to use for header parsing

	header_writer: TAR_HEADER_WRITER
			-- Writer to use for header writing
end
