#!/usr/bin/env luajit

require("test.test-parser")

luaunit = require("luaunit")
os.exit(luaunit.LuaUnit.run())
