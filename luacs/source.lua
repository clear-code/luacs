local Source = {}

local methods = {}

local metatable = {}
function metatable.__index(parser, key)
  return methods[key]
end

function methods.peek(self)
  return self.data[self.position]
end

function methods.seek(self, position)
  self.position = position
end

function methods.match(self, pattern)
  local start, last = self.data:find(pattern, self.position)
  if start == self.position then
    self.position = last + 1
    return self.data:sub(start, last)
  else
    return nil
  end
end

function methods.skip_whitespaces(self)
  while self:match("[ \t\r\n\f]") do
  end
  return true
end

function methods.match_ident(self)
  return self:match("-?[_%a][_%a%d-]*")
end

function methods.match_string(self)
  local position = self.position

  local first = self.data:sub(position, position)
  local delimiter
  if first == "\"" or first == "'" then
    delimiter = first
    self.position = position + 1
  else
    return false
  end

  local data_with_delimiter = self:match("[^" .. delimiter .. "]" .. delimiter)
  if data_with_delimiter then
    return data_with_delimiter:sub(0, -2)
  else
    self:seek(position)
    return false
  end
end

function methods.match_number(self)
  local position = self.position

  local number = self:match("%d+")
  if not number then
    number = self:match("%d?%.%d+")
  end

  if number then
    return tonumber(number)
  else
    self:seek(position)
    return false
  end
end

function methods.match_dimension(self)
  local position = self.position

  local number = self:match_number()
  if not number then
    return false
  end

  local ident = self:match_ident()
  if not ident then
    self:seek(position)
    return false
  end

  return self.data:sub(position, self.position - 1)
end

function methods.match_namespace_prefix(self)
  local position = self.position

  if self:match("|") then
    return ""
  end

  local prefix = self:match("-?[_%a][_%a%d-]*|")
  if not prefix then
    prefix = self:match("*|")
  end

  if prefix then
    return prefix:sub(0, -2)
  else
    return nil
  end
end

function methods.match_hash(self)
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
