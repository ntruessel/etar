note
	description: "[
		Eiffel tests that can be executed by testing tool.
	]"
	author: "EiffelStudio test wizard"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	USTAR_HEADER_WRITER_TEST_SET

inherit
	EQA_TEST_SET

feature -- Test routines

	test_easy_header
			-- Test whether USTAR_HEADER_WRITER generates correct ustar headers for a pretty standard file
		note
			testing:  "covers/{USTAR_HEADER_WRITER}"
		local
			easy_tar_header: TAR_HEADER
			unit_under_test: USTAR_HEADER_WRITER
			output: SPECIAL[CHARACTER_8]
		do
			create unit_under_test
			create easy_tar_header.make
			easy_tar_header.set_filename (create {PATH}.make_from_string (easy_header_filename))
			easy_tar_header.set_mode (easy_header_mode)
			easy_tar_header.set_user_id (easy_header_uid)
			easy_tar_header.set_group_id (easy_header_gid)
			easy_tar_header.set_size (easy_header_size)
			easy_tar_header.set_mtime (easy_header_mtime)
			easy_tar_header.set_typeflag (easy_header_typeflag)
			easy_tar_header.set_user_name (easy_header_username)
			easy_tar_header.set_group_name (easy_header_groupname)

			assert ("can write valid header", unit_under_test.can_write (easy_tar_header))
			assert ("has correct size", unit_under_test.required_space (easy_tar_header) = {TAR_CONST}.tar_block_size)

			output := unit_under_test.write_to_new_managed_pointer (easy_tar_header).read_special_character_8 (0, {TAR_CONST}.tar_block_size)
			easy_header_template.replace_substring_all ("$", "%U")

			assert ("correct output length", output.count = {TAR_CONST}.tar_block_size)
			assert ("correct output content", compare_special (easy_header_template.area, output, {TAR_CONST}.tar_block_size))
		end

	test_link_header
			-- Test whether USTAR_HEADER_WRITER generates correct ustar headers for symlinks
		note
			testing:  "covers/{USTAR_HEADER_WRITER}"
		local
			link_tar_header: TAR_HEADER
			unit_under_test: USTAR_HEADER_WRITER
			output: SPECIAL[CHARACTER_8]
		do
			create unit_under_test
			create link_tar_header.make
			link_tar_header.set_filename (create {PATH}.make_from_string (link_header_filename))
			link_tar_header.set_mode (link_header_mode)
			link_tar_header.set_user_id (link_header_uid)
			link_tar_header.set_group_id (link_header_gid)
			link_tar_header.set_mtime (link_header_mtime)
			link_tar_header.set_typeflag (link_header_typeflag)
			link_tar_header.set_linkname (create {PATH}.make_from_string (link_header_linkname))
			link_tar_header.set_user_name (link_header_username)
			link_tar_header.set_group_name (link_header_groupname)

			assert ("can write valid header", unit_under_test.can_write (link_tar_header))
			assert ("has correct size", unit_under_test.required_space (link_tar_header) = {TAR_CONST}.tar_block_size)

			output := unit_under_test.write_to_new_managed_pointer (link_tar_header).read_special_character_8 (0, {TAR_CONST}.tar_block_size)
			link_header_template.replace_substring_all ("$", "%U")

			assert ("correct output length", output.count = {TAR_CONST}.tar_block_size)
			assert ("correct output content", compare_special (link_header_template.area, output, {TAR_CONST}.tar_block_size))
		end

	test_devnode_header
			-- Test whether USTAR_HEADER_WRITER generates correct ustar headers for device nodes
		note
			testing:  "covers/{USTAR_HEADER_WRITER}"
		local
			devnode_tar_header: TAR_HEADER
			unit_under_test: USTAR_HEADER_WRITER
			output: SPECIAL[CHARACTER_8]
		do
			create unit_under_test
			create devnode_tar_header.make
			devnode_tar_header.set_filename (create {PATH}.make_from_string (devnode_header_filename))
			devnode_tar_header.set_mode (devnode_header_mode)
			devnode_tar_header.set_user_id (devnode_header_uid)
			devnode_tar_header.set_group_id (devnode_header_gid)
			devnode_tar_header.set_mtime (devnode_header_mtime)
			devnode_tar_header.set_typeflag (devnode_header_typeflag)
			devnode_tar_header.set_user_name (devnode_header_username)
			devnode_tar_header.set_group_name (devnode_header_groupname)
			devnode_tar_header.set_device_major (devnode_header_devmajor)
			devnode_tar_header.set_device_minor (devnode_header_devminor)

			assert ("can write valid header", unit_under_test.can_write (devnode_tar_header))
			assert ("has correct size", unit_under_test.required_space (devnode_tar_header) = {TAR_CONST}.tar_block_size)

			output := unit_under_test.write_to_new_managed_pointer (devnode_tar_header).read_special_character_8 (0, {TAR_CONST}.tar_block_size)
			devnode_header_template.replace_substring_all ("$", "%U")

			assert ("correct output length", output.count = {TAR_CONST}.tar_block_size)
			assert ("correct output content", compare_special (devnode_header_template.area, output, {TAR_CONST}.tar_block_size))
		end

feature {NONE} -- Test utils

	compare_special (expected, actual: SPECIAL[CHARACTER_8]; n: INTEGER): BOOLEAN
			-- Compare first n bytes of `expected` to `actual` and return whether they are equal.
			-- If they are not equal print all differences found
		require
			expected_size: expected.count >= n
			actual_size: actual.count >= n
		local
			i: INTEGER
		do
			from
				i := 0
				Result := true
			until
				i >= expected.count.min (actual.count)
			loop
				if expected[i] /= actual[i] then
					io.put_string ("Missmatch at byte ")
					io.put_integer (i)
					io.put_string (" expected: ")
					io.put_character (expected[i])
					io.put_string (" actual: ")
					io.put_character (actual[i])
					io.new_line
					Result := False
				end
				i := i + 1
			end
		end

feature {NONE} -- Data - Easy

	-- Templates use $ instead of %U (because like this all characters are the same width)
	--	                               Filename                                                                                            Mode    uid     gid     size        mtime       chksum T Linkname                                                                                            mag  Ve username                        groupname                       dmajor  dminor  prefix                                                                                                                                                     unused
	--                                |                                                                                                  ||      ||      ||      ||          ||          ||      |||                                                                                                  ||    ||||                              ||                              ||      ||      ||                                                                                                                                                         ||           |
	--                       Offset:  0       8      16      24      32      40      48      56      64      72      80      88      96     104     112     120     128     136     144     152     160     168     176     184     192     200     208     216     224     232     240     248     256     264     272     280     288     296     304     312     320     328     336     344     352     360     368     376     384     392     400     408     416     424     432     440     448     456     464     472     480     488     496     504     512
	--                                |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |
	easy_header_template: STRING_8 = "home/nicolas/out.ps$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$0000644$0001750$0000144$00001215414$12615214330$0015465$0$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ustar$00nicolas$$$$$$$$$$$$$$$$$$$$$$$$$users$$$$$$$$$$$$$$$$$$$$$$$$$$$0000000$0000000$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
	easy_header_filename: STRING_8 = "home/nicolas/out.ps"
	easy_header_mode: NATURAL_16 = 0c0644
	easy_header_uid: NATURAL_32 = 0c1750
	easy_header_gid: NATURAL_32 = 0c144
	easy_header_size: NATURAL_64 = 0c1215414
	easy_header_mtime: NATURAL_64 = 0c12615214330
	easy_header_typeflag: CHARACTER_8 = '0'
	easy_header_username: STRING_8 = "nicolas"
	easy_header_groupname: STRING_8 = "users"

feature {NONE} -- Data - Link

	-- Templates use $ instead of %U (because like this all characters are the same width)
	--	                               Filename                                                                                            Mode    uid     gid     size        mtime       chksum T Linkname                                                                                            mag  Ve username                        groupname                       dmajor  dminor  prefix                                                                                                                                                     unused
	--                                |                                                                                                  ||      ||      ||      ||          ||          ||      |||                                                                                                  ||    ||||                              ||                              ||      ||      ||                                                                                                                                                         ||           |
	--                       Offset:  0       8      16      24      32      40      48      56      64      72      80      88      96     104     112     120     128     136     144     152     160     168     176     184     192     200     208     216     224     232     240     248     256     264     272     280     288     296     304     312     320     328     336     344     352     360     368     376     384     392     400     408     416     424     432     440     448     456     464     472     480     488     496     504     512
	--                                |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |
	link_header_template: STRING_8 = ".zshrc$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$0000777$0001750$0000144$00000000000$12525702750$0016552$2dotfiles/zsh/zshrc$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ustar$00nicolas$$$$$$$$$$$$$$$$$$$$$$$$$users$$$$$$$$$$$$$$$$$$$$$$$$$$$0000000$0000000$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
	link_header_filename: STRING_8 = ".zshrc"
	link_header_mode: NATURAL_16 = 0c0777
	link_header_uid: NATURAL_32 = 0c1750
	link_header_gid: NATURAL_32 = 0c144
	link_header_mtime: NATURAL_64 = 0c12525702750
	link_header_typeflag: CHARACTER_8 = '2'
	link_header_linkname: STRING_8 = "dotfiles/zsh/zshrc"
	link_header_username: STRING_8 = "nicolas"
	link_header_groupname: STRING_8 = "users"

feature {NONE} -- Data - Device Node

	-- Templates use $ instead of %U (because like this all characters are the same width)
	--                                    Filename                                                                                            Mode    uid     gid     size        mtime       chksum T Linkname                                                                                            mag  Ve username                        groupname                       dmajor  dminor  prefix                                                                                                                                                     unused
	--                                   |                                                                                                  ||      ||      ||      ||          ||          ||      |||                                                                                                  ||    ||||                              ||                              ||      ||      ||                                                                                                                                                         ||           |
	--                          Offset:  0       8      16      24      32      40      48      56      64      72      80      88      96     104     112     120     128     136     144     152     160     168     176     184     192     200     208     216     224     232     240     248     256     264     272     280     288     296     304     312     320     328     336     344     352     360     368     376     384     392     400     408     416     424     432     440     448     456     464     472     480     488     496     504     512
	--                                   |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |
	devnode_header_template: STRING_8 = "dev/sda1$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$0000660$0000000$0000006$00000000000$12631223040$0012345$4$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ustar$00root$$$$$$$$$$$$$$$$$$$$$$$$$$$$disk$$$$$$$$$$$$$$$$$$$$$$$$$$$$0000010$0000001$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
	devnode_header_filename: STRING_8 = "dev/sda1"
	devnode_header_mode: NATURAL_16 = 0c0660
	devnode_header_uid: NATURAL_32 = 0c0
	devnode_header_gid: NATURAL_32 = 0c6
	devnode_header_mtime: NATURAL_64 = 0c12631223040
	devnode_header_typeflag: CHARACTER_8 = '4'
	devnode_header_username: STRING_8 = "root"
	devnode_header_groupname: STRING_8 = "disk"
	devnode_header_devmajor: NATURAL_32 = 0c10
	devnode_header_devminor: NATURAL_32 = 0c1


end


