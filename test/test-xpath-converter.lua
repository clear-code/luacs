local luaunit = require("luaunit")
local luacs = require("luacs")

TestXPathConverter = {}

function TestXPathConverter.test_combinator_plus()
  luaunit.assertEquals(
    luacs.to_xpaths("ul + li"),
    {"/descendant-or-self::ul" ..
       "/following-sibling::*[name() = 'li' and position() = 1]"})
end

function TestXPathConverter.test_combinator_greater()
  luaunit.assertEquals(luacs.to_xpaths("ul > li"),
                       {"/descendant-or-self::ul/li"})
end

function TestXPathConverter.test_combinator_tilda()
  luaunit.assertEquals(luacs.to_xpaths("ul ~ li"),
                       {"/descendant-or-self::ul/following-sibling::li"})
end

function TestXPathConverter.test_combinator_none()
  luaunit.assertEquals(luacs.to_xpaths("ul li"),
                       {"/descendant-or-self::ul/descendant-or-self::li"})
end
