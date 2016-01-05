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
			create extended_payload_unarchiver
			create global_payload_unarchiver
--			parsing_state := ps_pax_header

			Precursor

				-- Redirect error messages
			ustar_parser.register_redirector (Current, "ustar parser")
			extended_payload_unarchiver.register_redirector (Current, "extended payload unarchiver")
			global_payload_unarchiver.register_redirector (Current, "global payload unarchiver")
		end

feature -- Parsing

	parse_block (a_block: MANAGED_POINTER; a_pos: INTEGER)
			-- parse `a_block' (starting from `a_pos')
		do
			if not has_error then
				inspect parsing_state
				when ps_first_header then
					parsing_finished := False
					handle_first_header_block (a_block, a_pos)

				when ps_global_payload then
					handle_global_payload_block (a_block, a_pos)

				when ps_extended_payload then
					handle_extended_payload_block (a_block, a_pos)

				when ps_second_header then
					handle_second_header_block (a_block, a_pos)
				else
					report_error ("Unknown parsing state")
				end
			end
		end

feature {NONE} -- Implementation

	ustar_parser: USTAR_HEADER_PARSER
			-- Used to parse the headers

	global_payload_unarchiver: PAX_UNARCHIVER
			-- Used to unarchive global pax payload

	extended_payload_unarchiver: PAX_UNARCHIVER
			-- Used to unarchive extended pax payload

	parsing_state: INTEGER
			-- In what parsing state are we currently? One of the following constants

	ps_first_header: INTEGER = 0
			-- parsing state: next block to be parsed belongs to pax header

	ps_global_payload: INTEGER = 1
			-- parsint state: next block to be parsed belongs to global pax payload

	ps_extended_payload: INTEGER = 2
			-- parsing state: next block to be parsed belongs to pax payload

	ps_second_header: INTEGER = 3
			-- parsing state: next block to be parsed belongs to ustar header

	handle_first_header_block (a_block: MANAGED_POINTER; a_pos: INTEGER)
			-- Handle `a_block', starting from `a_pos', treating it as a first header block
		require
			correct_parsing_state: parsing_state = ps_first_header
			block_size_large_enough: a_pos + {TAR_CONST}.tar_block_size <= a_block.count
			non_negative_length: a_pos >= 0
			no_errors: not has_error
		do
			ustar_parser.parse_block (a_block, a_pos)

			if not has_error then
				if ustar_parser.parsing_finished then
					if attached ustar_parser.parsed_header as l_first_header then
						if l_first_header.typeflag = {TAR_CONST}.tar_typeflag_pax_global then
								-- global header
							global_payload_unarchiver.initialize (l_first_header)
							parsing_state := ps_global_payload
						elseif l_first_header.typeflag = {TAR_CONST}.tar_typeflag_pax_extended then
								-- extended header
							extended_payload_unarchiver.initialize (l_first_header)
							parsing_state := ps_extended_payload
						else
								-- ustar header
							last_parsed_header := l_first_header

							apply_unarchiver_header_updates (global_payload_unarchiver)

							parsing_state := ps_first_header
							parsing_finished := True
						end
					else
							-- Unreachable (TAR_HEADER_PARSER invariant)
						report_error ("Parsing first header failed")
					end
				end
			else
				report_error ("Parsing first header failed")
			end

		end

	handle_global_payload_block (a_block: MANAGED_POINTER; a_pos: INTEGER)
			-- Handle `a_block', starting from `a_pos', treating it as a global (pax) payload block
		require
			correct_parsing_state: parsing_state = ps_extended_payload
			block_size_large_enough: a_pos + {TAR_CONST}.tar_block_size <= a_block.count
			non_negative_length: a_pos >= 0
			no_errors: not has_error
		do
			if not global_payload_unarchiver.unarchiving_finished then
				global_payload_unarchiver.unarchive_block (a_block, a_pos)

				if not has_error then
					if global_payload_unarchiver.unarchiving_finished then
						parsing_state := ps_first_header
					end
				else
					report_error ("Parsing global pax payload failed")
				end
			else
				report_error ("Remaining in global pax payload parsing stage, even though all payload is unarchived")
			end
		end

	handle_extended_payload_block (a_block: MANAGED_POINTER; a_pos: INTEGER)
			-- Handle `a_block', starting from `a_pos', treating it as an extended (pax) payload block
		require
			correct_parsing_state: parsing_state = ps_extended_payload
			block_size_large_enough: a_pos + {TAR_CONST}.tar_block_size <= a_block.count
			non_negative_length: a_pos >= 0
			no_errors: not has_error
		do
			if not extended_payload_unarchiver.unarchiving_finished then
				extended_payload_unarchiver.unarchive_block (a_block, a_pos)

				if not has_error then
					if extended_payload_unarchiver.unarchiving_finished then
						parsing_state := ps_second_header
					end
				else
					report_error ("Parsing extended pax payload failed")
				end

			else
				report_error ("Remaining in extended pax payload parsing stage, even though all payload is unarchived")
			end
		end

	handle_second_header_block (a_block: MANAGED_POINTER; a_pos: INTEGER)
			-- Handle `a_block', starting from `a_pos', treating it as a second header block
		require
			correct_parsing_state: parsing_state = ps_second_header
			block_size_large_enough: a_pos + {TAR_CONST}.tar_block_size <= a_block.count
			non_negative_length: a_pos >= 0
			no_errors: not has_error
		do
			ustar_parser.parse_block (a_block, a_pos)
			if not has_error then
				if ustar_parser.parsing_finished then
					if attached ustar_parser.parsed_header as l_ustar_header then

							-- Modify header according to pax payload
						last_parsed_header := l_ustar_header

						apply_unarchiver_header_updates (global_payload_unarchiver)
						apply_unarchiver_header_updates (extended_payload_unarchiver)

						parsing_state := ps_first_header
						parsing_finished := True
					else
							-- Unreachable (TAR_HEADER_PARSER invariant)
						report_error ("Parsing second header failed")
					end
				end
			else
				report_error ("Parsing second header failed")
			end
		end

	apply_unarchiver_header_updates (a_pax_unarchiver: PAX_UNARCHIVER)
			-- Apply all updates that `a_pax_unarchiver' contains to `active_header'
		require
			has_active_header: last_parsed_header /= Void
			no_errors: not has_error
			correct_parsing_state: parsing_state = ps_first_header or parsing_state = ps_second_header
		local
			l_update_value: detachable READABLE_STRING_8
		do
			if attached last_parsed_header as l_header then
					-- filename
				l_update_value := a_pax_unarchiver.get_value ({TAR_HEADER_CONST}.name_pax_key)
				if l_update_value /= Void then
					l_header.set_filename (create {PATH}.make_from_string (l_update_value))
				end

					-- user id
				l_update_value := a_pax_unarchiver.get_value ({TAR_HEADER_CONST}.uid_pax_key)
				if l_update_value /= Void then
					if l_update_value.is_natural_32 then
						l_header.set_user_id (l_update_value.to_natural_32)
					else
						report_error ("Parsed uid is not a valid 32bit number: " + l_update_value)
					end
				end

					-- group id
				l_update_value := a_pax_unarchiver.get_value ({TAR_HEADER_CONST}.gid_pax_key)
				if l_update_value /= Void then
					if l_update_value.is_natural_32 then
						l_header.set_group_id (l_update_value.to_natural_32)
					else
						report_error ("Parsed gid is not a valid 32bit number: " + l_update_value)
					end
				end

					-- size
				l_update_value := a_pax_unarchiver.get_value ({TAR_HEADER_CONST}.size_pax_key)
				if l_update_value /= Void then
					if l_update_value.is_natural_64 then
						l_header.set_size (l_update_value.to_natural_64)
					else
						report_error ("Parsed size is not a valid 64bit number: " + l_update_value)
					end
				end

					-- mtime
					-- PAX time format: <epoch>[.<millis>], millis is optional
				l_update_value := a_pax_unarchiver.get_value ({TAR_HEADER_CONST}.mtime_pax_key)
				if l_update_value /= Void then
						-- Keep <epoch> only
					if l_update_value.index_of ('.', 1) > 0 then
						l_update_value := l_update_value.head (l_update_value.index_of ('.', 1) - 1)
					end

					if l_update_value.is_natural_64 then
						l_header.set_mtime (l_update_value.to_natural_64)
					else
						report_error ("Parsed mtime is not a valid 64bit number: " + l_update_value)
					end
				end

					-- linkname
				l_update_value := a_pax_unarchiver.get_value ({TAR_HEADER_CONST}.linkname_pax_key)
				if l_update_value /= Void then
					l_header.set_linkname (create {PATH}.make_from_string (l_update_value))
				end

					-- user name
				l_update_value := a_pax_unarchiver.get_value ({TAR_HEADER_CONST}.uname_pax_key)
				if l_update_value /= Void then
					l_header.set_user_name (l_update_value)
				end

					-- group name
				l_update_value := a_pax_unarchiver.get_value ({TAR_HEADER_CONST}.gname_pax_key)
				if l_update_value /= Void then
					l_header.set_group_name (l_update_value)
				end
			else
				-- Unreachable (precondition)
			end

		end
end
