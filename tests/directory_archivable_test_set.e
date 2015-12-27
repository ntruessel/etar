note
	description: "[
		Eiffel tests that can be executed by testing tool.
	]"
	author: "EiffelStudio test wizard"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	DIRECTORY_ARCHIVABLE_TEST_SET

inherit
	EQA_TEST_SET

feature -- Test routines

	test_directory_archivable_easy
			-- Test the DIRECTORY_ARCHIVABLE class with the easy_directory data
		local
			unit_under_test: DIRECTORY_ARCHIVABLE
			header_writer: TAR_HEADER_WRITER
			p: MANAGED_POINTER
		do
			create {USTAR_HEADER_WRITER} header_writer
			create unit_under_test.make (easy_directory)

			header_writer.set_active_header (unit_under_test.header)
			p := header_writer.write_to_new_managed_pointer
			p.append (unit_under_test.write_to_new_managed_pointer)

			assert ("Correct size", p.count = {TAR_CONST}.tar_block_size)

			assert ("Correct content", compare_block_special (easy_directory_blob, p.read_special_character_8 (0, p.count)))
		end


feature {NONE} -- Utilities

	compare_block_special (expected, actual: SPECIAL[CHARACTER_8]): BOOLEAN
			-- Compare all bytes of `expected` to `actual` and return whether they are equal.
			-- If they are not equal print all differences found
		require
			same_size: expected.count = actual.count
		local
			i: INTEGER
		do
			from
				i := 0
				Result := true
			until
				i >= expected.count
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


feature {NONE} -- Data - easy

	easy_directory_blob: SPECIAL[CHARACTER_8]
			-- Return blob for easy header
		local
			header_template: STRING_8
		once
			-- Templates use $ instead of %U and ^ instead of %N (because like this all characters are the same width)
			--                   Filename                                                                                            Mode    uid     gid     size        mtime       chksum T Linkname                                                                                            mag  Ve username                        groupname                       dmajor  dminor  prefix                                                                                                                                                     unused
			--                  |                                                                                                  ||      ||      ||      ||          ||          ||      |||                                                                                                  ||    ||||                              ||                              ||      ||      ||                                                                                                                                                         ||           |
			--         Offset:  0       8      16      24      32      40      48      56      64      72      80      88      96     104     112     120     128     136     144     152     160     168     176     184     192     200     208     216     224     232     240     248     256     264     272     280     288     296     304     312     320     328     336     344     352     360     368     376     384     392     400     408     416     424     432     440     448     456     464     472     480     488     496     504     512
			--                  |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |       |
			header_template := "test_files$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$0000755$0001750$0000144$00000000000$12637532333$0014016$5$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ustar$00nicolas$$$$$$$$$$$$$$$$$$$$$$$$$users$$$$$$$$$$$$$$$$$$$$$$$$$$$0000000$0000000$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
			header_template.replace_substring_all ("$", "%U")
			header_template.replace_substring_all ("^", "%N")
			Result := header_template.area
			Result.remove_tail (1)
		end

	easy_directory: FILE
			-- Return the easy file
		once
			create {RAW_FILE} Result.make_with_name ("test_files")
		end
end


