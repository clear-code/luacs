local XPathConverter = {}

local methods = {}

local function string_value(raw_value)
  local escaped_value, n_escaped =
    raw_value:gsub("(['\\])",
                   function(special_character)
                     return "\\" .. special_character
                   end)
  return "'" .. raw_value .. "'"
end

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
    xpath = xpath ..
      prefix ..
      "[local-name()=" .. string_value(element_name) .. "]"
  elseif namespace_prefix == "" then
    if prefix:sub(#prefix) == "]" then
      xpath = xpath ..
        prefix ..
        "[name()=" .. string_value(element_name) .. "]"
    else
      xpath = xpath .. prefix .. element_name
    end
  else
    local name = namespace_prefix .. ":" .. element_name
    if prefix:sub(#prefix) == "]" then
      xpath = xpath .. prefix .. "[name()=" .. string_value(name) .. "]"
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
      "[starts-with(name(), " .. string_value(namespace_prefix) .. ")]"
  end

  self.xpaths[#self.xpaths] = xpath
end

function methods.on_hash(self, name)
  local xpath = self.xpaths[#self.xpaths]
  xpath = xpath ..
    "[@id=" .. string_value(name) .. " or " ..
    "@name=" .. string_value(name) .. "]"
  self.xpaths[#self.xpaths] = xpath
end

local function attribute_include(xpath, name, value)
  return xpath ..
    "[contains(" ..
    "concat(' ', normalize-space(@" .. name .. "), ' '), " ..
    string_value(" " .. value .. " ") .. ")]"
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
    xpath = xpath ..
      "[starts-with(@" .. name .. ", " ..
      string_value(value) .. ")]"
  elseif operator == "$=" then
    xpath = xpath ..
      "[substring(@" .. name .. ", " ..
      "string-length(@" .. name .. ") - " .. #value .. ")" ..
      "=" .. string_value(value) .. "]"
  elseif operator == "*=" then
    xpath = xpath .. "[contains(@" .. name .. ", " .. string_value(value) .. ")]"
  elseif operator == "=" then
    xpath = xpath .. "[@" .. name .. "=" .. string_value(value) .. "]"
  elseif operator == "~=" then
    xpath = attribute_include(xpath, name, value)
  elseif operator == "|=" then
    xpath = xpath ..
      "[@" .. name .. "=" .. string_value(value) .. " or " ..
      "starts-with(@" .. name .. ", " .. string_value(value .. "-") .. ")]"
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

function methods.on_functional_pseudo_lang(self, name, expression)
  local xpath = self.xpaths[#self.xpaths]

  if #expression ~= 1 then
    error("Failed to convert to XPath: " .. name .. ": " ..
            "wrong number of arguments: " ..
            "(given " .. #expression .. ", expected 1)")
  end
  if expression[1][1] ~= "name" then
    error("Failed to convert to XPath: " .. name .. ": " ..
            "1st argument must be name: " ..
            "<" .. expression[1][2] .. ">(" .. expression[1][1] .. ")")
  end
  xpath = xpath .. "[lang(" .. string_value(expression[1][2]) .. ")]"

  self.xpaths[#self.xpaths] = xpath
end

function methods.on_functional_pseudo(self, name, expression)
  local callback = methods["on_functional_pseudo_" .. name]
  if callback then
    callback(self, name, expression)
  else
    error("Failed to convert to XPath: " ..
            "unsupported functional-pseudo: <" .. name .. ">")
  end
end

function XPathConverter.new()
  local converter = {
    xpaths = {},
  }
  setmetatable(converter, metatable)
  return converter
end

return XPathConverter
