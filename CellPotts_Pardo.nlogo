patches-own [
  spin           ;; There are as many spins as cells, and one additional value for the medium.
  types         ;; 0 for the medium and 1 or 2 for the two cell types
]

to setup
  clear-all
  setup-patches ;; It setup cells consisting of rows of patches in a deterministic fashion. The number of patches in each cell can be changed.
end

to go
  ask one-of patches [ update ] ;; It performs the modified Metropolis dynamics
  draw-plot1 ;; It draws the evolution of a clustering coefficient for cells of type 1
  draw-plot2 ;; It draws the evolution of a clustering coefficient for cells of type 1
  draw-plot3 ;; It draws the evolution of a clustering coefficient for all the cells
end 

to update  ;; patch procedure
  let zero count neighbors4 with [ types = 0 ] ;; Counts neighbors of type 0
  let one count neighbors4 with [ types = 1 ] ;; Counts neighbors of type 1
  let two count neighbors4 with [ types = 2 ] ;; Counts neighbors of type 2
  let Hp 0 ;; Energy of selected spin to flip
  let Hn 0 ;; Energy if the spin is flipped
  let H 0 ;; Change of energy in the system if the flip occurs
  
  let candidate one-of neighbors4 ;; candidate for the new spin
  let aux spin ;; auxiliary variable to store the current spin
  
  let same count neighbors4 with [ spin = aux ] ;; Number of neighbors that belong to the same cell
  if types = 0 
  [
   set Hp 2 * J01 * one + 2 * J02 * two ;; Energy for patch belonging to the medium 
  ]
  if types = 1 
  [
    set Hp 2 * J01 * zero + 2 * J11 * (one - same) + J12 * two + l * (count patches with [ spin = aux ] - A1) ^ 2 - l * (count patches with [ spin = aux ] - 1 - A1) ^ 2 ;; Energy for type 1 patch minus the surface energy of its cell if it flips 
  ]
  if types = 2 
  [
    set Hp 2 * J02 * zero + 2 * J12 * one + J22 * (two - same) + l * (count patches with [ spin = aux ] - A2) ^ 2 - l * (count patches with [ spin = aux ] - 1 - A2) ^ 2 ;; Energy for type 2 patch minus the surface energy of its cell if it flips
  ]
  
  set aux [spin] of candidate ;; auxiliary variable to store the spin of the candidate
  set same count neighbors4 with [ spin = aux ]
  
  if [types] of candidate = 0 
  [
   set Hn 2 * (J01 * one + J02 * two)
  ]
  if [types] of candidate = 1 ;; Energy for candidate patch belonging to the medium
  [
    set Hn 2 * (J01 * zero + J11 * (one - same) + J12 * two) + l * (count patches with [ spin = aux ] + 1 - A1) ^ 2 - l * (count patches with [ spin = aux ] - A1) ^ 2 ;; Energy for type 1 candidate patch minus the surface energy of its cell before the flip 
  ]
  if [types] of candidate = 2 
  [
    set Hn 2 * (J02 * zero + J12 * one + J22 * (two - same)) + l * (count patches with [ spin = aux ] + 1 - A2) ^ 2 - l * (count patches with [ spin = aux ] - A2) ^ 2 ;; Energy for type 2 candidate patch minus the surface energy of its cell before the flip
  ]
  set H Hn - Hp ;; Calculates the energy change.
  if (H <= 0) or
     (temperature > 0 and (random-float 1.0 < exp ((- H) / temperature))) ;; Decides whether flip the spin according to Metropolis probabilities. 
     [ 
       set spin [spin] of candidate
       recolor
     ]
end

to setup-patches ;; patch procedure, it initializes the system as an arrange of cells consisting of a row of n patches. 
  let i 1
  ;let j 0
  ;foreach sort patches
  ask n-of n patches
    [ 
      ask patches in-radius random 5 
      [
       set spin i
       
      ]
      set i i + 1 
      ;ask ?
       ; [ ifelse i mod (random 30 + 1)  = 0
            ;; patches outside the given width are black
        ;    [ 
        ;      set j j + 1
         ;     set spin j 
          ;   ]
            ;; other patches get a color and label
         ;   [ 
         ;     set spin j
         ;   ] 
             
        ;] 
       ; set i i + 1
    ]

  ask patches
    [ 
       recolor 
    ]
end

to recolor  ;; patch procedure, it colors the patches according to its spin and type (type 1 has a shade of blue, type two a shade of red)
  ifelse (spin = 0)
    [
      set types 0
      set pcolor black 
    ]
    [ 
      
      if spin mod 2 = 0
      [ 
        set types 1
        set pcolor blue + ((- 1) ^ ((spin) / 2)) * (spin - 1) / 2 * 0.015 
      ]
      if spin mod 2 = 1  
      [ 
        set types 2
        set pcolor red + ((- 1) ^ ((spin - 1) / 2)) * (spin - 2) / 3 * 0.015 
      ]
    ]
    
  end

to draw-plot1 ;; Plots the evolution of a clustering coefficient for type 1
  set-current-plot "Clustering type 1"
  let a count patches with [ types = 1 and
   count neighbors4 with [
     types = 1 
   ] = 4
   ]
  
 let total count patches with [types = 1]
  plot a / total
end

to draw-plot2 ;; Plots the evolution of a clustering coefficient for type 1
  set-current-plot "Clustering type 2"
  let b count patches with [ types = 2 and
   count neighbors4 with [
     types = 2  
   ] = 4
  ]
  
  let total count patches with [types = 2] 
  plot b / total
  
end

to draw-plot3
  set-current-plot "Total clustering" ;; Plots the evolution of a clustering coefficient for all cells
  
   let c count patches with [
   count neighbors4 with [
     types != 0  
   ] = 4
  ]
   
  let total count patches with [types != 0] 
 
  plot c / total
  
end
@#$#@#$#@
GRAPHICS-WINDOW
227
10
592
396
16
16
10.76
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
20
16
86
49
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
117
16
180
49
go
go
T
1
T
PATCH
NIL
NIL
NIL
NIL
1

SLIDER
14
63
186
96
J01
J01
0
20
10
1
1
NIL
HORIZONTAL

SLIDER
14
107
186
140
J02
J02
0
20
10
1
1
NIL
HORIZONTAL

SLIDER
14
154
186
187
J12
J12
0
20
8
1
1
NIL
HORIZONTAL

SLIDER
14
293
186
326
A1
A1
1
50
10
1
1
NIL
HORIZONTAL

SLIDER
14
342
186
375
A2
A2
1
50
10
1
1
NIL
HORIZONTAL

SLIDER
15
480
187
513
temperature
temperature
0
20
14
1
1
NIL
HORIZONTAL

SLIDER
14
199
186
232
J11
J11
0
20
2
1
1
NIL
HORIZONTAL

SLIDER
14
245
186
278
J22
J22
0
20
6
1
1
NIL
HORIZONTAL

PLOT
719
12
919
162
Clustering type 1
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles"

PLOT
719
171
919
321
Clustering type 2
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -14070903 true "" "plot count turtles"

PLOT
719
331
919
481
Total clustering
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"total" 1.0 0 -5298144 true "" "plot count turtles"

SLIDER
15
390
187
423
l
l
0
10
3
1
1
NIL
HORIZONTAL

SLIDER
15
436
187
469
n
n
0
200
69
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

The Graner-Glazier cellular aggregation model based on a modified Potts spin model. Cells are represented by a group of agents with the same spin, and they can be of two different types; a third type is defined to account for the medium in which the cells live. Each type has different interaction energy both  with the medium and with other cells of the same type.  

## HOW IT WORKS

Three different types of cell are defined, one for the medium and the other two representing cell types. In each timestep a cell is chosen at random and its energy is calculated according to the model in the reference paper. To update the system a modified Metropolis dynamics is used, in which the new spin in a proposed flip is chosen only among the spins of the nearest neighbors of the given patch. 

The initial condition is deterministic, with cells being created as rows of patches with the same spin and color (the number of patches in a cell is defined by the user). Once the system starts evolving the cells tend to get a more rounded shape and to be connected in general, but with some patches splitting from the main body from time to time.

## HOW TO USE IT

Press setup to create the original distribution of cells. Each slider modifies one parameter of the model, be it the interaction force between the spins or the areas each cell type wants to occupy.

J01: It is the interaction energy between the medium and type 1 cells.
J02: It is the interaction energy between the medium and type 2 cells.
J12: It is the interaction energy between type 1 and type 2 cells.
J11: It is the interaction energy among type 1 cells.
J22: It is the interaction energy among type 2 cells.
A1: It is the target area of type 1 cells. 
A2: It is the target area of type 2 cells.
l: It is a parameter determining how important is the surface energy for the dynamics of each cell
n: It is the total number of cells
Temperature: It is the temperature of the system, which mediates the dynamics.

The interaction energies determine how easy it is for a spin of certain type to flip to a spin of other type or to a different spin of the same type. This will yield the kind of motions of the cells, since after a certain number of steps individual spin flips let cells change their position as a single body. The target areas are the number of patches that a cell needs to have in order for it to minimize it's surface energy, i.e. if a cell has exactly that number of patches its Hamiltonian will only have a term given by the interaction energies with other cells.

Modeling Choices:

The system is initialized by selecting a user defined number of random patches and creating a 'circular' cell using the neighbors at a radius selected randomly between 1 and 5. This creates a initial state with uniformly distributed cells of different sizes and a medium of a size not specified explicitly. As the model evolves, with appropiate parameters, the cells tend to aggregate in one big cluster, with cells of different type segregating in different clusters within it (I don't obtain the circular shape presented in the paper, probably because of the random locations of cells during the initialization procedure).

I decided to leave all the parameters open for the user to play with, but in the analysis I will use the parameters given in the paper, except for reduced areas, since the world is not big enough to sustain cells of size 40 and for bigger worlds the program does not run smoothly.

Type 1 cells (dark cells) are blue and type 2 (light cells) are red. However, in order to differentiate between cells I used slightly different shades of these colors for each spin.  This lets the user see how cells of the same type are interacting with each other.

I considered all patches of type 0 (the medium) as a single cell, i.e. all of them have the same spin.

The plots show normalized clustering coefficients (# of cells of one type with all neighbors of the same type/total # of cells of that type) for each type and for all cells together respectively.

## THINGS TO NOTICE

The evolution of the system, even for a relatively small world (32x32) gets interrupted periodically when plot are included. Some minutes are required to observe the evolution of the system.
n 50
J11 2
J22 14
J12 11
J01 J02 16
A1 15
A2 20
l 1
Temperature 10
 
With the parameters of teh paper and smaller areas the cells of both types dissapear eventually, due to the difficulty of flipping patches of the medium for making the cells grow. However, before dissapearing they cluster and 'fight' the medium together.

If the target areas are augmented (30 each) the cells conquer the medium and tend to form two cluster, each one corresponding to one cell. Thus, we can see that there is a phase transition depending on the area parameters, with cells survival depending on them. A similar effect is accomplished by increasing the initial number of cells. It is worth noticing that the clustering coefficients descend at the beginning, while cells are still isolated, but then they quickly and steadily increase until they reach a plateau.

If the interaction energies with the medium are increased the borders between cells and the medium get smoother but almost fixed. For cells of different clusters to come together we need smaller J01 and J02. On the other hand, if they are smaller than the other interaction terms, the clustering is lost because the borders with the medium get diffused, with cells losing patches that go 'exploring' by themselves.

n 100
J11 2
J22 6
J12 4
J01 J02 8
A1 10
A2 10
l 3
Temperature 10

With this parameters we observe a similar phenomenon to that shown in the paper. Dark cells (blue) form clusters that are then surrounded by light cells (red), isolating them from the medium. However the circular shape is not obtained, probably because the cells occupy a larger area than the medium and end up surrounding it. Playing with the relative order of J11, J12 and J22 you obtain different amounts of clustering for each type, that is, different evolution on the curves plotted. 

With the selected values, clusterings tend to increase slowly, not showing a fast initial increase followed by a stabilization as in the previous cases.



## THINGS TO TRY

The most interesting parameters are the temperature and the interaction forces. Higher temperatures lead to faster dynamics and lower interaction forces yield more addhesive cells. Play with these parameters to see the different outcomes. It is also worth noticing that below certain area threshold the cells die, whereas above it they thrive and aggregate.

## EXTENDING THE MODEL

It would be interesting to try different types of initial configurations, as well as interactions between more types of cell.

## NETLOGO FEATURES

The usage of decimal scales for coloring cells of the same types with different shades of the same color might be a useful trick. 

## RELATED MODELS

Ising model in the models library can be consider a simplification of this model with only two spins and a more compact energy term. The idea for the initial condition was based on the model Fraction Colors.

## CREDITS AND REFERENCES

Model based on Graner, F., & Glazier, J. A. (1992). Simulation of biological cell sorting using a twodimensional
extended Potts model. Physical Review Letters, 69(13): 2013-2015. 

David Pardo
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.5
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
