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
			s: STRING
		do
			create unit_under_test

			-- Basic functionality
			s := "141223"
			assert ("Basic parsing (16bit)", unit_under_test.octal_string_to_natural_16 (s) = 0c141223)
			assert ("Basic parsing (32bit)", unit_under_test.octal_string_to_natural_32 (s) = 0c141223)
			assert ("Basic parsing (64bit)", unit_under_test.octal_string_to_natural_64 (s) = 0c141223)

			s := "70365"
			assert ("Basic parsing 2 (16bit)", unit_under_test.octal_string_to_natural_16 (s) = 0c70365)
			assert ("Basic parsing 2 (32bit)", unit_under_test.octal_string_to_natural_32 (s) = 0c70365)
			assert ("Basic parsing 2 (64bit)", unit_under_test.octal_string_to_natural_64 (s) = 0c70365)

			-- Max values
			s := "177777"
			assert ("Max 16bit parsing", unit_under_test.octal_string_to_natural_16 (s) = {NATURAL_16}.max_value)

			s := "37777777777"
			assert ("Max 32bit parsing", unit_under_test.octal_string_to_natural_32 (s) = {NATURAL_32}.max_value)

			s := "1777777777777777777777"
			assert ("Max 64bit parsing", unit_under_test.octal_string_to_natural_64 (s) = {NATURAL_64}.max_value)

			-- All zeros
			s := "000000000000000"
			assert ("All zero parsing (16bit)", unit_under_test.octal_string_to_natural_16 (s) = 0)
			assert ("All zero parsing (32bit)", unit_under_test.octal_string_to_natural_32 (s) = 0)
			assert ("All zero parsing (64bit)", unit_under_test.octal_string_to_natural_64 (s) = 0)

			-- Leading zeros
			s := "0000000000000001"
			assert ("All zero parsing (16bit)", unit_under_test.octal_string_to_natural_16 (s) = 1)
			assert ("All zero parsing (32bit)", unit_under_test.octal_string_to_natural_32 (s) = 1)
			assert ("All zero parsing (64bit)", unit_under_test.octal_string_to_natural_64 (s) = 1)

			-- Leading zeros max values
			s := "00000000177777"
			assert ("Max 16bit parsing", unit_under_test.octal_string_to_natural_16 (s) = {NATURAL_16}.max_value)

			s := "0000000037777777777"
			assert ("Max 32bit parsing", unit_under_test.octal_string_to_natural_32 (s) = {NATURAL_32}.max_value)

			s := "00000000000001777777777777777777777"
			assert ("Max 64bit parsing", unit_under_test.octal_string_to_natural_64 (s) = {NATURAL_64}.max_value)
		end

	test_parse
			-- Test parsing features
		note
			testing:	"covers/{OCTAL_UTILS}.natural_16_to_octal_string"
			testing:	"covers/{OCTAL_UTILS}.natural_32_to_octal_string"
			testing:	"covers/{OCTAL_UTILS}.natural_64_to_octal_string"
		local
			unit_under_test: OCTAL_UTILS
			n16: NATURAL_16
			n32: NATURAL_32
			n64: NATURAL_64
		do
			create unit_under_test

			-- Basic functionality
			n16 := 0c12642
			assert ("Basic output (16bit)", unit_under_test.natural_16_to_octal_string (n16) ~ "12642")
			n32 := 0c34635231
			assert ("Basic output (32bit)", unit_under_test.natural_32_to_octal_string (n32) ~ "34635231")
			n64 := 0c1467623523
			assert ("Basic output (64bit)", unit_under_test.natural_64_to_octal_string (n64) ~ "1467623523")

			n16 := 0c12042
			assert ("Basic output 2 (16bit)", unit_under_test.natural_16_to_octal_string (n16) ~ "12042")
			n32 := 0c30635031
			assert ("Basic output 2 (32bit)", unit_under_test.natural_32_to_octal_string (n32) ~ "30635031")
			n64 := 0c1460023523
			assert ("Basic output 2 (64bit)", unit_under_test.natural_64_to_octal_string (n64) ~ "1460023523")

			-- Max values
			n16 := {NATURAL_16}.max_value
			assert ("Max 16bit output", unit_under_test.natural_16_to_octal_string (n16) ~ "177777")

			n32 := {NATURAL_32}.max_value
			assert ("Max 32bit output", unit_under_test.natural_32_to_octal_string (n32) ~ "37777777777")

			n64 := {NATURAL_64}.max_value
			assert ("Max 64bit output", unit_under_test.natural_64_to_octal_string (n64) ~ "1777777777777777777777")

			-- Zero
			n16 := 0
			assert ("Zero 16bit output", unit_under_test.natural_16_to_octal_string (n16) ~ "0")

			n32 := 0
			assert ("Zero 32bit output", unit_under_test.natural_32_to_octal_string (n32) ~ "0")

			n64 := 0
			assert ("Zero 64bit output", unit_under_test.natural_64_to_octal_string (n64) ~ "0")
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

	test_utility_combinations
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


