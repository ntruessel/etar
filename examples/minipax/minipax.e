note
	description : "[
		minimal pax implementation (lacking many features, different usage, different behavior)
	]"
	date        : "$Date$"
	revision    : "$Revision$"

class
	MINIPAX

inherit
	SHARED_EXECUTION_ENVIRONMENT

	LOCALIZED_PRINTER

create
	make

feature {NONE} -- Initialization

	make
			-- Run minitar
		do
			create options
			options.parse (execution_environment.arguments)

			inspect options.mode
			when {OPTIONS}.mode_usage then
				print_usage
			when {OPTIONS}.mode_list then
				list
			when {OPTIONS}.mode_unarchive then
				unarchive
			when {OPTIONS}.mode_archive then
				archive
			else
				-- Unreachable
			end
		end

feature {NONE} -- Implementation

	options: OPTIONS
			-- Program options

	list
			-- List contents of the archive stored at `a_archive_filename'
		local
			l_archive: ARCHIVE
			l_header_save_unarchiver: HEADER_SAVE_UNARCHIVER
			l_pp: HEADER_LIST_PRETTY_PRINTER
			l_header_pp: LIST [READABLE_STRING_GENERAL]
		do
			l_archive := build_archive
			create l_header_save_unarchiver
			l_archive.add_unarchiver (l_header_save_unarchiver)
			l_archive.open_unarchive
			l_archive.unarchive

			create l_pp
			l_header_pp := l_pp.pretty_print (l_header_save_unarchiver.headers)
			across
				l_header_pp as l_cur
			loop
				localized_print (l_cur.item)
				localized_print ("%N")
			end
		end

	archive
			-- Archive `a_filenames' to the archive stored at `a_archive_filename' (creating it if it does not exist, overwriting otherwise)
		local
			l_archive: ARCHIVE
			l_file: FILE
			l_dir: DIRECTORY
			l_to_archive: QUEUE [PATH]
		do
			l_archive := build_archive
			l_archive.open_archive

			from
				create {ARRAYED_QUEUE [PATH]} l_to_archive.make (options.file_list.count)
				across
					options.file_list as l_cur
				loop
					l_to_archive.force (create {PATH}.make_from_string (l_cur.item))
				end
			until
				l_to_archive.is_empty
			loop
				create {RAW_FILE} l_file.make_with_path (l_to_archive.item)
				if l_file.exists then
					if l_file.is_directory then
						l_archive.add_entry (create {DIRECTORY_ARCHIVABLE}.make (l_file))

						create l_dir.make_with_path (l_to_archive.item)
						across
							l_dir.entries as l_cur
						loop
							if l_cur.item.name /~ "." and l_cur.item.name /~ ".." then
								l_to_archive.force (l_to_archive.item + l_cur.item)
							end
						end
					elseif l_file.is_plain and not l_file.path.same_as (create {PATH}.make_from_string (options.archive_name)) then
						l_archive.add_entry (create {FILE_ARCHIVABLE}.make (l_file))
					else
						-- Warn about unsupported filetype
					end
				else
					-- Warn about non-existing file
				end
				l_to_archive.remove
			end

			l_archive.finalize
		end

	unarchive
			-- Unarchive contents of the archive stored at `a_archive_filename'
		local
			l_archive: ARCHIVE
		do
			l_archive := build_archive
			l_archive.add_unarchiver (create {FILE_UNARCHIVER})
			l_archive.add_unarchiver (create {DIRECTORY_UNARCHIVER})
			l_archive.open_unarchive
			l_archive.unarchive
		end

	build_archive: ARCHIVE
			-- Build archive according to `options'
		do
			create Result.make (create {FILE_STORAGE_BACKEND}.make_from_filename (options.archive_name))

			if options.absolute_paths then
				Result.enable_absolute_filenames
			end
		end

	print_usage
			-- Print usage of this utility
		do
			localized_print (
			"[
Usage: 
    - minipax [-A] -f archive
        List mode: minipax prints the contents of the specified archive
    - minipax [-A] -r -f archive
        Read mode: minipax unarchives the contents of the specified archive
    - minipax [-A] -w -f archive file...
        Write mode: minipax archives the given list of files, creating the
                    archive if it does not exist, overriding it otherwise
Options
    -A      Allow absolute paths and parent directory identifiers in filenames

			]")
		end

end
