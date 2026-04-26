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
#let parse-tokens(tokens) = {
  tokens.filter(elem => elem != [ ]).map(token => {
    if token.func() == math.attach {
      parse-attach(token)
    } else if token.func() == math.root {
      parse-root(token)
    } else if token.func() == math.lr {
      parse-tokens(token.body.children)
    } else if token.func() == math.frac {
      let num = parse-tokens(if token.num.has("children") { token.num.children } else { (token.num,) })
      let den = parse-tokens(if token.denom.has("children") { token.denom.children } else { (token.denom,) })
      (
        code: "(" + num.map(i => i.code).join(" ") + ")/(" + den.map(i => i.code).join(" ") + ")",
        math: "(" + num.map(i => i.math).join(" ") + ")/(" + den.map(i => i.math).join(" ") + ")",
      )
    } else if token.text == "/" {
      (
        code: "/",
        math: "\\/",
      )
    } else {
      (
        code: token.text,
        math: token.text,
      )
    }
  }).flatten()
}

#let eqrun-builder(state) = {
  (equation, precision: 2) => {
    let tokens = equation.body.children

    let (left-side, right-side) = {
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

    let tokens = parse-tokens(right-side)
    let code = tokens.map(token => token.code).join(" ")
    let values = tokens.map(token => token.math).join(" ")

    let values = eval(
      values,
      mode: "math",
      scope: (
        cleanup: (val) => str(calc.round(val, digits: precision)),
        vars: state,
      ),
    )
    let result = calc.round(eval(code, scope: (vars: state)), digits: precision)

    $ equation = values = result $
  }
}

