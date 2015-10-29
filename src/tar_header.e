note
	description: "[
		Header of a tar entry.
		Contains the metadata about the following payload.
		
		Writes pax interchange format compliant headers to files,
		and parses them.
		
		Compare http://pubs.opengroup.org/onlinepubs/9699919799/
		for the pax/ustar specification
	]"
	date: "$Date$"
	revision: "$Revision$"

-- TODO: implement reading and writing from/to file

class
	TAR_HEADER
inherit {NONE}
	TAR_CONST

create
	make

feature {NONE} -- Initialization

	make
			-- Create an empty TAR_HEADER
		do
			create filename.make_empty
			create linkname.make_empty
			create user_name.make_empty
			create group_name.make_empty
		end

feature -- Fields

	filename: PATH
			-- File name

	mode: NATURAL_16
			-- Protection mode (lower 12 bits)

	user_id: NATURAL_32
			-- User ID

	group_id: NATURAL_32
			-- Group ID

	size: NATURAL_64
			-- File size

	mtime: NATURAL_64
			-- Last modification time

	checksum: NATURAL_32
			-- Header checksum

	typeflag: CHARACTER_8
			-- File type flag

	linkname: PATH
			-- Link target

	magic: STRING_8 = "ustar"
			-- Header magic, we only support ustar.

	version: STRING_8 = "00"
			-- Header version

	user_name: IMMUTABLE_STRING_8
			-- User name

	group_name: IMMUTABLE_STRING_8
			-- Group name

	device_major: NATURAL_32
			-- Major device number

	device_minor: NATURAL_32
			-- Minor device number

feature -- Mode queries

	is_setuid: BOOLEAN
			-- is the setuid bit set?
		do
			Result := (mode & setuid_mask) /= 0
		end

	is_setgid: BOOLEAN
			-- is the setgid bit set?
		do
			Result := (mode & setgid_mask) /= 0
		end

	is_user_readable: BOOLEAN
			-- is the user-read bit set?
		do
			Result := (mode & uread_mask) /= 0
		end

	is_user_writable: BOOLEAN
			-- is the user-write bit set?
		do
			Result := (mode & uwrite_mask) /= 0
		end

	is_user_executable: BOOLEAN
			-- is the user-execute bit set?
		do
			Result := (mode & uexec_mask) /= 0
		end

	is_group_readable: BOOLEAN
			-- is the group-read bit set?
		do
			Result := (mode & gread_mask) /= 0
		end

	is_group_writable: BOOLEAN
			-- is the group-write bit set?
		do
			Result := (mode & gwrite_mask) /= 0
		end

	is_group_executable: BOOLEAN
			-- is the group-execute bit set?
		do
			Result := (mode & gexec_mask) /= 0
		end

	is_other_readable: BOOLEAN
			-- is the other-read bit set?
		do
			Result := (mode & oread_mask) /= 0
		end

	is_other_writable: BOOLEAN
			-- is the other-write bit set?
		do
			Result := (mode & owrite_mask) /= 0
		end

	is_other_executable: BOOLEAN
			-- is the other-execute bit set?
		do
			Result := (mode & oexec_mask) /= 0
		end

feature -- Assign

	set_filename (a_filename: PATH)
			-- Set `filename' to `a_filename'
		do
			create filename.make_from_separate (a_filename)
		ensure
			correctly_set: filename ~ a_filename
		end

	set_mode (a_mode: NATURAL_16)
			-- Set `mode' to `a_mode'
		do
			mode := a_mode
		ensure
			correctly_set: mode = a_mode
		end

	set_user_id (a_user_id: NATURAL_32)
			-- Set `user_id' to `a_user_id'
		do
			user_id := a_user_id
		ensure
			correctly_set: user_id = a_user_id
		end

	set_group_id (a_group_id: NATURAL_32)
			-- Set `group_id' to `a_group_id'
		do
			group_id := a_group_id
		ensure
			correctly_set: group_id = a_group_id
		end

	set_size (a_size: NATURAL_64)
			-- Set `size' to `a_size'
		do
			size := a_size
		ensure
			correctly_set: size = a_size
		end

	set_mtime (a_mtime: NATURAL_64)
			-- Set `mtime' to `a_mtime'
		do
			mtime := a_mtime
		ensure
			correctly_set: mtime = a_mtime
		end

	set_typeflag (a_typeflag: CHARACTER_8)
			-- Set `typeflag' to `a_typeflag'
		do
			typeflag := a_typeflag
		ensure
			correctly_set: typeflag = a_typeflag
		end

	set_linkname (a_linkname: PATH)
			-- Set `linkname' to `a_linkname'
		do
			linkname := a_linkname
		ensure
			correctly_set: linkname ~ a_linkname
		end

	set_user_name (a_user_name: STRING_8)
			-- Set `user_name' to `a_user_name'
		do
			create user_name.make_from_string (a_user_name)
		ensure
			correctly_set: user_name.out ~ a_user_name
		end

	set_group_name (a_group_name: STRING_8)
			-- Set `group_name' to `a_group_name'
		do
			create group_name.make_from_string (a_group_name)
		ensure
			correctly_set: group_name.out ~ a_group_name
		end

	set_device_major (a_device_major: NATURAL_32)
			-- Set `device_major' to `a_device_major'
		do
			device_major := a_device_major
		ensure
			correctly_set: device_major = a_device_major
		end

	set_device_minor (a_device_minor: NATURAL_32)
			-- Set `device_minor' to `a_device_minor'
		do
			device_minor := a_device_minor
		ensure
			correctly_set: device_minor = a_device_minor
		end

	set_setuid (b: BOOLEAN)
			-- Set uid bit to `b'
		do
			mode := if b then mode | setuid_mask else mode & (setuid_mask.bit_not) end
		ensure
			correctly_set: is_setuid = b
		end

	set_setgid (b: BOOLEAN)
			-- Set gid bit to `b'
		do
			mode := if b then mode | setgid_mask else mode & (setgid_mask.bit_not) end
		ensure
			correctly_set: is_setgid = b
		end

	set_user_readable (b: BOOLEAN)
			-- Set user-read bit to `b'
		do
			mode := if b then mode | uread_mask else mode & (uread_mask.bit_not) end
		ensure
			correctly_set: is_user_readable = b
		end

	set_user_writable (b: BOOLEAN)
			-- Set user-write bit to `b'
		do
			mode := if b then mode | uwrite_mask else mode & (uwrite_mask.bit_not) end
		ensure
			correctly_set: is_user_writable = b
		end

	set_user_executable (b: BOOLEAN)
			-- Set user-execute bit to `b'
		do
			mode := if b then mode | uexec_mask else mode & (uexec_mask.bit_not) end
		ensure
			correctly_set: is_user_executable = b
		end

	set_group_readable (b: BOOLEAN)
			-- Set group-read bit to `b'
		do
			mode := if b then mode | gread_mask else mode & (gread_mask.bit_not) end
		ensure
			correctly_set: is_group_readable = b
		end

	set_group_writable (b: BOOLEAN)
			-- Set group-write bit to `b'
		do
			mode := if b then mode | gwrite_mask else mode & (gwrite_mask.bit_not) end
		ensure
			correctly_set: is_group_writable = b
		end

	set_group_executable (b: BOOLEAN)
			-- Set group-execute bit to `b'
		do
			mode := if b then mode | gexec_mask else mode & (gexec_mask.bit_not) end
		ensure
			correctly_set: is_group_executable = b
		end

	set_other_readable (b: BOOLEAN)
			-- Set other-read bit to `b'
		do
			mode := if b then mode | oread_mask else mode & (oread_mask.bit_not) end
		ensure
			correctly_set: is_other_readable = b
		end

	set_other_writable (b: BOOLEAN)
			-- Set other-write bit to `b'
		do
			mode := if b then mode | owrite_mask else mode & (owrite_mask.bit_not) end
		ensure
			correctly_set: is_other_writable = b
		end

	set_other_executable (b: BOOLEAN)
			-- Set other-execute bit to `b'
		do
			mode := if b then mode | oexec_mask else mode & (oexec_mask.bit_not) end
		ensure
			correctly_set: is_other_executable = b
		end

	set_from_fileinfo (a_fileinfo: FILE_INFO)
			-- Set all fields from `a_fileinfo' if a_fileinfo.file_name is attached
		do
			if attached a_fileinfo.file_entry as file_path and (a_fileinfo.is_plain or a_fileinfo.is_directory) then
				set_filename (file_path)
				set_mode (a_fileinfo.protection.to_natural_16)
				set_user_id (a_fileinfo.user_id.to_natural_32)
				set_group_id (a_fileinfo.group_id.to_natural_32)
				set_size (a_fileinfo.size.to_natural_64)
				set_mtime (a_fileinfo.date.to_natural_64)

				if (a_fileinfo.is_plain) then
					set_typeflag (tar_typeflag_regular_file)
				elseif (a_fileinfo.is_directory) then
					set_typeflag (tar_typeflag_directory)
				else
					-- unreachable
				end

				set_user_name (a_fileinfo.owner_name)
				set_group_name (a_fileinfo.group_name)
			end
		end

feature -- ustar fitting
	-- NOTE: Everything that always fits is not mentioned

	filename_fits: BOOLEAN
			-- Indicates whether `filename' fits in a ustar header
		do
			-- We don't mind splitting the string in a platform independent way.
			-- If it's too long to fit into the name field we add an extended header
			-- This is not as efficient as possible but less error prone than splitting
			Result := filename.utf_8_name.count <= tar_header_name_length
		end

	user_id_fits: BOOLEAN
			-- Indicates whether `user_id' fits in ustar header
		do
			-- + 1 for the terminating space or '%U'
			Result := drop_leading_zeros (natural_64_to_octal_string (user_id.to_natural_64)).count + 1 <= tar_header_uid_length
		end

	group_id_fits: BOOLEAN
			-- Indicates whether `group_id' fits in ustar header
		do
			-- + 1 for the terminating space or '%U'
			Result := drop_leading_zeros (natural_64_to_octal_string (group_id.to_natural_64)).count + 1 <= tar_header_gid_length
		end

	size_fits: BOOLEAN
			-- Indicates whether `size' fits in a ustar header
		do
			-- + 1 for the terminating space or '%U'
			Result := drop_leading_zeros (natural_64_to_octal_string (size)).count + 1 <= tar_header_size_length
		end

	user_name_fits: BOOLEAN
			-- Indicates whether `user_name' fits in a ustar header
		do
			Result := user_name.count <= tar_header_uname_length
		end

	group_name_fits: BOOLEAN
			-- Indicates whether `group_name' fits in a ustar header
		do
			Result := group_name.count <= tar_header_gname_length
		end

	fits_in_ustar: BOOLEAN
			-- Indecates whether the whole header fits in a ustar header
		do
			Result := filename_fits and user_id_fits and group_id_fits and size_fits and user_name_fits and group_name_fits
		end

feature -- Input

	read_from_file (a_file: FILE)
			-- Read an entire header from `a_file'
		do
			-- Read first header. If it's an extended header read things from its payload
			-- Now read ustar header and fill rest of informations (extended header has higher
			-- priority)
		end

feature -- Output

	write_to_file (a_file: FILE)
			-- Write the entire header to `a_file'
		do
			if fits_in_ustar then
				-- Fits into single ustar header
			else
				-- Have to create extended header
			end
		end

feature {NONE} -- Utilities

	natural_8_to_octal_character (a_number: NATURAL_8): CHARACTER_8
			-- Octal character representing `a_number'
		require
			in_bounds: 0 <= a_number and a_number <= 7
		do
			Result := (a_number.to_integer_32 + ('0').code).to_character_8
		ensure
			valid_character: ("01234567").has (Result)
		end

	natural_64_to_octal_string (a_number: NATURAL_64): STRING_8
			-- Octal representation of `a_number'
		local
			i: INTEGER
			tmp: NATURAL_64
		do
			from
				i := 1
				tmp := a_number
				create Result.make_empty
			until
				i > 64 // 3 + 1
			loop
				Result.append_character (natural_8_to_octal_character((tmp & 0c7).to_natural_8))
				tmp := tmp |>> 3
				i := i + 1
			end
			Result.mirror
		end

	drop_leading_zeros (a_string: STRING_8): STRING_8
			-- Drop all leading zeros of `a_string' except last
		local
			i: INTEGER
		do
			Result := a_string.twin
			from
				i := 1
			until
				i >= Result.count or else Result[i] /= '0'
			loop
				i := i + 1
			end
			Result.keep_tail (Result.count - i + 1)
		end

end
