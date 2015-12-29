note
	description: "Summary description for {PAX_HEADER_PARSER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PAX_HEADER_PARSER

inherit
	TAR_HEADER_PARSER
	redefine
		default_create
	end

feature {NONE} -- Initialization

	default_create
			-- Create new instance
		do
			create ustar_parser
			create pax_payload_unarchiver
--			parsing_state := ps_pax_header
		end

feature -- Parsing

	parse_block (block: MANAGED_POINTER; a_pos: INTEGER)
			-- parse `block' (starting from `a_pos')
		do
			if not has_error then
				inspect parsing_state
				when ps_first_header then
					parsing_finished := False

					handle_first_header_block (block, a_pos)

				when ps_pax_payload then
					handle_pax_payload_block (block, a_pos)

				when ps_second_header then
					handle_second_header_block (block, a_pos)
				else
					report_error ("Unknown parsing state")
				end
			end
		end

feature {NONE} -- Implementation

	ustar_parser: USTAR_HEADER_PARSER
			-- Used to parse the headers

	pax_payload_unarchiver: PAX_UNARCHIVER
			-- Used to unarchive pax payload

	parsing_state: INTEGER
			-- In what parsing state are we currently? One of the following constants

	ps_first_header: INTEGER = 0
			-- parsing state: next block to be parsed belongs to pax header

	ps_pax_payload: INTEGER = 1
			-- parsing state: next block to be parsed belongs to pax payload

	ps_second_header: INTEGER = 2
			-- parsing state: next block to be parsed belongs to ustar header

	handle_first_header_block (block: MANAGED_POINTER; a_pos: INTEGER)
			-- Handle `block', starting from `a_pos', treating it as a first header block
		require
			correct_parsing_state: parsing_state = ps_first_header
			block_size_large_enough: a_pos + {TAR_CONST}.tar_block_size <= block.count
			non_negative_length: a_pos >= 0
		do
			ustar_parser.parse_block (block, a_pos)

			if ustar_parser.has_error then
				if attached ustar_parser.error_messages as l_errors then
					across l_errors as it
					loop
						report_error (it.item)
					end
				end

				report_error ("Parsing first header failed")
			else
				if ustar_parser.parsing_finished then
					if attached ustar_parser.parsed_header as l_first_header then
						if pax_payload_unarchiver.can_unarchive (l_first_header) then
								-- pax header
							pax_payload_unarchiver.initialize (l_first_header)
							parsing_state := ps_pax_payload
						else
								-- ustar header
							last_parsed_header := l_first_header
							parsing_state := ps_first_header
							parsing_finished := True
						end
					else
						report_error ("Parsing first header failed")
					end
				end
			end

		end

	handle_pax_payload_block (block: MANAGED_POINTER; a_pos: INTEGER)
			-- Handle `block', starting from `a_pos', treating it as a pax payload block
		require
			correct_parsing_state: parsing_state = ps_pax_payload
			block_size_large_enough: a_pos + {TAR_CONST}.tar_block_size <= block.count
			non_negative_length: a_pos >= 0
		do
			if not pax_payload_unarchiver.unarchiving_finished then
				pax_payload_unarchiver.unarchive_block (block, a_pos)

				if pax_payload_unarchiver.has_error then
					if attached pax_payload_unarchiver.error_messages as l_errors then
						across l_errors as it
						loop
							report_error (it.item)
						end
					end

					report_error ("Parsing pax payload failed")
				end

				if pax_payload_unarchiver.unarchiving_finished then
					parsing_state := ps_second_header
				end
			else
				report_error ("Remaining in pax payload parsing stage, even though all payload is unarchived")
			end
		end

	handle_second_header_block (block: MANAGED_POINTER; a_pos: INTEGER)
			-- Handle `block', starting from `a_pos', treating it as a second header block
		require
			correct_parsing_state: parsing_state = ps_second_header
			block_size_large_enough: a_pos + {TAR_CONST}.tar_block_size <= block.count
			non_negative_length: a_pos >= 0
		local
			l_update_value: detachable READABLE_STRING_8
		do
			ustar_parser.parse_block (block, a_pos)
			if ustar_parser.has_error then
				if attached ustar_parser.error_messages as l_errors then
					across l_errors as it
					loop
						report_error (it.item)
					end
				end

				report_error ("Parsing second header failed")
			else

				if ustar_parser.parsing_finished then
					if attached ustar_parser.parsed_header as l_ustar_header then

							-- Modify header according to pax payload
						l_update_value := pax_payload_unarchiver.get_value ({TAR_HEADER_CONST}.name_pax_key)
						if l_update_value /= Void then
							l_ustar_header.set_filename (create {PATH}.make_from_string (l_update_value))
						end

						l_update_value := pax_payload_unarchiver.get_value ({TAR_HEADER_CONST}.uid_pax_key)
						if l_update_value /= Void then
							if l_update_value.is_natural_32 then
								l_ustar_header.set_user_id (l_update_value.to_natural_32)
							else
								report_error ("Parsed uid is not a valid 32bit number: " + l_update_value)
							end
						end

						l_update_value := pax_payload_unarchiver.get_value ({TAR_HEADER_CONST}.gid_pax_key)
						if l_update_value /= Void then
							if l_update_value.is_natural_32 then
								l_ustar_header.set_group_id (l_update_value.to_natural_32)
							else
								report_error ("Parsed gid is not a valid 32bit number: " + l_update_value)
							end
						end

						l_update_value := pax_payload_unarchiver.get_value ({TAR_HEADER_CONST}.size_pax_key)
						if l_update_value /= Void then
								-- PAX time format: <epoch>[.<millis>], millis is optional

								-- Keep <epoch> only
							if l_update_value.index_of ('.', 1) > 0 then
								l_update_value := l_update_value.head (l_update_value.index_of ('.', 1) - 1)
							end

							if l_update_value.is_natural_64 then
								l_ustar_header.set_size (l_update_value.to_natural_64)
							else
								report_error ("Parsed size is not a valid 64bit number: " + l_update_value)
							end
						end

						l_update_value := pax_payload_unarchiver.get_value ({TAR_HEADER_CONST}.mtime_pax_key)
						if l_update_value /= Void then
							if l_update_value.is_natural_64 then
								l_ustar_header.set_mtime (l_update_value.to_natural_64)
							else
								report_error ("Parsed mtime is not a valid 64bit number: " + l_update_value)
							end
						end

						l_update_value := pax_payload_unarchiver.get_value ({TAR_HEADER_CONST}.linkname_pax_key)
						if l_update_value /= Void then
							l_ustar_header.set_linkname (create {PATH}.make_from_string (l_update_value))
						end

						l_update_value := pax_payload_unarchiver.get_value ({TAR_HEADER_CONST}.uname_pax_key)
						if l_update_value /= Void then
							l_ustar_header.set_user_name (l_update_value)
						end

						l_update_value := pax_payload_unarchiver.get_value ({TAR_HEADER_CONST}.gname_pax_key)
						if l_update_value /= Void then
							l_ustar_header.set_group_name (l_update_value)
						end

						last_parsed_header := l_ustar_header

						parsing_state := ps_first_header
						parsing_finished := True
					else
						report_error ("Parsing second header failed")
					end
				end
			end
		end
end
