note
	description: "[
		Storage backends for files
	]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	FILE_STORAGE_BACKEND

inherit
	STORAGE_BACKEND
		redefine
			default_create
		end

create
	make

feature {NONE} -- Initialization

	default_create
			-- Used to initialize internal status
		do
			create block_buffer.make ({TAR_CONST}.tar_block_size)
			create {ARRAYED_QUEUE [MANAGED_POINTER]} buffer.make (2)

			Precursor
		end

	make (a_file: FILE)
			-- Create new instance for `a_file'
			-- Will create a clone of `a_file' to prevent interference with client-side changes
		do
			create {RAW_FILE} backend.make_with_path (a_file.path)
			default_create
		ensure
			backend_closed: backend.is_closed
		end

feature -- Status setting

	open_read
			-- Open for reading
		do
			if not has_error then
				if backend.exists and then backend.is_readable then
					backend.open_read
				elseif not backend.exists then
					report_error ("File does not exist")
				elseif not backend.is_readable then
					report_error ("File is not readable")
				else
					report_error ("Unknown error")
				end
			end
		end

	open_write
			-- Open for writing
		do
			if not has_error then
				if backend.exists implies backend.is_writable then
					backend.open_write
				elseif backend.exists then
					report_error ("File is not writable")
				else
					report_error ("Unknown error")
				end
			end
		end

	close
			-- Close backend
		do
			if not has_error then
				backend.close
			end
		end

feature -- Status

	archive_finished: BOOLEAN
			-- Indicates whether the next two blocks only contain NUL bytes or the file has not enough characters to read
		local
			l_buffer: MANAGED_POINTER
		do
			Result := backend.is_closed
			if not Result then
					-- Buffer current block
				l_buffer := block_buffer

					-- Read first block
				create block_buffer.make (block_buffer.count)
				read_block

				if block_ready then
						-- Succeeded reading first block
					buffer.put (block_buffer)

						-- Check whether it contains only NUL bytes
					if only_nul_bytes (block_buffer) then
							-- Read second block
						create block_buffer.make (block_buffer.count)
						read_block

						if block_ready then
								-- Succeeded reading second block
							buffer.put (block_buffer)

							if only_nul_bytes (block_buffer) then
								Result := True
							end
						else
								-- Not enough bytes available
							Result := True
						end
					end

				else
						-- Not enough bytes available
					Result := True
				end


					-- Restore current block
				block_buffer := l_buffer
			end
		end

	block_ready: BOOLEAN
			-- Indicate whether there is a block ready
		do
			Result := has_valid_block
		end

	is_readable: BOOLEAN
			-- Indicates whether this instance can be read from
		do
			Result := not has_error and then backend.is_open_read
		end

	is_writable: BOOLEAN
			-- Indicates whether this instance can be written to
		do
			Result := not has_error and then backend.is_open_write
		end

	is_closed: BOOLEAN
			-- Indicates whether backend is closed
		do
			Result := has_error or else backend.is_closed
		end

feature -- Access

	last_block: MANAGED_POINTER
			-- Return last block that was read
		do
			Result := block_buffer
		end

	read_block
			-- Read next block
		do
			if not buffer.is_empty then
					-- There are buffered items, use them
				block_buffer := buffer.item
				buffer.remove

				has_valid_block := True
			else
					-- No buffered items, read next block
				backend.read_to_managed_pointer (block_buffer, 0, block_buffer.count)
				has_valid_block := backend.bytes_read = block_buffer.count
			end
		end

feature {NONE} -- Implementation

	backend: FILE
			-- file backend

	buffer: QUEUE [MANAGED_POINTER]
			-- buffers blocks that were read ahead

	block_buffer: MANAGED_POINTER
			-- buffer to use for next read operation

	has_valid_block: BOOLEAN
			-- Boolean flag for `block_ready'

	only_nul_bytes (block: MANAGED_POINTER): BOOLEAN
			-- Check whether `block' only consists of NUL bytes
		do
			Result := block.read_special_character_8 (0, block.count).for_all_in_bounds (
				agent (c: CHARACTER_8): BOOLEAN
					do
						Result := c = '%U'
					end, 0, block.count - 1)
		end

end
