#set page(paper: "a5")
#set text(font: "JetBrainsMono NF")
#import "@preview/catppuccin:1.1.0": catppuccin, flavors
#show: catppuccin.with(flavors.mocha)

#let is-number(content) = regex("^\\d+$") in content.text
#let sym-name(symbol) = {
  import "./greek.typ": greek

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
#let parse-attach(input) = {
  if not input.has("base") {
    return input.text
  }

  let name = "vars." + if input.has("b") {
    input.base.text + "-" + sym-name(input.b.text)
  } else {
    input.base.text
  }

  if not input.has("t") {
    return name
  }

  if is-number(input.t) {
    "calc.pow(" + name + ", " + input.t.text + ")"
  } else {
    name + "-" + sym-name(input.t)
  }
}
#let parse-word(input) = {
  if is-number(input) {
    return input.text
  } else {
    return "vars." + input.text
  }
}
// undividable, either an attach or a word
#let parse-atom(input) = {
  if input.func() == math.attach {
    parse-attach(input)
  } else {
    parse-word(input)
  }
}
#let parse-root(input) = {
  let index = parse-atom(if input.has("index") { input.index } else { [2] })
  let radicand = parse-atom(input.radicand)

  "calc.root(" + radicand + ", " + index + ")"
}

#let expr = $P = a^2 + b_t + sqrt(x)$
#let tokens = expr.body.children.filter(elem => elem != [ ])
#let (left-side, right-side) = {
  let left-side = ()
  let right-side = ()
  let eq-ahead = true

  for token in tokens {
    if token == [#math.eq] {
      eq-ahead = false
      continue
    }

    if eq-ahead { left-side.push(token) } else { right-side.push(token) }
  }

  if eq-ahead {
    right-side = (..left-side)
    left-side = ([result],)
  }

  (left-side, right-side)
}
left: #left-side

right: #right-side

#let tokens = right-side.map(token => {
  if token.func() == math.attach {
    parse-attach(token)
  } else if token.func() == math.root {
    parse-root(token)
  }
})

parsed: #tokens

#let vars = (
  base-bottom: 16,
  a: 2,
  a-tau-b: 1,
  a-tau: 0,
)

sqrt 4: #parse-root($root(3, 8)$.body) \
sqrt a: #parse-root($sqrt(a)$.body) \
sqrt a^2: #parse-root($sqrt(a^2)$.body)
