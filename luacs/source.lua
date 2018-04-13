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

-- TODO: support non-ASCII characters
function methods:match_ident()
  return self:match("-?[_%a][_%a%d-]*")
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
