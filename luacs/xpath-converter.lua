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

function methods.on_universal(self, namespace_prefix, element_name)
  local xpath = self.xpaths[#self.xpaths]

  local prefix
  if self.combinator == "+" then
    prefix = "/following-sibling::*[position()=1]"
  elseif self.combinator == ">" then
    prefix = "/*"
  elseif self.combinator == "~" then
    prefix = "/following-sibling::*"
  elseif self.combinator == " " then
    prefix = "/descendant-or-self::*"
  end

  if namespace_prefix == nil or namespace_prefix == "*" then
    xpath = xpath .. prefix
  elseif namespace_prefix == "" then
    xpath = xpath .. prefix .. "[namespace-uri()='']"
  else
    xpath = xpath .. prefix ..
      "[starts-with(name(), '" .. namespace_prefix .. "')]"
  end

  self.xpaths[#self.xpaths] = xpath
end

function methods.on_hash(self, name)
  local xpath = self.xpaths[#self.xpaths]
  xpath = xpath .. "[@id='" .. name .. "' or @name='" .. name .. "']"
  self.xpaths[#self.xpaths] = xpath
end

local function attribute_include(xpath, name, value)
  return xpath ..
    "[contains(" ..
    "concat(' ', normalize-space(@" .. name .. "), ' '), " ..
    "' " .. value .. " ')]"
end

function methods.on_class(self, name)
  local xpath = self.xpaths[#self.xpaths]
  xpath = attribute_include(xpath .. "[@class]", "class", name)
  self.xpaths[#self.xpaths] = xpath
end

function methods.on_attribute(self,
                              namespace_prefix,
                              attribute_name,
                              operator,
                              value)
  local xpath = self.xpaths[#self.xpaths]

  local name
  if namespace_prefix then
    name = namespace_prefix .. ":" .. attribute_name
  else
    name = attribute_name
  end

  xpath = xpath .. "[@" .. name .. "]"
  if operator == "^=" then
    xpath = xpath .. "[starts-with(@" .. name .. ", '" .. value .. "')]"
  elseif operator == "$=" then
    xpath = xpath ..
      "[substring(@" .. name .. ", " ..
      "string-length(@" .. name .. ") - " .. #value .. ")" ..
      "='" .. value .. "']"
  elseif operator == "*=" then
    xpath = xpath .. "[contains(@" .. name .. ", '" .. value .. "')]"
  elseif operator == "=" then
    xpath = xpath .. "[@" .. name .. "='" .. value .. "']"
  elseif operator == "~=" then
    xpath = attribute_include(xpath, name, value)
  elseif operator == "|=" then
    xpath = xpath ..
      "[@" .. name .. "='" .. value .. "' or " ..
      "starts-with(@" .. name .. ", '" .. value .. "-')]"
  end

  self.xpaths[#self.xpaths] = xpath
end

function methods.on_pseudo_element(self, name)
  error("Failed to convert to XPath: " ..
          "pseudo-element isn't supported: <" .. name .. ">")
end

function methods.on_pseudo_class(self, name)
  error("Failed to convert to XPath: " ..
          "pseudo-class isn't supported: <" .. name .. ">")
end

function XPathConverter.new()
  local converter = {
    xpaths = {},
  }
  setmetatable(converter, metatable)
  return converter
end

return XPathConverter
