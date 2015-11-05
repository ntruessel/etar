note
	description: "[
		Interface for unarchiving facilities
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	UNARCHIVER

feature -- Unarchiving

	can_handle (a_header: TAR_HEADER): BOOLEAN
			-- Is `Current' able to handle tar entries with header `a_header' ?
		deferred
		end

	handle (a_header: TAR_HEADER; a_payload: MANAGED_POINTER; start_pos, nb_bytes: INTEGER)
			-- Handle tar entry with header `a_header' and payload starting at `start_pos' with size `nb_bytes' in `a_payload'
		deferred
		end

end
