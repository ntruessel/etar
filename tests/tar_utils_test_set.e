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

	test_uname_to_uid
			-- Test uname -> uid
		local
			unit_under_test: TAR_UTILS
		do
			create unit_under_test
			assert ("Root UID", unit_under_test.get_uid_from_username ("root") = 0)
			assert ("Invalid UID", unit_under_test.get_uid_from_username ("qwertyuiop") = -1)
		end

	test_gname_to_gid
			-- Test gname -> gid
		local
			unit_under_test: TAR_UTILS
		do
			create unit_under_test
			assert ("Root GID", unit_under_test.get_gid_from_groupname ("root") = 0)
			assert ("Invalid GID", unit_under_test.get_gid_from_groupname ("qwertyuiop") = -1)
		end

end


