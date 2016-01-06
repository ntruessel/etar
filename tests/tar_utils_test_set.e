note
	description: "[
		Eiffel tests that can be executed by testing tool.
	]"
	author: "EiffelStudio test wizard"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	TAR_UTILS_TEST_SET

inherit
	EQA_TEST_SET

feature -- Test routines

	test_path_unification
			-- test pathname unification
		local
			unit_under_test: TAR_UTILS
		do
			create unit_under_test
			assert ("Relative Path", unit_under_test.unify_utf_8_path (create {PATH}.make_from_string ("test/1/2/3")) ~ "test/1/2/3")
			assert ("Absolute Path", unit_under_test.unify_utf_8_path (create {PATH}.make_from_string ("/test/1/2/3")) ~ "/test/1/2/3")
			assert ("Umlaut Path", unit_under_test.unify_utf_8_path (create {PATH}.make_from_string ("צהü")) ~ (create {UTF_CONVERTER}).utf_32_string_to_utf_8_string_8 ("צהü"))
		end

	test_path_splitting
			-- test path split utils
		local
			unit_under_test: TAR_UTILS
			l_path_string: STRING_8
			l_res: TUPLE [filename_prefix: STRING_8; filename: STRING_8]
		do
			create unit_under_test
			--    Position:   1                                                                                                                                                       155/1                                                                                                100
			--                |                                                                                                                                                         | |                                                                                                  |
			l_path_string := "12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345/1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"
			l_res := unit_under_test.unify_and_split_filename (create {PATH}.make_from_string (l_path_string))
			assert ("Exact splitting (1a)", l_res.filename_prefix ~ "12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345")
			assert ("Exact splitting (1b)", l_res.filename ~ "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890")

			l_path_string := "1234567890123456789012345678901234567890123456789/1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890/2345/12345678901/345678901234567890123456/890123456789012345678901234567890123456789012345678901/34567890"
			l_res := unit_under_test.unify_and_split_filename (create {PATH}.make_from_string (l_path_string))
			assert ("Exact splitting (2a)", l_res.filename_prefix ~ "1234567890123456789012345678901234567890123456789/1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890/2345")
			assert ("Exact splitting (2b)", l_res.filename ~ "12345678901/345678901234567890123456/890123456789012345678901234567890123456789012345678901/34567890")

			l_path_string := "/123456789012345678901234567890123456/890123456789012345678901234567890123456789012345678901234567890"
			l_res := unit_under_test.unify_and_split_filename (create {PATH}.make_from_string (l_path_string))
			assert ("leading root (a)", l_res.filename_prefix ~ "/123456789012345678901234567890123456")
			assert ("leading root (b)", l_res.filename ~ "890123456789012345678901234567890123456789012345678901234567890")
		end

end


