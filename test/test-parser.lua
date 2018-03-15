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
