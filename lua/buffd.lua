local api = vim.api

local buf = api.nvim_create_buf(false, true)
local is_open = false

local function get_buff_numbers()
	local buffer_numbers = {}
	for number=1, vim.fn.bufnr('$') , 1 do 
        local is_listed = vim.fn.buflisted(number) == 1
		if is_listed then
			table.insert(buffer_numbers, number)
		end
	end
	return buffer_numbers
end

local function get_width()
	local width = 25
	local buffer_numbers = get_buff_numbers()
	local current = 0
	for k, v in pairs(buffer_numbers) do 
		width = math.max(width, string.len(vim.fn.bufname(v)))
	end
	if width > 50 then
		return 50
	else
		return width
	end
end

local function open_split_buffer()
	local width = get_width()
	vim.cmd(tostring(width+5)..'vs')
	local win = api.nvim_get_current_win()
	api.nvim_win_set_buf(win, buf)
	
	vim.cmd('set nonumber')
	vim.cmd('hi FocusedBuffer guifg=#5f87af gui=bold')
	vim.cmd('syntax region FocusedBuffer start=/ / end=/  / oneline')
	vim.cmd('wincmd p')
	print_buffers()
	is_open = true
	return win
end

local function strip_filename(full_name) 
	local len = string.len(full_name)
	for i=len, 0, -1 do 
		if full_name[i] == '/' then
			return string.sub(full_name, i+1, len)
		end
	end
	return full_name
end



local labels = {"e", "u", "j", "k", "p", "i", "a", "o"}

function print_buffers()
	api.nvim_buf_set_lines(buf, 0, vim.api.nvim_get_option("lines"), false, {})
	local buffer_numbers = get_buff_numbers()	
	local max_character = get_width()
	local line = 1
	for k, v in pairs(buffer_numbers) do 
		if vim.fn.bufnr('%') == v then
			local name = string.sub(vim.fn.bufname(v), 1, max_character)
	 		vim.fn.setbufline(buf, line, {'  '..labels[k]..": "..name.."  "})
		else
			local name = strip_filename(vim.fn.bufname(v))
			name = string.sub(name, 1, max_character)
	 		vim.fn.setbufline(buf, line, {'  '..labels[k]..": "..name})
		end

		local mapping = 'g'..labels[k]
		vim.api.nvim_set_keymap("n", 
			mapping, 
			":lua require'buffd'.focus_buffer("..v..")<CR>", 
			{noremap=true, silent=true})	
		line = line + 1
	end
end

local function focus_buffer(index)
	vim.cmd('b '..index)	
	print_buffers()
end

vim.api.nvim_set_keymap("n", 
			'go', 
			":lua require'buffd'.buffd()<CR>", 
			{noremap=true, silent=true})

local function buffd()
	if is_open then
		is_open = false
		api.nvim_win_close(windows, true)
	else
  		windows = open_split_buffer()
		is_open = true
	end
end

buffd()

return {
	buffd = buffd,
	focus_buffer = focus_buffer,
}
