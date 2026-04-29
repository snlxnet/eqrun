#set page(width: 10cm, height: 3cm)
#set align(horizon + center)
#import "./lib.typ": eqrun-builder

#let init = (
  w: 6,
  h: 7,
)
#let eqrun = eqrun-builder(init)

The area of a rectangle with sides $#init.w times #init.h$:
#eqrun($A = w dot h$)

#pagebreak()

Half of that is:
#eqrun($A_"triangle" = A / 2$)

#pagebreak()

#context [
  #let state = eqrun()
  A: #state.A\
  A triangle: #state.A-triangle
]
