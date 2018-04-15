local utf8 = require("lua-utf8")

local Source = {}

local methods = {}

local metatable = {}
function metatable.__index(parser, key)
  return methods[key]
end

function methods:inspect()
  return
    self.data:sub(1, self.position - 1) .. "|@|" ..
    self.data:sub(self.position)
end

function methods:peek()
  return self.data[self.position]
end

function methods:seek(position)
  self.position = position
end

function methods:match(pattern)
  local start, last = self.data:find(pattern, self.position)
  if start == self.position then
    self.position = last + 1
    return self.data:sub(start, last)
  else
    return nil
  end
end

function methods:match_whitespaces()
  return self:match("[ \t\r\n\f]+")
end

function methods:match_hyphen()
  return self:match("-")
end


function methods:match_name_character(is_start)
  local position = self.position

  local in_ascii
  if is_start then
    in_ascii = self:match("[_a-zA-Z]")
  else
    in_ascii = self:match("[_a-zA-Z0-9-]")
  end
  if in_ascii then
    return in_ascii
  end

  local data = self.data:sub(self.position)
  if #data > 0 then
    local code_point = utf8.codepoint(data)
    if code_point >= 0x80 then
      local next_offset, next_code_point = utf8.offset(data, 1)
      if next_offset then
        self.position = position + next_offset - 1
      else
        self.position = #self.data + 1
      end
      return utf8.char(code_point)
    end
  end

  self.position = position
  local unicode_escape = self:match("\\[0-9a-zA-Z]+")
  if unicode_escape then
    if #unicode_escape > 7 then
      self.position = self.position - (#unicode_escape - 7)
      unicode_escape = unicode_escape:sub(1, 7)
    end
    local code_point = tonumber("0x" .. unicode_escape:sub(2))
    if not self:match("\r\n") then
      self:match("[ \n\r\t\f]")
    end
    return utf8.char(code_point)
  end

  self.postion = position
  local escape = self:match("\\[^\n\r\f0-9a-zA-Z]")
  if escape then
    return escape:sub(2)
  end

  return nil
end

function methods:match_ident()
  local position = self.position
  local ident = ""

  local hyphen = self:match_hyphen()
  if hyphen then
    ident = ident .. hyhpen
  end

  local name_start = self:match_name_character(true)
  if not name_start then
    self.position = position
    return nil
  end
  ident = ident .. name_start

  while true do
    local name_character = self:match_name_character(false)
    if not name_character then
      break
    end
    ident = ident .. name_character
  end

  return ident
end

-- TODO: support escape and so on
function methods:match_string()
  local position = self.position

  local first = self.data:sub(position, position)
  local delimiter
  if first == "\"" or first == "'" then
    delimiter = first
    self.position = position + 1
  else
    return nil
  end

  local data_with_delimiter = self:match("[^" .. delimiter .. "]*" .. delimiter)
  if data_with_delimiter then
    return data_with_delimiter:sub(0, -2)
  else
    self:seek(position)
    return nil
  end
end

function methods:match_number()
  local position = self.position

  local number = self:match("%d+")
  if not number then
    number = self:match("%d?%.%d+")
  end

  if number then
    return tonumber(number)
  else
    self:seek(position)
    return nil
  end
end

function methods:match_dimension()
  local position = self.position

  local number = self:match_number()
  if not number then
    return nil
  end

  local ident = self:match_ident()
  if not ident then
    self:seek(position)
    return nil
  end

  return self.data:sub(position, self.position - 1)
end

function methods:match_namespace_prefix()
  local position = self.position

  if self:match("|") then
    return ""
  end

  local prefix = self:match("-?[_%a][_%a%d-]*|")
  if not prefix then
    prefix = self:match("%*|")
  end

  if prefix then
    return prefix:sub(0, -2)
  else
    return nil
  end
end

function methods:match_hash()
  matched = self:match("#[_%a%d-]+")
  if matched then
    return matched:sub(2)
  else
    return matched
  end
end

function Source.new(data)
  local source = {
    data = data,
    position = 1,
  }
  setmetatable(source, metatable)
  return source
end

return Source
