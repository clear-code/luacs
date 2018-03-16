-- -*- lua -*-

local package_version = "1.0.0"

package = "LuaCS"
version = package_version .. "-0"
description = {
  summary = "LuaCS is a Lua library for processing CSS selector",
  detailed = [[
    LuaCS provides CSS selector parser.
    LuaCS also provides CSS selector to XPath converter.
  ]],
  license = "MIT",
  homepage = "https://clear-code.github.io/luacs/",
  -- Since 3.0
  -- issues_url = "https://github.com/clear-code/luacs/issues",
  maintainer = "Horimoto Yasuhiro <horimoto@clear-code.com> and Kouhei Sutou <kou@clear-code.com>",
  -- Since 3.0
  -- labels = {"css"},
}
source = {
  url = "https://github.com/clear-code/luacs/archive/" .. package_version .. ".zip",
  dir = "luacs-" .. package_version,
}
build = {
  type = "builtin",
  modules = {
    ["luacs"] = "luacs.lua",
    ["luacs.parser"] = "luacs/parser.lua",
    ["luacs.source"] = "luacs/source.lua",
  },
  copy_directories = {
    "docs",
  }
}
