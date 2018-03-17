local luaunit = require("luaunit")
local luacs = require("luacs")

TestXPathConverter = {}

function TestXPathConverter.test_combinator_plus()
  luaunit.assertEquals(
    luacs.to_xpaths("ul + li"),
    {"/descendant-or-self::*[local-name()='ul']" ..
       "/following-sibling::*[position()=1][local-name()='li']"})
end

function TestXPathConverter.test_combinator_greater()
  luaunit.assertEquals(
    luacs.to_xpaths("ul > li"),
    {"/descendant-or-self::*[local-name()='ul']" ..
       "/*[local-name()='li']"})
end

function TestXPathConverter.test_combinator_tilda()
  luaunit.assertEquals(
    luacs.to_xpaths("ul ~ li"),
    {"/descendant-or-self::*[local-name()='ul']" ..
       "/following-sibling::*[local-name()='li']"})
end

function TestXPathConverter.test_combinator_whitespace()
  luaunit.assertEquals(
    luacs.to_xpaths("ul li"),
    {"/descendant-or-self::*[local-name()='ul']" ..
       "/descendant-or-self::*[local-name()='li']"})
end

function TestXPathConverter.test_type_selector()
  luaunit.assertEquals(
    luacs.to_xpaths("ul"),
    {"/descendant-or-self::*[local-name()='ul']"})
end

function TestXPathConverter.test_type_selector_namespace_prefix_name()
  luaunit.assertEquals(
    luacs.to_xpaths("xhtml|ul"),
    {"/descendant-or-self::xhtml:ul"})
end

function TestXPathConverter.test_type_selector_namespace_prefix_star()
  luaunit.assertEquals(
    luacs.to_xpaths("*|ul"),
    {"/descendant-or-self::*[local-name()='ul']"})
end

function TestXPathConverter.test_type_selector_namespace_prefix_none()
  luaunit.assertEquals(
    luacs.to_xpaths("|ul"),
    {"/descendant-or-self::ul"})
end

function TestXPathConverter.test_universal()
  luaunit.assertEquals(
    luacs.to_xpaths("*"),
    {"/descendant-or-self::*"})
end

function TestXPathConverter.test_universal_namespace_prefix_name()
  luaunit.assertEquals(
    luacs.to_xpaths("xhtml|*"),
    {"/descendant-or-self::*[starts-with(name(), 'xhtml')]"})
end

function TestXPathConverter.test_universal_namespace_prefix_star()
  luaunit.assertEquals(
    luacs.to_xpaths("*|*"),
    {"/descendant-or-self::*"})
end

function TestXPathConverter.test_universal_namespace_prefix_none()
  luaunit.assertEquals(
    luacs.to_xpaths("|*"),
    {"/descendant-or-self::*[namespace-uri()='']"})
end
