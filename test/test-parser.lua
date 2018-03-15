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
