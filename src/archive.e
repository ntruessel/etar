note
	description: "[
		This class models an archive and allows to
		create new archives and unarchive existing archives

		It supports the following modes:
			- unarchiving (reading)
			- archiving (writing)
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ARCHIVE

inherit
	ERROR_UTILS
		redefine
			default_create
		end

create
	make

feature {NONE} -- Initialization

	default_create
			-- (Ab)used for internal initialization
		do
				-- Header utilities
			create {PAX_HEADER_WRITER} header_writer
			create {PAX_HEADER_PARSER} header_parser

				-- Unarchivers
			create {ARRAYED_LIST [UNARCHIVER]} unarchivers.make (3)

--			unarchiving_finished := False

			Precursor

				-- Add default unarchivers
			add_unarchiver (create {SKIP_UNARCHIVER})
			add_unarchiver (create {FILE_UNARCHIVER})
			add_unarchiver (create {DIRECTORY_UNARCHIVER})


				-- Error redirections
			header_parser.register_redirector (Current, "Header parser")
			storage_backend.register_redirector (Current, "Storage backend")
		end

	make (a_storage_backend: STORAGE_BACKEND)
			-- Creat new archive with backend `a_storage_backend'
		do
			storage_backend := a_storage_backend

			default_create
		ensure
			storage_backend_set: storage_backend = a_storage_backend
		end

feature -- Status setting

	open_archive
			-- Open for archiving
		do
			storage_backend.open_write
			mode := mode_archive
		ensure
			archive_mode: mode = mode_archive
		end

	open_unarchive
			-- Open for unarchiving
		do
			storage_backend.open_read
			mode := mode_unarchive
		ensure
			unarchive_mode: mode = mode_unarchive
		end

feature -- Status

	mode: INTEGER
			-- In what mode has this instance been created

	mode_unarchive: INTEGER = 0
			-- unarchive (read) mode

	mode_archive: INTEGER = 1
			-- archive (write) mode

feature -- Unarchiving

	add_unarchiver (a_unarchiver: UNARCHIVER)
			-- Add unarchiver `a_unarchiver' to `unarchivers'
		do
			unarchivers.force (a_unarchiver)
			a_unarchiver.register_redirector (Current, a_unarchiver.name)
		end

	unarchiving_finished: BOOLEAN
			-- Indicate whether unarchiving finished
		do
			Result := has_error or storage_backend.archive_finished
		end

	unarchive
			-- Unarchive the whole archive
		require
			unarchiving_mode: mode = mode_unarchive
		do
			from

			until
				unarchiving_finished
			loop
				unarchive_next_entry
			end
		end

	unarchive_next_entry
			-- Unarchives the next entry
		require
			unarchiving_mode: mode = mode_unarchive
		local
			l_unarchiver: detachable UNARCHIVER
		do
			if not unarchiving_finished or has_error then
					-- parse header
				from
					storage_backend.read_block
					if storage_backend.block_ready then
						header_parser.parse_block (storage_backend.last_block, 0)
					else
						report_error ("Not enough blocks to parse header")
					end
				until
					header_parser.parsing_finished or has_error
				loop
					storage_backend.read_block
					if storage_backend.block_ready then
						header_parser.parse_block (storage_backend.last_block, 0)
					else
						report_error ("Not enough blocks to parse header")
					end
				end

				if not has_error then
					if attached header_parser.parsed_header as l_header then
						l_unarchiver := matching_unarchiver (l_header)
						if l_unarchiver /= Void then
								-- Parse payload
							from
								l_unarchiver.initialize (l_header)
							until
								has_error or l_unarchiver.unarchiving_finished
							loop
								storage_backend.read_block
								if storage_backend.block_ready then
									l_unarchiver.unarchive_block (storage_backend.last_block, 0)
								else
									report_error ("Not enough blocks for payload")
								end
							end
						else
							report_error ("No unarchiver found")
						end
					else
							-- unreachable (TAR_HEADER_PARSER invariant)
						report_error ("Failed to parse header")
					end
				end
			end
		end

feature {NONE} -- Implementation

	storage_backend: STORAGE_BACKEND
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
