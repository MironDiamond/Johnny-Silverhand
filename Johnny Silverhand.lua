script_name("Johnny Silverhand")
script_author("Miron Diamond")

script_version = 1.1

require("moonloader")

ffi = require("ffi")
mrkeys = require("rkeys")
https = require 'ssl.https'
dlstatus = require('moonloader').download_status
memory = require "memory"
encoding = require("encoding")
keys = require "vkeys"
imgui = require 'imgui'
pie = require "imgui_piemenu"
sampev = require "lib.samp.events"
inicfg = require 'inicfg'
bNotf, push = pcall(import, "imgui_notf.lua")
fa = require "faIcons"
fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
playsound_1 = loadAudioStream('moonloader/Johnny Silverhand/music/melody1.mp3')
playsound_2 = loadAudioStream('moonloader/Johnny Silverhand/music/melody2.mp3')
playsound_3 = loadAudioStream('moonloader/Johnny Silverhand/music/melody3.mp3')
directIni = "moonloader\\Johnny Silverhand\\config.ini"
imgui.ToggleButton = require('imgui_addons').ToggleButton
imgui.HotKey = require('imgui_addons').HotKey
imgui.Spinner = require('imgui_addons').Spinner
imgui.BufferingBar = require('imgui_addons').BufferingBar
encoding.default = 'CP1251'
u8 = encoding.UTF8

setAudioStreamVolume(playsound_1, 100)
setAudioStreamVolume(playsound_2, 100)
setAudioStreamVolume(playsound_3, 100)

mainIni = inicfg.load(nil, directIni)

thread_binder = lua_thread.create(function() end)

RENDER_FONT = renderCreateFont("Calibri", 14, 4)

Welcome_Status = mainIni.Welcome.status

-- Script

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(0) end
	math.randomseed(os.clock())
	AutoUpdate()
	Register_Table()
	Register_Imgui()
	Register_Hotkey()
	Register_Command()
	LoadSettings()
	if Welcome_Status then
		Notification("Johnny Silverhand:\n\nПроснись уже, самурай!\nВремя сжечь этот город.",3)
	else
		sampAddChatMessage("[Police System]{FFFFFF} Система активирована! | Главное меню: {C0C0C0}/police", 0x1E90FF)
		apply_welcome_blue_style()
		sampRegisterChatCommand("police", function()
			Imgui_Welcome_Mode = 0
			welcome_window_state.v = not welcome_window_state.v
			imgui.Process = welcome_window_state.v
		end)
	end
	while true do wait(0)
		if isKeyDown(tonumber(table.concat(HotKeyBindHint.v))) then
			for id, data in ipairs(BINDER) do
				if data.description and #data.hotkey > 0 then
					local hk = mrkeys.getKeysName(data.hotkey)
					if data.hint and data.hotkey then
						renderFontDrawText(RENDER_FONT, "{FFD700}"..table.concat(hk, " + ").."{FFFFFF} - "..tostring(u8:decode(data.description)).."\n", sw / 40, sh / 2.6 + 20*id, 0xFFFFFFFF)
					end
				end
			end
		end

		if #text_buffer_radio.v > 0 then
			if testCheat(u8:decode(text_buffer_radio.v)) then
				sampSetChatInputEnabled(true)
				sampSetChatInputText("/r ")
			end
		end

		if toggle_button_weapon_weapon.v and combo_weapon_select.v == 0 then
			RPGun(getCurrentCharWeapon(PLAYER_PED))
		end

		if not hud_window_state.v then
			if not main_window_state.v and not settings_window_state.v and not pursuit_mod_window_state.v and not wanted_window_state.v and not fastmenu_window_state.v and not hint_window_state.v and not ticket_window_state.v and not patrol_window_state.v and not welcome_window_state.v then
				hud_window_state.v = toggle_button_hud.v
				imgui.Process = hud_window_state.v
				imgui.ShowCursor = false
			end
		end

		if main_window_state.v or settings_window_state.v then
			if not Music_Mode then
				setAudioStreamState(playsound_2, 1)
				Music_Mode = true
			end
		else
			if Music_Mode then
				setAudioStreamState(playsound_2, 0)
				Music_Mode = false
			end
		end
	end
end

function AutoUpdate()
	lua_thread.create(function()
			local update_url = "https://raw.githubusercontent.com/MironDiamond/Johnny-Silverhand/main/update.ini"
			local update_text = https.request(update_url)
			local update_version = update_text:match("version=(.*)")
			local script_url = "https://raw.githubusercontent.com/MironDiamond/Johnny-Silverhand/main/Johnny%20Silverhand.lua"
			local script_path = thisScript().path
			if tonumber(update_version) > script_version then
				Notification("Обновление системы..", 2)
				downloadUrlToFile(script_url, script_path, function(id, status)
					if status == dlstatus.STATUS_ENDDOWNLOADDATA then
						Notification("Обновление завершено!", 2)
						thisScript():reload()
					end
				end)
			end
	end)
end

function SaveSettings()
	local filename_binder = (getGameDirectory().."\\moonloader\\Johnny Silverhand\\binder.json"):format(getFolderPath(0x05))
	local filename_hint = (getGameDirectory().."\\moonloader\\Johnny Silverhand\\hint.json"):format(getFolderPath(0x05))
	local filename_wanted = (getGameDirectory().."\\moonloader\\Johnny Silverhand\\wanted.json"):format(getFolderPath(0x05))
	local filename_ticket = (getGameDirectory().."\\moonloader\\Johnny Silverhand\\ticket.json"):format(getFolderPath(0x05))
	local filename_post = (getGameDirectory().."\\moonloader\\Johnny Silverhand\\post.json"):format(getFolderPath(0x05))

	local file = io.open(filename_binder, "w")
	for i, data in ipairs(BINDER) do
			file:write(encodeJson(data, true))
			if #BINDER ~= i then file:write("\n") end
	end
	file:close()

	local file = io.open(filename_hint, "w")
	for i, data in ipairs(HINT) do
			file:write(encodeJson(data, true))
			if #HINT ~= i then file:write("\n") end
	end
	file:close()

	local file = io.open(filename_wanted, "w")
	for i, data in ipairs(WANTED) do
			file:write(encodeJson(data, true))
			if #WANTED ~= i then file:write("\n") end
	end
	file:close()

	local file = io.open(filename_ticket, "w")
	for i, data in ipairs(TICKET) do
			file:write(encodeJson(data, true))
			if #TICKET ~= i then file:write("\n") end
	end
	file:close()

	local file = io.open(filename_post, "w")
	for i, data in ipairs(POST) do
			file:write(encodeJson(data, true))
			if #POST ~= i then file:write("\n") end
	end
	file:close()

	mainIni.HotKey.HotKeyMenu = encodeJson(HotKeyMenu.v)
	mainIni.HotKey.HotKeyHint = encodeJson(HotKeyHint.v)
	mainIni.HotKey.HotKeyBindHint = encodeJson(HotKeyBindHint.v)
	mainIni.HotKey.HotKeyFastMenu = encodeJson(HotKeyFastMenu.v)
	mainIni.HotKey.HotKeyPursuitMod = encodeJson(HotKeyPursuitMod.v)
	mainIni.HotKey.HotKeyPatrol = encodeJson(HotKeyPatrol.v)
	mainIni.HotKey.HotKeyWeapon = encodeJson(HotKeyWeapon.v)
	mainIni.HotKey.HotKeyMarkOff = encodeJson(HotKeyMarkOff.v)
	mainIni.Buffer.post_name = text_buffer_post_name.v
	mainIni.Buffer.patrol_mode1 = text_buffer_patrol_mode1.v
	mainIni.Buffer.patrol_mode2 = text_buffer_patrol_mode2.v
	mainIni.Buffer.patrol_n1 = text_buffer_patrol_n1.v
	mainIni.Buffer.patrol_n2 = text_buffer_patrol_n2.v
	mainIni.Buffer.patrol_n3 = text_buffer_patrol_n3.v
	mainIni.Buffer.patrol_tencode = text_buffer_patrol_tencode.v
	mainIni.Buffer.patrol_code = text_buffer_patrol_code.v
	mainIni.Buffer.patrol_mark = text_buffer_patrol_mark.v
	mainIni.Buffer.name = text_buffer_name.v
	mainIni.Buffer.ticket_t1 = text_buffer_ticket_t1.v
	mainIni.Buffer.ticket_t2 = text_buffer_ticket_t2.v
	mainIni.Buffer.ticket_t3 = text_buffer_ticket_t3.v
	mainIni.Buffer.ticket_t4 = text_buffer_ticket_t4.v
	mainIni.Buffer.organization = text_buffer_organization.v
	mainIni.Buffer.phone = text_buffer_phone.v
	mainIni.Buffer.rank = text_buffer_rank.v
	mainIni.Buffer.firstname = text_buffer_firstname.v
	mainIni.Buffer.surname = text_buffer_surname.v
	mainIni.Buffer.radio_rp = text_buffer_radio_rp.v
	mainIni.Buffer.radio = text_buffer_radio.v
	mainIni.Buffer.tag = text_buffer_tag.v
	mainIni.Buffer.accent = text_buffer_accent.v
	mainIni.Buffer.weapon_w1 = text_buffer_weapon_w1.v
	mainIni.Buffer.weapon_w2 = text_buffer_weapon_w2.v
	mainIni.Buffer.weapon_w3 = text_buffer_weapon_w3.v
	mainIni.Buffer.weapon_w4 = text_buffer_weapon_w4.v
	mainIni.Buffer.weapon_w5 = text_buffer_weapon_w5.v
	mainIni.Buffer.weapon_w6 = text_buffer_weapon_w6.v
	mainIni.Buffer.weapon_w7 = text_buffer_weapon_w7.v
	mainIni.Buffer.weapon_w8 = text_buffer_weapon_w8.v
	mainIni.Toggle.hud_block = toggle_button_hud_block.v
	mainIni.Toggle.hud_p1 = toggle_button_hud_p1.v
	mainIni.Toggle.hud_p2 = toggle_button_hud_p2.v
	mainIni.Toggle.hud_p3 = toggle_button_hud_p3.v
	mainIni.Toggle.hud_p4 = toggle_button_hud_p4.v
	mainIni.Toggle.hud_p5 = toggle_button_hud_p5.v
	mainIni.Toggle.hud_p6 = toggle_button_hud_p6.v
	mainIni.Toggle.hud = toggle_button_hud.v
	mainIni.Toggle.save = toggle_button_save.v
	mainIni.Toggle.autogun = toggle_button_autogun.v
	mainIni.Toggle.wanted = toggle_button_wanted.v
	mainIni.Toggle.radio_rp = toggle_button_radio_rp.v
	mainIni.Toggle.ticket = toggle_button_ticket.v
	mainIni.Toggle.tag = toggle_button_tag.v
	mainIni.Toggle.accent = toggle_button_accent.v
	mainIni.Toggle.weapon_weapon = toggle_button_weapon_weapon.v
	mainIni.Toggle.weapon_w1 = toggle_button_weapon_w1.v
	mainIni.Toggle.weapon_w2 = toggle_button_weapon_w2.v
	mainIni.Toggle.weapon_w3 = toggle_button_weapon_w3.v
	mainIni.Toggle.weapon_w4 = toggle_button_weapon_w4.v
	mainIni.Toggle.weapon_w5 = toggle_button_weapon_w5.v
	mainIni.Toggle.weapon_w6 = toggle_button_weapon_w6.v
	mainIni.Toggle.weapon_w7 = toggle_button_weapon_w7.v
	mainIni.Toggle.weapon_w8 = toggle_button_weapon_w8.v
	mainIni.Slider.hud = slider_buffer_hud.v
	mainIni.Slider.patrol_wait = slider_buffer_patrol_wait.v
	mainIni.Combo.weapon_select = combo_weapon_select.v
	mainIni.Combo.patrol_select = combo_patrol_select.v
	mainIni.Pos.hud_x = Pos_Hud.x
	mainIni.Pos.hud_y = Pos_Hud.y
	mainIni.Pos.pursuit_mod_x = Pos_Pursuit_Mod.x
	mainIni.Pos.pursuit_mod_y = Pos_Pursuit_Mod.y
	mainIni.Pos.fastmenu_x = Pos_FastMenu.x
	mainIni.Pos.fastmenu_y = Pos_FastMenu.y
	mainIni.Pos.patrol_x = Pos_Patrol.x
	mainIni.Pos.patrol_y = Pos_Patrol.y
	inicfg.save(mainIni, directIni)
end

function LoadSettings()
	local filename_binder = (getGameDirectory().."\\moonloader\\Johnny Silverhand\\binder.json"):format(getFolderPath(0x05))
	local filename_hint = (getGameDirectory().."\\moonloader\\Johnny Silverhand\\hint.json"):format(getFolderPath(0x05))
	local filename_wanted = (getGameDirectory().."\\moonloader\\Johnny Silverhand\\wanted.json"):format(getFolderPath(0x05))
	local filename_ticket = (getGameDirectory().."\\moonloader\\Johnny Silverhand\\ticket.json"):format(getFolderPath(0x05))
	local filename_post = (getGameDirectory().."\\moonloader\\Johnny Silverhand\\post.json"):format(getFolderPath(0x05))

	for line in io.lines(filename_binder) do
		local result, data = pcall(decodeJson, line)
		if result then
			table.insert(BINDER, data)
			if #data.hotkey > 0 then
					mrkeys.registerHotKey(data.hotkey, true, function()
					if not sampIsDialogActive() and not sampIsChatInputActive() then
						onStartHotkey(data.content)
					end
				end)
			end
			if #data.command > 0 then
				sampRegisterChatCommand(tostring(data.command), function()
					if not sampIsDialogActive() then
						onStartHotkey(data.content)
					end
				end)
			end
		end
	end

	for line in io.lines(filename_hint) do
		local result, data = pcall(decodeJson, line)
		if result then
			table.insert(HINT, data)
		end
	end

	for line in io.lines(filename_wanted) do
		local result, data = pcall(decodeJson, line)
		if result then
			table.insert(WANTED, data)
		end
	end

	for line in io.lines(filename_ticket) do
		local result, data = pcall(decodeJson, line)
		if result then
			table.insert(TICKET, data)
		end
	end

	for line in io.lines(filename_post) do
		local result, data = pcall(decodeJson, line)
		if result then
			table.insert(POST, data)
		end
	end

	text_buffer_post_name.v = mainIni.Buffer.post_name
	text_buffer_patrol_mode1.v = mainIni.Buffer.patrol_mode1
	text_buffer_patrol_mode2.v = mainIni.Buffer.patrol_mode2
	text_buffer_patrol_n1.v = mainIni.Buffer.patrol_n1
	text_buffer_patrol_n2.v = mainIni.Buffer.patrol_n2
	text_buffer_patrol_n3.v = mainIni.Buffer.patrol_n3
	text_buffer_patrol_tencode.v = mainIni.Buffer.patrol_tencode
	text_buffer_patrol_code.v = mainIni.Buffer.patrol_code
	text_buffer_patrol_mark.v = mainIni.Buffer.patrol_mark
	text_buffer_name.v = mainIni.Buffer.name
	text_buffer_ticket_t1.v = mainIni.Buffer.ticket_t1
	text_buffer_ticket_t2.v = mainIni.Buffer.ticket_t2
	text_buffer_ticket_t3.v = mainIni.Buffer.ticket_t3
	text_buffer_ticket_t4.v = mainIni.Buffer.ticket_t4
	text_buffer_organization.v = mainIni.Buffer.organization
	text_buffer_phone.v = mainIni.Buffer.phone
	text_buffer_rank.v = mainIni.Buffer.rank
	text_buffer_firstname.v = mainIni.Buffer.firstname
	text_buffer_surname.v = mainIni.Buffer.surname
	text_buffer_radio_rp.v = mainIni.Buffer.radio_rp
	text_buffer_tag.v = mainIni.Buffer.tag
	text_buffer_radio.v = mainIni.Buffer.radio
	text_buffer_accent.v = mainIni.Buffer.accent
	text_buffer_weapon_w1.v = mainIni.Buffer.weapon_w1
	text_buffer_weapon_w2.v = mainIni.Buffer.weapon_w2
	text_buffer_weapon_w3.v = mainIni.Buffer.weapon_w3
	text_buffer_weapon_w4.v = mainIni.Buffer.weapon_w4
	text_buffer_weapon_w5.v = mainIni.Buffer.weapon_w5
	text_buffer_weapon_w6.v = mainIni.Buffer.weapon_w6
	text_buffer_weapon_w7.v = mainIni.Buffer.weapon_w7
	text_buffer_weapon_w8.v = mainIni.Buffer.weapon_w8
	toggle_button_hud_block.v = mainIni.Toggle.hud_block
	toggle_button_hud_p1.v = mainIni.Toggle.hud_p1
	toggle_button_hud_p2.v = mainIni.Toggle.hud_p2
	toggle_button_hud_p3.v = mainIni.Toggle.hud_p3
	toggle_button_hud_p4.v = mainIni.Toggle.hud_p4
	toggle_button_hud_p5.v = mainIni.Toggle.hud_p5
	toggle_button_hud_p6.v = mainIni.Toggle.hud_p6
	toggle_button_hud.v = mainIni.Toggle.hud
	toggle_button_save.v = mainIni.Toggle.save
	toggle_button_autogun.v = mainIni.Toggle.autogun
	toggle_button_wanted.v = mainIni.Toggle.wanted
	toggle_button_radio_rp.v = mainIni.Toggle.radio_rp
	toggle_button_ticket.v = mainIni.Toggle.ticket
	toggle_button_tag.v = mainIni.Toggle.tag
	toggle_button_accent.v = mainIni.Toggle.accent
	toggle_button_weapon_weapon.v = mainIni.Toggle.weapon_weapon
	toggle_button_weapon_w1.v = mainIni.Toggle.weapon_w1
	toggle_button_weapon_w2.v = mainIni.Toggle.weapon_w2
	toggle_button_weapon_w3.v = mainIni.Toggle.weapon_w3
	toggle_button_weapon_w4.v = mainIni.Toggle.weapon_w4
	toggle_button_weapon_w5.v = mainIni.Toggle.weapon_w5
	toggle_button_weapon_w6.v = mainIni.Toggle.weapon_w6
	toggle_button_weapon_w7.v = mainIni.Toggle.weapon_w7
	toggle_button_weapon_w8.v = mainIni.Toggle.weapon_w8
	slider_buffer_hud.v = mainIni.Slider.hud
	slider_buffer_patrol_wait.v = mainIni.Slider.patrol_wait
	combo_weapon_select.v = mainIni.Combo.weapon_select
	combo_patrol_select.v = mainIni.Combo.patrol_select
	Pos_Hud.x = mainIni.Pos.hud_x
	Pos_Hud.y = mainIni.Pos.hud_y
	Pos_Pursuit_Mod.x = mainIni.Pos.pursuit_mod_x
	Pos_Pursuit_Mod.y = mainIni.Pos.pursuit_mod_y
	Pos_FastMenu.x = mainIni.Pos.fastmenu_x
	Pos_FastMenu.y = mainIni.Pos.fastmenu_y
	Pos_Patrol.x = mainIni.Pos.patrol_x
	Pos_Patrol.y = mainIni.Pos.patrol_y
end

function Register_Imgui()
	settings_mode = 1

	img1 = imgui.CreateTextureFromFile(getGameDirectory() ..  "\\moonloader\\Johnny Silverhand\\images\\image1.png")
	img2 = imgui.CreateTextureFromFile(getGameDirectory() ..  "\\moonloader\\Johnny Silverhand\\images\\image2.png")

	sw, sh = getScreenResolution()

	Pos_Pursuit_Mod = {x = sw / 2, y = sh / 2}
	Pos_FastMenu = {x = sw / 2, y = sh / 2}
	Pos_Hud = {x = sw / 2, y = sh / 2}
	Pos_Patrol = {x = sw / 2, y = sh / 2}

	main_window_state = imgui.ImBool(false)
	settings_window_state = imgui.ImBool(false)
	wanted_window_state = imgui.ImBool(false)
	ticket_window_state = imgui.ImBool(false)
	pursuit_mod_window_state = imgui.ImBool(false)
	fastmenu_window_state = imgui.ImBool(false)
	hud_window_state = imgui.ImBool(false)
	hint_window_state = imgui.ImBool(false)
	patrol_window_state = imgui.ImBool(false)
	variables_window_state = imgui.ImBool(false)
	welcome_window_state = imgui.ImBool(false)

	text_buffer_welcome_c =imgui.ImBuffer(256)
	text_buffer_welcome_p =imgui.ImBuffer(256)
	text_buffer_welcome_l = imgui.ImBuffer(256)
	text_buffer_variables_search = imgui.ImBuffer(256)
	text_buffer_post_name = imgui.ImBuffer(256)
	text_buffer_patrol_mode1 = imgui.ImBuffer(256)
	text_buffer_patrol_mode2 = imgui.ImBuffer(256)
	text_buffer_patrol_n3 = imgui.ImBuffer(256)
	text_buffer_patrol_n2 = imgui.ImBuffer(256)
	text_buffer_patrol_n1 = imgui.ImBuffer(256)
	text_buffer_patrol_tencode = imgui.ImBuffer(256)
	text_buffer_patrol_code = imgui.ImBuffer(256)
	text_buffer_patrol_mark = imgui.ImBuffer(256)
	text_buffer_name = imgui.ImBuffer(256)
	text_buffer_ticket_t1 = imgui.ImBuffer(256)
	text_buffer_ticket_t2 = imgui.ImBuffer(256)
	text_buffer_ticket_t3 = imgui.ImBuffer(256)
	text_buffer_ticket_t4 = imgui.ImBuffer(256)
	text_buffer_hint_search = imgui.ImBuffer(256)
	text_buffer_hint_name = imgui.ImBuffer(256)
	text_buffer_hint_content = imgui.ImBuffer(65000)
	text_buffer_ticket_search = imgui.ImBuffer(256)
	text_buffer_ticket_name = imgui.ImBuffer(256)
	text_buffer_ticket_content = imgui.ImBuffer(65000)
	text_buffer_wanted_search = imgui.ImBuffer(256)
	text_buffer_wanted_name = imgui.ImBuffer(256)
	text_buffer_wanted_content = imgui.ImBuffer(65000)
	text_buffer_phone = imgui.ImBuffer(256)
	text_buffer_rank = imgui.ImBuffer(256)
	text_buffer_organization = imgui.ImBuffer(256)
	text_buffer_firstname = imgui.ImBuffer(256)
	text_buffer_surname = imgui.ImBuffer(256)
	text_buffer_radio_rp = imgui.ImBuffer(256)
	text_buffer_radio = imgui.ImBuffer(256)
	text_buffer_tag = imgui.ImBuffer(256)
	text_buffer_accent = imgui.ImBuffer(256)
	text_buffer_binder_description = imgui.ImBuffer(256)
	text_buffer_binder_command = imgui.ImBuffer(256)
	text_buffer_binder_content = imgui.ImBuffer(65000)
	text_buffer_weapon_w1 = imgui.ImBuffer(256)
	text_buffer_weapon_w2 = imgui.ImBuffer(256)
	text_buffer_weapon_w3 = imgui.ImBuffer(256)
	text_buffer_weapon_w4 = imgui.ImBuffer(256)
	text_buffer_weapon_w5 = imgui.ImBuffer(256)
	text_buffer_weapon_w6 = imgui.ImBuffer(256)
	text_buffer_weapon_w7 = imgui.ImBuffer(256)
	text_buffer_weapon_w8 = imgui.ImBuffer(256)

	toggle_button_hud_block = imgui.ImBool(false)
	toggle_button_hud_p1 = imgui.ImBool(false)
	toggle_button_hud_p2 = imgui.ImBool(false)
	toggle_button_hud_p3 = imgui.ImBool(false)
	toggle_button_hud_p4 = imgui.ImBool(false)
	toggle_button_hud_p5 = imgui.ImBool(false)
	toggle_button_hud_p6 = imgui.ImBool(false)
	toggle_button_hud = imgui.ImBool(false)
	toggle_button_autogun = imgui.ImBool(false)
	toggle_button_save = imgui.ImBool(false)
	toggle_button_wanted = imgui.ImBool(false)
	toggle_button_radio_rp = imgui.ImBool(false)
	toggle_button_ticket = imgui.ImBool(false)
	toggle_button_tag = imgui.ImBool(false)
	toggle_button_accent = imgui.ImBool(false)
	toggle_button_weapon_weapon = imgui.ImBool(false)
	toggle_button_weapon_w1 = imgui.ImBool(false)
	toggle_button_weapon_w2 = imgui.ImBool(false)
	toggle_button_weapon_w3 = imgui.ImBool(false)
	toggle_button_weapon_w4 = imgui.ImBool(false)
	toggle_button_weapon_w5 = imgui.ImBool(false)
	toggle_button_weapon_w6 = imgui.ImBool(false)
	toggle_button_weapon_w7 = imgui.ImBool(false)
	toggle_button_weapon_w8 = imgui.ImBool(false)

	slider_buffer_hud = imgui.ImInt(100)
	slider_buffer_patrol_wait = imgui.ImInt(60)

	combo_weapon_select = imgui.ImInt(0)
	combo_weapon_str = {u8"При прокрутке оружия", u8"При нажатии клавиши", u8"При прицеливании"}

	combo_patrol_select = imgui.ImInt(0)
	combo_patrol_str = {u8"Доклад с поста", u8"Доклад с патруля"}

	 skins = {}
	 for i = 0, 311 do
		local file = ('moonloader/Johnny Silverhand/skins/'..i..'.png')
		skins[i] = imgui.CreateTextureFromFile(file)
	 end
end

function Register_Hotkey()
	HotKeyMenu = {v=decodeJson(mainIni.HotKey.HotKeyMenu)}
	HotKeyHint = {v=decodeJson(mainIni.HotKey.HotKeyHint)}
	HotKeyBindHint = {v=decodeJson(mainIni.HotKey.HotKeyBindHint)}
	HotKeyFastMenu = {v=decodeJson(mainIni.HotKey.HotKeyFastMenu)}
	HotKeyPursuitMod = {v=decodeJson(mainIni.HotKey.HotKeyPursuitMod)}
	HotKeyPatrol = {v=decodeJson(mainIni.HotKey.HotKeyPatrol)}
	HotKeyWeapon = {v=decodeJson(mainIni.HotKey.HotKeyWeapon)}
	HotKeyMarkOff = {v=decodeJson(mainIni.HotKey.HotKeyMarkOff)}

	if Welcome_Status then
		bindMenu = mrkeys.registerHotKey(HotKeyMenu.v, true, function()
			if not settings_window_state.v and not pursuit_mod_window_state.v and not wanted_window_state.v and not fastmenu_window_state.v and not hint_window_state.v and not ticket_window_state.v and not patrol_window_state.v then
				if not sampIsDialogActive() and not sampIsChatInputActive() then
					main_window_state.v = not main_window_state.v
					imgui.Process = main_window_state.v
				end
			end
		end)

		bindHint = mrkeys.registerHotKey(HotKeyHint.v, true, function()
			if not main_window_state.v and not settings_window_state.v and not pursuit_mod_window_state.v and not wanted_window_state.v and not fastmenu_window_state.v and not ticket_window_state.v and not patrol_window_state.v then
				if not sampIsDialogActive() and not sampIsChatInputActive() then
					hint_window_state.v = not hint_window_state.v
					imgui.Process = hint_window_state.v
				end
			end
		end)

		bindPursuitMod = mrkeys.registerHotKey(HotKeyPursuitMod.v, true, function()
			if not main_window_state.v and not settings_window_state.v and not wanted_window_state.v and not fastmenu_window_state.v and not hint_window_state.v and not ticket_window_state.v and not patrol_window_state.v then
				if not sampIsDialogActive() and not sampIsChatInputActive() then
					pursuit_mod_window_state.v = not pursuit_mod_window_state.v
					imgui.Process = pursuit_mod_window_state.v
				end
			end
		end)

		bindPatrol = mrkeys.registerHotKey(HotKeyPatrol.v, true, function()
			if not main_window_state.v and not settings_window_state.v and not pursuit_mod_window_state.v and not wanted_window_state.v and not fastmenu_window_state.v and not hint_window_state.v and not ticket_window_state.v then
				if not sampIsDialogActive() and not sampIsChatInputActive() then
					patrol_window_state.v = not patrol_window_state.v
					imgui.Process = patrol_window_state.v
				end
			end
		end)

		bindFastMenu = mrkeys.registerHotKey(HotKeyFastMenu.v, true, function()
			if not main_window_state.v and not settings_window_state.v and not pursuit_mod_window_state.v and not wanted_window_state.v and not hint_window_state.v and not ticket_window_state.v and not patrol_window_state.v then
				if not sampIsDialogActive() and not sampIsChatInputActive() then
					fastmenu_window_state.v = not fastmenu_window_state.v
					imgui.Process = fastmenu_window_state.v
				end
			end
		end)

		bindWeapon = mrkeys.registerHotKey(HotKeyWeapon.v, true, function()
			if not sampIsDialogActive() and not sampIsChatInputActive() then
				if toggle_button_weapon_weapon.v and combo_weapon_select.v == 1 then
					RPGun(getCurrentCharWeapon(PLAYER_PED))
				end
			end
		end)

		bindMarkOff = mrkeys.registerHotKey(HotKeyMarkOff.v, true, function()
			if not sampIsDialogActive() and not sampIsChatInputActive() then
				if bs then
					raknetEmulRpcReceiveBitStream(39, bs)
					raknetDeleteBitStream(bs)
					Notification("Метка убрана с глаз долой.", 2)
				end
			end
		end)

		mrkeys.registerHotKey({2}, true, function()
			if toggle_button_weapon_weapon.v and combo_weapon_select.v == 2 then
				RPGun(getCurrentCharWeapon(PLAYER_PED))
			end
		end)

		mrkeys.registerHotKey({2,18}, true, function()
		local result, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
			if result and doesCharExist(ped) then
				local success, id = sampGetPlayerIdByCharHandle(ped)
				if success then
					current_id = id
					Notification("Вы начали взаимодействие с игроком: " .. sampGetPlayerNickname(id) .. "(" .. id .. ")", 2)
				end
			end
		end)
	end
end

function Register_Command()
	if Welcome_Status then
		sampRegisterChatCommand("johnny", function()
			if not settings_window_state.v and not pursuit_mod_window_state.v and not wanted_window_state.v and not fastmenu_window_state.v and not hint_window_state.v and not ticket_window_state.v and not patrol_window_state.v then
				main_window_state.v = not main_window_state.v
				imgui.Process = main_window_state.v
			end
		end)

		sampRegisterChatCommand("jhelp", function()
			sampShowDialog(777, "{FFD700}Johnny Silverhand | by Miron Diamond", "{FFD700}/johnny{FFFFFF}\t\tОткрыть главное меню\n{FFD700}/target{FFFFFF}\t\tНачать взаимодействие с игроком.\n{FFD700}/targetoff{FFFFFF}\tПерестать взаимодействие с игроком.\n{FFD700}/cc{FFFFFF}\t\tПолностью очистить чат.\n{FFD700}/rec{FFFFFF}\t\tРеконнект в секундах.", "Закрыть", "", 0)
		end)

		sampRegisterChatCommand("target", function(arg)
			if tonumber(arg) <= 999 and tonumber(arg) >= 0 and sampIsPlayerConnected(arg) then
				local Player_ID = tostring(arg)
				local Player_Nick = sampGetPlayerNickname(Player_ID)
				current_id = tonumber(Player_ID)
				Notification("Вы начали взаимодействие с игроком: " .. Player_Nick .. "(" .. Player_ID .. ")", 2)
			else
				current_id = nil
				Notification("Ошибка ID.", 2)
			end
		end)

		sampRegisterChatCommand("targetoff", function()
			if current_id then
				current_id = nil
				Notification("Вы перестали взаимодействие с игроком.", 2)
			end
		end)

		sampRegisterChatCommand("cc", function()
			memory.fill(sampGetChatInfoPtr() + 306, 0x0, 25200)
			memory.write(sampGetChatInfoPtr() + 306, 25562, 4, 0x0)
			memory.write(sampGetChatInfoPtr() + 0x63DA, 1, 1)
			Notification("Чат очищен.", 2)
		end)

		sampRegisterChatCommand("markoff", function()
			if bs then
				raknetEmulRpcReceiveBitStream(39, bs)
				raknetDeleteBitStream(bs)
				Notification("Метка убрана с глаз долой.", 2)
			end
		end)

		sampRegisterChatCommand("rec", function(sec)
			Rec_Time = tonumber(sec)
			RECONNECT:run()
		end)

		sampRegisterChatCommand("su", function(id)
			if toggle_button_wanted.v then
				if tonumber(id) then
					local id = tonumber(id)
					if id >= 0 or id <= 1000 then
						if sampIsPlayerConnected(id) then
							Notification("Выбранный игрок:\n"..sampGetPlayerNickname(id).." ("..id..")",2)
							current_su_id = id
							wanted_window_state.v = true
							imgui.Process = wanted_window_state.v
						else
							Notification("Данный игрок не в сети!",2)
						end
					end
				end
			else
				sampSendChat("/su "..id)
			end
		end)

		sampRegisterChatCommand("ticket", function(id)
			if toggle_button_ticket.v then
				if tonumber(id) then
					local id = tonumber(id)
					if id >= 0 or id <= 1000 then
						if sampIsPlayerConnected(id) then
							Notification("Выбранный игрок:\n"..sampGetPlayerNickname(id).." ("..id..")",2)
							current_ticket_id = id
							ticket_window_state.v = true
							imgui.Process = ticket_window_state.v
						else
							Notification("Данный игрок не в сети!",2)
						end
					end
				end
			else
				sampSendChat("/ticket "..id)
			end
		end)

		sampRegisterChatCommand("r", function(command)
				lua_thread.create(function()
					if toggle_button_radio_rp.v then
						sampSendChat(u8:decode(text_buffer_radio_rp.v))
						wait(1500)
					end
					if toggle_button_tag.v then
						sampSendChat("/r "..u8:decode(text_buffer_tag.v).." "..command)
					else
						sampSendChat("/r "..command)
					end
				end)
		end)
	end
end

function Register_Table()
	BINDER = {}
	WANTED = {}
	TICKET = {}
	POST = {}
	HINT = {}

	LastKeys = {}

	HotKeyMenu = {v={}}
	HotKeyHint = {v={}}
	HotKeyBindHint = {v={}}
	HotKeyFastMenu = {v={}}
	HotKeyPursuitMod = {v={}}
	HotKeyPatrol = {v={}}
	HotKeyBinder = {v={}}
	HotKeyWeapon = {v={}}
	HotKeyMarkOff = {v={}}

	cars = {"Landstalker","Bravura","Buffalo","Linerunner","Perrenial","Sentinel","Dumper","Firetruck","Trashmaster","Stretch","Manana","Infernus","Voodoo","Pony","Mule","Cheetah","Ambulance","Leviathan","Moonbeam","Esperanto","Taxi","Washington","Bobcat","Whoopee","BFInjection","Hunter","Premier","Enforcer","Securicar","Banshee","Predator","Bus","Rhino","Barracks","Hotknife","Trailer","Previon","Coach","Cabbie","Stallion","Rumpo","RCBandit","Romero","Packer","Monster","Admiral","Squalo","Seasparrow","Pizzaboy","Tram","Trailer","Turismo","Speeder","Reefer","Tropic","Flatbed","Yankee","Caddy","Solair","Berkley'sRCVan","Skimmer","PCJ-600","Faggio","Freeway","RCBaron","RCRaider","Glendale","Oceanic","Sanchez","Sparrow","Patriot","Quad","Coastguard","Dinghy","Hermes","Sabre","Rustler","ZR-350","Walton","Regina","Comet","BMX","Burrito","Camper","Marquis","Baggage","Dozer","Maverick","NewsChopper","Rancher","FBIRancher","Virgo","Greenwood","Jetmax","Hotring","Sandking","BlistaCompact","PoliceMaverick","Boxvillde","Benson","Mesa","RCGoblin","HotringRacerA","HotringRacerB","BloodringBanger","Rancher","SuperGT","Elegant","Journey","Bike","MountainBike","Beagle","Cropduster","Stunt","Tanker","Roadtrain","Nebula","Majestic","Buccaneer","Shamal","Hydra","FCR-900","NRG-500","HPV1000","CementTruck","TowTruck","Fortune","Cadrona","FBITruck","Willard","Forklift","Tractor","Combine","Feltzer","Remington","Slamvan","Blade","Freight","Streak","Vortex","Vincent","Bullet","Clover","Sadler","Firetruck","Hustler","Intruder","Primo","Cargobob","Tampa","Sunrise","Merit","Utility","Nevada","Yosemite","Windsor","Monster","Monster","Uranus","Jester","Sultan","Stratum","Elegy","Raindance","RCTiger","Flash","Tahoma","Savanna","Bandito","FreightFlat","StreakCarriage","Kart","Mower","Dune","Sweeper","Broadway","Tornado","AT-400","DFT-30","Huntley","Stafford","BF-400","NewsVan","Tug","Trailer","Emperor","Wayfarer","Euros","Hotdog","Club","FreightBox","Trailer","Andromada","Dodo","RCCam","Launch","PoliceCar","PoliceCar","PoliceCar","PoliceRanger","Picador","S.W.A.T","Alpha","Phoenix","GlendaleShit","SadlerShit","Luggage","Luggage","Stairs","Boxville","Tiller","UtilityTrailer"}
end

-- Imgui

function imgui.BeforeDrawFrame()
  if fa_font == nil then
    local font_config = imgui.ImFontConfig()
    font_config.MergeMode = true
    fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/Johnny Silverhand/fonts/font-awesome.ttf', 13.0, font_config, fa_glyph_ranges)
  end

	if cyberpunk == nil then
		cyberpunk = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/Johnny Silverhand/fonts/font-cyberpunk.ttf', 20.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
		cyberpunk_author = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/Johnny Silverhand/fonts/font-cyberpunk.ttf', 25.0, nil,imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
		cyberpunk_menu = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/Johnny Silverhand/fonts/font-cyberpunk.ttf', 38.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
	end

	if fontsize50 == nil then
		fontsize50 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 50.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
		fontsize20 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 20.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
		fontsize18 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 18.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
		fontsize14 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 14.5, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
	end
end

function imgui.OnDrawFrame()
	if not main_window_state.v and not settings_window_state.v and not pursuit_mod_window_state.v and not wanted_window_state.v and not fastmenu_window_state.v and not hud_window_state.v and not hint_window_state.v and not ticket_window_state.v and not patrol_window_state.v and not welcome_window_state.v then
		imgui.Process = false
	end

	if main_window_state.v or settings_window_state.v or pursuit_mod_window_state.v or wanted_window_state.v or fastmenu_window_state.v or hint_window_state.v or ticket_window_state.v or patrol_window_state.v or welcome_window_state.v then
		hud_window_state.v = false
		imgui.ShowCursor = true
	end

	if welcome_window_state.v then
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(700, 600), imgui.Cond.FirstUseEver)
		imgui.Begin("Police System", nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove)
		if Imgui_Welcome_Mode == 0 then
			imgui.SetCursorPosX(imgui.GetWindowWidth() / 2 - 155)
			imgui.SetCursorPosY(220)
			imgui.BeginChild("##HUAHIB1UIHA", imgui.ImVec2(300, 150), true)
			imgui.PushFont(fontsize20)
			imgui.TextCenter(u8"Авторизация")
			imgui.PopFont()
			imgui.Text("")
			imgui.NewInputText('##UIHBA8198ACAZ', text_buffer_welcome_l, -1, u8'Логин', 1)
			imgui.NewInputText('##18BAHJBZCA', text_buffer_welcome_p, -1, u8'Пароль', 1, imgui.InputTextFlags.Password)
			imgui.Text("")
			if imgui.Button(u8"Войти", imgui.ImVec2(-1, 20)) then
				if #text_buffer_welcome_l.v > 0 and #text_buffer_welcome_p.v > 0 then
					Imgui_Welcome_Mode = 1
				end
			end
			imgui.EndChild()
		elseif Imgui_Welcome_Mode == 1 then
			imgui.SetCursorPosX(imgui.GetWindowWidth() / 2 - 155)
			imgui.SetCursorPosY(220)
			imgui.BeginChild("##88800123ABHUJA1A", imgui.ImVec2(300, 150), true)
			imgui.Text("")
			imgui.PushFont(fontsize20)
			imgui.TextCenter(u8"Проверка на робота")
			imgui.PopFont()
			imgui.Text("")
			if imgui.Button(fa.ICON_VOLUME_UP, imgui.ImVec2(20, 20)) then
				setAudioStreamState(playsound_3, 1)
			end
			imgui.SameLine()
			imgui.NewInputText('##Hbabh187acHJABZ', text_buffer_welcome_c, -1, u8'Капча', 1)
			imgui.Text("")
			if imgui.Button(u8"Подтвердить", imgui.ImVec2(-1, 20)) then
				if text_buffer_welcome_c.v == u8"Мирон Даймонд" or text_buffer_welcome_c.v == ("Miron Diamond") then
					Welcome_Loading = 0
					WELCOME_LOADING:run()
					Imgui_Welcome_Mode = 2
				else
					Notification("Ошибка капчи.", 3)
				end
			end
			imgui.EndChild()
		elseif Imgui_Welcome_Mode == 2 then
			imgui.SetCursorPosY(210)
			imgui.SetCursorPosX(imgui.GetWindowWidth() / 2 - 70)
			imgui.Spinner("##046ABHJGAZ", 70, 10, imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.ButtonHovered]))
			imgui.SetCursorPosY(380)
			imgui.PushFont(fontsize50)
			imgui.TextCenter(u8"Диагностика системы")
			imgui.TextCenter("("..Welcome_Loading.."%)")
			imgui.PopFont()
		elseif Imgui_Welcome_Mode == 3 then
			imgui.SetCursorPosY(260)
			imgui.PushFont(fontsize50)
			imgui.TextCenter(u8"Ошибка!")
			imgui.PopFont()
		elseif Imgui_Welcome_Mode == 4 then
			imgui.SetCursorPosX(imgui.GetWindowWidth() / 2 - 205)
			imgui.SetCursorPosY(220)
			imgui.BeginChild("##056804AHGUZ817AC", imgui.ImVec2(400, 120), true)
			imgui.Text("")
			imgui.PushFont(fontsize14)
			imgui.TextCenter(u8"Неизвестное приложение запрашивает доступ к настройкам.")
			imgui.TextCenter(u8"Разрешить доступ?")
			imgui.PopFont()
			imgui.Text("")
			if imgui.Button(u8"Да", imgui.ImVec2(187, 20)) then
				WELCOME_UPDATE:run()
			end
			imgui.SameLine()
			if imgui.Button(u8"Нет", imgui.ImVec2(-1, 20)) then
				Notification("Отказано в доступе!", 2)
			end
			imgui.EndChild()
		end
		imgui.End()
	end

	if main_window_state.v then
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(400, 400), imgui.Cond.FirstUseEver)
		imgui.Begin("Menu", nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove)
		imgui.Image(img2, imgui.ImVec2(383, 383))
		imgui.SetCursorPosY(8)
		colors[clr.ChildWindowBg] = ImVec4(0.00, 0.00, 0.00, 0.80)
		imgui.BeginChild("##0746AHJGAZXC", imgui.ImVec2(383, 383), true)
		imgui.SetCursorPosY(50)
		imgui.PushFont(cyberpunk_menu)
		imgui.TextCenterRGB("{FFD700}Johnny Silverhand")
		imgui.PopFont()
		imgui.PushFont(cyberpunk_author)
		imgui.TextCenterRGB("{FFD700}by Miron Diamond")
		imgui.PopFont()
		imgui.SetCursorPosY(285)
		if imgui.Button(fa.ICON_COGS..u8" Открыть настройки всей системы", imgui.ImVec2(-1,20)) then
			main_window_state.v = false
			settings_window_state.v = true
		end
		if imgui.Button(fa.ICON_FLOPPY_O..u8" Сохранить все настройки", imgui.ImVec2(-1, 20)) then
			SaveSettings()
			Notification("Настройки успешно сохранены!", 2)
		end
		if imgui.Button(fa.ICON_REFRESH..u8" Перезагрузить систему", imgui.ImVec2(-1,20)) then
			lua_thread.create(function()
				Notification("Перезагрузка системы..",2)
				wait(1000)
				thisScript():reload()
			end)
		end
		if imgui.Button(fa.ICON_POWER_OFF..u8" Завершить работу", imgui.ImVec2(-1,20)) then
			lua_thread.create(function()
				Notification("Johnny Silverhand:\n\nТы так легко от меня не избавишся!",3)
				wait(1000)
				thisScript():unload()
				showCursor(false)
				imgui.ShowCursor = false
			end)
		end
		imgui.EndChild()
		colors[clr.ChildWindowBg] = ImVec4(0.00, 0.00, 0.00, 0.40)
		imgui.End()
	end

	if settings_window_state.v then
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(800, 540), imgui.Cond.FirstUseEver)
		imgui.Begin("Settings", nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove)
		imgui.Image(img1, imgui.ImVec2(783, 200))
		imgui.BeginChild("##UAB1UAIB", imgui.ImVec2(200, -1), true)
		imgui.PushFont(cyberpunk)
		imgui.TextColoredRGB("{FFD700}Johnny Silverhand")
		imgui.PopFont()
		imgui.SetCursorPosY(40)
		if imgui.Selectable(u8"Основные настройки", settings_mode == 1, imgui.SelectableFlags.SpanAllColumns) then
			settings_mode = 1
		end
		if imgui.Selectable(u8"Настройки биндера", settings_mode == 2, imgui.SelectableFlags.SpanAllColumns) then
			settings_mode = 2
		end
		if imgui.Selectable(u8"Настройки подсказок", settings_mode == 3, imgui.SelectableFlags.SpanAllColumns) then
			settings_mode = 3
		end
		if imgui.Selectable(u8"Настройки розыска", settings_mode == 4, imgui.SelectableFlags.SpanAllColumns) then
			settings_mode = 4
		end
		if imgui.Selectable(u8"Настройки штрафов", settings_mode == 5, imgui.SelectableFlags.SpanAllColumns) then
			settings_mode = 5
		end
		if imgui.Selectable(u8"Настройки постов", settings_mode == 6, imgui.SelectableFlags.SpanAllColumns) then
			settings_mode = 6
		end
		if imgui.Selectable(u8"Настройки оружия", settings_mode == 7, imgui.SelectableFlags.SpanAllColumns) then
			settings_mode = 7
		end
		if imgui.Selectable(u8"Настройки клавиш", settings_mode == 8, imgui.SelectableFlags.SpanAllColumns) then
			settings_mode = 8
		end
		if imgui.Selectable(u8"Настройки оверлея", settings_mode == 9, imgui.SelectableFlags.SpanAllColumns) then
			settings_mode = 9
		end
		imgui.SetCursorPosY(290)
		if imgui.Button(u8"Закрыть", imgui.ImVec2(-1, 20)) then
			settings_window_state.v = false
			main_window_state.v = true
		end
		imgui.EndChild()
		imgui.SameLine()
		imgui.BeginChild("##BYAI187B9AXA", imgui.ImVec2(-1, -1), true)
		if settings_mode == 1 then
			imgui.NewInputText('##Ваш акцент', text_buffer_accent, 265, u8'Ваш акцент', 1)
			imgui.SameLine(300)
			imgui.NewInputText('##Ваше имя', text_buffer_firstname, 265, u8'Ваше имя', 1)
			imgui.NewInputText('##Ваш тег в рации', text_buffer_tag, 265, u8'Ваш тег в рации', 1)
			imgui.SameLine(300)
			imgui.NewInputText('##Ваша фамилия', text_buffer_surname, 265, u8'Ваша фамилия', 1)
			imgui.NewInputText('##Ваша организация', text_buffer_organization, 265, u8'Ваша организация', 1)
			imgui.SameLine(300)
			imgui.NewInputText('##Ваш кличка', text_buffer_name, 265, u8'Ваша кличка', 1)
			imgui.NewInputText('##Ваша должность', text_buffer_rank, 265, u8'Ваша должность', 1)
			imgui.SameLine(300)
			imgui.NewInputText('##Ваш номер телефона', text_buffer_phone, 265, u8'Ваш номер телефона', 1)
			imgui.SetCursorPosY(115)
			imgui.Separator()
			imgui.SetCursorPosY(125)
			imgui.Columns(2, "ToogleButtons", false)
			imgui.Text(u8"Включить акцент")
			imgui.SameLine(230)
			imgui.ToggleButton("##BAU1YGJAHGA", toggle_button_accent)
			imgui.Text(u8"Включить тег в рации")
			imgui.SameLine(230)
			imgui.ToggleButton(u8"##Включить тег в рации", toggle_button_tag)
			imgui.Text(u8"Включить умный штраф")
			imgui.SameLine(230)
			imgui.ToggleButton("##AIUB1YUGKJAS", toggle_button_ticket)
			imgui.Text(u8"Включить умный розыск")
			imgui.SameLine(230)
			imgui.ToggleButton("##AUYTGASDG1", toggle_button_wanted)
			imgui.NextColumn()
			imgui.Text(u8"  Включить авто-отыгровку рации")
			imgui.SameLine(235)
			imgui.ToggleButton("##AUIBYAUI1876UA", toggle_button_radio_rp)
			imgui.Text(u8"  Включить авто-сохранение")
			imgui.SameLine(235)
			imgui.ToggleButton("##AUYGAHVGJGA", toggle_button_save)
			imgui.Text(u8"  Включить авто-взятие оружия")
			imgui.SameLine(235)
			imgui.ToggleButton("##UGAYGFJAAS", toggle_button_autogun)
			imgui.Text(u8"  Включить авто-отыгровку оружия")
			imgui.SameLine(235)
			imgui.ToggleButton("##AUHGBJSDFB", toggle_button_weapon_weapon)
			imgui.SetCursorPosY(217)
			imgui.Separator()
			imgui.SetCursorPosY(227)
			imgui.Columns(1, "##NBVBB1OFOA", false)
			imgui.NewInputText('##Чит-код', text_buffer_radio, 60, u8'Чит-код', 1)
			imgui.SameLine(75)
			imgui.NewInputText('##RP Отыгровка рации', text_buffer_radio_rp, 490, u8'RP Отыгровка рации', 1)
			imgui.SetCursorPosY(257)
			imgui.Separator()
			imgui.SetCursorPosY(267)
			imgui.NewInputText(u8'##AJIHAIA', text_buffer_ticket_t1, 265, u8'Сумма штрафа от 1-2 года проживания', 1)
			imgui.SameLine(300)
			imgui.NewInputText(u8'##HUIGAU06575A', text_buffer_ticket_t2, 265, u8'Сумма штрафа от 3-5 лет проживания', 1)
			imgui.NewInputText(u8'##HGUHAV0A44Z', text_buffer_ticket_t3, 265, u8'Сумма штрафа от 6-15 лет проживания', 1)
			imgui.SameLine(300)
			imgui.NewInputText(u8'##05AHGNNNVZB1', text_buffer_ticket_t4, 265, u8'Сумма штрафа от 16 лет проживания', 1)
		elseif settings_mode == 2 then
			imgui.BeginChild("##IOB1879Z9Q", imgui.ImVec2(200, 280), true)
			local Variables = Variables()
				for id, data in ipairs(BINDER) do
					local hint_text = ""
					if imgui.Selectable(id..". "..data.description, current_bind == id, imgui.SelectableFlags.SpanAllColumns) then
						text_buffer_binder_description.v = data.description
						text_buffer_binder_command.v = data.command
						text_buffer_binder_content.v = data.content
						HotKeyBinder.v = data.hotkey
						current_bind = id
					end
					for line in data.content:gmatch("[^\r\n]+") do
						if line:len() > 0 then
							if not line:find("^wait%(%d+%)$") then
								hint_text = hint_text..""..line.."\n"
							else
								local wait_text = line:match("^wait%((%d+)%)$")
								hint_text = hint_text..u8"(Задержка: "..wait_text..u8" мс.)".."\n"
							end
							for k, v in pairs(Variables) do
								hint_text = hint_text:gsub(k, v)
							end
						end
					end
					if #u8:decode(hint_text) > 0 then
						ShowHelpMarker(u8:decode(hint_text))
					else
						ShowHelpMarker("<(мс)> - Задержка в мс.\n! - Отправить сообщение клиенту SAMP.\n@ - Отправить сообщение в локальный чат.\n# - Отправить сообщение в строку чата.")
					end
				end
			imgui.EndChild()
			imgui.SameLine()
			imgui.BeginChild("##BIJWHHURA1", imgui.ImVec2(-1, 280), true)
				if current_bind then
					imgui.HotKey("##0DG1BJSHGJX", HotKeyBinder, LastKeys, 90)
					imgui.SameLine()
					imgui.NewInputText("##AIUGBY1UKJA", text_buffer_binder_description, 127, u8"Название бинда", 1)
					imgui.SameLine(241)
					imgui.NewInputText("##AUUYBUAS", text_buffer_binder_command, 100, u8"Команда", 1)
					imgui.InputTextMultiline('##NSY761765', text_buffer_binder_content, imgui.ImVec2(-1, 216))
					if imgui.Button(fa.ICON_FLOPPY_O..u8" Сохранить", imgui.ImVec2(162.5, 20)) then
						Notification("Все изменения успешно сохранены!", 2)
						local bind = BINDER[current_bind]
						if #bind.hotkey > 0 then
							if mrkeys.isHotKeyDefined(bind.hotkey) then
								mrkeys.unRegisterHotKey(bind.hotkey)
							end
						end
						if sampIsChatCommandDefined(tostring(bind.command)) then
							sampUnregisterChatCommand(tostring(bind.command))
						end
						bind.description = text_buffer_binder_description.v
						bind.command = text_buffer_binder_command.v
						bind.content = text_buffer_binder_content.v
						bind.hotkey = HotKeyBinder.v
						if #bind.hotkey > 0 then
							mrkeys.registerHotKey(bind.hotkey, true, function()
								if not sampIsDialogActive() and not sampIsChatInputActive() then
									onStartHotkey(bind.content)
								end
							end)
						end
						if #bind.command > 0 then
							sampRegisterChatCommand(tostring(bind.command), function()
								if not sampIsDialogActive() then
									onStartHotkey(bind.content)
								end
							end)
						end
					end
					imgui.SameLine()
					if imgui.Button(fa.ICON_TIMES_CIRCLE..u8" Отмена", imgui.ImVec2(162.5, 20)) then
						current_bind = nil
					end
				end
			imgui.EndChild()
			style.FrameRounding = 10
			if imgui.Button(fa.ICON_INFO, imgui.ImVec2(22, 22)) then
				variables_window_state.v = not variables_window_state.v
			end
			imgui.SameLine()
			if imgui.Button(fa.ICON_PLUS, imgui.ImVec2(22, 22)) then
				table.insert(BINDER, {hotkey = {}, description = "", command = "", content = "", menu = false, hint = false})
				current_bind = #BINDER
				text_buffer_binder_command.v = ""
				text_buffer_binder_content.v = ""
				text_buffer_binder_description.v = ""
				HotKeyBinder.v = {}
			end
			imgui.SameLine()
			if imgui.Button(fa.ICON_MINUS, imgui.ImVec2(22, 22)) then
				if current_bind then
					local bind = BINDER[current_bind]
					if mrkeys.isHotKeyDefined(bind.hotkey) then
						mrkeys.unRegisterHotKey(bind.hotkey)
					end
					if sampIsChatCommandDefined(tostring(bind.command)) then
						sampUnregisterChatCommand(tostring(bind.command))
					end
					table.remove(BINDER, current_bind)
					if current_bind > 1 then
						current_bind = current_bind - 1
						local bind = BINDER[current_bind]
						text_buffer_binder_command.v = bind.command
						text_buffer_binder_content.v = bind.content
						text_buffer_binder_description.v = bind.description
						HotKeyBinder.v = bind.hotkey
					else
						current_bind = nil
						text_buffer_binder_command.v = ""
						text_buffer_binder_content.v = ""
						text_buffer_binder_description.v = ""
						HotKeyBinder.v = {}
					end
				end
			end
			imgui.SameLine()
			if current_bind then
				local data = BINDER[current_bind]
				if data.menu then
					if imgui.Button(fa.ICON_BAN, imgui.ImVec2(22, 22)) then
						if current_bind then
							data.menu = not data.menu
						end
					end
				else
					if imgui.Button(fa.ICON_CHECK, imgui.ImVec2(22, 22)) then
						if current_bind then
						 	data.menu = not data.menu
						end
				 	end
				end
				imgui.SameLine()
				if data.hint then
					if imgui.Button(fa.ICON_EYE_SLASH, imgui.ImVec2(22, 22)) then
						if current_bind then
						 data.hint = not data.hint
					 end
				 end
				else
					if imgui.Button(fa.ICON_EYE, imgui.ImVec2(22, 22)) then
						if current_bind then
							data.hint = not data.hint
						end
					end
				end
			end
			style.FrameRounding = 3
			if variables_window_state.v then
				imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
				imgui.SetNextWindowSize(imgui.ImVec2(600, 500), imgui.Cond.FirstUseEver)
				imgui.Begin("Variables", nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
				imgui.BeginChild("##BUAH178AG", imgui.ImVec2(-1, -1), true)
				imgui.NewInputText("##806HA1789AGHJAZ", text_buffer_variables_search, 200, fa.ICON_SEARCH..u8" Поиск", 1)
				for var, text in pairs(HelpVariables()) do
					if #text_buffer_variables_search.v == 0 then
						imgui.HelpVariables(var, text)
					elseif var:find(text_buffer_variables_search.v:gsub("%p", "%%%1")) or u8(text):find(text_buffer_variables_search.v:gsub("%p", "%%%1")) then
						imgui.HelpVariables(var, text)
					end
				end
				imgui.EndChild()
				imgui.End()
			end
		elseif settings_mode == 3 then
			imgui.BeginChild("##DUG19890654z", imgui.ImVec2(-1, 280), true)
				for id, data in ipairs(HINT) do
					if imgui.Selectable(id..". "..data.name, current_hint == id, imgui.SelectableFlags.SpanAllColumns) then
						current_hint = id
					end
				end
			imgui.EndChild()
			if imgui.Button(fa.ICON_PENCIL_SQUARE_O..u8" Создать", imgui.ImVec2(180.5, 20)) then
				table.insert(HINT, {name = "", content = ""})
				current_hint = #HINT
				text_buffer_hint_name.v = ""
				text_buffer_hint_content.v = ""
				imgui.OpenPopup("Johnny Silverhand##Hint")
			end
			imgui.SameLine()
			if imgui.Button(fa.ICON_COG..u8" Изменить", imgui.ImVec2(180.5, 20)) then
				if current_hint then
					local data = HINT[current_hint]
					text_buffer_hint_name.v = data.name
					text_buffer_hint_content.v = data.content
					imgui.OpenPopup("Johnny Silverhand##Hint")
				end
			end
			imgui.SameLine()
			if imgui.Button(fa.ICON_TRASH..u8" Удалить", imgui.ImVec2(-1, 20)) then
					if current_hint then
						table.remove(HINT, current_hint)
						if current_hint > 1 then
							current_hint = current_hint - 1
						else
							current_hint = nil
						end
					end
				end
			end
			if imgui.BeginPopupModal(u8"Johnny Silverhand##Hint",_, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
				imgui.SetWindowSize(imgui.ImVec2(500, 360))
				imgui.BeginChild("##07869504456", imgui.ImVec2(-1, -1), false)
					imgui.BeginChild("##DSHFUGHSDFGSDF", imgui.ImVec2(-1, -1), false)
					imgui.SetCursorPosY(10)
					imgui.SetCursorPosX(10)
					imgui.NewInputText('##0768DFGH2FG', text_buffer_hint_name, 463, u8'Название', 1)
					imgui.SetCursorPosX(10)
					imgui.InputTextMultiline('##SDFGSDYFG78SDF', text_buffer_hint_content, imgui.ImVec2(463, 275))
					imgui.SetCursorPosX(10)
					if imgui.Button(fa.ICON_FLOPPY_O..u8" Сохранить", imgui.ImVec2(227.5, 20)) then
						local data = HINT[current_hint]
						data.name = text_buffer_hint_name.v
						data.content = text_buffer_hint_content.v
						imgui.CloseCurrentPopup()
					end
					imgui.SameLine()
					if imgui.Button(fa.ICON_TIMES_CIRCLE..u8" Закрыть", imgui.ImVec2(227.5, 20)) then
						imgui.CloseCurrentPopup()
					end
					imgui.EndChild()
				imgui.EndChild()
			imgui.EndPopup()
		elseif settings_mode == 4 then
			imgui.BeginChild("##AH06574F", imgui.ImVec2(-1, 280), true)
				for id, data in ipairs(WANTED) do
					if imgui.Selectable(id..". "..data.name, current_wanted == id, imgui.SelectableFlags.SpanAllColumns) then
						current_wanted = id
					end
					ShowHelpMarker("Правильность ввода:\n(Уровень розыска):(Причина)\n\nПример:\n6:Ограбление банка")
				end
			imgui.EndChild()
			if imgui.Button(fa.ICON_PENCIL_SQUARE_O..u8" Создать", imgui.ImVec2(180.5, 20)) then
				table.insert(WANTED, {name = "", content = ""})
				current_wanted = #WANTED
				text_buffer_wanted_name.v = ""
				text_buffer_wanted_content.v = ""
				imgui.OpenPopup("Johnny Silverhand##Wanted")
			end
			imgui.SameLine()
			if imgui.Button(fa.ICON_COG..u8" Изменить", imgui.ImVec2(180.5, 20)) then
				if current_wanted then
					local data = WANTED[current_wanted]
					text_buffer_wanted_name.v = data.name
					text_buffer_wanted_content.v = data.content
					imgui.OpenPopup("Johnny Silverhand##Wanted")
				end
			end
			imgui.SameLine()
			if imgui.Button(fa.ICON_TRASH..u8" Удалить", imgui.ImVec2(-1, 20)) then
					if current_wanted then
						table.remove(WANTED, current_wanted)
						if current_wanted > 1 then
							current_wanted = current_wanted - 1
						else
							current_wanted = nil
						end
					end
				end
			end

			if imgui.BeginPopupModal(u8"Johnny Silverhand##Wanted",_, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
				imgui.SetWindowSize(imgui.ImVec2(500, 360))
				imgui.BeginChild("##AV1UYTSADUYFADSF", imgui.ImVec2(-1, -1), false)
					imgui.BeginChild("##O1086AV1", imgui.ImVec2(-1, -1), false)
					imgui.SetCursorPosY(10)
					imgui.SetCursorPosX(10)
					imgui.NewInputText('##AJKY6087ASZ', text_buffer_wanted_name, 463, u8'Название', 1)
					imgui.SetCursorPosX(10)
					imgui.InputTextMultiline('##A5067987HS', text_buffer_wanted_content, imgui.ImVec2(463, 275))
					imgui.SetCursorPosX(10)
					if imgui.Button(fa.ICON_FLOPPY_O..u8" Сохранить", imgui.ImVec2(227.5, 20)) then
						local data = WANTED[current_wanted]
						data.name = text_buffer_wanted_name.v
						data.content = text_buffer_wanted_content.v
						imgui.CloseCurrentPopup()
					end
					imgui.SameLine()
					if imgui.Button(fa.ICON_TIMES_CIRCLE..u8" Закрыть", imgui.ImVec2(227.5, 20)) then
						imgui.CloseCurrentPopup()
					end
					imgui.EndChild()
				imgui.EndChild()
			imgui.EndPopup()
		elseif settings_mode == 5 then
			imgui.BeginChild("##NN189VAJI", imgui.ImVec2(-1, 280), true)
				for id, data in ipairs(TICKET) do
					if imgui.Selectable(id..". "..data.name, current_ticket == id, imgui.SelectableFlags.SpanAllColumns) then
						current_ticket = id
					end
				end
			imgui.EndChild()
			if imgui.Button(fa.ICON_PENCIL_SQUARE_O..u8" Создать", imgui.ImVec2(180.5, 20)) then
				table.insert(TICKET, {name = "", content = ""})
				current_ticket = #TICKET
				text_buffer_ticket_name.v = ""
				text_buffer_ticket_content.v = ""
				imgui.OpenPopup("Johnny Silverhand##Ticket")
			end
			imgui.SameLine()
			if imgui.Button(fa.ICON_COG..u8" Изменить", imgui.ImVec2(180.5, 20)) then
				if current_ticket then
					local data = TICKET[current_ticket]
					text_buffer_ticket_name.v = data.name
					text_buffer_ticket_content.v = data.content
					imgui.OpenPopup("Johnny Silverhand##Ticket")
				end
			end
			imgui.SameLine()
			if imgui.Button(fa.ICON_TRASH..u8" Удалить", imgui.ImVec2(-1, 20)) then
					if current_ticket then
						table.remove(TICKET, current_ticket)
						if current_ticket > 1 then
							current_ticket = current_ticket - 1
						else
							current_ticket = nil
						end
					end
				end
			end
			if imgui.BeginPopupModal(u8"Johnny Silverhand##Ticket",_, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar) then
				imgui.SetWindowSize(imgui.ImVec2(500, 360))
				imgui.BeginChild("##2065AC1231", imgui.ImVec2(-1, -1), false)
					imgui.BeginChild("##087BBBAN10760", imgui.ImVec2(-1, -1), false)
					imgui.SetCursorPosY(10)
					imgui.SetCursorPosX(10)
					imgui.NewInputText('##FF55107AC', text_buffer_ticket_name, 463, u8'Название', 1)
					imgui.SetCursorPosX(10)
					imgui.InputTextMultiline('##M288ACAZ', text_buffer_ticket_content, imgui.ImVec2(463, 275))
					imgui.SetCursorPosX(10)
					if imgui.Button(fa.ICON_FLOPPY_O..u8" Сохранить", imgui.ImVec2(227.5, 20)) then
						local data = TICKET[current_ticket]
						data.name = text_buffer_ticket_name.v
						data.content = text_buffer_ticket_content.v
						imgui.CloseCurrentPopup()
					end
					imgui.SameLine()
					if imgui.Button(fa.ICON_TIMES_CIRCLE..u8" Закрыть", imgui.ImVec2(227.5, 20)) then
						imgui.CloseCurrentPopup()
					end
					imgui.EndChild()
				imgui.EndChild()
			imgui.EndPopup()
		elseif settings_mode == 6 then
			imgui.BeginChild("##0456AHI190A", imgui.ImVec2(-1, 280), true)
				for id, data in ipairs(POST) do
					if imgui.Selectable(id..". "..data.name, current_post == id, imgui.SelectableFlags.SpanAllColumns) then
						current_post = id
						text_buffer_post_name.v = data.name
					end
				end
			imgui.EndChild()
			if imgui.Button(fa.ICON_PLUS, imgui.ImVec2(20, 20)) then
				local x, y = getCharCoordinates(PLAYER_PED)
				table.insert(POST, {name = text_buffer_post_name.v, x = x, y = y})
			end
			imgui.SameLine()
			imgui.NewInputText('##UHABU1046ABGBBA', text_buffer_post_name, 475, u8'Название поста', 1)
			imgui.SameLine(517)
			if imgui.Button(fa.ICON_SEARCH, imgui.ImVec2(20, 20)) then
				if current_post then
					local post = POST[current_post]
					setMarker(1, post.x, post.y)
					Notification("Метка установлена!",2)
				end
			end
			imgui.SameLine()
			if imgui.Button(fa.ICON_MINUS, imgui.ImVec2(20, 20)) then
				if current_post then
					table.remove(POST, current_post)
					if current_post > 1 then
						current_post = current_post - 1
						local post = POST[current_post]
						text_buffer_post_name.v = post.name
					else
						current_post = nil
						text_buffer_post_name.v = ""
					end
				end
			end
		elseif settings_mode == 7 then
			imgui.PushItemWidth(200)
			imgui.Combo('##WQXVUIYQIBA', combo_weapon_select, combo_weapon_str, #combo_weapon_str)
			imgui.PopItemWidth()
			if combo_weapon_select.v == 1 then
				imgui.SameLine()
				if imgui.HotKey("##IOUBA7618A", HotKeyWeapon, LastKeys, 90) then
					mrkeys.changeHotKey(bindWeapon, HotKeyWeapon.v)
				end
			end
			imgui.SetCursorPosY(40)
			imgui.Separator()
			imgui.SetCursorPosY(55)
			imgui.ToggleButton("##TG-W1", toggle_button_weapon_w1)
			imgui.SameLine()
			imgui.NewInputText('##INPUT-W1', text_buffer_weapon_w1, -1, u8'Дубинка', 1)
			imgui.ToggleButton("##TG-W2", toggle_button_weapon_w2)
			imgui.SameLine()
			imgui.NewInputText('##INPUT-W2', text_buffer_weapon_w2, -1, u8'Desert Eagle', 1)
			imgui.ToggleButton("###TG-W3", toggle_button_weapon_w3)
			imgui.SameLine()
			imgui.NewInputText('##INPUT-W3', text_buffer_weapon_w3, -1, u8'SP-Pistol', 1)
			imgui.ToggleButton("##TG-W4", toggle_button_weapon_w4)
			imgui.SameLine()
			imgui.NewInputText('##INPUT-W4', text_buffer_weapon_w4, -1, u8'M4A1', 1)
			imgui.ToggleButton("##TG-W5", toggle_button_weapon_w5)
			imgui.SameLine()
			imgui.NewInputText('##INPUT-W5', text_buffer_weapon_w5, -1, u8'AK47', 1)
			imgui.ToggleButton("##TG-W6", toggle_button_weapon_w6)
			imgui.SameLine()
			imgui.NewInputText('##INPUT-W6', text_buffer_weapon_w6, -1, u8'MP5', 1)
			imgui.ToggleButton("##TG-W7", toggle_button_weapon_w7)
			imgui.SameLine()
			imgui.NewInputText('##INPUT-W7', text_buffer_weapon_w7, -1, u8'Rifle', 1)
			imgui.ToggleButton("##TG-W8", toggle_button_weapon_w8)
			imgui.SameLine()
			imgui.NewInputText('##INPUT-W8', text_buffer_weapon_w8, -1, u8'Shotgun', 1)
		elseif settings_mode == 8 then
			if imgui.HotKey("##1I7YUYAGHZ", HotKeyMenu, LastKeys, 90) then
				mrkeys.changeHotKey(bindMenu, HotKeyMenu.v)
			end
			imgui.SameLine()
			imgui.Text(u8"Главное меню")
			if imgui.HotKey("##55511AHA1U", HotKeyHint, LastKeys, 90) then
				mrkeys.changeHotKey(bindHint, HotKeyHint.v)
			end
			imgui.SameLine()
			imgui.Text(u8"Меню подсказок")
			if imgui.HotKey("##ADHYUG2897298S", HotKeyFastMenu, LastKeys, 90) then
				mrkeys.changeHotKey(bindFastMenu, HotKeyFastMenu.v)
			end
			imgui.SameLine()
			imgui.Text(u8"Меню действий")
			if imgui.HotKey("##0468AHYUF17887A", HotKeyPatrol, LastKeys, 90) then
				mrkeys.changeHotKey(bindPatrol, HotKeyPatrol.v)
			end
			imgui.SameLine()
			imgui.Text(u8"Меню патруля")
			if imgui.HotKey("##AIUBYNAIA", HotKeyPursuitMod, LastKeys, 90) then
				mrkeys.changeHotKey(bindPursuitMod, HotKeyPursuitMod.v)
			end
			imgui.SameLine()
			imgui.Text(u8"Меню Pursuit Mod")
			if imgui.HotKey("##JBBANNA78AG", HotKeyBindHint, LastKeys, 90) then
				if HotKeyBindHint.v[2] then
					table.remove(HotKeyBindHint.v, 2)
				end
			end
			imgui.SameLine()
			imgui.Text(u8"Подсказка биндов") ShowHelpMarker("Работает только на одну клавишу")
			if imgui.HotKey("##BBA781ABJZ", HotKeyMarkOff, LastKeys, 90) then
				mrkeys.changeHotKey(bindMarkOff, HotKeyMarkOff.v)
			end
			imgui.SameLine()
			imgui.Text(u8"Убрать метку с радара")
		elseif settings_mode == 9 then
			if toggle_button_hud_block.v then
				if imgui.Button(fa.ICON_LOCK, imgui.ImVec2(20, 20)) then toggle_button_hud_block.v = not toggle_button_hud_block.v end
			else
				if imgui.Button(fa.ICON_UNLOCK_ALT, imgui.ImVec2(20, 20)) then toggle_button_hud_block.v = not toggle_button_hud_block.v end
			end
			imgui.SameLine()
			imgui.Text(u8"Включить оверлей")
			imgui.SameLine()
			imgui.ToggleButton("##HJDSFGSD465", toggle_button_hud)
			imgui.Separator()
			imgui.SetCursorPosY(40)
			imgui.Text(u8"Включить отображение вашего никнейма")
			imgui.SameLine(270)
			imgui.ToggleButton("##AHUG0152HGHVZ", toggle_button_hud_p1)
			imgui.Text(u8"Включить отображение никнейма цели")
			imgui.SameLine(270)
			imgui.ToggleButton("##JJIVAVZ066", toggle_button_hud_p2)
			imgui.Text(u8"Включить отображение здоровья и брони")
			imgui.SameLine(270)
			imgui.ToggleButton("##BY0019A", toggle_button_hud_p3)
			imgui.Text(u8"Включить отображение статуса сирены")
			imgui.SameLine(270)
			imgui.ToggleButton("##07897AHVA", toggle_button_hud_p4)
			imgui.Text(u8"Включить отображение названия района")
			imgui.SameLine(270)
			imgui.ToggleButton("##UIANJQK112", toggle_button_hud_p5)
			imgui.Text(u8"Включить отображение времени и даты")
			imgui.SameLine(270)
			imgui.ToggleButton("##8789044BB9832CZ", toggle_button_hud_p6)
			imgui.SetCursorPosY(180)
			imgui.Separator()
			imgui.SetCursorPosY(190)
			imgui.PushItemWidth(-1)
			imgui.TextCenter(u8"Прозрачность оверлея:")
			imgui.SliderInt('##JYAH787ZXC' , slider_buffer_hud, 0, 100)
			imgui.PopItemWidth()
		end
		imgui.EndChild()
		imgui.End()
	end

	if wanted_window_state.v then
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(600, 400), imgui.Cond.FirstUseEver)
		imgui.Begin("Wanted", nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove)
		imgui.NewInputText("##AY1UIYAIG", text_buffer_wanted_search, 200, fa.ICON_SEARCH..u8" Поиск", 1)
		imgui.SameLine(570)
		if imgui.Button(fa.ICON_TIMES, imgui.ImVec2(20, 20)) then wanted_window_state.v = not wanted_window_state.v end
		imgui.BeginChild("##HAUIVY80975A", imgui.ImVec2(-1, -1), true)
			if #text_buffer_wanted_search.v == 0 then
				for id, data in ipairs(WANTED) do
					if imgui.CollapsingHeader(data.name.."##"..id) then
						imgui.BeginChild("##A067654"..id, imgui.ImVec2(-1,-1),true)
							local btn_id = 0
							for line in data.content:gmatch("[^\r\n]+") do
								btn_id = btn_id + 1
								if line:find("(%d):(.+)") then
									local lvl, text = line:match("(%d):(.+)")
									if imgui.Button(text.."##"..btn_id, imgui.ImVec2(-1, 20)) then
										sampSendChat("su "..current_su_id.." "..lvl.." "..u8:decode(text))
									end
								end
							end
						imgui.EndChild()
					end
					if id ~= #WANTED then
						imgui.Separator()
					end
				end
			else
				for id, data in ipairs(WANTED) do
					imgui.BeginChild("##UAYBUIAYIA"..id, imgui.ImVec2(-1,-1),true)
					local btn_id = 0
						for line in data.content:gmatch("[^\r\n]+") do
							if line:find("(%d):(.+)") then
								local lvl, text = line:match("(%d):(.+)")
								if text:find(text_buffer_wanted_search.v:gsub("%p", "%%%1")) then
									btn_id = btn_id +1
									if imgui.Button(text.."##"..btn_id, imgui.ImVec2(-1, 20)) then
										sampSendChat("su "..current_su_id.." "..lvl.." "..u8:decode(text))
									end
								end
							end
						end
					imgui.EndChild()
				end
			end
		imgui.EndChild()
		imgui.End()
	end

	if ticket_window_state.v then
		local value = ""
		local player_score = sampGetPlayerScore(current_ticket_id)

		if player_score <= 2 then
			value = tostring(text_buffer_ticket_t1.v)
		elseif player_score <= 5 then
			value = tostring(text_buffer_ticket_t2.v)
		elseif player_score <= 15 then
 			value = tostring(text_buffer_ticket_t3.v)
		elseif player_score >= 16  then
			value = tostring(text_buffer_ticket_t4.v)
		else
			value = "0"
		end

		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(600, 400), imgui.Cond.FirstUseEver)
		imgui.Begin("Ticket", nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove)
		imgui.NewInputText("##078935AFA", text_buffer_ticket_search, 200, fa.ICON_SEARCH..u8" Поиск", 1)
		imgui.SameLine(570)
		if imgui.Button(fa.ICON_TIMES, imgui.ImVec2(20, 20)) then ticket_window_state.v = not ticket_window_state.v end
		imgui.BeginChild("##078650AGYTYAA", imgui.ImVec2(-1, -1), true)
			if #text_buffer_ticket_search.v == 0 then
				for id, data in ipairs(TICKET) do
					if imgui.CollapsingHeader(data.name.."##"..id) then
						imgui.BeginChild("##JTATUGBAJHGDA"..id, imgui.ImVec2(-1,-1),true)
							local btn_id = 0
							for line in data.content:gmatch("[^\r\n]+") do
								btn_id = btn_id + 1
								if imgui.Button(line.."##"..btn_id, imgui.ImVec2(-1, 20)) then
									sampSendChat("/ticket "..current_ticket_id.." "..value.." "..u8:decode(line))
								end
							end
						imgui.EndChild()
					end
					if id ~= #TICKET then
						imgui.Separator()
					end
				end
			else
				for id, data in ipairs(TICKET) do
					imgui.BeginChild("##YAYUGJHTAYDA065435"..id, imgui.ImVec2(-1,-1),true)
					local btn_id = 0
						for line in data.content:gmatch("[^\r\n]+") do
							if line:find(text_buffer_ticket_search.v:gsub("%p", "%%%1")) then
								btn_id = btn_id +1
								if imgui.Button(line.."##"..btn_id, imgui.ImVec2(-1, 20)) then
									sampSendChat("/ticket "..current_ticket_id.." "..value.." "..u8:decode(line))
								end
							end
						end
					imgui.EndChild()
				end
			end
		imgui.EndChild()
		imgui.End()
	end

	if pursuit_mod_window_state.v then
		imgui.SetNextWindowPos(imgui.ImVec2(Pos_Pursuit_Mod.x, Pos_Pursuit_Mod.y), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(300, 200), imgui.Cond.FirstUseEver)
		imgui.Begin("Pursuit Mod", nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
		Pos_Pursuit_Mod = imgui.GetWindowPos()
		imgui.BeginChild("##AUYDSFTAUSDTFGUYASDF", true, imgui.ImVec2(-1, -1))
		imgui.BeginChild("##12A289053A7556HSDF", false, imgui.ImVec2(-1, -1))
		if not current_id then
			imgui.SetCursorPosY(5)
			imgui.TextCenter(u8"Выбор цели:")
			imgui.Separator()
			for id = 0, sampGetMaxPlayerId(true) do
				local result, player_ped = sampGetCharHandleBySampPlayerId(id)
				if result then
					local _, player_id = sampGetPlayerIdByCharHandle(player_ped)
					local player_nick = sampGetPlayerNickname(player_id)
					if imgui.Selectable(" "..player_nick.." ("..player_id..")") then
						current_id = id
					end
				end
			end
		elseif pursuit_mod_off then
			imgui.SetCursorPosY(5)
			imgui.TextCenter(u8"Выбор сценария окончания погони:")
			imgui.Separator()
			imgui.Text("")
			if imgui.Selectable(u8" Прекратить преследование без доклада.") then
				current_id = nil
				pursuit_mod_off = nil
				PLAYER_SEARCH:terminate()
			end
			if imgui.Selectable(u8" Подозреваемый скрылся.") then
				current_id = nil
				pursuit_mod_off = nil
				PLAYER_SEARCH:terminate()
				sampProcessChatInput("/r Отбой по преследованию, подозреваемый скрылся.")
			end
			if imgui.Selectable(u8" Подозреваемый был задержан.") then
				current_id = nil
				pursuit_mod_off = nil
				PLAYER_SEARCH:terminate()
				sampProcessChatInput("/r Ситуация урегулирована по преследованию, подозреваемый был задержан.")
				Notification("Johnny Silverhand:\n\nЗаебись, пакуй его нахуй.",3)
			end
			if imgui.Selectable(u8" Подозреваемому был выписан штраф.") then
				current_id = nil
				pursuit_mod_off = nil
				PLAYER_SEARCH:terminate()
				sampProcessChatInput("/r Ситуация урегулирована, подозреваемому был выписан штраф.")
			end
			imgui.Text("")
			if imgui.Selectable(u8" Вернуться назад.") then
				pursuit_mod_off = nil
			end
		else
			local result, player_ped = sampGetCharHandleBySampPlayerId(current_id)
			if result then
				local player_id = current_id
				local player_nick = sampGetPlayerNickname(player_id)
				local player_skin = getCharModel(player_ped)
				local player_hp = sampGetPlayerHealth(player_id)
				local player_arm = sampGetPlayerArmor(player_id)
				local player_score = sampGetPlayerScore(player_id)
				local player_ping = sampGetPlayerPing(player_id)
				local player_gun = getCurrentCharWeapon(player_ped)
				local player_veh = "N/A"
				local player_veh_hp = "N/A"
				local player_veh_speed = "N/A"
				local player_afk = u8"Нет"
				if isCharInAnyCar(player_ped) then
					if storeCarCharIsInNoSave(player_ped) then
						local car = storeCarCharIsInNoSave(player_ped)
						if isCharInCar(player_ped) then
							player_veh = cars[tonumber(getCarModel(car))-399]
							player_veh_hp = getCarHealth(car)
							player_veh_speed = round(getCarSpeed(car))
						end
					end
				end
				if sampIsPlayerPaused(player_id) then
					player_afk = u8"Да"
				end
				imgui.SetCursorPosX(10)
				imgui.SetCursorPosY(10)
				imgui.Image(skins[tonumber(player_skin)], imgui.ImVec2(50, 50))
				imgui.PushFont(fontsize18)
				imgui.SetCursorPosX(70)
				imgui.SetCursorPosY(10)
				imgui.Text(player_nick.." ("..player_id..")")
				imgui.PopFont()
				imgui.PushFont(fontsize14)
				imgui.SetCursorPosX(70)
				imgui.SetCursorPosY(30)
				imgui.Text("HP: "..player_hp.."%")
				imgui.SetCursorPosX(70)
				imgui.SetCursorPosY(45)
				imgui.Text("ARMOUR: "..player_arm.."%")
				imgui.PopFont()
				imgui.SetCursorPosY(70)
				imgui.Separator()
				imgui.SetCursorPosY(80)
				imgui.Columns(2, "##SHDS123SAAASF", false)
				imgui.SetCursorPosX(5)
				imgui.Text(u8" Уровень: "..player_score)
				imgui.SetCursorPosX(5)
				imgui.Text(u8" Пинг: "..player_ping)
				imgui.SetCursorPosX(5)
				imgui.Text(u8" Оружие: "..player_gun)
				imgui.SetCursorPosX(5)
				imgui.Text(u8" AFK: "..player_afk)
				imgui.NextColumn()
				imgui.Text(u8"Расстояние: "..distanceBetweenPlayer(player_id)..u8" мс.")
				imgui.Text(u8"Марка авто: "..player_veh)
				imgui.Text(u8"Состояние: "..player_veh_hp)
				imgui.Text(u8"Скорость: "..player_veh_speed)
				imgui.SetCursorPosY(155)
				imgui.Separator()
				imgui.Columns(1, "##AUIHVYTAU", false)
				imgui.SetCursorPosX(5)
				style.FrameRounding = 100
				if imgui.Button(fa.ICON_CHECK, imgui.ImVec2(20, 20)) then
					sampSendChat("/ps "..player_id)
				end
				imgui.SameLine(60)
				if imgui.Button(fa.ICON_STAR, imgui.ImVec2(20, 20)) then
					sampSendChat("/su "..player_id.." 3 Ст. №25 [Уход]")
				end
				imgui.SameLine(imgui.GetWindowWidth() / 2 - 15)
				if imgui.Button(fa.ICON_SEARCH , imgui.ImVec2(20, 20)) then
					if PLAYER_SEARCH:status() == "suspended" or PLAYER_SEARCH:status() == "dead" then
						PLAYER_SEARCH:run()
						Notification("Вы активировали поиск подозреваемого!", 2)
					else
						PLAYER_SEARCH:terminate()
						Notification("Вы деактивировали поиск подозреваемого!", 2)
						print(PLAYER_SEARCH:status())
					end
				end
				imgui.SameLine(200)
				if imgui.Button(fa.ICON_BULLHORN, imgui.ImVec2(20, 20)) then
					if not player_veh:find("N/A") then
						lua_thread.create(function()
							Notification("Johnny Silverhand:\n\nСейчас прочистим слух этому ублюдку.", 3)
							sampSendChat('/m Автомобиль '..player_veh..' с номерами "SA-'..player_id..'"! Немедленно остановитесь!')
							wait(1000)
							sampSendChat("/m Прижмитесь к обочине и заглушите двигатель!")
						end)
					else
						Notification("Игрок находится не в автомобиле.", 2)
					end
				end
				imgui.SameLine(260)
				if imgui.Button(fa.ICON_BAN, imgui.ImVec2(20, 20)) then
					pursuit_mod_off = true
				end
				style.FrameRounding = 3
			else
				Notification("Johnny Silverhand:\n\nЁбаный в рот, скрылся уёбок!", 3)
				current_id = nil
			end
		end
		imgui.EndChild()
		imgui.EndChild()
		imgui.End()
	end

	if fastmenu_window_state.v then
		imgui.SetNextWindowPos(imgui.ImVec2(Pos_FastMenu.x, Pos_FastMenu.y), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(280, 270), imgui.Cond.FirstUseEver)
		imgui.Begin("Fast Menu", nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
			Pos_FastMenu = imgui.GetWindowPos()
			imgui.BeginChild("##60AF760A", imgui.ImVec2(-1, -1), true)
				for id, data in ipairs(BINDER) do
					if data.menu then
						if imgui.Button(data.description.."##"..id, imgui.ImVec2(-1, 20)) then
							if not sampIsDialogActive() and not sampIsChatInputActive() then
								onStartHotkey(data.content)
							end
						end
					end
				end
			imgui.EndChild()
		imgui.End()
	end

	if hint_window_state.v then
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(900, 600), imgui.Cond.FirstUseEver)
		imgui.Begin("Hint", nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove)
		imgui.BeginChild("##70798AV13A", imgui.ImVec2(200,-1), true)
		imgui.TextCenter(u8"Название подсказки:")
		imgui.SetCursorPosY(35)
		imgui.Separator()
		for id, data in ipairs(HINT) do
			if imgui.Selectable(data.name.."##"..id, current_hint_id == id, imgui.SelectableFlags.SpanAllColumns) then
				current_hint_id = id
			end
		end
		imgui.EndChild()
		imgui.SameLine()
		imgui.BeginChild("##0789AGYVUA67", imgui.ImVec2(-1,-1), true)
		imgui.NewInputText("##80789AJUIBAC", text_buffer_hint_search, 200, fa.ICON_SEARCH..u8" Поиск", 1)
		imgui.SameLine(644)
		if imgui.Button(fa.ICON_TIMES, imgui.ImVec2(20, 20)) then hint_window_state.v = not hint_window_state.v end
		imgui.SetCursorPosY(35)
		imgui.Separator()
		imgui.SetCursorPosY(45)
		imgui.BeginChild("##048658743", imgui.ImVec2(-1,-1), true)
		if current_hint_id then
			if #text_buffer_hint_search.v == 0 then
				local data = HINT[current_hint_id]
				for line in data.content:gmatch("[^\r\n]+") do
					imgui.TextColoredRGB(line)
				end
			else
				local data = HINT[current_hint_id]
				for line in data.content:gmatch("[^\r\n]+") do
					if line:find(text_buffer_hint_search.v:gsub("%p", "%%%1")) then
						imgui.TextColoredRGB(line)
					end
				end
			end
		end
		imgui.EndChild()
		imgui.EndChild()
		imgui.End()
	end

	if patrol_window_state.v then
		imgui.SetNextWindowPos(imgui.ImVec2(Pos_Patrol.x, Pos_Patrol.y), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(300, 200), imgui.Cond.FirstUseEver)
		imgui.Begin("Patrol", nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
			Pos_Patrol = imgui.GetWindowPos()
			imgui.BeginChild("##HGAHU123", true, imgui.ImVec2(-1, -1))
				imgui.BeginChild("##07465435ADS", false, imgui.ImVec2(-1, -1))
					imgui.SetCursorPosY(5)
					imgui.SetCursorPosX(5)
					imgui.PushItemWidth(274)
					imgui.Combo('##HGUHGA12310456A', combo_patrol_select, combo_patrol_str, #combo_patrol_str)
					imgui.PopItemWidth()
					imgui.Separator()
					imgui.SetCursorPosX(5)
					imgui.NewInputText("##AUHBAG5671NNJA01", text_buffer_patrol_mark, 150, u8"Ваша маркировка", 1)
					imgui.SameLine(160)
					imgui.NewInputText("##74087AHGVJA141", text_buffer_patrol_code, 50, u8"Код", 2)
					imgui.SameLine(215)
					imgui.NewInputText("##BHJAY7897BHJAVVV44", text_buffer_patrol_tencode, 64, u8"Тен-код", 2)
					imgui.SetCursorPosX(5)
					imgui.NewInputText("##GHBB177897ABBBCZ", text_buffer_patrol_n1, 87, u8"Напарник 1", 2)
					imgui.SameLine(97)
					imgui.NewInputText("##0758967GFAFVJ12", text_buffer_patrol_n2, 90, u8"Напарник 2", 2)
					imgui.SameLine(192)
					imgui.NewInputText("##04665BY178A", text_buffer_patrol_n3, 87, u8"Напарник 3", 2)
					imgui.Separator()
					imgui.SetCursorPosX(5)
					imgui.NewInputText("##HABHJ1786AC", text_buffer_patrol_mode1, 274, u8"Форма доклада с поста", 1)
					imgui.SetCursorPosX(5)
					imgui.NewInputText("##HABHJAGHJVA", text_buffer_patrol_mode2, 274, u8"Форма доклада с патруля", 1)
					imgui.Separator()
					imgui.SetCursorPosX(5)
					imgui.PushItemWidth(274)
					imgui.SliderInt('##078869AHGUA' , slider_buffer_patrol_wait, 0, 60)
					imgui.PopItemWidth()
					imgui.SetCursorPosX(5)
					if PATROL_REPORT:status() == "suspended" or PATROL_REPORT:status() == "dead" then
						if imgui.Button(fa.ICON_CHECK_CIRCLE..u8" Запустить", imgui.ImVec2(274,20)) then PATROL_REPORT:run() end
					else
						if imgui.Button(fa.ICON_TIMES_CIRCLE..u8" Остановить", imgui.ImVec2(274,20)) then PATROL_REPORT:terminate() end
					end
				imgui.EndChild()
			imgui.EndChild()
		imgui.End()
	end

	if hud_window_state.v then
		if not cursor_off then
			showCursor(false)
			imgui.ShowCursor = false
		 	cursor_off = true
		end

		local _, MyID = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local MyNick = sampGetPlayerNickname(MyID)
		local MyPing = sampGetPlayerPing(MyID)
		local Siren_Status = fa.ICON_TIMES_CIRCLE
		local Player_Name = u8"Неизвестно"
		if current_id then
			Player_Name = sampGetPlayerNickname(current_id).."("..current_id..")"
		end
		if isCharInAnyCar(PLAYER_PED) then
			if storeCarCharIsInNoSave(PLAYER_PED) then
				local car = storeCarCharIsInNoSave(PLAYER_PED)
				if isCharInCar(PLAYER_PED, car) then
					local car = storeCarCharIsInNoSave(PLAYER_PED)
					if isCarSirenOn(car) then
						Siren_Status = fa.ICON_CHECK_CIRCLE
					end
				end
			end
		end

		local size = 52
		local value = 18

		if toggle_button_hud_p1.v then size = size + value end
		if toggle_button_hud_p2.v then size = size + value end
		if toggle_button_hud_p3.v then size = size + value end
		if toggle_button_hud_p4.v then size = size + value end
		if toggle_button_hud_p5.v then size = size + value*2 end
		if toggle_button_hud_p6.v then size = size + value end

		imgui.SetNextWindowPos(imgui.ImVec2(Pos_Hud.x, Pos_Hud.y), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowSize(imgui.ImVec2(228, 70), imgui.Cond.FirstUseEver)
		colors[clr.WindowBg] = ImVec4(0.06, 0.53, 0.98, tonumber(slider_buffer_hud.v/100))

		local flags = imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar
		if toggle_button_hud_block.v then
			flags = imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove
		end

		imgui.Begin("Hud", nil, tonumber(flags))
		Pos_Hud = imgui.GetWindowPos()
		imgui.SetWindowSize(imgui.ImVec2(228, size))
		imgui.BeginChild("##HUIAHY9076", imgui.ImVec2(-1, -1), true)
		imgui.PushFont(cyberpunk)
		imgui.SetCursorPosY(-2)
		imgui.TextCenterRGB("{FFD700}Johnny Silverhand")
		imgui.PopFont()
		imgui.Separator()
		if not toggle_button_hud_p5.v and not toggle_button_hud_p6.v then
			imgui.SetCursorPosY(31)
		elseif not toggle_button_hud_p5.v then
			imgui.SetCursorPosY(29)
		elseif not toggle_button_hud_p6.v then
			imgui.SetCursorPosY(30)
		end
		if toggle_button_hud_p1.v then imgui.TextCenter(fa.ICON_USER_CIRCLE.." "..MyNick.."("..MyID..")") end
		if toggle_button_hud_p2.v then imgui.TextCenter(fa.ICON_USER_SECRET..u8" Игрок: "..Player_Name) end
		if toggle_button_hud_p3.v then imgui.TextCenter(fa.ICON_HEART..u8" Здоровье: "..getCharHealth(PLAYER_PED)..u8" | Броня: "..getCharArmour(PLAYER_PED)) end
		if toggle_button_hud_p4.v then imgui.TextCenter(fa.ICON_BULLHORN..u8" Статус сирены: "..Siren_Status) end
		if toggle_button_hud_p5.v then
			imgui.Separator()
			imgui.TextCenter(fa.ICON_MAP..u8" Район: "..u8(calculateZone()))
			imgui.TextCenter(fa.ICON_BANDCAMP..u8" Квадрат: "..u8(kvadrat()))
		end
		if toggle_button_hud_p6.v then
			imgui.Separator()
			imgui.TextCenterRGB(os.date("{C0C0C0}%d.%m.%Y %H:%M:%S", os.time()))
		end
		imgui.SetWindowSize(imgui.ImVec2(228, size))
		imgui.EndChild()
		imgui.End()
		colors[clr.WindowBg] = ImVec4(0.06, 0.53, 0.98, 0.70)
	end
end

-- Events

function sampev.onSendChat(message)
	if message == ')' or message == '(' or message ==  '))' or message == '((' then return{message} end

	if toggle_button_accent.v then
		return{'['..u8:decode(text_buffer_accent.v)..']: '..message}
	else
		return{message}
	end
end

function sampev.onShowDialog(id, style, title, button1, button2, text)
	if toggle_button_autogun.v then
		if title:find("Склад оружия") then
			if getAmmoInCharWeapon(PLAYER_PED, 24) <= 21 then
				sampSendDialogResponse(id, 1, 0, "")
			elseif getAmmoInCharWeapon(PLAYER_PED, 25) <= 30 then
				sampSendDialogResponse(id, 1, 1, "")
			elseif getAmmoInCharWeapon(PLAYER_PED, 29) <= 90 then
				sampSendDialogResponse(id, 1, 2, "")
			elseif getAmmoInCharWeapon(PLAYER_PED, 31) <= 150 then
				sampSendDialogResponse(id, 1, 3, "")
			elseif getAmmoInCharWeapon(PLAYER_PED, 33) <= 30 then
				sampSendDialogResponse(id, 1, 4, "")
			elseif getCharArmour(PLAYER_PED) < 99 then
				sampSendDialogResponse(id, 1, 5, "")
			elseif getAmmoInCharWeapon(PLAYER_PED, 3) < 1 then
				sampSendDialogResponse(id, 1, 6, "")
			end
			return false
		end
	end
end

function sampev.onSendTakeDamage(playerId)
	HitMe_ID = tostring(playerId)
end

function sampev.onSendGiveDamage(playerId)
	HitByMe_ID = tostring(playerId)
end

function sampev.onSendEnterVehicle(vid, mid)
	if getCharArmour(PLAYER_PED) == 0 then
		Notification("Johnny Silverhand:\n\nКуда блять без бронежилета?!", 3)
	end
end

function sampev.onSendDeathNotification()
	Notification("Johnny Silverhand:\n\nЕбать ты нулина..", 3)
end

function onScriptTerminate(script, quitGame)
  if thisScript() == script then
		if toggle_button_save.v then
			SaveSettings()
		end
  end
end

-- Thread

WELCOME_UPDATE = lua_thread.create_suspended(function()
	Imgui_Welcome_Mode = 5
	welcome_window_state.v = false
	wait(1000)
	WelcomeNotification("Johnny Silverhand:\n\nОтлично, встретимся после перезагрузки.\nЯ чуть изменил активацию, теперь чтобы открыть главное меню, используй:\n/johnny", 3)
	wait(6000)
	Notification("Сбой глобальных настроек!",2)
	wait(3000)
	Notification("Незапланированная перезагрузка системы!",2)
	wait(5000)
	Notification("3",2)
	wait(1000)
	Notification("2",2)
	wait(1000)
	Notification("1",2)
	wait(1000)
	Notification("Перезагрузка..",2)
	wait(4000)
	mainIni.Welcome.status = true
	inicfg.save(mainIni, directIni)
	thisScript():reload()
end)

WELCOME_LOADING = lua_thread.create_suspended(function()
	while Welcome_Loading < 100 do wait(1600)
		local value = math.random(1, 9)
		local loading = Welcome_Loading + value
		if loading >= 100 then
			Welcome_Loading = 100
		else
			Welcome_Loading = loading
		end
	end
	Imgui_Welcome_Mode = 3
	WelcomeNotification("Ошибка: обнаружено вредоносное ПО!", 3)
	setAudioStreamState(playsound_1, 1)
	apply_welcome_red_style()
	wait(7000)
	WelcomeNotification("<?/@^2t&%'%1*#-*>", 3)
	wait(8000)
	WelcomeNotification("Johnny Silverhand:\n\nНу здарова ебать.", 3)
	wait(7000)
	WelcomeNotification("Johnny Silverhand:\n\nСтоп блять, ты что - коп?\nПиздец..", 3)
	wait(10000)
	WelcomeNotification("Johnny Silverhand:\n\nЛучше бы я попал в тело бомжа, чем быть в обосранной сука форме.", 3)
	wait(10000)
	WelcomeNotification("Johnny Silverhand:\n\nЛадно, пелёнки при родах не выбирают..", 3)
	wait(10000)
	WelcomeNotification("Johnny Silverhand:\n\nСекунду, проверю что у тебя там с интерфейсом системы.", 3)
	wait(15000)
	WelcomeNotification("Johnny Silverhand:\n\nЁбанный ад блять, ты как сука с этим жил?!", 3)
	wait(5000)
	WelcomeNotification("Johnny Silverhand:\n\nПринимай, пока я добрый.", 3)
	wait(3000)
	Imgui_Welcome_Mode = 4
end)

RECONNECT = lua_thread.create_suspended(function()
	if tonumber(Rec_Time) then
		Notification("Переподключение к серверу..", 2)
		sampDisconnectWithReason(1)
		wait(Rec_Time*1000)
		sampSetGamestate(1)
	else
		Notification("Используйте: /rec (сек.)", 2)
	end
end)

PLAYER_SEARCH = lua_thread.create_suspended(function()
	while true do
		local result, player_ped = sampGetCharHandleBySampPlayerId(current_id)
		if result then
			local x, y = getCharCoordinates(player_ped)
			setMarker(1,x,y)
		else
			return
		end
		wait(1000)
	end
end)

PATROL_REPORT = lua_thread.create_suspended(function()
	while true do
		local text = ""
		if combo_patrol_select.v == 0 then
			text = u8:decode(text_buffer_patrol_mode1.v)
		elseif combo_patrol_select.v == 1 then
			text = u8:decode(text_buffer_patrol_mode2.v)
		end
		local Variables = Variables()
		for k, v in pairs(Variables) do
			text = text:gsub(k, v)
		end
		if combo_patrol_select.v == 0 then
			sampProcessChatInput("/r "..text)
		elseif combo_patrol_select.v == 1 then
			sampProcessChatInput("/r "..text)
		end
		wait(tonumber(slider_buffer_patrol_wait.v)*60*1000)
	end
end)

-- Function

function onStartHotkey(content)
  local content = u8:decode(content)
	thread_binder:terminate()
	thread_binder = lua_thread.create(function()
	local Variables = Variables()
		if #content > 0 then
	    for line in content:gmatch("[^\r\n]+") do
	      if line:len() > 0 then
					if line:find("^%<%d+%>$") then
						local sleep = line:match("^%<(%d+)%>$")
						wait(tonumber(sleep))
					elseif line:find("^%@(.+)") then
						local line = line:match("^%@(.+)")
						for k, v in pairs(Variables) do
							line = line:gsub(k, v)
						end
						sampAddChatMessage(line, -1)
					elseif line:find("^%!(.+)") then
						local line = line:match("^%!(.+)")
						for k, v in pairs(Variables) do
							line = line:gsub(k, v)
						end
						sampProcessChatInput(line)
					elseif line:find("^%#(.+)") then
						local line = line:match("^%#(.+)")
						sampSetChatInputEnabled(true)
						for k, v in pairs(Variables) do
							line = line:gsub(k, v)
						end
						sampSetChatInputText(line)
					else
						for k, v in pairs(Variables) do
							line = line:gsub(k, v)
						end
	          sampSendChat(line)
					end
	      end
	    end
		else
			return
		end
	end)
end

function Variables()
	local _, MyID = sampGetPlayerIdByCharHandle(PLAYER_PED)
	local player_id = nil
	local player_id = ""
	local player_nick =""
	local player_score = ""
	local player_ping = ""
	local player_rpnick = string.gsub(sampGetPlayerNickname(current_id), "_", " ")
	local member1 = ""
	local member2 = ""
	local member3 = ""
	local post = ""
	local member1_nick = sampGetPlayerNickname(u8:decode(text_buffer_patrol_n1.v))
	local member2_nick = sampGetPlayerNickname(u8:decode(text_buffer_patrol_n2.v))
	local member3_nick = sampGetPlayerNickname(u8:decode(text_buffer_patrol_n3.v))

	if current_id then
	 	player_id = current_id
		player_nick = sampGetPlayerNickname(current_id)
		player_score = sampGetPlayerScore(current_id)
		player_ping = sampGetPlayerPing(current_id)
		player_rpnick = string.gsub(sampGetPlayerNickname(current_id), "_", " ")
	else
		player_id = ""
		player_nick = ""
		player_score = ""
		player_ping = ""
		player_rpnick =  ""
	 end

	 if member1_nick:find("(%a).+_(.+)") then
		 	local n1, n2 = member1_nick:match("(%a).+_(.+)")
			member1 = n1..". "..n2
	 end

	 if member2_nick:find("(%a).+_(.+)") then
			local n1, n2 = member1_nick:match("(%a).+_(.+)")
			member2 = n1..". "..n2
	 end

	 if member3_nick:find("(%a).+_(.+)") then
			local n1, n2 = member1_nick:match("(%a).+_(.+)")
			member3 = n1..". "..n2
	 end

	 for id, data in ipairs(POST) do
		 local mx, my = getCharCoordinates(PLAYER_PED)
		 if getDistanceBetweenCoords2d(mx, my, data.x, data.y) < 100 then
			 post = u8:decode(data.name)
			 break
		 end
	 end

	local Variables = {
		["{myid}"] = tostring(MyID),
		["{mynick}"] = tostring(sampGetPlayerNickname(MyID)),
		["{myrpnick}"] = tostring(string.gsub(sampGetPlayerNickname(MyID), "_", " ")),
		["{myping}"] = sampGetPlayerPing(MyID),
		["{myscore}"] = tostring(sampGetPlayerScore(MyID)),
		["{myname}"] = tostring(u8:decode(text_buffer_name.v)),
		["{myfirstname}"] = tostring(u8:decode(text_buffer_firstname.v)),
		["{mysurname}"] = tostring(u8:decode(text_buffer_surname.v)),
		["{myorganization}"] = tostring(u8:decode(text_buffer_organization.v)),
		["{myphone}"] = tostring(u8:decode(text_buffer_phone.v)),
		["{myrank}"] = tostring(u8:decode(text_buffer_rank.v)),
		["{select_id}"] = tostring(player_id),
		["{select_nick}"] = tostring(player_nick),
		["{select_score}"] = tostring(player_score),
		["{select_ping}"] = tostring(player_ping),
		["{select_rpnick}"] = tostring(player_rpnick),
		["{area}"] = tostring(calculateZone()),
		["{mygun_name}"] = tostring(GunInfo()),
		["{mygun_id}"] = tostring(getCurrentCharWeapon(PLAYER_PED)),
		["{myveh_name}"] = tostring(VehInfoName()),
		["{myveh_id}"] = tostring(VehInfoID()),
		["{h}"] = tostring(os.date("%H", os.time())),
		["{m}"] = tostring(os.date("%M", os.time())),
		["{s}"] = tostring(os.date("%S", os.time())),
		["{date}"] = tostring(os.date("%d.%m.%Y ", os.time())),
		["{dmg_me_id}"] = tostring(HitMe_ID),
		["{dmg_id}"] = tostring(HitByMe_ID),
		["{closest_veh_id}"] = tostring(getClosestCarId()),
		["{closest_veh_name}"] = tostring(getClosestCarName()),
		["{mark}"] = tostring(u8:decode(text_buffer_patrol_mark.v)),
		["{code}"] = tostring(u8:decode(text_buffer_patrol_code.v)),
		["{tencode}"] = tostring(u8:decode(text_buffer_patrol_tencode.v)),
		["{member1}"] = tostring(member1),
		["{member2}"] = tostring(member2),
		["{member3}"] = tostring(member3),
		["{post}"] = tostring(post)
	}
	return Variables
end

function HelpVariables()
	local Variables = {
		["{myid}"] = "Возвращает ваш текущий id.",
		["{mynick}"] = "Возвращает ваш текущик ник.",
		["{myrpnick}"] = "Возвращает ваш текущий рп-ник.",
		["{myping}"] = "Возвращает ваш текущий пинг.",
		["{myscore}"] = "Возвращает ваш текущий уровень.",
		["{myname}"] = "Возвращает вашу кличку.",
		["{myfirstname}"] = "Возвращает ваше имя.",
		["{mysurname}"] = "Возвращает вашу фамилию.",
		["{myorganization}"] = "Возвращает вашу организацию.",
		["{myphone}"] = "Возвращает ваш номер телефона.",
		["{myrank}"] = "Возвращает вашу должность.",
		["{select_id}"] = "Возвращает id вашей цели.",
		["{select_nick}"] = "Возвращает ник вашей цели.",
		["{select_score}"] = "Возвращает уровень вашей цели.",
		["{select_ping}"] = "Возвращает пинг вашей цели.",
		["{select_rpnick}"] = "Возвращает рп-ник вашей цели.",
		["{area}"] = "Возвращает ваш текущий район.",
		["{mygun_name}"] = "Возвращает название текущего оружия.",
		["{mygun_id}"] = "Возвращает id текущего оружия.",
		["{myveh_name}"] = "Возвращает название текущего транспорта.",
		["{myveh_id}"] = "Возвращает id текущего транспорта.",
		["{h}"] = "Возвращает текущий час.",
		["{m}"] = "Возвращает текущие минуты.",
		["{s}"] = "Возвращает текущие секунды.",
		["{date}"] = "Возвращает текущую дату.",
		["{dmg_me_id}"] = "Возвращает id того кто стрелял по вам.",
		["{dmg_id}"] = "Возвращает id того по которому вы стреляли.",
		["{closest_veh_id}"] = "Возвращает id ближайшего транспорта.",
		["{closest_veh_name}"] = "Возвращает название ближайшего транспорта.",
		["{mark}"] = "Возвращает вашу маркировку.",
		["{code}"] = "Возвращает ваш код ситуации.",
		["{tencode}"] = "Возвращает ваш тен-код.",
		["{member1}"] = "Возвращает сокращенный ник вашего напарника №1.",
		["{member2}"] = "Возвращает сокращенный ник вашего напарника №2.",
		["{member3}"] = "Возвращает сокращенный ник вашего напарника №3.",
		["{post}"] = "Возвращает ваш текущий пост.",
	}
	return Variables
end

function setMarker(type,x,y,z)
    bs = raknetNewBitStream()
    raknetBitStreamWriteInt8(bs, type)
    raknetBitStreamWriteFloat(bs, x)
    raknetBitStreamWriteFloat(bs, y)
    raknetBitStreamWriteFloat(bs, z)
    raknetBitStreamWriteFloat(bs, 0)
    raknetBitStreamWriteFloat(bs, 0)
    raknetBitStreamWriteFloat(bs, 0)
    raknetBitStreamWriteFloat(bs, 6)
    raknetEmulRpcReceiveBitStream(38, bs)
    raknetDeleteBitStream(bs)
end

function round(number)
  if (number - (number % 0.1)) - (number - (number % 1)) < 0.5 then
    number = number - (number % 1)
  else
    number = (number - (number % 1)) + 1
  end
 return number
end

function RPGun(gun)
	if gun ~= LastWeapon then
		if gun == 3 and toggle_button_weapon_w1.v then
			sampSendChat(tostring(u8:decode(text_buffer_weapon_w1.v)))
		elseif gun == 24 and toggle_button_weapon_w2.v then
			sampSendChat(tostring(u8:decode(text_buffer_weapon_w2.v)))
		elseif gun == 23 and toggle_button_weapon_w3.v then
			sampSendChat(tostring(u8:decode(text_buffer_weapon_w3.v)))
		elseif gun == 31 and toggle_button_weapon_w4.v then
			sampSendChat(tostring(u8:decode(text_buffer_weapon_w4.v)))
		elseif gun == 30 and toggle_button_weapon_w5.v then
			sampSendChat(tostring(u8:decode(text_buffer_weapon_w5.v)))
		elseif gun == 29 and toggle_button_weapon_w6.v then
			sampSendChat(tostring(u8:decode(text_buffer_weapon_w6.v)))
		elseif gun == 33 and toggle_button_weapon_w7.v then
			sampSendChat(tostring(u8:decode(text_buffer_weapon_w7.v)))
		elseif gun == 25 and toggle_button_weapon_w8.v then
			sampSendChat(tostring(u8:decode(text_buffer_weapon_w8.v)))
		end
		LastWeapon = gun
	end
end

function Notification(text, style)
	push.addNotification(tostring(text), 4, style)
end

function WelcomeNotification(text, style)
	push.addNotification(tostring(text), 8, style)
end

function getClosestCarId()
    local minDist = 9999
    local closestId = -1
    local x, y, z = getCharCoordinates(PLAYER_PED)
    for i, k in ipairs(getAllVehicles()) do
       local xi, yi, zi = getCarCoordinates(k)
       local dist = math.sqrt( (xi - x) ^ 2 + (yi - y) ^ 2 + (zi - z) ^ 2 )
       if dist < minDist then
          minDist = dist
          closestId = getCarModel(k)
       end
    end
    return closestId
end

function getClosestCarName()
  local minDist = 9999
  local closestName = -1
  local x, y, z = getCharCoordinates(PLAYER_PED)
  for i, k in ipairs(getAllVehicles()) do
     local xi, yi, zi = getCarCoordinates(k)
     local dist = math.sqrt( (xi - x) ^ 2 + (yi - y) ^ 2 + (zi - z) ^ 2 )
     if dist < minDist then
        minDist = dist
        closestName = cars[tonumber(getCarModel(k)) - 399]
     end
  end
  return closestName
end

function GunInfo()
	local currentWeapon = getCurrentCharWeapon(PLAYER_PED)
	if currentWeapon == 0 then
	MyGun_Name = ""
	elseif (currentWeapon == 1) then
	MyGun_Name = "Кастет"
	elseif (currentWeapon == 2) then
	MyGun_Name = "Клюшка"
	elseif (currentWeapon == 3) then
	MyGun_Name = "Дубинка"
	elseif (currentWeapon == 4) then
	MyGun_Name = "Нож"
	elseif (currentWeapon == 5) then
	MyGun_Name = "Бита"
	elseif (currentWeapon == 6) then
	MyGun_Name = "Лопата"
	elseif (currentWeapon == 7) then
	MyGun_Name = "Кия"
	elseif (currentWeapon == 8) then
	MyGun_Name = "Катана"
	elseif (currentWeapon == 9) then
	MyGun_Name = "Бензопила"
	elseif (currentWeapon == 10) then
	MyGun_Name = "Двухсторонний дилдо"
	elseif (currentWeapon == 11) then
	MyGun_Name = "Дилдо"
	elseif (currentWeapon == 12) then
	MyGun_Name = "Вибратор"
	elseif (currentWeapon == 13) then
	MyGun_Name = "Серебряный вибратор"
	elseif (currentWeapon == 14) then
	MyGun_Name = "Букет цветов"
	elseif (currentWeapon == 15) then
	MyGun_Name = "Трость"
	elseif (currentWeapon == 16) then
	MyGun_Name = "Граната"
	elseif (currentWeapon == 17) then
	MyGun_Name = "Слезоточивый газ"
	elseif (currentWeapon == 18) then
	MyGun_Name = "Коктейль Молотова"
	elseif (currentWeapon == 22) then
	MyGun_Name = "Pistol"
	elseif (currentWeapon == 23) then
	MyGun_Name = "SDPistol"
	elseif (currentWeapon == 24) then
	MyGun_Name = "Desert Eagle"
	elseif (currentWeapon == 25) then
	MyGun_Name = "Shotgun"
	elseif (currentWeapon == 26) then
	MyGun_Name = "Sawn-off shotgun"
	elseif (currentWeapon == 27) then
	MyGun_Name = "Combat shotgun"
	elseif (currentWeapon == 28) then
	MyGun_Name = "Micro Uzi"
	elseif (currentWeapon == 29) then
	MyGun_Name = "MP5"
	elseif (currentWeapon == 30) then
	MyGun_Name = "AK47"
	elseif (currentWeapon == 31) then
	MyGun_Name = 'M4A1'
	elseif (currentWeapon == 32) then
	MyGun_Name = 'Tec-9'
	elseif (currentWeapon == 33) then
	MyGun_Name = 'Rifle'
	elseif (currentWeapon == 34) then
	MyGun_Name = "Sniper rifle"
	elseif (currentWeapon == 42) then
	MyGun_Name = 'Огнетушитель'
	elseif (currentWeapon == 43) then
	MyGun_Name = 'Фотоаппарат'
	elseif (currentWeapon == 44) then
	MyGun_Name = 'Прибор ночного видения'
	elseif (currentWeapon == 45) then
	MyGun_Name = 'Тепловизор'
	elseif (currentWeapon == 46) then
	MyGun_Name = 'Парашют'
	elseif (currentWeapon == 41) then
	MyGun_Name = 'Баллончик с краской'
	elseif (currentWeapon == 35) then
	MyGun_Name = 'РПГ'
	elseif (currentWeapon == 36) then
	MyGun_Name = 'Базука'
	elseif (currentWeapon == 37) then
	MyGun_Name = 'Огнемет'
	elseif (currentWeapon == 38) then
	MyGun_Name = 'Миниган'
	elseif (currentWeapon == 39) then
	MyGun_Name = 'Сумка с тротилом'
	elseif (currentWeapon == 40) then
	MyGun_Name = 'Детонатор к сумке'
	elseif (currentWeapon == 41) then
	MyGun_Name = 'Баллончик с краской'
	end
	return MyGun_Name
end

function direction()
    if sampIsLocalPlayerSpawned() then
        local angel = math.ceil(getCharHeading(PLAYER_PED))
        if angel then
            if (angel >= 0 and angel <= 30) or (angel <= 360 and angel >= 330) then
                return "Север"
            elseif (angel > 80 and angel < 100) then
                    return "Запад"
            elseif (angel > 260 and angel < 280) then
                    return "Восток"
            elseif (angel >= 170 and angel <= 190) then
                    return "Юг"
            elseif (angel >= 31 and angel <= 79) then
                    return "Северо-запад"
            elseif (angel >= 191 and angel <= 259) then
                    return "Юго-восток"
            elseif (angel >= 81 and angel <= 169) then
                    return "Юго-запад"
            elseif (angel >= 259 and angel <= 329) then
                    return "Северо-восток"
            else
                return angel
            end
        else
            return "Неизвестно"
        end
    else
        return "Неизвестно"
    end
end

function kvadrat()
    local KV = {
        [1] = "А",
        [2] = "Б",
        [3] = "В",
        [4] = "Г",
        [5] = "Д",
        [6] = "Ж",
        [7] = "З",
        [8] = "И",
        [9] = "К",
        [10] = "Л",
        [11] = "М",
        [12] = "Н",
        [13] = "О",
        [14] = "П",
        [15] = "Р",
        [16] = "С",
        [17] = "Т",
        [18] = "У",
        [19] = "Ф",
        [20] = "Х",
        [21] = "Ц",
        [22] = "Ч",
        [23] = "Ш",
        [24] = "Я",
    }
    local X, Y, Z = getCharCoordinates(playerPed)
    X = math.ceil((X + 3000) / 250)
    Y = math.ceil((Y * - 1 + 3000) / 250)
    Y = KV[Y]
    local KVX = (Y.."-"..X)
    return KVX
end

function calculateZone()
		local positionX, positionY, positionZ = getCharCoordinates(PLAYER_PED)
    local streets = {{"Avispa Country Club", -2667.810, -302.135, -28.831, -2646.400, -262.320, 71.169},
    {"Easter Bay Airport", -1315.420, -405.388, 15.406, -1264.400, -209.543, 25.406},
    {"Avispa Country Club", -2550.040, -355.493, 0.000, -2470.040, -318.493, 39.700},
    {"Easter Bay Airport", -1490.330, -209.543, 15.406, -1264.400, -148.388, 25.406},
    {"Garcia", -2395.140, -222.589, -5.3, -2354.090, -204.792, 200.000},
    {"Shady Cabin", -1632.830, -2263.440, -3.0, -1601.330, -2231.790, 200.000},
    {"East Los Santos", 2381.680, -1494.030, -89.084, 2421.030, -1454.350, 110.916},
    {"LVA Freight Depot", 1236.630, 1163.410, -89.084, 1277.050, 1203.280, 110.916},
    {"Blackfield Intersection", 1277.050, 1044.690, -89.084, 1315.350, 1087.630, 110.916},
    {"Avispa Country Club", -2470.040, -355.493, 0.000, -2270.040, -318.493, 46.100},
    {"Temple", 1252.330, -926.999, -89.084, 1357.000, -910.170, 110.916},
    {"Unity Station", 1692.620, -1971.800, -20.492, 1812.620, -1932.800, 79.508},
    {"LVA Freight Depot", 1315.350, 1044.690, -89.084, 1375.600, 1087.630, 110.916},
    {"Los Flores", 2581.730, -1454.350, -89.084, 2632.830, -1393.420, 110.916},
    {"Starfish Casino", 2437.390, 1858.100, -39.084, 2495.090, 1970.850, 60.916},
    {"Easter Bay Chemicals", -1132.820, -787.391, 0.000, -956.476, -768.027, 200.000},
    {"Downtown Los Santos", 1370.850, -1170.870, -89.084, 1463.900, -1130.850, 110.916},
    {"Esplanade East", -1620.300, 1176.520, -4.5, -1580.010, 1274.260, 200.000},
    {"Market Station", 787.461, -1410.930, -34.126, 866.009, -1310.210, 65.874},
    {"Linden Station", 2811.250, 1229.590, -39.594, 2861.250, 1407.590, 60.406},
    {"Montgomery Intersection", 1582.440, 347.457, 0.000, 1664.620, 401.750, 200.000},
    {"Frederick Bridge", 2759.250, 296.501, 0.000, 2774.250, 594.757, 200.000},
    {"Yellow Bell Station", 1377.480, 2600.430, -21.926, 1492.450, 2687.360, 78.074},
    {"Downtown Los Santos", 1507.510, -1385.210, 110.916, 1582.550, -1325.310, 335.916},
    {"Jefferson", 2185.330, -1210.740, -89.084, 2281.450, -1154.590, 110.916},
    {"Mulholland", 1318.130, -910.170, -89.084, 1357.000, -768.027, 110.916},
    {"Avispa Country Club", -2361.510, -417.199, 0.000, -2270.040, -355.493, 200.000},
    {"Jefferson", 1996.910, -1449.670, -89.084, 2056.860, -1350.720, 110.916},
    {"Julius Thruway West", 1236.630, 2142.860, -89.084, 1297.470, 2243.230, 110.916},
    {"Jefferson", 2124.660, -1494.030, -89.084, 2266.210, -1449.670, 110.916},
    {"Julius Thruway North", 1848.400, 2478.490, -89.084, 1938.800, 2553.490, 110.916},
    {"Rodeo", 422.680, -1570.200, -89.084, 466.223, -1406.050, 110.916},
    {"Cranberry Station", -2007.830, 56.306, 0.000, -1922.000, 224.782, 100.000},
    {"Downtown Los Santos", 1391.050, -1026.330, -89.084, 1463.900, -926.999, 110.916},
    {"Redsands West", 1704.590, 2243.230, -89.084, 1777.390, 2342.830, 110.916},
    {"Little Mexico", 1758.900, -1722.260, -89.084, 1812.620, -1577.590, 110.916},
    {"Blackfield Intersection", 1375.600, 823.228, -89.084, 1457.390, 919.447, 110.916},
    {"Los Santos International", 1974.630, -2394.330, -39.084, 2089.000, -2256.590, 60.916},
    {"Beacon Hill", -399.633, -1075.520, -1.489, -319.033, -977.516, 198.511},
    {"Rodeo", 334.503, -1501.950, -89.084, 422.680, -1406.050, 110.916},
    {"Richman", 225.165, -1369.620, -89.084, 334.503, -1292.070, 110.916},
    {"Downtown Los Santos", 1724.760, -1250.900, -89.084, 1812.620, -1150.870, 110.916},
    {"The Strip", 2027.400, 1703.230, -89.084, 2137.400, 1783.230, 110.916},
    {"Downtown Los Santos", 1378.330, -1130.850, -89.084, 1463.900, -1026.330, 110.916},
    {"Blackfield Intersection", 1197.390, 1044.690, -89.084, 1277.050, 1163.390, 110.916},
    {"Conference Center", 1073.220, -1842.270, -89.084, 1323.900, -1804.210, 110.916},
    {"Montgomery", 1451.400, 347.457, -6.1, 1582.440, 420.802, 200.000},
    {"Foster Valley", -2270.040, -430.276, -1.2, -2178.690, -324.114, 200.000},
    {"Blackfield Chapel", 1325.600, 596.349, -89.084, 1375.600, 795.010, 110.916},
    {"Los Santos International", 2051.630, -2597.260, -39.084, 2152.450, -2394.330, 60.916},
    {"Mulholland", 1096.470, -910.170, -89.084, 1169.130, -768.027, 110.916},
    {"Yellow Bell Gol Course", 1457.460, 2723.230, -89.084, 1534.560, 2863.230, 110.916},
    {"The Strip", 2027.400, 1783.230, -89.084, 2162.390, 1863.230, 110.916},
    {"Jefferson", 2056.860, -1210.740, -89.084, 2185.330, -1126.320, 110.916},
    {"Mulholland", 952.604, -937.184, -89.084, 1096.470, -860.619, 110.916},
    {"Aldea Malvada", -1372.140, 2498.520, 0.000, -1277.590, 2615.350, 200.000},
    {"Las Colinas", 2126.860, -1126.320, -89.084, 2185.330, -934.489, 110.916},
    {"Las Colinas", 1994.330, -1100.820, -89.084, 2056.860, -920.815, 110.916},
    {"Richman", 647.557, -954.662, -89.084, 768.694, -860.619, 110.916},
    {"LVA Freight Depot", 1277.050, 1087.630, -89.084, 1375.600, 1203.280, 110.916},
    {"Julius Thruway North", 1377.390, 2433.230, -89.084, 1534.560, 2507.230, 110.916},
    {"Willowfield", 2201.820, -2095.000, -89.084, 2324.000, -1989.900, 110.916},
    {"Julius Thruway North", 1704.590, 2342.830, -89.084, 1848.400, 2433.230, 110.916},
    {"Temple", 1252.330, -1130.850, -89.084, 1378.330, -1026.330, 110.916},
    {"Little Mexico", 1701.900, -1842.270, -89.084, 1812.620, -1722.260, 110.916},
    {"Queens", -2411.220, 373.539, 0.000, -2253.540, 458.411, 200.000},
    {"Las Venturas Airport", 1515.810, 1586.400, -12.500, 1729.950, 1714.560, 87.500},
    {"Richman", 225.165, -1292.070, -89.084, 466.223, -1235.070, 110.916},
    {"Temple", 1252.330, -1026.330, -89.084, 1391.050, -926.999, 110.916},
    {"East Los Santos", 2266.260, -1494.030, -89.084, 2381.680, -1372.040, 110.916},
    {"Julius Thruway East", 2623.180, 943.235, -89.084, 2749.900, 1055.960, 110.916},
    {"Willowfield", 2541.700, -1941.400, -89.084, 2703.580, -1852.870, 110.916},
    {"Las Colinas", 2056.860, -1126.320, -89.084, 2126.860, -920.815, 110.916},
    {"Julius Thruway East", 2625.160, 2202.760, -89.084, 2685.160, 2442.550, 110.916},
    {"Rodeo", 225.165, -1501.950, -89.084, 334.503, -1369.620, 110.916},
    {"Las Brujas", -365.167, 2123.010, -3.0, -208.570, 2217.680, 200.000},
    {"Julius Thruway East", 2536.430, 2442.550, -89.084, 2685.160, 2542.550, 110.916},
    {"Rodeo", 334.503, -1406.050, -89.084, 466.223, -1292.070, 110.916},
    {"Vinewood", 647.557, -1227.280, -89.084, 787.461, -1118.280, 110.916},
    {"Rodeo", 422.680, -1684.650, -89.084, 558.099, -1570.200, 110.916},
    {"Julius Thruway North", 2498.210, 2542.550, -89.084, 2685.160, 2626.550, 110.916},
    {"Downtown Los Santos", 1724.760, -1430.870, -89.084, 1812.620, -1250.900, 110.916},
    {"Rodeo", 225.165, -1684.650, -89.084, 312.803, -1501.950, 110.916},
    {"Jefferson", 2056.860, -1449.670, -89.084, 2266.210, -1372.040, 110.916},
    {"Hampton Barns", 603.035, 264.312, 0.000, 761.994, 366.572, 200.000},
    {"Temple", 1096.470, -1130.840, -89.084, 1252.330, -1026.330, 110.916},
    {"Kincaid Bridge", -1087.930, 855.370, -89.084, -961.950, 986.281, 110.916},
    {"Verona Beach", 1046.150, -1722.260, -89.084, 1161.520, -1577.590, 110.916},
    {"Commerce", 1323.900, -1722.260, -89.084, 1440.900, -1577.590, 110.916},
    {"Mulholland", 1357.000, -926.999, -89.084, 1463.900, -768.027, 110.916},
    {"Rodeo", 466.223, -1570.200, -89.084, 558.099, -1385.070, 110.916},
    {"Mulholland", 911.802, -860.619, -89.084, 1096.470, -768.027, 110.916},
    {"Mulholland", 768.694, -954.662, -89.084, 952.604, -860.619, 110.916},
    {"Julius Thruway South", 2377.390, 788.894, -89.084, 2537.390, 897.901, 110.916},
    {"Idlewood", 1812.620, -1852.870, -89.084, 1971.660, -1742.310, 110.916},
    {"Ocean Docks", 2089.000, -2394.330, -89.084, 2201.820, -2235.840, 110.916},
    {"Commerce", 1370.850, -1577.590, -89.084, 1463.900, -1384.950, 110.916},
    {"Julius Thruway North", 2121.400, 2508.230, -89.084, 2237.400, 2663.170, 110.916},
    {"Temple", 1096.470, -1026.330, -89.084, 1252.330, -910.170, 110.916},
    {"Glen Park", 1812.620, -1449.670, -89.084, 1996.910, -1350.720, 110.916},
    {"Easter Bay Airport", -1242.980, -50.096, 0.000, -1213.910, 578.396, 200.000},
    {"Martin Bridge", -222.179, 293.324, 0.000, -122.126, 476.465, 200.000},
    {"The Strip", 2106.700, 1863.230, -89.084, 2162.390, 2202.760, 110.916},
    {"Willowfield", 2541.700, -2059.230, -89.084, 2703.580, -1941.400, 110.916},
    {"Marina", 807.922, -1577.590, -89.084, 926.922, -1416.250, 110.916},
    {"Las Venturas Airport", 1457.370, 1143.210, -89.084, 1777.400, 1203.280, 110.916},
    {"Idlewood", 1812.620, -1742.310, -89.084, 1951.660, -1602.310, 110.916},
    {"Esplanade East", -1580.010, 1025.980, -6.1, -1499.890, 1274.260, 200.000},
    {"Downtown Los Santos", 1370.850, -1384.950, -89.084, 1463.900, -1170.870, 110.916},
    {"The Mako Span", 1664.620, 401.750, 0.000, 1785.140, 567.203, 200.000},
    {"Rodeo", 312.803, -1684.650, -89.084, 422.680, -1501.950, 110.916},
    {"Pershing Square", 1440.900, -1722.260, -89.084, 1583.500, -1577.590, 110.916},
    {"Mulholland", 687.802, -860.619, -89.084, 911.802, -768.027, 110.916},
    {"Gant Bridge", -2741.070, 1490.470, -6.1, -2616.400, 1659.680, 200.000},
    {"Las Colinas", 2185.330, -1154.590, -89.084, 2281.450, -934.489, 110.916},
    {"Mulholland", 1169.130, -910.170, -89.084, 1318.130, -768.027, 110.916},
    {"Julius Thruway North", 1938.800, 2508.230, -89.084, 2121.400, 2624.230, 110.916},
    {"Commerce", 1667.960, -1577.590, -89.084, 1812.620, -1430.870, 110.916},
    {"Rodeo", 72.648, -1544.170, -89.084, 225.165, -1404.970, 110.916},
    {"Roca Escalante", 2536.430, 2202.760, -89.084, 2625.160, 2442.550, 110.916},
    {"Rodeo", 72.648, -1684.650, -89.084, 225.165, -1544.170, 110.916},
    {"Market", 952.663, -1310.210, -89.084, 1072.660, -1130.850, 110.916},
    {"Las Colinas", 2632.740, -1135.040, -89.084, 2747.740, -945.035, 110.916},
    {"Mulholland", 861.085, -674.885, -89.084, 1156.550, -600.896, 110.916},
    {"King's", -2253.540, 373.539, -9.1, -1993.280, 458.411, 200.000},
    {"Redsands East", 1848.400, 2342.830, -89.084, 2011.940, 2478.490, 110.916},
    {"Downtown", -1580.010, 744.267, -6.1, -1499.890, 1025.980, 200.000},
    {"Conference Center", 1046.150, -1804.210, -89.084, 1323.900, -1722.260, 110.916},
    {"Richman", 647.557, -1118.280, -89.084, 787.461, -954.662, 110.916},
    {"Ocean Flats", -2994.490, 277.411, -9.1, -2867.850, 458.411, 200.000},
    {"Greenglass College", 964.391, 930.890, -89.084, 1166.530, 1044.690, 110.916},
    {"Glen Park", 1812.620, -1100.820, -89.084, 1994.330, -973.380, 110.916},
    {"LVA Freight Depot", 1375.600, 919.447, -89.084, 1457.370, 1203.280, 110.916},
    {"Regular Tom", -405.770, 1712.860, -3.0, -276.719, 1892.750, 200.000},
    {"Verona Beach", 1161.520, -1722.260, -89.084, 1323.900, -1577.590, 110.916},
    {"East Los Santos", 2281.450, -1372.040, -89.084, 2381.680, -1135.040, 110.916},
    {"Caligula's Palace", 2137.400, 1703.230, -89.084, 2437.390, 1783.230, 110.916},
    {"Idlewood", 1951.660, -1742.310, -89.084, 2124.660, -1602.310, 110.916},
    {"Pilgrim", 2624.400, 1383.230, -89.084, 2685.160, 1783.230, 110.916},
    {"Idlewood", 2124.660, -1742.310, -89.084, 2222.560, -1494.030, 110.916},
    {"Queens", -2533.040, 458.411, 0.000, -2329.310, 578.396, 200.000},
    {"Downtown", -1871.720, 1176.420, -4.5, -1620.300, 1274.260, 200.000},
    {"Commerce", 1583.500, -1722.260, -89.084, 1758.900, -1577.590, 110.916},
    {"East Los Santos", 2381.680, -1454.350, -89.084, 2462.130, -1135.040, 110.916},
    {"Marina", 647.712, -1577.590, -89.084, 807.922, -1416.250, 110.916},
    {"Richman", 72.648, -1404.970, -89.084, 225.165, -1235.070, 110.916},
    {"Vinewood", 647.712, -1416.250, -89.084, 787.461, -1227.280, 110.916},
    {"East Los Santos", 2222.560, -1628.530, -89.084, 2421.030, -1494.030, 110.916},
    {"Rodeo", 558.099, -1684.650, -89.084, 647.522, -1384.930, 110.916},
    {"Easter Tunnel", -1709.710, -833.034, -1.5, -1446.010, -730.118, 200.000},
    {"Rodeo", 466.223, -1385.070, -89.084, 647.522, -1235.070, 110.916},
    {"Redsands East", 1817.390, 2202.760, -89.084, 2011.940, 2342.830, 110.916},
    {"The Clown's Pocket", 2162.390, 1783.230, -89.084, 2437.390, 1883.230, 110.916},
    {"Idlewood", 1971.660, -1852.870, -89.084, 2222.560, -1742.310, 110.916},
    {"Montgomery Intersection", 1546.650, 208.164, 0.000, 1745.830, 347.457, 200.000},
    {"Willowfield", 2089.000, -2235.840, -89.084, 2201.820, -1989.900, 110.916},
    {"Temple", 952.663, -1130.840, -89.084, 1096.470, -937.184, 110.916},
    {"Prickle Pine", 1848.400, 2553.490, -89.084, 1938.800, 2863.230, 110.916},
    {"Los Santos International", 1400.970, -2669.260, -39.084, 2189.820, -2597.260, 60.916},
    {"Garver Bridge", -1213.910, 950.022, -89.084, -1087.930, 1178.930, 110.916},
    {"Garver Bridge", -1339.890, 828.129, -89.084, -1213.910, 1057.040, 110.916},
    {"Kincaid Bridge", -1339.890, 599.218, -89.084, -1213.910, 828.129, 110.916},
    {"Kincaid Bridge", -1213.910, 721.111, -89.084, -1087.930, 950.022, 110.916},
    {"Verona Beach", 930.221, -2006.780, -89.084, 1073.220, -1804.210, 110.916},
    {"Verdant Bluffs", 1073.220, -2006.780, -89.084, 1249.620, -1842.270, 110.916},
    {"Vinewood", 787.461, -1130.840, -89.084, 952.604, -954.662, 110.916},
    {"Vinewood", 787.461, -1310.210, -89.084, 952.663, -1130.840, 110.916},
    {"Commerce", 1463.900, -1577.590, -89.084, 1667.960, -1430.870, 110.916},
    {"Market", 787.461, -1416.250, -89.084, 1072.660, -1310.210, 110.916},
    {"Rockshore West", 2377.390, 596.349, -89.084, 2537.390, 788.894, 110.916},
    {"Julius Thruway North", 2237.400, 2542.550, -89.084, 2498.210, 2663.170, 110.916},
    {"East Beach", 2632.830, -1668.130, -89.084, 2747.740, -1393.420, 110.916},
    {"Fallow Bridge", 434.341, 366.572, 0.000, 603.035, 555.680, 200.000},
    {"Willowfield", 2089.000, -1989.900, -89.084, 2324.000, -1852.870, 110.916},
    {"Chinatown", -2274.170, 578.396, -7.6, -2078.670, 744.170, 200.000},
    {"El Castillo del Diablo", -208.570, 2337.180, 0.000, 8.430, 2487.180, 200.000},
    {"Ocean Docks", 2324.000, -2145.100, -89.084, 2703.580, -2059.230, 110.916},
    {"Easter Bay Chemicals", -1132.820, -768.027, 0.000, -956.476, -578.118, 200.000},
    {"The Visage", 1817.390, 1703.230, -89.084, 2027.400, 1863.230, 110.916},
    {"Ocean Flats", -2994.490, -430.276, -1.2, -2831.890, -222.589, 200.000},
    {"Richman", 321.356, -860.619, -89.084, 687.802, -768.027, 110.916},
    {"Green Palms", 176.581, 1305.450, -3.0, 338.658, 1520.720, 200.000},
    {"Richman", 321.356, -768.027, -89.084, 700.794, -674.885, 110.916},
    {"Starfish Casino", 2162.390, 1883.230, -89.084, 2437.390, 2012.180, 110.916},
    {"East Beach", 2747.740, -1668.130, -89.084, 2959.350, -1498.620, 110.916},
    {"Jefferson", 2056.860, -1372.040, -89.084, 2281.450, -1210.740, 110.916},
    {"Downtown Los Santos", 1463.900, -1290.870, -89.084, 1724.760, -1150.870, 110.916},
    {"Downtown Los Santos", 1463.900, -1430.870, -89.084, 1724.760, -1290.870, 110.916},
    {"Garver Bridge", -1499.890, 696.442, -179.615, -1339.890, 925.353, 20.385},
    {"Julius Thruway South", 1457.390, 823.228, -89.084, 2377.390, 863.229, 110.916},
    {"East Los Santos", 2421.030, -1628.530, -89.084, 2632.830, -1454.350, 110.916},
    {"Greenglass College", 964.391, 1044.690, -89.084, 1197.390, 1203.220, 110.916},
    {"Las Colinas", 2747.740, -1120.040, -89.084, 2959.350, -945.035, 110.916},
    {"Mulholland", 737.573, -768.027, -89.084, 1142.290, -674.885, 110.916},
    {"Ocean Docks", 2201.820, -2730.880, -89.084, 2324.000, -2418.330, 110.916},
    {"East Los Santos", 2462.130, -1454.350, -89.084, 2581.730, -1135.040, 110.916},
    {"Ganton", 2222.560, -1722.330, -89.084, 2632.830, -1628.530, 110.916},
    {"Avispa Country Club", -2831.890, -430.276, -6.1, -2646.400, -222.589, 200.000},
    {"Willowfield", 1970.620, -2179.250, -89.084, 2089.000, -1852.870, 110.916},
    {"Esplanade North", -1982.320, 1274.260, -4.5, -1524.240, 1358.900, 200.000},
    {"The High Roller", 1817.390, 1283.230, -89.084, 2027.390, 1469.230, 110.916},
    {"Ocean Docks", 2201.820, -2418.330, -89.084, 2324.000, -2095.000, 110.916},
    {"Last Dime Motel", 1823.080, 596.349, -89.084, 1997.220, 823.228, 110.916},
    {"Bayside Marina", -2353.170, 2275.790, 0.000, -2153.170, 2475.790, 200.000},
    {"King's", -2329.310, 458.411, -7.6, -1993.280, 578.396, 200.000},
    {"El Corona", 1692.620, -2179.250, -89.084, 1812.620, -1842.270, 110.916},
    {"Blackfield Chapel", 1375.600, 596.349, -89.084, 1558.090, 823.228, 110.916},
    {"The Pink Swan", 1817.390, 1083.230, -89.084, 2027.390, 1283.230, 110.916},
    {"Julius Thruway West", 1197.390, 1163.390, -89.084, 1236.630, 2243.230, 110.916},
    {"Los Flores", 2581.730, -1393.420, -89.084, 2747.740, -1135.040, 110.916},
    {"The Visage", 1817.390, 1863.230, -89.084, 2106.700, 2011.830, 110.916},
    {"Prickle Pine", 1938.800, 2624.230, -89.084, 2121.400, 2861.550, 110.916},
    {"Verona Beach", 851.449, -1804.210, -89.084, 1046.150, -1577.590, 110.916},
    {"Robada Intersection", -1119.010, 1178.930, -89.084, -862.025, 1351.450, 110.916},
    {"Linden Side", 2749.900, 943.235, -89.084, 2923.390, 1198.990, 110.916},
    {"Ocean Docks", 2703.580, -2302.330, -89.084, 2959.350, -2126.900, 110.916},
    {"Willowfield", 2324.000, -2059.230, -89.084, 2541.700, -1852.870, 110.916},
    {"King's", -2411.220, 265.243, -9.1, -1993.280, 373.539, 200.000},
    {"Commerce", 1323.900, -1842.270, -89.084, 1701.900, -1722.260, 110.916},
    {"Mulholland", 1269.130, -768.027, -89.084, 1414.070, -452.425, 110.916},
    {"Marina", 647.712, -1804.210, -89.084, 851.449, -1577.590, 110.916},
    {"Battery Point", -2741.070, 1268.410, -4.5, -2533.040, 1490.470, 200.000},
    {"The Four Dragons Casino", 1817.390, 863.232, -89.084, 2027.390, 1083.230, 110.916},
    {"Blackfield", 964.391, 1203.220, -89.084, 1197.390, 1403.220, 110.916},
    {"Julius Thruway North", 1534.560, 2433.230, -89.084, 1848.400, 2583.230, 110.916},
    {"Yellow Bell Gol Course", 1117.400, 2723.230, -89.084, 1457.460, 2863.230, 110.916},
    {"Idlewood", 1812.620, -1602.310, -89.084, 2124.660, -1449.670, 110.916},
    {"Redsands West", 1297.470, 2142.860, -89.084, 1777.390, 2243.230, 110.916},
    {"Doherty", -2270.040, -324.114, -1.2, -1794.920, -222.589, 200.000},
    {"Hilltop Farm", 967.383, -450.390, -3.0, 1176.780, -217.900, 200.000},
    {"Las Barrancas", -926.130, 1398.730, -3.0, -719.234, 1634.690, 200.000},
    {"Pirates in Men's Pants", 1817.390, 1469.230, -89.084, 2027.400, 1703.230, 110.916},
    {"City Hall", -2867.850, 277.411, -9.1, -2593.440, 458.411, 200.000},
    {"Avispa Country Club", -2646.400, -355.493, 0.000, -2270.040, -222.589, 200.000},
    {"The Strip", 2027.400, 863.229, -89.084, 2087.390, 1703.230, 110.916},
    {"Hashbury", -2593.440, -222.589, -1.0, -2411.220, 54.722, 200.000},
    {"Los Santos International", 1852.000, -2394.330, -89.084, 2089.000, -2179.250, 110.916},
    {"Whitewood Estates", 1098.310, 1726.220, -89.084, 1197.390, 2243.230, 110.916},
    {"Sherman Reservoir", -789.737, 1659.680, -89.084, -599.505, 1929.410, 110.916},
    {"El Corona", 1812.620, -2179.250, -89.084, 1970.620, -1852.870, 110.916},
    {"Downtown", -1700.010, 744.267, -6.1, -1580.010, 1176.520, 200.000},
    {"Foster Valley", -2178.690, -1250.970, 0.000, -1794.920, -1115.580, 200.000},
    {"Las Payasadas", -354.332, 2580.360, 2.0, -133.625, 2816.820, 200.000},
    {"Valle Ocultado", -936.668, 2611.440, 2.0, -715.961, 2847.900, 200.000},
    {"Blackfield Intersection", 1166.530, 795.010, -89.084, 1375.600, 1044.690, 110.916},
    {"Ganton", 2222.560, -1852.870, -89.084, 2632.830, -1722.330, 110.916},
    {"Easter Bay Airport", -1213.910, -730.118, 0.000, -1132.820, -50.096, 200.000},
    {"Redsands East", 1817.390, 2011.830, -89.084, 2106.700, 2202.760, 110.916},
    {"Esplanade East", -1499.890, 578.396, -79.615, -1339.890, 1274.260, 20.385},
    {"Caligula's Palace", 2087.390, 1543.230, -89.084, 2437.390, 1703.230, 110.916},
    {"Royal Casino", 2087.390, 1383.230, -89.084, 2437.390, 1543.230, 110.916},
    {"Richman", 72.648, -1235.070, -89.084, 321.356, -1008.150, 110.916},
    {"Starfish Casino", 2437.390, 1783.230, -89.084, 2685.160, 2012.180, 110.916},
    {"Mulholland", 1281.130, -452.425, -89.084, 1641.130, -290.913, 110.916},
    {"Downtown", -1982.320, 744.170, -6.1, -1871.720, 1274.260, 200.000},
    {"Hankypanky Point", 2576.920, 62.158, 0.000, 2759.250, 385.503, 200.000},
    {"K.A.C.C. Military Fuels", 2498.210, 2626.550, -89.084, 2749.900, 2861.550, 110.916},
    {"Harry Gold Parkway", 1777.390, 863.232, -89.084, 1817.390, 2342.830, 110.916},
    {"Bayside Tunnel", -2290.190, 2548.290, -89.084, -1950.190, 2723.290, 110.916},
    {"Ocean Docks", 2324.000, -2302.330, -89.084, 2703.580, -2145.100, 110.916},
    {"Richman", 321.356, -1044.070, -89.084, 647.557, -860.619, 110.916},
    {"Randolph Industrial Estate", 1558.090, 596.349, -89.084, 1823.080, 823.235, 110.916},
    {"East Beach", 2632.830, -1852.870, -89.084, 2959.350, -1668.130, 110.916},
    {"Flint Water", -314.426, -753.874, -89.084, -106.339, -463.073, 110.916},
    {"Blueberry", 19.607, -404.136, 3.8, 349.607, -220.137, 200.000},
    {"Linden Station", 2749.900, 1198.990, -89.084, 2923.390, 1548.990, 110.916},
    {"Glen Park", 1812.620, -1350.720, -89.084, 2056.860, -1100.820, 110.916},
    {"Downtown", -1993.280, 265.243, -9.1, -1794.920, 578.396, 200.000},
    {"Redsands West", 1377.390, 2243.230, -89.084, 1704.590, 2433.230, 110.916},
    {"Richman", 321.356, -1235.070, -89.084, 647.522, -1044.070, 110.916},
    {"Gant Bridge", -2741.450, 1659.680, -6.1, -2616.400, 2175.150, 200.000},
    {"Lil' Probe Inn", -90.218, 1286.850, -3.0, 153.859, 1554.120, 200.000},
    {"Flint Intersection", -187.700, -1596.760, -89.084, 17.063, -1276.600, 110.916},
    {"Las Colinas", 2281.450, -1135.040, -89.084, 2632.740, -945.035, 110.916},
    {"Sobell Rail Yards", 2749.900, 1548.990, -89.084, 2923.390, 1937.250, 110.916},
    {"The Emerald Isle", 2011.940, 2202.760, -89.084, 2237.400, 2508.230, 110.916},
    {"El Castillo del Diablo", -208.570, 2123.010, -7.6, 114.033, 2337.180, 200.000},
    {"Santa Flora", -2741.070, 458.411, -7.6, -2533.040, 793.411, 200.000},
    {"Playa del Seville", 2703.580, -2126.900, -89.084, 2959.350, -1852.870, 110.916},
    {"Market", 926.922, -1577.590, -89.084, 1370.850, -1416.250, 110.916},
    {"Queens", -2593.440, 54.722, 0.000, -2411.220, 458.411, 200.000},
    {"Pilson Intersection", 1098.390, 2243.230, -89.084, 1377.390, 2507.230, 110.916},
    {"Spinybed", 2121.400, 2663.170, -89.084, 2498.210, 2861.550, 110.916},
    {"Pilgrim", 2437.390, 1383.230, -89.084, 2624.400, 1783.230, 110.916},
    {"Blackfield", 964.391, 1403.220, -89.084, 1197.390, 1726.220, 110.916},
    {"'The Big Ear'", -410.020, 1403.340, -3.0, -137.969, 1681.230, 200.000},
    {"Dillimore", 580.794, -674.885, -9.5, 861.085, -404.790, 200.000},
    {"El Quebrados", -1645.230, 2498.520, 0.000, -1372.140, 2777.850, 200.000},
    {"Esplanade North", -2533.040, 1358.900, -4.5, -1996.660, 1501.210, 200.000},
    {"Easter Bay Airport", -1499.890, -50.096, -1.0, -1242.980, 249.904, 200.000},
    {"Fisher's Lagoon", 1916.990, -233.323, -100.000, 2131.720, 13.800, 200.000},
    {"Mulholland", 1414.070, -768.027, -89.084, 1667.610, -452.425, 110.916},
    {"East Beach", 2747.740, -1498.620, -89.084, 2959.350, -1120.040, 110.916},
    {"San Andreas Sound", 2450.390, 385.503, -100.000, 2759.250, 562.349, 200.000},
    {"Shady Creeks", -2030.120, -2174.890, -6.1, -1820.640, -1771.660, 200.000},
    {"Market", 1072.660, -1416.250, -89.084, 1370.850, -1130.850, 110.916},
    {"Rockshore West", 1997.220, 596.349, -89.084, 2377.390, 823.228, 110.916},
    {"Prickle Pine", 1534.560, 2583.230, -89.084, 1848.400, 2863.230, 110.916},
    {"Easter Basin", -1794.920, -50.096, -1.04, -1499.890, 249.904, 200.000},
    {"Leafy Hollow", -1166.970, -1856.030, 0.000, -815.624, -1602.070, 200.000},
    {"LVA Freight Depot", 1457.390, 863.229, -89.084, 1777.400, 1143.210, 110.916},
    {"Prickle Pine", 1117.400, 2507.230, -89.084, 1534.560, 2723.230, 110.916},
    {"Blueberry", 104.534, -220.137, 2.3, 349.607, 152.236, 200.000},
    {"El Castillo del Diablo", -464.515, 2217.680, 0.000, -208.570, 2580.360, 200.000},
    {"Downtown", -2078.670, 578.396, -7.6, -1499.890, 744.267, 200.000},
    {"Rockshore East", 2537.390, 676.549, -89.084, 2902.350, 943.235, 110.916},
    {"San Fierro Bay", -2616.400, 1501.210, -3.0, -1996.660, 1659.680, 200.000},
    {"Paradiso", -2741.070, 793.411, -6.1, -2533.040, 1268.410, 200.000},
    {"The Camel's Toe", 2087.390, 1203.230, -89.084, 2640.400, 1383.230, 110.916},
    {"Old Venturas Strip", 2162.390, 2012.180, -89.084, 2685.160, 2202.760, 110.916},
    {"Juniper Hill", -2533.040, 578.396, -7.6, -2274.170, 968.369, 200.000},
    {"Juniper Hollow", -2533.040, 968.369, -6.1, -2274.170, 1358.900, 200.000},
    {"Roca Escalante", 2237.400, 2202.760, -89.084, 2536.430, 2542.550, 110.916},
    {"Julius Thruway East", 2685.160, 1055.960, -89.084, 2749.900, 2626.550, 110.916},
    {"Verona Beach", 647.712, -2173.290, -89.084, 930.221, -1804.210, 110.916},
    {"Foster Valley", -2178.690, -599.884, -1.2, -1794.920, -324.114, 200.000},
    {"Arco del Oeste", -901.129, 2221.860, 0.000, -592.090, 2571.970, 200.000},
    {"Fallen Tree", -792.254, -698.555, -5.3, -452.404, -380.043, 200.000},
    {"The Farm", -1209.670, -1317.100, 114.981, -908.161, -787.391, 251.981},
    {"The Sherman Dam", -968.772, 1929.410, -3.0, -481.126, 2155.260, 200.000},
    {"Esplanade North", -1996.660, 1358.900, -4.5, -1524.240, 1592.510, 200.000},
    {"Financial", -1871.720, 744.170, -6.1, -1701.300, 1176.420, 300.000},
    {"Garcia", -2411.220, -222.589, -1.14, -2173.040, 265.243, 200.000},
    {"Montgomery", 1119.510, 119.526, -3.0, 1451.400, 493.323, 200.000},
    {"Creek", 2749.900, 1937.250, -89.084, 2921.620, 2669.790, 110.916},
    {"Los Santos International", 1249.620, -2394.330, -89.084, 1852.000, -2179.250, 110.916},
    {"Santa Maria Beach", 72.648, -2173.290, -89.084, 342.648, -1684.650, 110.916},
    {"Mulholland Intersection", 1463.900, -1150.870, -89.084, 1812.620, -768.027, 110.916},
    {"Angel Pine", -2324.940, -2584.290, -6.1, -1964.220, -2212.110, 200.000},
    {"Verdant Meadows", 37.032, 2337.180, -3.0, 435.988, 2677.900, 200.000},
    {"Octane Springs", 338.658, 1228.510, 0.000, 664.308, 1655.050, 200.000},
    {"Come-A-Lot", 2087.390, 943.235, -89.084, 2623.180, 1203.230, 110.916},
    {"Redsands West", 1236.630, 1883.110, -89.084, 1777.390, 2142.860, 110.916},
    {"Santa Maria Beach", 342.648, -2173.290, -89.084, 647.712, -1684.650, 110.916},
    {"Verdant Bluffs", 1249.620, -2179.250, -89.084, 1692.620, -1842.270, 110.916},
    {"Las Venturas Airport", 1236.630, 1203.280, -89.084, 1457.370, 1883.110, 110.916},
    {"Flint Range", -594.191, -1648.550, 0.000, -187.700, -1276.600, 200.000},
    {"Verdant Bluffs", 930.221, -2488.420, -89.084, 1249.620, -2006.780, 110.916},
    {"Palomino Creek", 2160.220, -149.004, 0.000, 2576.920, 228.322, 200.000},
    {"Ocean Docks", 2373.770, -2697.090, -89.084, 2809.220, -2330.460, 110.916},
    {"Easter Bay Airport", -1213.910, -50.096, -4.5, -947.980, 578.396, 200.000},
    {"Whitewood Estates", 883.308, 1726.220, -89.084, 1098.310, 2507.230, 110.916},
    {"Calton Heights", -2274.170, 744.170, -6.1, -1982.320, 1358.900, 200.000},
    {"Easter Basin", -1794.920, 249.904, -9.1, -1242.980, 578.396, 200.000},
    {"Los Santos Inlet", -321.744, -2224.430, -89.084, 44.615, -1724.430, 110.916},
    {"Doherty", -2173.040, -222.589, -1.0, -1794.920, 265.243, 200.000},
    {"Mount Chiliad", -2178.690, -2189.910, -47.917, -2030.120, -1771.660, 576.083},
    {"Fort Carson", -376.233, 826.326, -3.0, 123.717, 1220.440, 200.000},
    {"Foster Valley", -2178.690, -1115.580, 0.000, -1794.920, -599.884, 200.000},
    {"Ocean Flats", -2994.490, -222.589, -1.0, -2593.440, 277.411, 200.000},
    {"Fern Ridge", 508.189, -139.259, 0.000, 1306.660, 119.526, 200.000},
    {"Bayside", -2741.070, 2175.150, 0.000, -2353.170, 2722.790, 200.000},
    {"Las Venturas Airport", 1457.370, 1203.280, -89.084, 1777.390, 1883.110, 110.916},
    {"Blueberry Acres", -319.676, -220.137, 0.000, 104.534, 293.324, 200.000},
    {"Palisades", -2994.490, 458.411, -6.1, -2741.070, 1339.610, 200.000},
    {"North Rock", 2285.370, -768.027, 0.000, 2770.590, -269.740, 200.000},
    {"Hunter Quarry", 337.244, 710.840, -115.239, 860.554, 1031.710, 203.761},
    {"Los Santos International", 1382.730, -2730.880, -89.084, 2201.820, -2394.330, 110.916},
    {"Missionary Hill", -2994.490, -811.276, 0.000, -2178.690, -430.276, 200.000},
    {"San Fierro Bay", -2616.400, 1659.680, -3.0, -1996.660, 2175.150, 200.000},
    {"Restricted Area", -91.586, 1655.050, -50.000, 421.234, 2123.010, 250.000},
    {"Mount Chiliad", -2997.470, -1115.580, -47.917, -2178.690, -971.913, 576.083},
    {"Mount Chiliad", -2178.690, -1771.660, -47.917, -1936.120, -1250.970, 576.083},
    {"Easter Bay Airport", -1794.920, -730.118, -3.0, -1213.910, -50.096, 200.000},
    {"The Panopticon", -947.980, -304.320, -1.1, -319.676, 327.071, 200.000},
    {"Shady Creeks", -1820.640, -2643.680, -8.0, -1226.780, -1771.660, 200.000},
    {"Back o Beyond", -1166.970, -2641.190, 0.000, -321.744, -1856.030, 200.000},
    {"Mount Chiliad", -2994.490, -2189.910, -47.917, -2178.690, -1115.580, 576.083},
    {"Tierra Robada", -1213.910, 596.349, -242.990, -480.539, 1659.680, 900.000},
    {"Flint County", -1213.910, -2892.970, -242.990, 44.615, -768.027, 900.000},
    {"Whetstone", -2997.470, -2892.970, -242.990, -1213.910, -1115.580, 900.000},
    {"Bone County", -480.539, 596.349, -242.990, 869.461, 2993.870, 900.000},
    {"Tierra Robada", -2997.470, 1659.680, -242.990, -480.539, 2993.870, 900.000},
    {"San Fierro", -2997.470, -1115.580, -242.990, -1213.910, 1659.680, 900.000},
    {"Las Venturas", 869.461, 596.349, -242.990, 2997.060, 2993.870, 900.000},
    {"Red County", -1213.910, -768.027, -242.990, 2997.060, 596.349, 900.000},
    {"Los Santos", 44.615, -2892.970, -242.990, 2997.060, -768.027, 900.000}}
    for i, v in ipairs(streets) do
        if (positionX >= v[2]) and (positionY >= v[3]) and (positionZ >= v[4]) and (positionX <= v[5]) and (positionY <= v[6]) and (positionZ <= v[7]) then
            return v[1]
        end
    end
    return "Неизвестно"
end

function VehInfoID()
	if isCharInAnyCar(playerPed) then
		local carh = storeCarCharIsInNoSave(playerPed)
		local cmdl = getCarModel(carh)
		MyVeh_ID = cmdl
	else
		MyVeh_ID = ""
	end
	return MyVeh_ID
end

function VehInfoName()
	if isCharInAnyCar(PLAYER_PED) then
		local carh = storeCarCharIsInNoSave(PLAYER_PED)
		local cmdl = getCarModel(carh)
		local carname = cars[cmdl-399]
		local MyVeh_Name = carname
	else
		MyVeh_Name = ""
	end
	return MyVeh_Name
end

-- Technical Function

function imgui.HelpVariables(var, text)
	imgui.Separator() if imgui.Button(tostring(var), imgui.ImVec2(120,20)) then setClipboardText(tostring(var)) Notification("Переменная успешно скопирована!", 2) end imgui.SameLine() imgui.Text(u8(tostring(text)))
end

function distanceBetweenPlayer(playerId)
  if sampIsPlayerConnected(playerId) then
      local result, ped = sampGetCharHandleBySampPlayerId(playerId)
      if result and doesCharExist(ped) then
          local myX, myY, myZ = getCharCoordinates(playerPed)
          local playerX, playerY, playerZ = getCharCoordinates(ped)
          return math.floor(getDistanceBetweenCoords3d(myX, myY, myZ, playerX, playerY, playerZ))
      end
  end
  return nil
end

function ShowHelpMarker(text)
	imgui.SameLine()
    imgui.TextDisabled(fa.ICON_QUESTION_CIRCLE_O)
    if (imgui.IsItemHovered()) then
        imgui.SetTooltip(u8(text))
    end
end

function imgui.TextColoredRGB(text)
  local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], text[i])
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(w) end
        end
    end

    render_text(text)
end

function imgui.CenterColumnText(text)
  imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
  imgui.Text(text)
end

function imgui.NewInputText(lable, val, width, hint, hintpos, flags)
    local hint = hint and hint or ''
    local hintpos = tonumber(hintpos) and tonumber(hintpos) or 1
    local cPos = imgui.GetCursorPos()
    imgui.PushItemWidth(width)
    if flags ~= 0 then
        local result = imgui.InputText(lable, val, flags)
    else local result = imgui.InputText(lable, val) end
    if #val.v == 0 then
        local hintSize = imgui.CalcTextSize(hint)
        if hintpos == 2 then imgui.SameLine(cPos.x + (width - hintSize.x) / 2)
        elseif hintpos == 3 then imgui.SameLine(cPos.x + (width - hintSize.x - 5))
        else imgui.SameLine(cPos.x + 5) end
        imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 0.40), tostring(hint))
    end
    imgui.PopItemWidth()
    return result
end

function imgui.VerticalSeparator()
    local p = imgui.GetCursorScreenPos()
    imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x, p.y + 999999999999999999), imgui.GetColorU32(imgui.GetStyle().Colors[imgui.Col.Separator]))
end

function imgui.TextCenter(text)
    local textSize = imgui.CalcTextSize(text)
    imgui.SetCursorPosX(imgui.GetWindowWidth() / 2 - textSize.x / 2)
    return imgui.Text(text)
end

function imgui.TextCenterRGB(text)
    local width = imgui.GetWindowWidth()
    local explode_argb = function(argb)
        local a = bit.band(bit.rshift(argb, 24), 0xFF)
        local r = bit.band(bit.rshift(argb, 16), 0xFF)
        local g = bit.band(bit.rshift(argb, 8), 0xFF)
        local b = bit.band(argb, 0xFF)
        return a, r, g, b
    end

    local getcolor = function(color)
        if color:sub(1, 6):upper() == 'SSSSSS' then
            local r, g, b = colors[1].x, colors[1].y, colors[1].z
            local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
            return ImVec4(r, g, b, a / 255)
        end
        local color = type(color) == 'string' and tonumber(color, 16) or color
        if type(color) ~= 'number' then return end
        local r, g, b, a = explode_argb(color)
        return imgui.ImColor(r, g, b, a):GetVec4()
    end

    local render_text = function(text_)
        for w in text_:gmatch('[^\r\n]+') do
            local textsize = w:gsub('{.-}', '')
            local text_width = imgui.CalcTextSize(u8(textsize))
            imgui.SetCursorPosX( width / 2 - text_width .x / 2 )
            local text, colors_, m = {}, {}, 1
            w = w:gsub('{(......)}', '{%1FF}')
            while w:find('{........}') do
                local n, k = w:find('{........}')
                local color = getcolor(w:sub(n + 1, k - 1))
                if color then
                    text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
                    colors_[#colors_ + 1] = color
                    m = n
                end
                w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
            end
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else
                imgui.Text(w)
            end
        end
    end
    render_text(text)
end

function apply_welcome_blue_style()
	style.WindowRounding = 8
	style.FrameRounding = 3
	style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
	colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
	colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
	colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.TitleBg]                = ImVec4(0.16, 0.29, 0.48, 1.00)
	colors[clr.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
	colors[clr.TitleBgCollapsed]       = ImVec4(0.16, 0.29, 0.48, 1.00)
	colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
	colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
	colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
	colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
	colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
	colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.Separator]              = colors[clr.Border]
	colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
	colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
	colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
	colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
	colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
	colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
	colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
	colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.ComboBg]                = colors[clr.PopupBg]
	colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
	colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
	colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
	colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
	colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
	colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
	colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
	colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
	colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
	colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
	colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

function apply_welcome_red_style()
	colors[clr.FrameBg]                = ImVec4(0.48, 0.16, 0.16, 0.54)
	colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.26, 0.26, 0.40)
	colors[clr.FrameBgActive]          = ImVec4(0.98, 0.26, 0.26, 0.67)
	colors[clr.TitleBg]                = ImVec4(0.48, 0.16, 0.16, 1.00)
	colors[clr.TitleBgActive]          = colors[clr.TitleBg]
	colors[clr.TitleBgCollapsed]       = colors[clr.TitleBg]
	colors[clr.CheckMark]              = ImVec4(0.98, 0.26, 0.26, 1.00)
	colors[clr.SliderGrab]             = ImVec4(0.88, 0.26, 0.24, 1.00)
	colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.26, 0.26, 1.00)
	colors[clr.Button]                 = ImVec4(0.98, 0.26, 0.26, 0.40)
	colors[clr.ButtonHovered]          = ImVec4(0.98, 0.26, 0.26, 1.00)
	colors[clr.ButtonActive]           = ImVec4(0.98, 0.06, 0.06, 1.00)
	colors[clr.Header]                 = ImVec4(0.98, 0.26, 0.26, 0.31)
	colors[clr.HeaderHovered]          = ImVec4(0.98, 0.26, 0.26, 0.80)
	colors[clr.HeaderActive]           = ImVec4(0.98, 0.26, 0.26, 1.00)
	colors[clr.Separator]              = colors[clr.Border]
	colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.10, 0.10, 0.78)
	colors[clr.SeparatorActive]        = ImVec4(0.75, 0.10, 0.10, 1.00)
	colors[clr.ResizeGrip]             = ImVec4(0.98, 0.26, 0.26, 0.25)
	colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.26, 0.26, 0.67)
	colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.26, 0.26, 0.95)
	colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.26, 0.26, 0.35)
	colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
	colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 1.00)
	colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
	colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.ComboBg]                = colors[clr.PopupBg]
	colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
	colors[clr.BorderShadow]           = ImVec4(0.48, 0.16, 0.16, 0.00)
	colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
	colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
	colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
	colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
	colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
	colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
	colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
	colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
	colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
	colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

function apply_custom_style()
  imgui.SwitchContext()
	style = imgui.GetStyle()
	colors = style.Colors
	clr = imgui.Col
	ImVec4 = imgui.ImVec4
	ImVec2 = imgui.ImVec2
	style.FrameRounding = 3
  style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
	style.ChildWindowRounding = 5
	style.ScrollbarSize = 0
	colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
	colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
	colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
	colors[clr.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
	colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
	colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
	colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
	colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
	colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
	colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
	colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.Separator]              = colors[clr.Border]
	colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
	colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
	colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
	colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
	colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
	colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
	colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
	colors[clr.WindowBg]               = ImVec4(0.06, 0.53, 0.98, 0.70)
	colors[clr.ChildWindowBg]          = ImVec4(0.00, 0.00, 0.00, 0.40)
	colors[clr.PopupBg]                = colors[clr.WindowBg]
	colors[clr.ComboBg]                = ImVec4(0.16, 0.29, 0.48, 1.00)
	colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
	colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
	colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
	colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
	colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
	colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
	colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
	colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
	colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
	colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
	colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
	colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end
apply_custom_style()
