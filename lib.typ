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
  let name = "vars." + if input.has("b") {
    sym-name(input.base.text) + "-" + sym-name(input.b.text)
  } else {
    sym-name(input.base.text)
  }

  if not input.has("t") {
    return (code: name, math: "#cleanup(" + name + ")")
  }

  if is-number(input.t) {
    (
      code: "calc.pow(" + name + ", " + input.t.text + ")",
      math: "#cleanup(" + name + ")^(" + input.t.text + ")",
    )
  } else {
    (
      code: name + "-" + sym-name(input.t),
      math: "#cleanup(" + name + "-" + sym-name(input.t) + ")",
    )
  }
}
#let parse-word(input) = {
  if is-number(input) {
    (
      code: input.text,
      math: input.text,
    )
  } else {
    (
      code: "vars." + input.text,
      math: "#cleanup(vars." + input.text + ")",
    )
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

  (
    code: "calc.root(" + radicand.code + ", " + index.code + ")",
    math: if input.has("index") {
      "root(" + index.math + ", " + radicand.math + ")"
    } else {
      "sqrt(" + radicand.math + ")"
    },
  )
}

#let precision = 3 // digits after the dot
#let expr = $P = (a_"ok" + b_"broken" + sqrt(c)) \/ Delta_tau^5$
#let tokens = expr.body.children
#tokens
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

#let parse-tokens(tokens) = {
  tokens.filter(elem => elem != [ ]).map(token => {
    if token.func() == math.attach {
      parse-attach(token)
    } else if token.func() == math.root {
      parse-root(token)
    } else if token.func() == math.lr {
      parse-tokens(token.body.children)
      // ( code: "", math: "", )
    } else {
      (
        code: token.text,
        math: token.text,
      )
    }
  }).flatten()
}
#let tokens = parse-tokens(right-side)
#let code = tokens.map(token => token.code).join(" ")
#let values = tokens.map(token => token.math).join(" ")

#let vars = (
  a-ok: 5.1,
  b-broken: 6,
  c: 7,
  Delta-tau: 1,
)

= Given
#vars

= Calculation

$
  #expr
  =
  #eval(
    values,
    mode: "math",
    scope: (
      cleanup: (val) => str(calc.round(val, digits: precision)),
      vars: vars,
    ),
  )
  =
  #calc.round(eval(code, scope: (vars: vars)), digits: precision)
$

= Debugging info
#tokens
