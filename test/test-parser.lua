local luaunit = require("luaunit")
local luacs = require("luacs")

TestParser = {}

function parse(selectors_group)
  local events = {}
  local listener = {}
  listener.on_start_selectors_group = function()
    table.insert(events, "start_selectors_group")
  end
  listener.on_start_selector = function()
    table.insert(events, "start_selector")
  end
  listener.on_start_simple_selector_sequence = function()
    table.insert(events, "start_simple_selector_sequence")
  end
  listener.on_type_selector = function(namespace_prefix, element_name)
    table.insert(events, {
                   event = "type_selector",
                   namespace_prefix = namespace_prefix,
                   element_name = element_name,
    })
  end
  listener.on_universal = function(namespace_prefix)
    table.insert(events, {
                   event = "universal",
                   namespace_prefix = namespace_prefix,
    })
  end
  listener.on_hash = function(name)
    table.insert(events, {
                   event = "hash",
                   name = name,
    })
  end
  listener.on_class = function(name)
    table.insert(events, {
                   event = "class",
                   name = name,
    })
  end
  listener.on_attribute = function(namespace_prefix, name)
    table.insert(events, {
                   event = "attribute",
                   namespace_prefix = namespace_prefix,
                   name = name,
    })
  end
  listener.on_pseudo_element = function(name)
    table.insert(events, {
                   event = "pseudo_element",
                   name = name,
    })
  end
  listener.on_pseudo_class = function(name)
    table.insert(events, {
                   event = "pseudo_class",
                   name = name,
    })
  end
  listener.on_functional_pseudo = function(name, expression)
    table.insert(events, {
                   event = "functional_pseudo",
                   name = name,
                   expression = expression,
    })
  end
  local parser = luacs.Parser.new(selectors_group, listener)
  local successed = parser:parse()
  return {successed, events}
end

function TestParser.test_type_selector()
  luaunit.assertEquals(parse("html"),
                       {
                         true,
                         {
                           "start_selectors_group",
                           "start_selector",
                           "start_simple_selector_sequence",
                           {
                             event = "type_selector",
                             namespace_prefix = nil,
                             element_name = "html",
                           },
                         },
                       }
  )
end

function TestParser.test_type_selector_with_namespace_prefix_star()
  luaunit.assertEquals(parse("*|html"),
                       {
                         true,
                         {
                           "start_selectors_group",
                           "start_selector",
                           "start_simple_selector_sequence",
                           {
                             event = "type_selector",
                             namespace_prefix = "*",
                             element_name = "html",
                           },
                         },
                       }
  )
end

function TestParser.test_type_selector_with_namespace_prefix_name()
  luaunit.assertEquals(parse("xhtml|html"),
                       {
                         true,
                         {
                           "start_selectors_group",
                           "start_selector",
                           "start_simple_selector_sequence",
                           {
                             event = "type_selector",
                             namespace_prefix = "xhtml",
                             element_name = "html",
                           },
                         },
                       }
  )
end

function TestParser.test_type_selector_hash()
  luaunit.assertEquals(parse("p#content"),
                       {
                         true,
                         {
                           "start_selectors_group",
                           "start_selector",
                           "start_simple_selector_sequence",
                           {
                             event = "type_selector",
                             namespace_prefix = nil,
                             element_name = "p",
                           },
                           {
                             event = "hash",
                             name = "content",
                           },
                         },
                       }
  )
end

function TestParser.test_type_selector_class()
  luaunit.assertEquals(parse("p.content"),
                       {
                         true,
                         {
                           "start_selectors_group",
                           "start_selector",
                           "start_simple_selector_sequence",
                           {
                             event = "type_selector",
                             namespace_prefix = nil,
                             element_name = "p",
                           },
                           {
                             event = "class",
                             name = "content",
                           },
                         },
                       }
  )
end

function TestParser.test_type_selector_attribute()
  luaunit.assertEquals(parse("p[ id ]"),
                       {
                         true,
                         {
                           "start_selectors_group",
                           "start_selector",
                           "start_simple_selector_sequence",
                           {
                             event = "type_selector",
                             namespace_prefix = nil,
                             element_name = "p",
                           },
                           {
                             event = "attribute",
                             namespace_prefix = nil,
                             name = "id",
                           },
                         },
                       }
  )
end

function TestParser.test_type_selector_attribute_with_namespace_prefix()
  luaunit.assertEquals(parse("p[ xml|lang ]"),
                       {
                         true,
                         {
                           "start_selectors_group",
                           "start_selector",
                           "start_simple_selector_sequence",
                           {
                             event = "type_selector",
                             namespace_prefix = nil,
                             element_name = "p",
                           },
                           {
                             event = "attribute",
                             namespace_prefix = "xml",
                             name = "lang",
                           },
                         },
                       }
  )
end

function TestParser.test_type_selector_pseudo_element()
  luaunit.assertEquals(parse("p::before"),
                       {
                         true,
                         {
                           "start_selectors_group",
                           "start_selector",
                           "start_simple_selector_sequence",
                           {
                             event = "type_selector",
                             namespace_prefix = nil,
                             element_name = "p",
                           },
                           {
                             event = "pseudo_element",
                             name = "before",
                           },
                         },
                       }
  )
end

function TestParser.test_type_selector_pseudo_class()
  luaunit.assertEquals(parse("a:visited"),
                       {
                         true,
                         {
                           "start_selectors_group",
                           "start_selector",
                           "start_simple_selector_sequence",
                           {
                             event = "type_selector",
                             namespace_prefix = nil,
                             element_name = "a",
                           },
                           {
                             event = "pseudo_class",
                             name = "visited",
                           },
                         },
                       }
  )
end

function TestParser.test_type_selector_functional_pseudo_plus()
  luaunit.assertEquals(parse("p:nth-child(+1)"),
                       {
                         true,
                         {
                           "start_selectors_group",
                           "start_selector",
                           "start_simple_selector_sequence",
                           {
                             event = "type_selector",
                             namespace_prefix = nil,
                             element_name = "p",
                           },
                           {
                             event = "functional_pseudo",
                             name = "nth-child",
                             expression = {
                               {"plus"},
                               {"number", 1},
                             },
                           },
                         },
                       }
  )
end

function TestParser.test_type_selector_functional_pseudo_minus()
  luaunit.assertEquals(parse("p:nth-child(-1)"),
                       {
                         true,
                         {
                           "start_selectors_group",
                           "start_selector",
                           "start_simple_selector_sequence",
                           {
                             event = "type_selector",
                             namespace_prefix = nil,
                             element_name = "p",
                           },
                           {
                             event = "functional_pseudo",
                             name = "nth-child",
                             expression = {
                               {"minus"},
                               {"number", 1},
                             },
                           },
                         },
                       }
  )
end

function TestParser.test_type_selector_functional_pseudo_dimension()
  luaunit.assertEquals(parse("p:nth-child(2n)"),
                       {
                         true,
                         {
                           "start_selectors_group",
                           "start_selector",
                           "start_simple_selector_sequence",
                           {
                             event = "type_selector",
                             namespace_prefix = nil,
                             element_name = "p",
                           },
                           {
                             event = "functional_pseudo",
                             name = "nth-child",
                             expression = {
                               {"dimension", "2n"},
                             },
                           },
                         },
                       }
  )
end

function TestParser.test_type_selector_functional_pseudo_number()
  luaunit.assertEquals(parse("p:nth-child(1)"),
                       {
                         true,
                         {
                           "start_selectors_group",
                           "start_selector",
                           "start_simple_selector_sequence",
                           {
                             event = "type_selector",
                             namespace_prefix = nil,
                             element_name = "p",
                           },
                           {
                             event = "functional_pseudo",
                             name = "nth-child",
                             expression = {
                               {"number", 1},
                             },
                           },
                         },
                       }
  )
end

function TestParser.test_type_selector_functional_pseudo_string_double_quote()
  -- TODO: Invalid nth-child
  luaunit.assertEquals(parse("p:nth-child(\"a\")"),
                       {
                         true,
                         {
                           "start_selectors_group",
                           "start_selector",
                           "start_simple_selector_sequence",
                           {
                             event = "type_selector",
                             namespace_prefix = nil,
                             element_name = "p",
                           },
                           {
                             event = "functional_pseudo",
                             name = "nth-child",
                             expression = {
                               {"string", "a"},
                             },
                           },
                         },
                       }
  )
end

function TestParser.test_type_selector_functional_pseudo_string_single_quote()
  -- TODO: Invalid nth-child
  luaunit.assertEquals(parse("p:nth-child('a')"),
                       {
                         true,
                         {
                           "start_selectors_group",
                           "start_selector",
                           "start_simple_selector_sequence",
                           {
                             event = "type_selector",
                             namespace_prefix = nil,
                             element_name = "p",
                           },
                           {
                             event = "functional_pseudo",
                             name = "nth-child",
                             expression = {
                               {"string", "a"},
                             },
                           },
                         },
                       }
  )
end

function TestParser.test_type_selector_functional_pseudo_ident()
  luaunit.assertEquals(parse("p:lang(ja)"),
                       {
                         true,
                         {
                           "start_selectors_group",
                           "start_selector",
                           "start_simple_selector_sequence",
                           {
                             event = "type_selector",
                             namespace_prefix = nil,
                             element_name = "p",
                           },
                           {
                             event = "functional_pseudo",
                             name = "lang",
                             expression = {
                               {"name", "ja"},
                             },
                           },
                         },
                       }
  )
end

function TestParser.test_universal()
  luaunit.assertEquals(parse("*"),
                       {
                         true,
                         {
                           "start_selectors_group",
                           "start_selector",
                           "start_simple_selector_sequence",
                           {
                             event = "universal",
                             namespace_prefix = nil,
                           },
                         },
                       }
  )
end

function TestParser.test_universal_with_namespace_prefix_star()
  luaunit.assertEquals(parse("*|*"),
                       {
                         true,
                         {
                           "start_selectors_group",
                           "start_selector",
                           "start_simple_selector_sequence",
                           {
                             event = "universal",
                             namespace_prefix = "*",
                           },
                         },
                       }
  )
end

function TestParser.test_universal_with_namespace_prefix_name()
  luaunit.assertEquals(parse("xhtml|*"),
                       {
                         true,
                         {
                           "start_selectors_group",
                           "start_selector",
                           "start_simple_selector_sequence",
                           {
                             event = "universal",
                             namespace_prefix = "xhtml",
                           },
                         },
                       }
  )
end

function TestParser.test_universal_hash()
  luaunit.assertEquals(parse("*#content"),
                       {
                         true,
                         {
                           "start_selectors_group",
                           "start_selector",
                           "start_simple_selector_sequence",
                           {
                             event = "universal",
                             namespace_prefix = nil,
                           },
                           {
                             event = "hash",
                             name = "content",
                           },
                         },
                       }
  )
end

function TestParser.test_universal_class()
  luaunit.assertEquals(parse("*.content"),
                       {
                         true,
                         {
                           "start_selectors_group",
                           "start_selector",
                           "start_simple_selector_sequence",
                           {
                             event = "universal",
                             namespace_prefix = nil,
                           },
                           {
                             event = "class",
                             name = "content",
                           },
                         },
                       }
  )
end

function TestParser.test_universal_attribute()
  luaunit.assertEquals(parse("*[id]"),
                       {
                         true,
                         {
                           "start_selectors_group",
                           "start_selector",
                           "start_simple_selector_sequence",
                           {
                             event = "universal",
                             namespace_prefix = nil,
                           },
                           {
                             event = "attribute",
                             namespace_prefix = nil,
                             name = "id",
                           },
                         },
                       }
  )
end

function TestParser.test_universal_attribute_with_namespace_prefix()
  luaunit.assertEquals(parse("*[xml|lang]"),
                       {
                         true,
                         {
                           "start_selectors_group",
                           "start_selector",
                           "start_simple_selector_sequence",
                           {
                             event = "universal",
                             namespace_prefix = nil,
                           },
                           {
                             event = "attribute",
                             namespace_prefix = "xml",
                             name = "lang",
                           },
                         },
                       }
  )
end

function TestParser.test_universal_pseudo_element()
  luaunit.assertEquals(parse("*::before"),
                       {
                         true,
                         {
                           "start_selectors_group",
                           "start_selector",
                           "start_simple_selector_sequence",
                           {
                             event = "universal",
                             namespace_prefix = nil,
                           },
                           {
                             event = "pseudo_element",
                             name = "before",
                           },
                         },
                       }
  )
end

function TestParser.test_universal_pseudo_class()
  luaunit.assertEquals(parse("*:visited"),
                       {
                         true,
                         {
                           "start_selectors_group",
                           "start_selector",
                           "start_simple_selector_sequence",
                           {
                             event = "universal",
                             namespace_prefix = nil,
                           },
                           {
                             event = "pseudo_class",
                             name = "visited",
                           },
                         },
                       }
  )
end

function TestParser.test_universal_functional_pseudo_plus()
  luaunit.assertEquals(parse("*:nth-child(+1)"),
                       {
                         true,
                         {
                           "start_selectors_group",
                           "start_selector",
                           "start_simple_selector_sequence",
                           {
                             event = "universal",
                             namespace_prefix = nil,
                           },
                           {
                             event = "functional_pseudo",
                             name = "nth-child",
                             expression = {
                               {"plus"},
                               {"number", 1},
                             },
                           },
                         },
                       }
  )
end

function TestParser.test_universal_functional_pseudo_minus()
  luaunit.assertEquals(parse("*:nth-child(-1)"),
                       {
                         true,
                         {
                           "start_selectors_group",
                           "start_selector",
                           "start_simple_selector_sequence",
                           {
                             event = "universal",
                             namespace_prefix = nil,
                           },
                           {
                             event = "functional_pseudo",
                             name = "nth-child",
                             expression = {
                               {"minus"},
                               {"number", 1},
                             },
                           },
                         },
                       }
  )
end

function TestParser.test_universal_functional_pseudo_dimension()
  luaunit.assertEquals(parse("*:nth-child(2n)"),
                       {
                         true,
                         {
                           "start_selectors_group",
                           "start_selector",
                           "start_simple_selector_sequence",
                           {
                             event = "universal",
                             namespace_prefix = nil,
                           },
                           {
                             event = "functional_pseudo",
                             name = "nth-child",
                             expression = {
                               {"dimension", "2n"},
                             },
                           },
                         },
                       }
  )
end

function TestParser.test_universal_functional_pseudo_number()
  luaunit.assertEquals(parse("*:nth-child(1)"),
                       {
                         true,
                         {
                           "start_selectors_group",
                           "start_selector",
                           "start_simple_selector_sequence",
                           {
                             event = "universal",
                             namespace_prefix = nil,
                           },
                           {
                             event = "functional_pseudo",
                             name = "nth-child",
                             expression = {
                               {"number", 1},
                             },
                           },
                         },
                       }
  )
end

function TestParser.test_universal_functional_pseudo_string_double_quote()
  -- TODO: Invalid nth-child
  luaunit.assertEquals(parse("*:nth-child(\"a\")"),
                       {
                         true,
                         {
                           "start_selectors_group",
                           "start_selector",
                           "start_simple_selector_sequence",
                           {
                             event = "universal",
                             namespace_prefix = nil,
                           },
                           {
                             event = "functional_pseudo",
                             name = "nth-child",
                             expression = {
                               {"string", "a"},
                             },
                           },
                         },
                       }
  )
end

function TestParser.test_universal_functional_pseudo_string_single_quote()
  -- TODO: Invalid nth-child
  luaunit.assertEquals(parse("*:nth-child('a')"),
                       {
                         true,
                         {
                           "start_selectors_group",
                           "start_selector",
                           "start_simple_selector_sequence",
                           {
                             event = "universal",
                             namespace_prefix = nil,
                           },
                           {
                             event = "functional_pseudo",
                             name = "nth-child",
                             expression = {
                               {"string", "a"},
                             },
                           },
                         },
                       }
  )
end

function TestParser.test_universal_functional_pseudo_ident()
  luaunit.assertEquals(parse("*:lang(ja)"),
                       {
                         true,
                         {
                           "start_selectors_group",
                           "start_selector",
                           "start_simple_selector_sequence",
                           {
                             event = "universal",
                             namespace_prefix = nil,
                           },
                           {
                             event = "functional_pseudo",
                             name = "lang",
                             expression = {
                               {"name", "ja"},
                             },
                           },
                         },
                       }
  )
end
