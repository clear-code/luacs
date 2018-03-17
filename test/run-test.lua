#!/usr/bin/env luajit

require("test.test-parser")
require("test.test-xpath-converter")

luaunit = require("luaunit")
os.exit(luaunit.LuaUnit.run())
