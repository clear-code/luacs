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

function TestXPathConverter.test_selectors_group()
  luaunit.assertEquals(
    luacs.to_xpaths("ul, ol"),
    {
      "/descendant::*[local-name()='ul']",
      "/descendant::*[local-name()='ol']",
    }
  )
end

function TestXPathConverter.test_combinator_plus()
  luaunit.assertEquals(
    luacs.to_xpaths("ul + li"),
    {"/descendant::*[local-name()='ul']" ..
       "/following-sibling::*[position()=1][local-name()='li']"})
end

function TestXPathConverter.test_combinator_greater()
  luaunit.assertEquals(
    luacs.to_xpaths("ul > li"),
    {"/descendant::*[local-name()='ul']" ..
       "/*[local-name()='li']"})
end

function TestXPathConverter.test_combinator_tilda()
  luaunit.assertEquals(
    luacs.to_xpaths("ul ~ li"),
    {"/descendant::*[local-name()='ul']" ..
       "/following-sibling::*[local-name()='li']"})
end

function TestXPathConverter.test_combinator_whitespace()
  luaunit.assertEquals(
    luacs.to_xpaths("ul li"),
    {"/descendant::*[local-name()='ul']" ..
       "/descendant::*[local-name()='li']"})
end

function TestXPathConverter.test_type_selector()
  luaunit.assertEquals(
    luacs.to_xpaths("ul"),
    {"/descendant::*[local-name()='ul']"})
end

function TestXPathConverter.test_type_selector_namespace_prefix_name()
  luaunit.assertEquals(
    luacs.to_xpaths("xhtml|ul"),
    {"/descendant::*[name()='xhtml:ul']"})
end

function TestXPathConverter.test_type_selector_namespace_prefix_star()
  luaunit.assertEquals(
    luacs.to_xpaths("*|ul"),
    {"/descendant::*[local-name()='ul']"})
end

function TestXPathConverter.test_type_selector_namespace_prefix_none()
  luaunit.assertEquals(
    luacs.to_xpaths("|ul"),
    {"/descendant::ul"})
end

function TestXPathConverter.test_universal()
  luaunit.assertEquals(
    luacs.to_xpaths("*"),
    {"/descendant::*"})
end

function TestXPathConverter.test_universal_namespace_prefix_name()
  luaunit.assertEquals(
    luacs.to_xpaths("xhtml|*"),
    {"/descendant::*[starts-with(name(), 'xhtml')]"})
end

function TestXPathConverter.test_universal_namespace_prefix_star()
  luaunit.assertEquals(
    luacs.to_xpaths("*|*"),
    {"/descendant::*"})
end

function TestXPathConverter.test_universal_namespace_prefix_none()
  luaunit.assertEquals(
    luacs.to_xpaths("|*"),
    {"/descendant::*[namespace-uri()='']"})
end

function TestXPathConverter.test_hash()
  luaunit.assertEquals(
    luacs.to_xpaths("#main"),
    {"/descendant::*[@id='main' or @name='main']"})
end

function TestXPathConverter.test_hash_type_selector()
  luaunit.assertEquals(
    luacs.to_xpaths("div#main"),
    {"/descendant::*[local-name()='div'][@id='main' or @name='main']"})
end

function TestXPathConverter.test_class()
  luaunit.assertEquals(
    luacs.to_xpaths(".main"),
    {"/descendant::*" ..
       "[@class]" ..
       "[contains(concat(' ', normalize-space(@class), ' '), ' main ')]"})
end

function TestXPathConverter.test_class_type_selector()
  luaunit.assertEquals(
    luacs.to_xpaths("div.main"),
    {"/descendant::*[local-name()='div']" ..
       "[@class]" ..
       "[contains(concat(' ', normalize-space(@class), ' '), ' main ')]"})
end

function TestXPathConverter.test_attribute()
  luaunit.assertEquals(
    luacs.to_xpaths("[data-x]"),
    {"/descendant::*[@data-x]"})
end

function TestXPathConverter.test_class_type_selector()
  luaunit.assertEquals(
    luacs.to_xpaths("div[data-x]"),
    {"/descendant::*[local-name()='div'][@data-x]"})
end

function TestXPathConverter.test_attribute_prefix_match()
  luaunit.assertEquals(
    luacs.to_xpaths("[data-x^='xxx']"),
    {"/descendant::*" ..
       "[@data-x][starts-with(@data-x, 'xxx')]"})
end

function TestXPathConverter.test_attribute_suffix_match()
  luaunit.assertEquals(
    luacs.to_xpaths("[data-x$='xxx']"),
    {"/descendant::*" ..
       "[@data-x][substring(@data-x, string-length(@data-x) - 2) = 'xxx']"})
end

function TestXPathConverter.test_attribute_substring_match()
  luaunit.assertEquals(
    luacs.to_xpaths("[data-x*='xxx']"),
    {"/descendant::*" ..
       "[@data-x][contains(@data-x, 'xxx')]"})
end

function TestXPathConverter.test_attribute_equal()
  luaunit.assertEquals(
    luacs.to_xpaths("[data-x='xxx']"),
    {"/descendant::*" ..
       "[@data-x][@data-x='xxx']"})
end

function TestXPathConverter.test_attribute_include()
  luaunit.assertEquals(
    luacs.to_xpaths("[data-x~='xxx']"),
    {"/descendant::*" ..
       "[@data-x]" ..
       "[contains(concat(' ', normalize-space(@data-x), ' '), ' xxx ')]"})
end

function TestXPathConverter.test_attribute_dash_match()
  luaunit.assertEquals(
    luacs.to_xpaths("[lang|='ja']"),
    {"/descendant::*" ..
       "[@lang][@lang='ja' or starts-with(@lang, 'ja-')]"})
end

function TestXPathConverter.test_attribute_dash_match_namespace_prefix()
  luaunit.assertEquals(
    luacs.to_xpaths("[xml|lang|='ja']"),
    {"/descendant::*" ..
       "[@xml:lang][@xml:lang='ja' or starts-with(@xml:lang, 'ja-')]"})
end

function TestXPathConverter.test_pseudo_element()
  assert_to_xpath_error("::before",
                        "Failed to convert to XPath: " ..
                          "pseudo-element isn't supported: <before>")
end

function TestXPathConverter.test_pseudo_element_type_selector()
  assert_to_xpath_error("div::before",
                        "Failed to convert to XPath: " ..
                          "pseudo-element isn't supported: <before>")
end

function TestXPathConverter.test_pseudo_class()
  assert_to_xpath_error(":hover",
                        "Failed to convert to XPath: " ..
                          "unsupported pseudo-class: <hover>")
end

function TestXPathConverter.test_pseudo_class_type_selector()
  assert_to_xpath_error("a:hover",
                        "Failed to convert to XPath: " ..
                          "unsupported pseudo-class: <hover>")
end

function TestXPathConverter.test_pseudo_class_root()
  luaunit.assertEquals(
    luacs.to_xpaths(":root"),
    {"/descendant::*[not(parent::*)]"})
end

function TestXPathConverter.test_pseudo_class_root_type_selector()
  luaunit.assertEquals(
    luacs.to_xpaths("html:root"),
    {"/descendant::*[local-name()='html'][not(parent::*)]"})
end

function TestXPathConverter.test_pseudo_class_first_child()
  luaunit.assertEquals(
    luacs.to_xpaths("p:first-child"),
    {"/descendant::*[local-name()='p']" ..
       "[count(preceding-sibling::*) = 0]"})
end

function TestXPathConverter.test_pseudo_class_first_child_nested()
  luaunit.assertEquals(
    luacs.to_xpaths("p :first-child"),
    {"/descendant::*[local-name()='p']" ..
       "/descendant::*[count(preceding-sibling::*) = 0]"})
end

function TestXPathConverter.test_pseudo_class_last_child()
  luaunit.assertEquals(
    luacs.to_xpaths("p:last-child"),
    {"/descendant::*[local-name()='p']" ..
       "[count(following-sibling::*) = 0]"})
end

function TestXPathConverter.test_pseudo_class_first_of_type()
  luaunit.assertEquals(
    luacs.to_xpaths("p:first-of-type"),
    {"/descendant::*[local-name()='p']" ..
       "[count(preceding-sibling::*[local-name()='p']) = 0]"})
end

function TestXPathConverter.test_pseudo_class_first_of_type_universal()
  assert_to_xpath_error("*:first-of-type",
                        "Failed to convert to XPath: *:first-of-type: " ..
                          "unsupported pseudo-class")
end

function TestXPathConverter.test_pseudo_class_last_of_type()
  luaunit.assertEquals(
    luacs.to_xpaths("p:last-of-type"),
    {"/descendant::*[local-name()='p']" ..
       "[count(following-sibling::*[local-name()='p']) = 0]"})
end

function TestXPathConverter.test_pseudo_class_last_of_type_universal()
  assert_to_xpath_error("*:last-of-type",
                        "Failed to convert to XPath: *:last-of-type: " ..
                          "unsupported pseudo-class")
end

function TestXPathConverter.test_pseudo_class_only_child()
  luaunit.assertEquals(
    luacs.to_xpaths("p:only-child"),
    {"/descendant::*[local-name()='p']" ..
       "[count(parent::*/*) = 1]"})
end

function TestXPathConverter.test_pseudo_class_only_of_type()
  luaunit.assertEquals(
    luacs.to_xpaths("p:only-of-type"),
    {"/descendant::*[local-name()='p']" ..
       "[count(parent::*/*[local-name()='p']) = 1]"})
end

function TestXPathConverter.test_pseudo_class_only_of_type_universal()
  assert_to_xpath_error("*:only-of-type",
                        "Failed to convert to XPath: *:only-of-type: " ..
                          "unsupported pseudo-class")
end

function TestXPathConverter.test_pseudo_class_empty()
  luaunit.assertEquals(
    luacs.to_xpaths("p:empty"),
    {"/descendant::*[local-name()='p']" ..
       "[not(node())]"})
end

function TestXPathConverter.test_functional_pseudo_lang()
  luaunit.assertEquals(
    luacs.to_xpaths("p:lang(ja)"),
    {"/descendant::*[local-name()='p'][lang('ja')]"})
end

function TestXPathConverter.test_functional_pseudo_nth_child_number()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-child(1)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(preceding-sibling::*) = 0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_child_odd()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-child(odd)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(preceding-sibling::*) mod 2 = 0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_child_even()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-child(even)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(preceding-sibling::*) mod 2 = 1]"})
end

function TestXPathConverter.test_functional_pseudo_nth_child_1n()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-child(1n)"),
    {"/descendant::*[local-name()='p']"})
end

function TestXPathConverter.test_functional_pseudo_nth_child_n_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-child(n + 2)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(preceding-sibling::*) >= 1]"})
end

function TestXPathConverter.test_functional_pseudo_nth_child_n_minus_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-child(n - 2)"),
    {"/descendant::*[local-name()='p']"})
end

function TestXPathConverter.test_functional_pseudo_nth_child_minus_n()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-child(-n)"),
    {"/descendant::*[local-name()='p'][0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_child_minus_n_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-child(-n + 2)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(preceding-sibling::*) <= 1]"})
end

function TestXPathConverter.test_functional_pseudo_nth_child_minus_n_minus_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-child(-n - 2)"),
    {"/descendant::*[local-name()='p'][0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_child_3n()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-child(3n)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(preceding-sibling::*) mod 3 = 2]"})
end

function TestXPathConverter.test_functional_pseudo_nth_child_3n_1()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-child(3n+1)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(preceding-sibling::*) mod 3 = 0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_child_3n_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-child(3n+2)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(preceding-sibling::*) >= 1]" ..
       "[count(preceding-sibling::*) mod 3 = 1]"})
end

function TestXPathConverter.test_functional_pseudo_nth_child_plus_3n_minus_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-child(+3n-2)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(preceding-sibling::*) mod 3 = 0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_child_minus_3n_plus_5()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-child(-3n+5)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(preceding-sibling::*) <= 4]" ..
       "[count(preceding-sibling::*) mod -3 = -2]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_child_number()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-child(1)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(following-sibling::*) = 0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_child_odd()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-child(odd)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(following-sibling::*) mod 2 = 0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_child_even()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-child(even)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(following-sibling::*) mod 2 = 1]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_child_1n()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-child(1n)"),
    {"/descendant::*[local-name()='p']"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_child_n_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-child(n + 2)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(following-sibling::*) >= 1]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_child_n_minus_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-child(n - 2)"),
    {"/descendant::*[local-name()='p']"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_child_minus_n()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-child(-n)"),
    {"/descendant::*[local-name()='p'][0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_child_minus_n_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-child(-n + 2)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(following-sibling::*) <= 1]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_child_minus_n_minus_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-child(-n - 2)"),
    {"/descendant::*[local-name()='p'][0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_child_3n()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-child(3n)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(following-sibling::*) mod 3 = 2]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_child_3n_1()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-child(3n+1)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(following-sibling::*) mod 3 = 0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_child_3n_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-child(3n+2)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(following-sibling::*) >= 1]" ..
       "[count(following-sibling::*) mod 3 = 1]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_child_plus_3n_minus_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-child(+3n-2)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(following-sibling::*) mod 3 = 0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_child_minus_3n_plus_5()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-child(-3n+5)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(following-sibling::*) <= 4]" ..
       "[count(following-sibling::*) mod -3 = -2]"})
end

function TestXPathConverter.test_functional_pseudo_nth_of_type_number()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-of-type(1)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(preceding-sibling::*[local-name()='p']) = 0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_of_type_odd()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-of-type(odd)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(preceding-sibling::*[local-name()='p']) mod 2 = 0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_of_type_even()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-of-type(even)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(preceding-sibling::*[local-name()='p']) mod 2 = 1]"})
end

function TestXPathConverter.test_functional_pseudo_nth_of_type_1n()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-of-type(1n)"),
    {"/descendant::*[local-name()='p']"})
end

function TestXPathConverter.test_functional_pseudo_nth_of_type_n_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-of-type(n + 2)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(preceding-sibling::*[local-name()='p']) >= 1]"})
end

function TestXPathConverter.test_functional_pseudo_nth_of_type_n_minus_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-of-type(n - 2)"),
    {"/descendant::*[local-name()='p']"})
end

function TestXPathConverter.test_functional_pseudo_nth_of_type_minus_n()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-of-type(-n)"),
    {"/descendant::*[local-name()='p'][0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_of_type_minus_n_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-of-type(-n + 2)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(preceding-sibling::*[local-name()='p']) <= 1]"})
end

function TestXPathConverter.test_functional_pseudo_nth_of_type_minus_n_minus_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-of-type(-n - 2)"),
    {"/descendant::*[local-name()='p'][0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_of_type_3n()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-of-type(3n)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(preceding-sibling::*[local-name()='p']) mod 3 = 2]"})
end

function TestXPathConverter.test_functional_pseudo_nth_of_type_3n_1()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-of-type(3n+1)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(preceding-sibling::*[local-name()='p']) mod 3 = 0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_of_type_3n_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-of-type(3n+2)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(preceding-sibling::*[local-name()='p']) >= 1]" ..
       "[count(preceding-sibling::*[local-name()='p']) mod 3 = 1]"})
end

function TestXPathConverter.test_functional_pseudo_nth_of_type_plus_3n_minus_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-of-type(+3n-2)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(preceding-sibling::*[local-name()='p']) mod 3 = 0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_of_type_minus_3n_plus_5()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-of-type(-3n+5)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(preceding-sibling::*[local-name()='p']) <= 4]" ..
       "[count(preceding-sibling::*[local-name()='p']) mod -3 = -2]"})
end

function TestXPathConverter.test_functional_pseudo_nth_of_type_universal()
  assert_to_xpath_error("*:nth-of-type(odd)",
                        "Failed to convert to XPath: *:nth-of-type: " ..
                          "unsupported functional-pseudo")
end

function TestXPathConverter.test_functional_pseudo_nth_last_of_type_number()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-of-type(1)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(following-sibling::*[local-name()='p']) = 0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_of_type_odd()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-of-type(odd)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(following-sibling::*[local-name()='p']) mod 2 = 0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_of_type_even()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-of-type(even)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(following-sibling::*[local-name()='p']) mod 2 = 1]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_of_type_1n()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-of-type(1n)"),
    {"/descendant::*[local-name()='p']"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_of_type_n_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-of-type(n + 2)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(following-sibling::*[local-name()='p']) >= 1]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_of_type_n_minus_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-of-type(n - 2)"),
    {"/descendant::*[local-name()='p']"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_of_type_minus_n()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-of-type(-n)"),
    {"/descendant::*[local-name()='p'][0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_of_type_minus_n_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-of-type(-n + 2)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(following-sibling::*[local-name()='p']) <= 1]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_of_type_minus_n_minus_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-of-type(-n - 2)"),
    {"/descendant::*[local-name()='p'][0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_of_type_3n()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-of-type(3n)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(following-sibling::*[local-name()='p']) mod 3 = 2]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_of_type_3n_1()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-of-type(3n+1)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(following-sibling::*[local-name()='p']) mod 3 = 0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_of_type_3n_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-of-type(3n+2)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(following-sibling::*[local-name()='p']) >= 1]" ..
       "[count(following-sibling::*[local-name()='p']) mod 3 = 1]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_of_type_plus_3n_minus_2()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-of-type(+3n-2)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(following-sibling::*[local-name()='p']) mod 3 = 0]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_of_type_minus_3n_plus_5()
  luaunit.assertEquals(
    luacs.to_xpaths("p:nth-last-of-type(-3n+5)"),
    {"/descendant::*[local-name()='p']" ..
       "[count(following-sibling::*[local-name()='p']) <= 4]" ..
       "[count(following-sibling::*[local-name()='p']) mod -3 = -2]"})
end

function TestXPathConverter.test_functional_pseudo_nth_last_of_type_universal()
  assert_to_xpath_error("*:nth-last-of-type(odd)",
                        "Failed to convert to XPath: *:nth-last-of-type: " ..
                          "unsupported functional-pseudo")
end

function TestXPathConverter.test_functional_pseudo_negation()
  luaunit.assertEquals(
    luacs.to_xpaths(":not([class])"),
    {"/descendant::*" ..
       "[not(self::node()[@class])]"})
end

function TestXPathConverter.test_functional_pseudo_negation_type_selector()
  luaunit.assertEquals(
    luacs.to_xpaths("p:not([class])"),
    {"/descendant::*[local-name()='p']" ..
       "[not(self::node()[@class])]"})
end

