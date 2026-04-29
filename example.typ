#set page(paper: "a5")
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

#eqrun($x = a + b_i$)
#eqrun($c_sli = 2 times x$)
#eqrun($P = (a + b_i + sqrt(c_sli)) / Delta_tau^5$)
