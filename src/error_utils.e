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
			create {ARRAYED_LIST [READABLE_STRING_32]} error_messages.make (1)
			report_error := agent report_error_local (?)
			redirection_target := Current
			redirection_message_prefix := "Local"
		end

feature -- Access

	has_error: BOOLEAN
			-- Error occurred?
		do
			Result := not error_messages.is_empty
		end

	error_messages: LIST [READABLE_STRING_32]
			-- Error messages.

	reset_error
			-- Reset errors.
		do
			error_messages.wipe_out
		ensure
			has_no_error: not has_error
		end

	register_redirector (other: ERROR_UTILS; a_message_prefix: READABLE_STRING_GENERAL)
			-- Register `other' as new target to send error messages to, prefixing all messages with `a_message_prefix' ("prefix: message")
		do
			redirection_target := other
			redirection_message_prefix := a_message_prefix
			report_error := agent report_error_remote (?)
		end

feature {ERROR_UTILS} -- Error reporting

	report_error: PROCEDURE [ANY, TUPLE [a_message: READABLE_STRING_GENERAL]]
			-- Procedure used to report error message `a_message'


feature {NONE} -- Implementation

	report_error_local (a_message: READABLE_STRING_GENERAL)
			-- Locally report error message `a_message'.
		do
			error_messages.force (a_message.as_string_32)
		ensure
			has_error: has_error
		end

	redirection_target: ERROR_UTILS
			-- Target for error message redirection

	redirection_message_prefix: READABLE_STRING_GENERAL
			-- Error message prefix when redirecting errors

	report_error_remote (a_message: READABLE_STRING_GENERAL)
			-- Report error message `a_message' to `redirection_target'
		do
			redirection_target.report_error(redirection_message_prefix + ": " + a_message)
		end

end
