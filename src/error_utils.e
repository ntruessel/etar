note
	description: "[
		Error handling facility, allows to report errors,
		check for errors and register a different error handler,
		where errors should be redirected to.
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ERROR_UTILS

inherit
	ANY
		redefine
			default_create
		end

feature {NONE} -- Initialization

	default_create
			-- Initialize error handling structures
		do
			create {ARRAYED_LIST [STRING_8]} error_messages.make (1)
			create {ARRAYED_LIST [PROCEDURE [ANY, TUPLE [STRING_8]]]} error_listeners.make (1)
			register_error_callaback (agent error_messages.force (?))
		end

feature -- Access

	has_error: BOOLEAN
			-- Error occured?
		do
			Result := not error_messages.is_empty
		end

	error_messages: LIST [STRING_8]
			-- Error messages.

	reset_error
			-- Reset errors.
		do
			error_messages.wipe_out
		ensure
			has_no_error: not has_error
		end

	register_error_callaback (a_callback: PROCEDURE [ANY, TUPLE [a_message: STRING_8]])
			-- Register `a_callback' as new target to send error messages to
		do
			error_listeners.force (a_callback)
		end

feature {NONE} -- Error reporting

	report_error (a_message: STRING_8)
			-- Report error message `a_message'
		do
			across
				error_listeners as l_listener_cursor
			loop
				l_listener_cursor.item (a_message)
			end
		end

	report_prefixed_error (a_prefix: STRING_8; a_message: STRING_8)
			-- Report error message `a_prefix': `a_message'
		do
			report_error (a_prefix + ": " + a_message)
		end

	error_listeners: LIST [PROCEDURE [ANY, TUPLE [a_message: STRING_8]]]
			-- All procedures that are notified on error

end
