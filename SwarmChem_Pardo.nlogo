breed [canary canaries]
breed [snake snakes]
breed [frog frogs]



turtles-own [
  flockmates         ;; agentset of nearby turtles
  nearest-neighbor   ;; closest one of our flockmates
]

to setup
  clear-all
  create-canary type-1
  [ 
    set color yellow - 2 + random 3
    set size 1.5  ;; easier to see
    setxy random-xcor random-ycor
  ]
  create-snake type-2 
  [ 
    set color green - 2 + random 3
    set size 1.5  ;; easier to see
    setxy random-xcor random-ycor
  ]
  create-frog type-3
    [ set color blue - 2 + random 3  ;; random shades look nice
      set size 1.5  ;; easier to see
      setxy random-xcor random-ycor ]
  reset-ticks
end

to go
  ask turtles [ run word breed "-flock" ]
  ;; the following line is used to make the turtles
  ;; animate more smoothly.
  repeat 5 [ ask turtles [ fd 0.2 ] display ]
  ;; for greater efficiency, at the expense of smooth
  ;; animation, substitute the following line instead:
  ;;   ask turtles [ fd 1 ]
  tick
end

to canary-flock  ;; turtle procedure
  canary-find-flockmates
  if any? flockmates
    [ find-nearest-neighbor
      ifelse distance nearest-neighbor < minimum-separation-1
        [ canary-separate ]
        [ canary-align
          canary-cohere ] ]
end

to snake-flock  ;; turtle procedure
  snake-find-flockmates
  if any? flockmates
    [ find-nearest-neighbor
      ifelse distance nearest-neighbor < minimum-separation-2
        [ snake-separate ]
        [ snake-align
          snake-cohere ] ]
end

to frog-flock  ;; turtle procedure
  frog-find-flockmates
  if any? flockmates
    [ find-nearest-neighbor
      ifelse distance nearest-neighbor < minimum-separation-3
        [ frog-separate ]
        [ frog-align
          frog-cohere ] ]
end

to canary-find-flockmates  ;; canary procedure
  ifelse reaction-1
  [
    ifelse followers-1
    [
      set flockmates other (turtles with [breed != canary])  in-radius vision-1
    ]
    [
      set flockmates other turtles in-radius vision-1
    ]
  ]
  [
    set flockmates other canary in-radius vision-1
  ]
end

to snake-find-flockmates  ;; snake procedure
  ifelse reaction-2
  [
    ifelse followers-2
    [
      set flockmates other (turtles with [breed != snake])  in-radius vision-2
    ]
    [
      set flockmates other turtles in-radius vision-2
    ]
  ]
  [
    set flockmates other snake in-radius vision-2
  ]
end

to frog-find-flockmates  ;; frog procedure
  ifelse reaction-3
  [
    ifelse followers-3
    [
      set flockmates other (turtles with [breed != frog])  in-radius vision-3
    ]
    [
      set flockmates other turtles in-radius vision-3
    ]
  ]
  [
    set flockmates other frog in-radius vision-3
  ]
  
end

to find-nearest-neighbor ;; turtle procedure
  set nearest-neighbor min-one-of flockmates [distance myself]
end



;;; SEPARATE

to canary-separate  ;; canary procedure
  canary-turn-away ([heading] of nearest-neighbor) max-separate-turn-1
end

to snake-separate  ;; snake procedure
  snake-turn-away ([heading] of nearest-neighbor) max-separate-turn-2
end

to frog-separate  ;; frog procedure
  frog-turn-away ([heading] of nearest-neighbor) max-separate-turn-3
end

;;; ALIGN

to canary-align  ;; canary procedure
  canary-turn-towards average-flockmate-heading max-align-turn-1
end

to snake-align  ;; snake procedure
  snake-turn-towards average-flockmate-heading max-align-turn-2
end

to frog-align  ;; frog procedure
  frog-turn-towards average-flockmate-heading max-align-turn-3
end

to-report average-flockmate-heading  ;; turtle procedure
  ;; We can't just average the heading variables here.
  ;; For example, the average of 1 and 359 should be 0,
  ;; not 180.  So we have to use trigonometry.
  let x-component sum [dx] of flockmates
  let y-component sum [dy] of flockmates
  ifelse x-component = 0 and y-component = 0
    [ report heading ]
    [ report atan x-component y-component ]
end

;;; COHERE

to canary-cohere  ;; canary procedure
  canary-turn-towards average-heading-towards-flockmates max-cohere-turn-1
end

to snake-cohere  ;; snake procedure
  snake-turn-towards average-heading-towards-flockmates max-cohere-turn-2
end

to frog-cohere  ;; frog procedure
  frog-turn-towards average-heading-towards-flockmates max-cohere-turn-3
end

to-report average-heading-towards-flockmates  ;; turtle procedure
  ;; "towards myself" gives us the heading from the other turtle
  ;; to me, but we want the heading from me to the other turtle,
  ;; so we add 180
  let x-component mean [sin (towards myself + 180)] of flockmates
  let y-component mean [cos (towards myself + 180)] of flockmates
  ifelse x-component = 0 and y-component = 0
    [ report heading ]
    [ report atan x-component y-component ]
end

;;; HELPER PROCEDURES

to canary-turn-towards [new-heading max-turn-1]  ;; canary procedure
  canary-turn-at-most (subtract-headings new-heading heading) max-turn-1
end

to snake-turn-towards [new-heading max-turn-2]  ;; snake procedure
  snake-turn-at-most (subtract-headings new-heading heading) max-turn-2
end

to frog-turn-towards [new-heading max-turn-3]  ;; frog procedure
  frog-turn-at-most (subtract-headings new-heading heading) max-turn-3
end

to canary-turn-away [new-heading max-turn-1]  ;; turtle procedure
  canary-turn-at-most (subtract-headings heading new-heading) max-turn-1
end

to snake-turn-away [new-heading max-turn-2]  ;; turtle procedure
  snake-turn-at-most (subtract-headings heading new-heading) max-turn-2
end

to frog-turn-away [new-heading max-turn-3]  ;; turtle procedure
  frog-turn-at-most (subtract-headings heading new-heading) max-turn-3
end

;; turn right by "turn" degrees (or left if "turn" is negative),
;; but never turn more than "max-turn" degrees
to canary-turn-at-most [turn max-turn-1]  ;; turtle procedure
  ifelse abs turn > max-turn-1
    [ ifelse turn > 0
        [ rt max-turn-1 ]
        [ lt max-turn-1 ] ]
    [ rt turn ]
end

to snake-turn-at-most [turn max-turn-2]  ;; turtle procedure
  ifelse abs turn > max-turn-2
    [ ifelse turn > 0
        [ rt max-turn-2 ]
        [ lt max-turn-2 ] ]
    [ rt turn ]
end

to frog-turn-at-most [turn max-turn-3]  ;; turtle procedure
  ifelse abs turn > max-turn-3
    [ ifelse turn > 0
        [ rt max-turn-3 ]
        [ lt max-turn-3 ] ]
    [ rt turn ]
end

to set-one-species
  set type-1 300
  set type-2 0
  set type-3 0
  set minimum-separation-1 0
  set max-align-turn-1 2
  set max-cohere-turn-1 20
  set max-separate-turn-1 0
  set reaction-1 true
  set followers-1 false
end

to set-two-species
  set type-1 200
  set type-2 200
  set type-3 0
  set vision-1 2
  set vision-2 8
  set minimum-separation-1 5
  set minimum-separation-2 1
  set max-align-turn-1 5
  set max-align-turn-2 15
  set max-cohere-turn-1 5
  set max-cohere-turn-2 15
  set max-separate-turn-1 15
  set max-separate-turn-2 5
  set reaction-1 true
  set reaction-2 true
  set followers-2 true
end

to set-three-species
  set type-1 100
  set type-2 100
  set type-3 100
  set vision-1 10
  set vision-2 5
  set vision-3 0
  set minimum-separation-1 0
  set minimum-separation-2 2
  set minimum-separation-3 5
  set max-align-turn-1 20
  set max-align-turn-2 10
  set max-align-turn-3 0
  set max-cohere-turn-1 20
  set max-cohere-turn-2 10
  set max-cohere-turn-3 0
  set max-separate-turn-1 0
  set max-separate-turn-2 10
  set max-separate-turn-3 20
  set reaction-1 true
  set reaction-2 true
  set reaction-3 true
  set followers-1 false
  set followers-2 false
  set followers-3 false
end

to set-high-coherence
  set type-1 100
  set type-2 100
  set type-3 100
  set vision-1 10
  set vision-2 8
  set vision-3 6
  set minimum-separation-1 0
  set minimum-separation-2 1
  set minimum-separation-3 2
  set max-align-turn-1 20
  set max-align-turn-2 17
  set max-align-turn-3 15
  set max-cohere-turn-1 20
  set max-cohere-turn-2 18
  set max-cohere-turn-3 15
  set max-separate-turn-1 0
  set max-separate-turn-2 3
  set max-separate-turn-3 5
  set reaction-1 true
  set reaction-2 true
  set reaction-3 true
  set followers-1 false
  set followers-2 false
  set followers-3 false
end

to set-low-coherence
  set type-1 100
  set type-2 100
  set type-3 100
  set vision-1 0
  set vision-2 2
  set vision-3 3
  set minimum-separation-1 5
  set minimum-separation-2 4
  set minimum-separation-3 3
  set max-align-turn-1 0
  set max-align-turn-2 5
  set max-align-turn-3 10
  set max-cohere-turn-1 0
  set max-cohere-turn-2 5
  set max-cohere-turn-3 10
  set max-separate-turn-1 20
  set max-separate-turn-2 15
  set max-separate-turn-3 10
  set reaction-1 true
  set reaction-2 true
  set reaction-3 true
  set followers-1 false
  set followers-2 false
  set followers-3 false
end

to set-fanatics
  set type-1 10
  set type-2 500
  set type-3 0
  set vision-1 1
  set vision-2 8
  set minimum-separation-1 5
  set minimum-separation-2 1
  set max-align-turn-1 5
  set max-align-turn-2 15
  set max-cohere-turn-1 5
  set max-cohere-turn-2 15
  set max-separate-turn-1 15
  set max-separate-turn-2 5
  set reaction-1 true
  set reaction-2 true
  set followers-2 true
end
; Copyright 1998 Uri Wilensky.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
250
10
757
538
35
35
7.0
1
10
1
1
1
0
1
1
1
-35
35
-35
35
1
1
1
ticks
30.0

BUTTON
36
469
113
502
NIL
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
119
469
200
502
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
10
83
233
116
Type-3
Type-3
1.0
500.0
100
1.0
1
NIL
HORIZONTAL

SLIDER
773
273
1002
306
max-align-turn-1
max-align-turn-1
0.0
20.0
20
0.25
1
degrees
HORIZONTAL

SLIDER
1059
10
1301
43
max-cohere-turn-1
max-cohere-turn-1
0.0
20.0
20
0.25
1
degrees
HORIZONTAL

SLIDER
1062
150
1314
183
max-separate-turn-1
max-separate-turn-1
0.0
20.0
0
0.25
1
degrees
HORIZONTAL

SLIDER
771
10
994
43
vision-1
vision-1
0.0
10.0
10
0.5
1
patches
HORIZONTAL

SLIDER
773
150
996
183
minimum-separation-1
minimum-separation-1
0.0
5.0
0
0.25
1
patches
HORIZONTAL

SLIDER
11
12
232
45
Type-1
Type-1
0.0
500.0
100
1.0
1
NIL
HORIZONTAL

SLIDER
10
47
233
80
Type-2
Type-2
0.0
500.0
100
1.0
1
NIL
HORIZONTAL

SLIDER
772
47
995
80
vision-2
vision-2
0.0
10.0
5
0.5
1
patches
HORIZONTAL

SLIDER
773
84
994
117
vision-3
vision-3
0.0
10.0
0
0.5
1
patches
HORIZONTAL

SLIDER
773
187
998
220
minimum-separation-2
minimum-separation-2
0.0
5.0
2
0.25
1
patches
HORIZONTAL

SLIDER
773
226
999
259
minimum-separation-3
minimum-separation-3
0.0
5.0
5
0.25
1
patches
HORIZONTAL

SLIDER
773
309
1001
342
max-align-turn-2
max-align-turn-2
0.0
20.0
10
0.25
1
degrees
HORIZONTAL

SLIDER
774
345
1001
378
max-align-turn-3
max-align-turn-3
0
20.0
0
0.25
1
degrees
HORIZONTAL

SLIDER
1059
47
1302
80
max-cohere-turn-2
max-cohere-turn-2
0
20.0
10
0.25
1
degrees
HORIZONTAL

SLIDER
1059
84
1302
117
max-cohere-turn-3
max-cohere-turn-3
0
20.0
0
0.25
1
degrees
HORIZONTAL

SLIDER
1062
189
1314
222
max-separate-turn-2
max-separate-turn-2
0
20.0
10
0.25
1
degrees
HORIZONTAL

SLIDER
1063
228
1315
261
max-separate-turn-3
max-separate-turn-3
0
20.0
20
0.25
1
degrees
HORIZONTAL

BUTTON
46
130
200
163
NIL
set-one-species
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
46
170
199
203
NIL
set-two-species
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
46
209
199
242
NIL
set-three-species
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
45
268
201
301
NIL
set-high-coherence
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
45
310
200
343
NIL
set-low-coherence
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
1063
271
1186
304
reaction-1
reaction-1
0
1
-1000

SWITCH
1063
310
1186
343
reaction-2
reaction-2
0
1
-1000

SWITCH
1063
349
1186
382
reaction-3
reaction-3
0
1
-1000

BUTTON
45
362
198
395
NIL
set-fanatics
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
1197
350
1325
383
followers-3
followers-3
1
1
-1000

SWITCH
1196
310
1324
343
followers-2
followers-2
1
1
-1000

SWITCH
1195
272
1323
305
followers-1
followers-1
1
1
-1000

@#$#@#$#@
## WHAT IS IT?

This model presents the interaction of swarms of different types of agents (up to three different types), which are base in bird flocking models.

## HOW IT WORKS

As stated in Netlogo's bird flocking model:

<<The birds follow three rules: "alignment", "separation", and "cohesion".

"Alignment" means that a bird tends to turn so that it is moving in the same direction that nearby birds are moving.

"Separation" means that a bird will turn to avoid another bird which gets too close.

"Cohesion" means that a bird will move towards other nearby birds (unless another bird is too close).

When two birds are too close, the "separation" rule overrides the other two, which are deactivated until the minimum separation is achieved.

The three rules affect only the bird's heading.  Each bird always moves forward at the same constant speed.>>

In our case, each rule will have different parameters for each species, and even the selection of neighbors can depend on the type of bird.

## HOW TO USE IT

Select The size of the different populations:

Type-1: yellow birds
Type-2: green birds
Type-3: blue birds

You can select one of the presets:

One-species: It creates a population of only one species and suggests intermediate coherence parameters.
Two-species: It creates two different species, suggesting a highly coherent one and a highly disagreggating one.
Three-species: It creates three different species, covering the spectrum of coherence a highly aggregating species, an intermediate one and a non coherent one.

The sliders and switches can be changed afterwards to create different types of interactions.

High-coherence: All species have high coherent behaviour, with different levels to seeslightly different effects for each one.

Low-coherence: All species have low coherent behaviour, with different levels, with different levels to seeslightly different effects for each one.

Fanatics: One highly coherent species only see members of the other, thus it tends to form groups that closely follows the agents of the other species.

Once a combination of parameters has been selected, press SETUP and GO.

The parametes are the same as in the Bird Flocking model, but now there is a slider per species for each of them.

Additionally I created the switches REACTION and FOLLOWERS. The former ones determine whether a species takes the other species into account when selecting its neighborhood (On for yes, Off for no). The latter determines whether the species takes its own members into account when selecting its neighborhood (On for no, i.e. becoming a follower of other species, Off for yes). This last group of switches make the simulations considerably slowers when they are in off because the calculation of the neighborhood becomes more involved, specially if there isa  big number of agents in the valid radius.

## MODELING CHOICES

I based my model in Netlogo's Bird Flocking model. I didn't change the rules of cohesion, alignment and separation, and decided not to add different velocity or random steering in order to focus on different interactions between species. Even without these additional rules, interesting behaviours are observed when two or three species interact in the same world, and the general spirit of Sayama's model is preserved.

I modeled each species as one breed and I created different functions for each breed. Although this leads to a lot of code repetition, it has the potential of creating highly dissimilar behaviours for each species without big changes in the code. To illustrate this I added switches which let a bird ignore the other species or ignore birds of its own species when selecting its neighborhood. This permits the observer analyze different interactions separately.

A fun application of this structure is the fanatics preset, in which one species only see members the other one, while the other species only sees its own members. What we obtain is that the system converge to big groups of the first species fervently following one or more members of the second one.

## THINGS TO NOTICE

When one species is highly coherent and more so than the others, it tends to create leader groups, i.e. flocks of that species that are followed by members of the others. This leader behaviour is emergent, it is not fixed by the observer whatsoever.

If a species does not take into account its own members as neighbors, it tend to become a species of followers as would be expected. If they are highly coherent, they will behave as fanatics, following members of the other species almost move by move.

The behavior of a lowly coherent species is similar whether it takes into account the other species or not. However it affects the behaviour of the other species; in fact, having a completely uninteracting species in the background can radically change the behaviour of one species if it is too influenciable or its population is not big enough to fight the effect of the noise imposed by the different agents moving in straight trajectories.

Playing with all the parameters it is possible to obtain a big variety of final behaviours. It is also interesting to change some parameters as the simulations are running to see the immediate effect that they have in the different agents.

## THINGS TO TRY

Altering the presets to get new interesting behaviours and designing additional presets to achieve asymptotical behaviours of personal interest.

## EXTENDING THE MODEL

Appart from the natural extensions for one species models such as different neighborhood creation rules, presence of obstacles, different velocities of agents, etc., there are possible extensions related directly with the presence of different species. For instance, it would be interesting to assign fundamentally different rules for each species, e.g. one of them using pheromone-like cues, other having a neighborhood defined by topological distance and a third one behaving as stated in the current model. 

## NETLOGO FEATURES

The breeds feature was used to represent different species of agent, which could potentially be useful to assign different rules of behaviour to each group.

## RELATED MODELS

Bird Flocking

## CREDITS AND REFERENCES

David Pardo

* H. Sayama (2007) Decentralized control and interactive design methods for large-scale
heterogeneous self-organizing swarms, Advances in Artificial Life: Proceedings of the Ninth
European Conference on Artificial Life (ECAL 2007), F. Almeida e Costa et al., eds., pp.675-
684, Lisbon, Portugal, 2007, Springer-Verlag. 

* Wilensky, U. (1998).  NetLogo Flocking model.  http://ccl.northwestern.edu/netlogo/models/Flocking.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.
* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.
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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.5
@#$#@#$#@
set population 200
setup
repeat 200 [ go ]
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
