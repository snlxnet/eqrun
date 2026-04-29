#set text(font: "JetBrainsMono NF")
#import "@preview/catppuccin:1.1.0": catppuccin, flavors
#show: catppuccin.with(flavors.mocha)

#import "./lib.typ": eqrun-builder

#let vars = (
  a: 5.1,
  b-i: 6,
  Delta-tau: 1,
)
#let eqrun = eqrun-builder(vars)

= Given
#vars

= Calculation

#let sli = "some long index"

#eqrun($t = 2508 / 3$)
#eqrun($x = a + b_i$)
#eqrun($c_sli = 2 times x$)
#eqrun($P = (a + b_i + sqrt(c_sli)) / Delta_tau^5$)

#context[
  #let state = eqrun()
  The calculated value is #text(fill: flavors.mocha.colors.green.rgb)[#state.P].
  We can now use it as any normal variable.

  For instance, here's a hexagon of that diameter:

  #import "@preview/cetz:0.5.0"

  #figure(
    cetz.canvas({
      import cetz.draw: *
      polygon((0, 0), 6, radius: state.P/2, stroke: flavors.mocha.colors.lavender.rgb)
    }),
    caption: [A hexagon with $D = #state.P$]
  )
]
