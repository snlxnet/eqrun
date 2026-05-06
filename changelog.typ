#import "@preview/eqrun:0.1.1": eqrun-builder

#let eqrun = eqrun-builder((result: 0))
#set page(width: 10cm, height: 3cm)
#set align(horizon + center)
#show heading: underline
#set text(font: "DejaVu Sans Mono", size: 3mm)
#show heading: set text(3mm)

#set page(columns: 2)
= Fixed in #text(fill: red)[v0.1.1]
#eqrun($a = (1 + 2)$)
#eqrun($a = (a + 3)/2$)
#eqrun($a=(10+20)/(a*2)$)
#eqrun($(10+20)/2$)
#eqrun($R_2 = 0.5$)

= Added in #text(fill: eastern)[v0.1.1]
#eqrun($R_2 = 0.5$, unit: "m")
#eqrun($V_4 = 2$, unit: $m/s$)
#eqrun($t = 1$, unit: "s")

#eqrun($omega_2 = V_4 / R_2$, unit: $s^(-1)$)
