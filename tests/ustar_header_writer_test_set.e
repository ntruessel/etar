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

	test_ustar_header_writer
			-- Test whether ustar header writer generates correct ustar headers
		note
			testing:  "covers/{USTAR_HEADER_WRITER}"
		local
			easy_tar_header: TAR_HEADER
			unit_under_test: USTAR_HEADER_WRITER
			p: MANAGED_POINTER
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

			p := unit_under_test.write_to_new_managed_pointer (easy_tar_header)
			easy_header_template.replace_substring_all ("$", "%U")
			
			assert ("can write valid header", unit_under_test.can_write (easy_tar_header))
			assert ("has correct size", unit_under_test.required_space (easy_tar_header) = 512)


			assert ("not_implemented", False)
		end

feature {NONE} -- Data

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
end


