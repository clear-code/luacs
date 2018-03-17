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

function TestXPathConverter.test_hash()
  luaunit.assertEquals(
    luacs.to_xpaths("div#main"),
    {"/descendant-or-self::*[local-name()='div'][@id='main' or @name='main']"})
end

function TestXPathConverter.test_class()
  luaunit.assertEquals(
    luacs.to_xpaths("div.main"),
    {"/descendant-or-self::*[local-name()='div']" ..
       "[@class]" ..
       "[contains(concat(' ', normalize-space(@class), ' '), ' main ')]"})
end

function TestXPathConverter.test_attribute()
  luaunit.assertEquals(
    luacs.to_xpaths("div[data-x]"),
    {"/descendant-or-self::*[local-name()='div'][@data-x]"})
end

function TestXPathConverter.test_attribute_prefix_match()
  luaunit.assertEquals(
    luacs.to_xpaths("div[data-x^='xxx']"),
    {"/descendant-or-self::*[local-name()='div']" ..
       "[@data-x][starts-with(@data-x, 'xxx')]"})
end

function TestXPathConverter.test_attribute_suffix_match()
  luaunit.assertEquals(
    luacs.to_xpaths("div[data-x$='xxx']"),
    {"/descendant-or-self::*[local-name()='div']" ..
       "[@data-x][substring(@data-x, string-length(@data-x) - 3)='xxx']"})
end

function TestXPathConverter.test_attribute_substring_match()
  luaunit.assertEquals(
    luacs.to_xpaths("div[data-x*='xxx']"),
    {"/descendant-or-self::*[local-name()='div']" ..
       "[@data-x][contains(@data-x, 'xxx')]"})
end

function TestXPathConverter.test_attribute_equal()
  luaunit.assertEquals(
    luacs.to_xpaths("div[data-x='xxx']"),
    {"/descendant-or-self::*[local-name()='div']" ..
       "[@data-x][@data-x='xxx']"})
end

function TestXPathConverter.test_attribute_include()
  luaunit.assertEquals(
    luacs.to_xpaths("div[data-x~='xxx']"),
    {"/descendant-or-self::*[local-name()='div']" ..
       "[@data-x]" ..
       "[contains(concat(' ', normalize-space(@data-x), ' '), ' xxx ')]"})
end

function TestXPathConverter.test_attribute_dash_match()
  luaunit.assertEquals(
    luacs.to_xpaths("div[xml|lang|='ja']"),
    {"/descendant-or-self::*[local-name()='div']" ..
       "[@xml:lang][@xml:lang='ja' or starts-with(@xml:lang, 'ja-')]"})
end
