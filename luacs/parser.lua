local Parser = {}

local Source = require("luacs.source")

local methods = {}

local metatable = {}
function metatable.__index(parser, key)
  return methods[key]
end

-- Specification: https://www.w3.org/TR/selectors-3/
--
-- Grammar:
--
-- selectors_group
--   : selector [ COMMA S* selector ]*
--   ;
--
-- selector
--   : simple_selector_sequence [ combinator simple_selector_sequence ]*
--   ;
--
-- combinator
--   /* combinators can be surrounded by whitespace */
--   : PLUS S* | GREATER S* | TILDE S* | S+
--   ;
--
-- simple_selector_sequence
--   : [ type_selector | universal ]
--     [ HASH | class | attrib | pseudo | negation ]*
--   | [ HASH | class | attrib | pseudo | negation ]+
--   ;
--
-- type_selector
--   : [ namespace_prefix ]? element_name
--   ;
--
-- namespace_prefix
--   : [ IDENT | '*' ]? '|'
--   ;
--
-- element_name
--   : IDENT
--   ;
--
-- universal
--   : [ namespace_prefix ]? '*'
--   ;
--
-- class
--   : '.' IDENT
--   ;
--
-- attrib
--   : '[' S* [ namespace_prefix ]? IDENT S*
--         [ [ PREFIXMATCH |
--             SUFFIXMATCH |
--             SUBSTRINGMATCH |
--             '=' |
--             INCLUDES |
--             DASHMATCH ] S* [ IDENT | STRING ] S*
--         ]? ']'
--   ;
--
-- pseudo
--   /* '::' starts a pseudo-element, ':' a pseudo-class */
--   /* Exceptions: :first-line, :first-letter, :before and :after. */
--   /* Note that pseudo-elements are restricted to one per selector and */
--   /* occur only in the last simple_selector_sequence. */
--   : ':' ':'? [ IDENT | functional_pseudo ]
--   ;
--
-- functional_pseudo
--   : FUNCTION S* expression ')'
--   ;
--
-- expression
--   /* In CSS3, the expressions are identifiers, strings, */
--   /* or of the form "an+b" */
--   : [ [ PLUS | '-' | DIMENSION | NUMBER | STRING | IDENT ] S* ]+
--   ;
--
-- negation
--   : NOT S* negation_arg S* ')'
--   ;
--
-- negation_arg
--   : type_selector | universal | HASH | class | attrib | pseudo
--   ;
--
--
-- Lexer:
--
-- %option case-insensitive
--
-- ident     [-]?{nmstart}{nmchar}*
-- name      {nmchar}+
-- nmstart   [_a-z]|{nonascii}|{escape}
-- nonascii  [^\0-\177]
-- unicode   \\[0-9a-f]{1,6}(\r\n|[ \n\r\t\f])?
-- escape    {unicode}|\\[^\n\r\f0-9a-f]
-- nmchar    [_a-z0-9-]|{nonascii}|{escape}
-- num       [0-9]+|[0-9]*\.[0-9]+
-- string    {string1}|{string2}
-- string1   \"([^\n\r\f\\"]|\\{nl}|{nonascii}|{escape})*\"
-- string2   \'([^\n\r\f\\']|\\{nl}|{nonascii}|{escape})*\'
-- invalid   {invalid1}|{invalid2}
-- invalid1  \"([^\n\r\f\\"]|\\{nl}|{nonascii}|{escape})*
-- invalid2  \'([^\n\r\f\\']|\\{nl}|{nonascii}|{escape})*
-- nl        \n|\r\n|\r|\f
-- w         [ \t\r\n\f]*
--
-- D         d|\\0{0,4}(44|64)(\r\n|[ \t\r\n\f])?
-- E         e|\\0{0,4}(45|65)(\r\n|[ \t\r\n\f])?
-- N         n|\\0{0,4}(4e|6e)(\r\n|[ \t\r\n\f])?|\\n
-- O         o|\\0{0,4}(4f|6f)(\r\n|[ \t\r\n\f])?|\\o
-- T         t|\\0{0,4}(54|74)(\r\n|[ \t\r\n\f])?|\\t
-- V         v|\\0{0,4}(58|78)(\r\n|[ \t\r\n\f])?|\\v
--
-- %%
--
-- [ \t\r\n\f]+     return S;
--
-- "~="             return INCLUDES;
-- "|="             return DASHMATCH;
-- "^="             return PREFIXMATCH;
-- "$="             return SUFFIXMATCH;
-- "*="             return SUBSTRINGMATCH;
-- {ident}          return IDENT;
-- {string}         return STRING;
-- {ident}"("       return FUNCTION;
-- {num}            return NUMBER;
-- "#"{name}        return HASH;
-- {w}"+"           return PLUS;
-- {w}">"           return GREATER;
-- {w}","           return COMMA;
-- {w}"~"           return TILDE;
-- ":"{N}{O}{T}"("  return NOT;
-- @{ident}         return ATKEYWORD;
-- {invalid}        return INVALID;
-- {num}%           return PERCENTAGE;
-- {num}{ident}     return DIMENSION;
-- "<!--"           return CDO;
-- "-->"            return CDC;
--
-- \/\*[^*]*\*+([^/*][^*]*\*+)*\/                    /* ignore comments */
--
-- .                return *yytext;

local function on(parser, name, ...)
  local callback = parser.listener["on_" .. name]
  if callback then
    callback(...)
  end
end

local function type_selector(parser)
  local source = parser.source
  local position = source.position
  local namespace_prefix = source:match_namespace_prefix()
  local element_name = source:match_ident()

  if not element_name then
    source:seek(position)
    return false
  end

  on(parser, "type_selector", namespace_prefix, element_name)
  return true
end

local function universal(parser)
  local source = parser.source
  local position = source.position
  local namespace_prefix = source:match_namespace_prefix()
  local asterisk = source:match("%*")

  if not asterisk then
    source:seek(position)
    return false
  end

  on(parser, "universal", namespace_prefix)
  return true
end

local function hash(parser)
  local name = parser.source:match_hash()
  if name then
    on(parser, "hash", name)
    return true
  else
    return false
  end
end

local function class(parser)
  local source = parser.source
  local position = source.position

  if not source:match(".") then
    return false
  end

  local name = parser.source:match_ident()
  if name then
    on(parser, "class", name)
    return true
  else
    source:seek(position)
    return false
  end
end

local function simple_selector_sequence(parser)
  on(parser, "start_simple_selector_sequence")
  if type_selector(parser) or universal(parser) then
    if hash(parser) or class(parser) then
    end
    return true
  else
    return false
  end
end

local function selector(parser)
  on(parser, "start_selector")
  if not simple_selector_sequence(parser) then
    return false
  end
  return true
end

local function selectors_group(parser)
  parser.source:skip_whitespaces()
  on(parser, "start_selectors_group")
  if not selector(parser) then
    return false
  end
  while true do
    parser.source:skip_whitespaces()
    if not parser.source:match(",") then
      return true
    end
    if not selector(parser) then
      error("XXX")
      return false
    end
  end
  return true
end

function methods.parse(self)
  return selectors_group(self)
end

function Parser.new(input, listener)
  local parser = {
    source = Source.new(input),
    listener = listener,
  }
  setmetatable(parser, metatable)
  return parser
end

return Parser
