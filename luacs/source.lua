local Source = {}

local methods = {}

local metatable = {}
function metatable.__index(parser, key)
  return methods[key]
end

function methods.peek(self)
  return self.data[self.position]
end

function methods.match(self, characters)
  local character = self.data[self.position]
  for _, value in ipairs(characters) do
    if value == character then
      self.position = self.position + 1
      return value
    end
  end
  return nil
end

local whitespaces = {
  " ",
  "\t",
  "\r",
  "\n",
  "\f",
}
function methods.skip_whitespaces(self)
  while self:match(whitespaces) do
  end
  return true
end

function methods.match_ident(self)
  local start, last = self.data:find("-?[_%a][_%a%d-]*", self.position)
  if start == self.position then
    self.position = last + 1
    return self.data:sub(start, last)
  else
    return nil
  end
end

function methods.match_namespace_prefix(self)
  local start, last

  start, last = self.data:find("-?[_%a][_%a%d-]*|", self.position)
  if start ~= self.position then
    start, last = self.data:find("*|", self.position)
  end

  if start == self.position then
    self.position = last + 1
    return self.data:sub(start, last - 1)
  else
    return nil
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
