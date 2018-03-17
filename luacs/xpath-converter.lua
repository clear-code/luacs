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
  if self.combinator == "+" then
    xpath = xpath ..
      "/following-sibling::*[name() = '" ..
      element_name ..
      "' and position() = 1]"
  elseif self.combinator == ">" then
    xpath = xpath .. "/" .. element_name
  elseif self.combinator == "~" then
    xpath = xpath .. "/following-sibling::" .. element_name
  elseif self.combinator == " " then
    xpath = xpath .. "/descendant-or-self::" .. element_name
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
