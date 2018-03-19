# README

## Name

LuaCS

## Description

LuaCS is a Lua library for parsing [CSS Selectors][css-selectors]. It's written in pure Lua.

LuaCS provides CSS Selectors to [XPath][xpath] converter. You can use the feature by just calling [`luacs.to_xpaths`][luacs-to-xpaths].

[XMLua][xmlua] is well integrated with LuaCS. You can search nodes in HTML/XML DOM with CSS Selectors by ['xmlua.Searchable.css_select`][xmlua-searchable-css-select].

## Dependencies

  * LuaJIT

## Install

See [online document][install].

## Usage

See [online document][tutorial].

## Authors

  * Kouhei Sutou \<kou@clear-code.com\>

## License

MIT. See LICENSE for details.

[css-selectors]:https://www.w3.org/TR/selectors-3/

[xpath]:https://www.w3.org/TR/xpath/

[luacs-to-xpaths]:reference/luacs.html#to-xpaths

[xmlua]:https://clear-code.github.io/xmlua/

[xmlua-searchable-css-select]:https://clear-code.github.io/xmlua/reference/searchable.html#css-select

[install]:https://clear-code.github.io/luacs/install/

[tutorial]:https://clear-code.github.io/luacs/tutorial/
