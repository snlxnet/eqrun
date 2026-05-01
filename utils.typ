#import "./greek.typ": greek

#let is-number(content) = regex("^[.,\\d]+$") in content.text
#let get-sym-name(symbol) = {
  if type(symbol) == "content" {
    symbol = symbol.text
  }
  let match = greek.find(((key, val)) => val == symbol)

  if match == none {
    symbol
  } else {
    match.at(0)
  }
}

#let to-array(token-or-math-block) = {
  if type(token-or-math-block) == array {
    token-or-math-block
  } else if token-or-math-block.has("children") {
    token-or-math-block.children
  } else {
    (token-or-math-block,)
  }
}

