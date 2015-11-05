note
	description: "[
		Eiffel tests that can be executed by testing tool.
	]"
	author: "EiffelStudio test wizard"
	date: "$Date$"
	revision: "$Revision$"
	testing: "type/manual"

class
	OCTAL_UTILS_TEST_SET

inherit
	EQA_TEST_SET

feature -- Test routines

	test_output
			-- Test printing features
		note
			testing:	"covers/{OCTAL_UTILS}.octal_string_to_natural_16"
			testing:	"covers/{OCTAL_UTILS}.octal_string_to_natural_32"
			testing:	"covers/{OCTAL_UTILS}.octal_string_to_natural_64"
		local
			unit_under_test: OCTAL_UTILS
		do
			create unit_under_test
			assert ("not_implemented", False)
		end

	test_parse
			-- Test parsing features
		note
			testing:	"covers/{OCTAL_UTILS}.natural_16_to_octal_string"
			testing:	"covers/{OCTAL_UTILS}.natural_32_to_octal_string"
			testing:	"covers/{OCTAL_UTILS}.natural_64_to_octal_string"
		local
			unit_under_test: OCTAL_UTILS
		do
			create unit_under_test
			assert ("not_implemented", False)
		end

feature -- Utilities

	test_octal_conversion
			-- Test utility features
		note
			testing:	"covers/{OCTAL_UTILS}.natural_8_to_octal_character"
		local
			unit_under_test: OCTAL_UTILS
			i: NATURAL_8
		do
			-- Character conversion
			create unit_under_test
			from
				i := 0
			until
				i > 7
			loop
				assert ("Octal character conversion", i.out[1] = unit_under_test.natural_8_to_octal_character (i))
				i := i + 1
			end
		end

	test_leading_zeros
			-- Test leading zeros
		note
			testing:	"covers/{OCTAL_UTILS}.leading_zeros_count"
		local
			unit_under_test: OCTAL_UTILS
			i: NATURAL_8
			s: STRING
		do
			create unit_under_test
			-- -> all zeros
			from
				i := 1
			until
				i > 15
			loop
				s := "0"
				s.multiply (i)
				assert ("All leading zeros", unit_under_test.leading_zeros_count (s) = i - 1)
				i := i + 1
			end
			-- -> No leading zeros
			assert ("No leading zeros", unit_under_test.leading_zeros_count ("123456789") = 0)

			-- -> All zeros but last
			from
				i := 1
			until
				i > 15
			loop
				s := "0"
				s.multiply (i)
				s.append (i.out)
				assert ("Some leading zeros", unit_under_test.leading_zeros_count (s) = i)
				i := i + 1
			end

			-- -> Empty string
			assert ("Empty string", unit_under_test.leading_zeros_count ("") = 0)
		end

	test_truncate_leading_zeros
			-- Test leading zero truncation
		note
			testing:	"covers/{OCTAL_UTILS}.truncate_leading_zeros"
		local
			unit_under_test: OCTAL_UTILS
			s: STRING
		do
			create unit_under_test
			s := "123456789"
			unit_under_test.truncate_leading_zeros (s)
			assert ("No leading zeros", s ~ "123456789")

			s := "000012345"
			unit_under_test.truncate_leading_zeros (s)
			assert ("Some leading zeros", s ~ "12345")

			s := "000000000000"
			unit_under_test.truncate_leading_zeros (s)
			assert ("No leading zeros", s ~ "0")

			s := ""
			unit_under_test.truncate_leading_zeros (s)
			assert ("Empty string", s ~ "")
		end

	test_pad
			-- Test padding
		note
			testing:	"covers/{OCTAL_UTILS}.pad"
		local
			unit_under_test: OCTAL_UTILS
			s: STRING
		do
			create unit_under_test
			s := "12345"
			unit_under_test.pad (s, 0)
			assert ("No padding", s ~ "12345")

			s := "12345"
			unit_under_test.pad (s, 5)
			assert ("Some padding", s ~ "0000012345")

			s := ""
			unit_under_test.pad (s, 1)
			assert ("Empty string", s ~ "0")
		end

	test_combinations
			-- Test various combinations of the utility functions
		local
			unit_under_test: OCTAL_UTILS
			s: STRING
			i: INTEGER
		do
			create unit_under_test
			s := "123456789"
			from
				i := 1
			until
				i > 16
			loop
				unit_under_test.pad (s, i)
				assert ("Zeros added", unit_under_test.leading_zeros_count (s) = i)

				unit_under_test.truncate_leading_zeros (s)
				assert ("Zeros removed", s ~ "123456789")
				i := i + 1
			end

			s := ""
			unit_under_test.pad (s, 10)
			unit_under_test.truncate_leading_zeros (s)
			assert ("Do not remove last 0", s ~ "0")
		end

end


