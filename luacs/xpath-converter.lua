local XPathConverter = {}

local methods = {}

local metatable = {}
function metatable.__index(parser, key)
  return methods[key]
end

function methods.on_start_selector(self)
  table.insert(self.xpaths, "")
  self.combinator = " "
end

function methods.on_combinator(self, combinator)
  self.combinator = combinator
end

function methods.on_type_selector(self, namespace_prefix, element_name)
  local xpath = self.xpaths[#self.xpaths]

  local prefix
  if self.combinator == "+" then
    prefix = "/following-sibling::*[position()=1]"
  elseif self.combinator == ">" then
    prefix = "/"
  elseif self.combinator == "~" then
    prefix = "/following-sibling::"
  elseif self.combinator == " " then
    prefix = "/descendant-or-self::"
  end

  if namespace_prefix == nil or namespace_prefix == "*" then
    if prefix:sub(#prefix) ~= "]" then
      prefix = prefix .. "*"
    end
    xpath = xpath .. prefix .. "[local-name()='" .. element_name .. "']"
  elseif namespace_prefix == "" then
    if prefix:sub(#prefix) == "]" then
      xpath = xpath .. prefix .. "[name()='" .. element_name .. "']"
    else
      xpath = xpath .. prefix .. element_name
    end
  else
    local name = namespace_prefix .. ":" .. element_name
    if prefix:sub(#prefix) == "]" then
      xpath = xpath .. prefix .. "[name()='" .. name .. "']"
    else
      xpath = xpath .. prefix .. name
    end
  end

  self.xpaths[#self.xpaths] = xpath
end

function XPathConverter.new()
  local converter = {
    xpaths = {},
  }
  setmetatable(converter, metatable)
  return converter
end

return XPathConverter
