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
		local
			l_update_value: detachable READABLE_STRING_8
		do
			if not has_error then
				inspect parsing_state
				when ps_pax_header then
					parsing_finished := False

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
									parsing_state := ps_pax_header
									parsing_finished := True
								end
							else
								report_error ("Parsing first header failed")
							end
						end

					end
				when ps_pax_payload then
					pax_payload_unarchiver.unarchive_block (block, a_pos)
					if pax_payload_unarchiver.has_error then
						if attached pax_payload_unarchiver.error_messages as l_errors then
							across l_errors as it
							loop
								report_error (it.item)
							end
						end

						report_error ("Parsing pax payload failed")
					else
						if pax_payload_unarchiver.unarchiving_finished then
							parsing_state := ps_ustar_header
						end
					end
				when ps_ustar_header then
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

								parsing_state := ps_pax_header
								parsing_finished := True
							else
								report_error ("Parsing second header failed")
							end
						end
					end
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

	ps_pax_header: INTEGER = 0
			-- parsing state: next block to be parsed belongs to pax header

	ps_pax_payload: INTEGER = 1
			-- parsing state: next block to be parsed belongs to pax payload

	ps_ustar_header: INTEGER = 2
			-- parsing state: next block to be parsed belongs to ustar header

end
