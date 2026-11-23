#!/data/data/com.termux/files/usr/bin/lua5.5
-- Terminal Module

local argparse = require("argparse")
local parser = argparse("glowberry", "Terminal helper utility")

-- ВЕРСИЯ ПАКЕТА
parser:flag("-v --version", "Показать версию и выйти"):action(function()
  print("glowberry 1.0.0")
  os.exit(0)
end)
-- 0 АРГУМЕНТ
parser:argument("separator", "Разделитель"):args(1)
-- 1 АРГУМЕНТ
parser:argument("text", "Текст для вывода"):args(1)
-- 2 АРГУМЕНТ

local args = parser:parse()

local function get_width()
  -- 1) Переменная окружения, если она реально экспортирована
  local env = tonumber(os.getenv("COLUMNS"))
  if env and env > 0 then
    return env
  end

  -- 2) Реальная ширина терминала (fish не экспортирует COLUMNS)
  local handle = io.popen("stty size < /dev/tty 2>/dev/null")
  if handle then
    local size = handle:read("*a") or ""
    handle:close()
    local cols = tonumber(size:match("%d+ (%d+)"))
    if cols and cols > 0 then
      return cols
    end
  end

  return 80
end

local function process()
  local columns = get_width()
  local trimmed = args.text:match("^%s*(.-)%s*$")

  -- Ширина текста вместе с пробелами по краям
  local text_width = (utf8.len(trimmed) or #trimmed) + 2
  -- Сколько символов разделителя остаётся на рамку
  local filler = columns - text_width

  if filler < 2 then
    io.write(trimmed, "\n")
    return
   end

  -- Остаток от нечётной ширины добавляем слева
  local left = math.floor(filler / 2)
  local right = filler - left

  io.write(
    args.separator:rep(left),
    " ",
    trimmed,
    " ",
    args.separator:rep(right),
    "\n"
  )
end

process()
