local luaunit = require("luaunit")
local luacs = require("luacs")

TestXPathConverter = {}

local function assert_to_xpath_error(css_selector_groups, expected_message)
  local success, actual_message = pcall(luacs.to_xpaths, css_selector_groups)
  luaunit.failIf(success,
                 "Must be fail to convert: <" .. css_selector_groups .. ">")
  luaunit.assertEquals(actual_message:gsub("^.+:%d+: ", ""),
                       expected_message)
end

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

function TestXPathConverter.test_pseudo_element()
  assert_to_xpath_error("div::before",
                        "Failed to convert to XPath: " ..
                          "pseudo-element isn't supported: <before>")
end

function TestXPathConverter.test_pseudo_class()
  assert_to_xpath_error("a:hover",
                        "Failed to convert to XPath: " ..
                          "unsupported pseudo-class: <hover>")
end

function TestXPathConverter.test_pseudo_class_root()
  luaunit.assertEquals(
    luacs.to_xpaths("html:root"),
    {"/descendant-or-self::*[local-name()='html'][not(parent::*)]"})
end

function TestXPathConverter.test_pseudo_class_first_child()
  luaunit.assertEquals(
    luacs.to_xpaths("p:first-child"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(preceding-sibling::*) = 0]"})
end

function TestXPathConverter.test_pseudo_class_last_child()
  luaunit.assertEquals(
    luacs.to_xpaths("p:last-child"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(following-sibling::*) = 0]"})
end

function TestXPathConverter.test_pseudo_class_first_of_type()
  luaunit.assertEquals(
    luacs.to_xpaths("p:first-of-type"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(preceding-sibling::*[local-name()='p']) = 0]"})
end

function TestXPathConverter.test_pseudo_class_first_of_type_universal()
  luaunit.assertEquals(
    luacs.to_xpaths("*:first-of-type"),
    {"/descendant-or-self::*" ..
       "[count(preceding-sibling::*) = 0]"})
end

function TestXPathConverter.test_functional_pseudo_lang()
  luaunit.assertEquals(
    luacs.to_xpaths("p:lang(ja)"),
    {"/descendant-or-self::*[local-name()='p'][lang('ja')]"})
end

function TestXPathConverter.test_functional_pseudo_nth_child_number()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-child(1)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(preceding-sibling::*) = 0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_child_odd()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-child(odd)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(preceding-sibling::*) mod 2 = 0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_child_even()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-child(even)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(preceding-sibling::*) mod 2 = 1]"})
end

function TestXPathConverter.test_functional_pseudo_nth_child_1n()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-child(1n)"),
    {"/descendant-or-self::*[local-name()='p']"})
end

function TestXPathConverter.test_functional_pseudo_nth_child_n_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-child(n + 2)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(preceding-sibling::*) >= 1]"})
end

function TestXPathConverter.test_functional_pseudo_nth_child_n_minus_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-child(n - 2)"),
    {"/descendant-or-self::*[local-name()='p']"})
end

function TestXPathConverter.test_functional_pseudo_nth_child_minus_n()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-child(-n)"),
    {"/descendant-or-self::*[local-name()='p'][0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_child_minus_n_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-child(-n + 2)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(preceding-sibling::*) <= 1]"})
end

function TestXPathConverter.test_functional_pseudo_nth_child_minus_n_minus_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-child(-n - 2)"),
    {"/descendant-or-self::*[local-name()='p'][0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_child_3n()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-child(3n)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(preceding-sibling::*) mod 3 = 2]"})
end

function TestXPathConverter.test_functional_pseudo_nth_child_3n_1()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-child(3n+1)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(preceding-sibling::*) mod 3 = 0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_child_3n_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-child(3n+2)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(preceding-sibling::*) >= 1]" ..
       "[count(preceding-sibling::*) mod 3 = 1]"})
end

function TestXPathConverter.test_functional_pseudo_nth_child_plus_3n_minus_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-child(+3n-2)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(preceding-sibling::*) mod 3 = 0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_child_minus_3n_plus_5()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-child(-3n+5)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(preceding-sibling::*) <= 4]" ..
       "[count(preceding-sibling::*) mod -3 = -2]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_child_number()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-child(1)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(following-sibling::*) = 0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_child_odd()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-child(odd)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(following-sibling::*) mod 2 = 0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_child_even()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-child(even)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(following-sibling::*) mod 2 = 1]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_child_1n()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-child(1n)"),
    {"/descendant-or-self::*[local-name()='p']"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_child_n_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-child(n + 2)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(following-sibling::*) >= 1]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_child_n_minus_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-child(n - 2)"),
    {"/descendant-or-self::*[local-name()='p']"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_child_minus_n()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-child(-n)"),
    {"/descendant-or-self::*[local-name()='p'][0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_child_minus_n_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-child(-n + 2)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(following-sibling::*) <= 1]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_child_minus_n_minus_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-child(-n - 2)"),
    {"/descendant-or-self::*[local-name()='p'][0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_child_3n()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-child(3n)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(following-sibling::*) mod 3 = 2]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_child_3n_1()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-child(3n+1)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(following-sibling::*) mod 3 = 0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_child_3n_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-child(3n+2)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(following-sibling::*) >= 1]" ..
       "[count(following-sibling::*) mod 3 = 1]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_child_plus_3n_minus_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-child(+3n-2)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(following-sibling::*) mod 3 = 0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_child_minus_3n_plus_5()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-child(-3n+5)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(following-sibling::*) <= 4]" ..
       "[count(following-sibling::*) mod -3 = -2]"})
end

function TestXPathConverter.test_functional_pseudo_nth_of_type_number()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-of-type(1)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(preceding-sibling::*[local-name()='p']) = 0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_of_type_odd()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-of-type(odd)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(preceding-sibling::*[local-name()='p']) mod 2 = 0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_of_type_even()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-of-type(even)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(preceding-sibling::*[local-name()='p']) mod 2 = 1]"})
end

function TestXPathConverter.test_functional_pseudo_nth_of_type_1n()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-of-type(1n)"),
    {"/descendant-or-self::*[local-name()='p']"})
end

function TestXPathConverter.test_functional_pseudo_nth_of_type_n_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-of-type(n + 2)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(preceding-sibling::*[local-name()='p']) >= 1]"})
end

function TestXPathConverter.test_functional_pseudo_nth_of_type_n_minus_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-of-type(n - 2)"),
    {"/descendant-or-self::*[local-name()='p']"})
end

function TestXPathConverter.test_functional_pseudo_nth_of_type_minus_n()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-of-type(-n)"),
    {"/descendant-or-self::*[local-name()='p'][0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_of_type_minus_n_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-of-type(-n + 2)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(preceding-sibling::*[local-name()='p']) <= 1]"})
end

function TestXPathConverter.test_functional_pseudo_nth_of_type_minus_n_minus_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-of-type(-n - 2)"),
    {"/descendant-or-self::*[local-name()='p'][0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_of_type_3n()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-of-type(3n)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(preceding-sibling::*[local-name()='p']) mod 3 = 2]"})
end

function TestXPathConverter.test_functional_pseudo_nth_of_type_3n_1()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-of-type(3n+1)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(preceding-sibling::*[local-name()='p']) mod 3 = 0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_of_type_3n_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-of-type(3n+2)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(preceding-sibling::*[local-name()='p']) >= 1]" ..
       "[count(preceding-sibling::*[local-name()='p']) mod 3 = 1]"})
end

function TestXPathConverter.test_functional_pseudo_nth_of_type_plus_3n_minus_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-of-type(+3n-2)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(preceding-sibling::*[local-name()='p']) mod 3 = 0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_of_type_minus_3n_plus_5()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-of-type(-3n+5)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(preceding-sibling::*[local-name()='p']) <= 4]" ..
       "[count(preceding-sibling::*[local-name()='p']) mod -3 = -2]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_of_type_number()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-of-type(1)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(following-sibling::*[local-name()='p']) = 0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_of_type_odd()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-of-type(odd)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(following-sibling::*[local-name()='p']) mod 2 = 0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_of_type_even()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-of-type(even)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(following-sibling::*[local-name()='p']) mod 2 = 1]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_of_type_1n()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-of-type(1n)"),
    {"/descendant-or-self::*[local-name()='p']"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_of_type_n_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-of-type(n + 2)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(following-sibling::*[local-name()='p']) >= 1]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_of_type_n_minus_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-of-type(n - 2)"),
    {"/descendant-or-self::*[local-name()='p']"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_of_type_minus_n()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-of-type(-n)"),
    {"/descendant-or-self::*[local-name()='p'][0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_of_type_minus_n_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-of-type(-n + 2)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(following-sibling::*[local-name()='p']) <= 1]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_of_type_minus_n_minus_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-of-type(-n - 2)"),
    {"/descendant-or-self::*[local-name()='p'][0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_of_type_3n()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-of-type(3n)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(following-sibling::*[local-name()='p']) mod 3 = 2]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_of_type_3n_1()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-of-type(3n+1)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(following-sibling::*[local-name()='p']) mod 3 = 0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_of_type_3n_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-of-type(3n+2)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(following-sibling::*[local-name()='p']) >= 1]" ..
       "[count(following-sibling::*[local-name()='p']) mod 3 = 1]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_of_type_plus_3n_minus_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-of-type(+3n-2)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(following-sibling::*[local-name()='p']) mod 3 = 0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_of_type_minus_3n_plus_5()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-of-type(-3n+5)"),
    {"/descendant-or-self::*[local-name()='p']" ..
       "[count(following-sibling::*[local-name()='p']) <= 4]" ..
       "[count(following-sibling::*[local-name()='p']) mod -3 = -2]"})
end
