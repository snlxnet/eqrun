#set page(paper: "a5")
#set text(font: "JetBrainsMono NF")
#import "@preview/catppuccin:1.1.0": catppuccin, flavors
#show: catppuccin.with(flavors.mocha)

#import "./lib.typ": eqrun-builder

#let vars = (
  a-ok: 5.1,
  b-broken: 6,
  c: 7,
  Delta-tau: 1,
)
#let eqrun = eqrun-builder(vars)

= Given
#vars

= Calculation
#eqrun($P = (a_"ok" + b_"broken" + sqrt(c)) / Delta_tau^5$)
