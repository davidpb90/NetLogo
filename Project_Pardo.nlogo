globals [nearby ;;variable to define new neighborhoods
  number-guerrillas ;;number of guerrillas
  number-armies ;;number of armies
  resources-guerrillas ;;guerrilla's resources
  resources-armies ;;armies' resources
  guerrillas-capacity ;;guerrilla's soldier capacity 
  armies-capacity ;;armies' soldier capacity
  body-count-armies ;;number of dead armies
  body-count-guerrillas ;;number of dead guerrillas
  my-initial-number-guerrillas  ;; keep track of how much grass there is
  clustering-armies
  clustering-guerrillas]  
;; Guerrillas and armies are both breeds of turtle.
breed [guerrillas guerrilla]  ;; sheep is its own plural, so we use "a-sheep" as the singular.
breed [armies army]
turtles-own [
   soldiers ;;Number of soldiers in a group
   money ;;Money own by a group of soldiers
   max-money ;;Maximum money a group can own
   ]        
patches-own [resources                       ;; available resources in a patch
  population                                 ;; current population in a patch
  capacity                                   ;; maximum population capacity of a patch
  new-color       ;; brown or green
  inner-neighbors ;; other patches in a circle around the patch
  outer-neighbors ;; other patches in a ring around the patch (but usually not touching the patch)
  active-armies   ;; number of active armies in the patch
  active-guerrillas ;; number of active guerrillas in the patch
  kind              ;; hospitable or inhospitable
  seen-armies           ;; auxiliary variable to measure clustering
  seen-guerrillas
]

to init-globals
  set my-initial-number-guerrillas initial-number-guerrillas
end 

to setup ;; initializes the militants and the geography
  clear-all
  init-globals
  set guerrillas-capacity 1000
  set armies-capacity 1000
  set body-count-armies 0
  set body-count-guerrillas 0
  ask patches 
  [
     set pcolor green
     set kind "hospitable"
     set resources random max-resources-patches
     set capacity random max-capacity 
     set population 0
     set active-armies 0
     set active-guerrillas 0
     set seen-armies false
     set seen-guerrillas false
    
 ]
 
 
    ask patches [
      let percentage-inhospitable 0
      let inner-radius-x 0
      let inner-radius-y 0
      let outer-radius-x 0
      let outer-radius-y 0
      if what-geography = "isolated"
      [
        set percentage-inhospitable 20 
        set inner-radius-x 2
        set inner-radius-y 4
        set outer-radius-x 6
        set outer-radius-y 6
        ifelse percentage-inhospitable < random 100 
         [set pcolor green]
         [set pcolor brown]
      ]
      if what-geography = "ranges"
      [
        set percentage-inhospitable 10 
        set inner-radius-x 1.5
        set inner-radius-y 3
        set outer-radius-x 6
        set outer-radius-y 6
        ifelse percentage-inhospitable < random 100 
         [set pcolor green]
         [set pcolor brown]
      ]
      if what-geography = "mountains"
      [
        set percentage-inhospitable 30 
        set inner-radius-x 2
        set inner-radius-y 2
        set outer-radius-x 6
        set outer-radius-y 6
        ifelse percentage-inhospitable < random 100 
         [set pcolor green]
         [set pcolor brown]
      ]
      if what-geography = "islands"
      [
        set percentage-inhospitable 5
        set inner-radius-x 2
        set inner-radius-y 3
        set outer-radius-x 4
        set outer-radius-y 5
        ifelse percentage-inhospitable < random 100 
         [set pcolor green]
         [set pcolor brown]
      ]
      
      
      set inner-neighbors ellipse-in inner-radius-x inner-radius-y
      ;; outer-neighbors needs more computation because we want only the cells in the circular ring
      set outer-neighbors ellipse-ring outer-radius-x outer-radius-y inner-radius-x inner-radius-y
    ]
      
  
  set-default-shape armies "person soldier"
  
  create-armies ceiling (initial-number-armies / 20) ;; create the armies, then initialize their variables
  [
    set color white
    set size 2.5  ;; easier to see
    set label-color blue - 2
    set soldiers max-army-size
    set money random max-resources-army
    set max-money max-resources-army
    setxy random-xcor random-ycor
    
  ]
  set-default-shape guerrillas "person guerrilla"
  create-guerrillas ceiling (initial-number-guerrillas / 10)  ;; create the guerrillas, then initialize their variables
  [
    set color black
    set size 2.5  ;; easier to see
    set soldiers max-guerrilla-size 
    set money random max-resources-guerrilla
    set max-money max-resources-guerrilla
    setxy random-xcor random-ycor
  ]
  set number-guerrillas 0
  set resources-guerrillas 0
  calculate-population-guerrillas
  set number-armies 0
  set resources-armies 0
  calculate-population-armies
 
  display-labels
  ;set grass count patches with [pcolor = green]
  reset-ticks
  setup-geography ;; creates the geography
end



to setup-geography ;; creates the geography of the model using the algorithm of the fur model
  create-geography
  let n 10
  ask n-of n patches ;;creates n areas of prosperity
    [ 
      let aux max-resources-patches
      ask patches in-radius 5 
      [
       if pcolor = green
       [
         set kind "hospitable"
         set resources aux
         set pcolor green - resources * 0.02
       ]
       
      ]
    ]
  
  ask n-of (2 * n) patches ;;creates 2n areas sharing the same resources within each of them
    [ 
      let aux random max-resources-patches  
      ask patches in-radius 3 
      [
       if pcolor = green
       [
         set kind "hospitable"
         set resources aux
         set pcolor green - resources * 0.02
       ]
      ]
    ]
  ask patches[    ;;random assignment of resources for the rest of the patches
      if pcolor = brown
        [ set resources random 20 
          set kind "inhospitable"
          set pcolor brown + resources * 0.04]
      if pcolor = green
        [ 
          set resources random max-resources-patches 
          set kind "hospitable"
          set pcolor green -  resources * 0.02 
      ]
        
      
     ; initialize grass grow clocks randomly for brown patches
  ]
end
  
to go
  if not any? armies or not any? guerrillas [ stop ]
  if ticks > 2000 [ stop ]
  ask patches [
    calculate-population
  ]
  calculate-population-armies
  calculate-population-guerrillas
  while [armies-capacity < number-armies] ;; kills an army group if the maximum capacity is reached
  [
    ask one-of armies [die]
    calculate-population-armies
  ]
          
  while [guerrillas-capacity < number-guerrillas] ;; kills a guerrilla group if the maximum capacity is reached
  [
    ask one-of guerrillas [die]
    calculate-population-guerrillas
  ]
          
  if number-guerrillas > paramilitary-threshold
  [
   ask guerrillas
   [
    let die-probability 0.2
    if [resources] of patch-here > 50 and die-probability > random 1  ;; IF the guerrilla population is too big, a paramilitary regime is established
    [
       ;set body-count-guerrillas body-count-guerrillas + soldiers
       die
    ]  
   ] 
  ]
          
  while [max-resources-global < resources-armies]
          [ask one-of armies [set money 0]
            calculate-population-armies]
  while [max-resources-global < resources-guerrillas]
          [ask one-of guerrillas [set money 0]
            calculate-population-guerrillas]
   ask patches [
    calculate-population
  
  ]      
  ask armies [      ;;Armies collect resources and recruit population according to the available resources in the patch
    if resources-armies < max-resources-global
    [
    if money < max-money
       [
         collect-resources-armies
         ask patch-here[lose-resources] 
       ]
    ]
    armies-attack
    move-armies
    if population < capacity
        [
          reproduce-armies
          ask patch-here[lose-resources]
        ]
        
    kill
  ]
  ask guerrillas [     ;;Guerrillas collect resources and recruit population according to the available resources in the patch
    if resources-armies < max-resources-global
    [if money < max-money
      [
        collect-resources-guerrillas
        ask patch-here[lose-resources]
      ]
    ]
    guerrillas-attack
    move-guerrillas
    if population < capacity
       [
         reproduce-guerrillas
         ask patch-here[lose-resources]
       ]
    kill
  ]
  
  ask patches[
    set active-guerrillas 0
    set active-armies 0
    if resources <= max-resources-patches
    [
      grow-resources
    ]
    recolor
    
    ]
  calculate-clustering-armies
  calculate-clustering-guerrillas
  tick
 
  display-labels
end

to calculate-clustering-armies
  let sum-patches 0
  ask armies[
    let radius 2  ;vision radius of the group
    set nearby moore-offsets radius ;create neighborhood with that vision radius
    let myneighbors patch-here
    ask patch-here[
      set myneighbors patches at-points nearby]
    ask myneighbors
    [
      if not seen-armies
      [
        set sum-patches sum-patches + 1
        set seen-armies true  
      ]
    ]
  ] 
  ifelse count armies = 0
  [set clustering-armies 0]
  [set clustering-armies 1 - sum-patches / ((count armies) * 25)]
  ask patches[set seen-armies false]
end

to calculate-clustering-guerrillas
  let sum-patches 0
  ask guerrillas[
    let radius 2  ;vision radius of the group
    set nearby moore-offsets radius ;create neighborhood with that vision radius
    let myneighbors patch-here
    ask patch-here[
      set myneighbors patches at-points nearby]
    ask myneighbors
    [
      if not seen-guerrillas
      [
        set sum-patches sum-patches + 1
        set seen-guerrillas true  
      ]
    ]
  ] 
  ifelse count guerrillas = 0
  [set clustering-guerrillas 0]
  [set clustering-guerrillas 1 - sum-patches / ((count guerrillas) * 25)]
  ask patches[set seen-guerrillas false]
end

to calculate-population ;; patch procedure, it calculates the total population
  let pop 0
  ask turtles-here[set pop (pop + soldiers)]
  set population pop
end

to calculate-population-guerrillas ;; guerrilla procedure, calculates the total guerrilla population
  let number-guerrillas-aux 0
  
  let resources-guerrillas-aux 0
  
  ask guerrillas 
  [
    set number-guerrillas-aux number-guerrillas-aux + soldiers 
    set resources-guerrillas-aux resources-guerrillas-aux + money
    ]
    set number-guerrillas number-guerrillas-aux
    set resources-guerrillas resources-guerrillas-aux
end

to  calculate-population-armies ;; armies procedure, calculates the total army population
  let number-armies-aux 0
  let resources-armies-aux 0
  ask armies 
  [
    set number-armies-aux number-armies-aux + soldiers 
    set resources-armies-aux resources-armies-aux + money
    ]
    set number-armies number-armies-aux
    set resources-armies resources-armies-aux
end

to collect-resources-armies ;;armies procedure, collects resources from the patch
  let percentage-money 0.1
  set money (money + percentage-money * resources)
end 
 
to armies-attack ;; armies procedure
  let prey nobody
  let radius 1  ;vision radius of the group
  set nearby moore-offsets radius ;create neighborhood with that vision radius
  let myneighbors patch-here
  ask patch-here[
    set myneighbors patches at-points nearby]
  if 0.8 > random 1 [set prey one-of guerrillas-on myneighbors  ]                   ;; grab a random guerrilla
   if prey != nobody                          ;; did we get one?  if so,
    [ ask prey 
      [ let victims random (ceiling ([soldiers] of myself / 6)) ;; The number of killed guerrillas is a random number between zero and a sixth of the number of soldiers in the army group 
        ifelse resources > (resources - ([soldiers] of myself / 4))
        [set resources (resources - ([soldiers] of myself / 4))]
        [set resources 0]  ;;The resources lost by the rivals in the battle are proportional to the size of the army group
        set soldiers soldiers - victims
        set body-count-guerrillas body-count-guerrillas + victims
      ] 
      let myvictims random (ceiling ([soldiers] of prey / 3)) ;; The number of killed army soldiers is a random number between zero and a third of the number of soldiers in the guerrilla group 

      set soldiers soldiers - myvictims
      set body-count-armies body-count-armies + myvictims
       
      ifelse resources > (resources - ([soldiers] of prey / 2))
      [set resources (resources - ([soldiers] of prey / 2))]
      [set resources 0] ;;The resources lost in the battle are proportional to the size of the rival group
      if soldiers <= 0 [die]
      if [soldiers] of prey <= 0
         [ if money < max-money ;; If the rival group is destroyed the resources are taken
              [set resources resources + [resources] of prey]
           ask prey [die]
         ]
        ;; kill it
       ] ;; get energy from eating
end

to collect-resources-guerrillas ;;guerrillas procedure, guerrillas collect resources
  set money (money + 0.1 * resources)
end 

to guerrillas-attack ;; guerrillas procedure
  let prey nobody ;army to attack
  let radius 2  ;vision radius of the group
  set nearby moore-offsets radius ;create neighborhood with that vision radius
  let myneighbors patch-here
  ask patch-here[
    set myneighbors patches at-points nearby]
  set prey one-of armies-on myneighbors       ;; grab a random army out of the neighbors
  ;set prey one-of armies-here
  if prey != nobody                                ;; did we get one?  if so,
    [ ask prey 
      [ let victims random [soldiers] of myself ;; The number of killed armies is a random number between zero and the number of soldiers in the guerrilla group 
        ifelse resources > (resources - ([soldiers] of myself / 2))
        [set resources (resources - ([soldiers] of myself / 2))]
        [set resources 0] ;;The resources lost by the rivals in the battle are proportional to the size of the guerrilla group
        set soldiers soldiers - victims
        set body-count-armies body-count-armies + victims
      ] 
     
      let myvictims random (ceiling ([soldiers] of prey / 3)) ;; The number of killed guerrillas is a random number between zero and a third of the number of soldiers in the army group 
        
      set soldiers soldiers - myvictims
      set body-count-guerrillas body-count-guerrillas + myvictims 
      ifelse resources > (resources - ([soldiers] of prey / 4))
      [set resources (resources - ([soldiers] of prey / 4))]
      [set resources 0] ;;The resources lost in the battle are proportional to the size of the rival group
      if soldiers <= 0 [die]
      if [soldiers] of prey <= 0
         [ if money < max-money
              [set resources resources + [resources] of prey] ;; If the rival group is destroyed the resources are taken
           ask prey [die]
         ]
        ;; kill it
       ] 
end

to move-armies  ;; army procedure, how the armies move
  let radius 10  ;vision radius of the group
  set nearby moore-offsets radius ;create neighborhood with that vision radius
  let myneighbors patch-here
  ask patch-here[
  set myneighbors patches at-points nearby]
  let closest min-one-of other patches with [any? guerrillas-here] [distance myself]
  let a-guerrilla one-of myneighbors with [any? guerrillas-here] 
  let closest-hospitable min-one-of other patches with [kind = "hospitable"] [distance myself]
  let a-hospitable one-of other patches at-points nearby with [kind = "hospitable" and resources > 30 ]
 ifelse kind = "inhospitable" ;;If in a inhospitable patch, the group will either move towards the closest hospitable patch with probability 0.3 or it will move to a random patch.
    [ 
      ifelse 0.3 > random 1
      [
        if closest-hospitable != nobody
        [face closest-hospitable]
        fd 1
      ]
      [
      fd 2
      ]
     ]
 [ 
  ifelse closest != nobody  ;;Either follow a guerrilla or move towards a hospitable patch
  [ face closest
    ifelse [kind] of patch-ahead 1 = "inhospitable" or count [armies-here] of patch-ahead 1 > 1
    [ifelse 0.5 > random 1 
      [if a-guerrilla != nobody [face a-guerrilla]
      fd 1]
      [
       fd 2
      ]
    ]
    [ 
     fd 2
    ]
  ]
  [
    ifelse 0.8 > random 1
      [
        if a-hospitable != nobody
        [face a-hospitable]
        fd 1
       ]
       [
        rt random 180
        lt random 180
        fd 1
       ]
  ]
]
  
end

to move-guerrillas  ;; guerrillas procedure
  let someone neighbors with [population > 0]
  let good neighbors with [not any? armies-here and resources > 20]
  let bad neighbors with [any? armies-here]
  let closest-hospitable min-one-of other patches with [kind = "hospitable"] [distance myself]
  let best-patch max-one-of other patches [resources]
  let closest-inhospitable min-one-of other patches with [kind = "inhospitable"] [distance myself]
   
  ifelse [kind] of patch-here = "inhospitable"
  [  
    ifelse not any? someone
    [ if best-patch != nobody [face closest-hospitable]
      fd 1]
    [   
        ifelse any? good 
        [face one-of good
          fd 1]
        [face one-of patches with [kind = "inhospitable"]
        fd 1] 
    ]
        
  ]
  [ ifelse number-guerrillas < high-mobility-threshold 
    [
      ifelse count bad > 0
      [
        if closest-inhospitable != nobody [face closest-inhospitable]
        fd 5
      ]
      [;if count guerrillas-here > 1 and [active-guerrillas] of patch-here < count (guerrillas-here) - 1 
        ifelse any? good
          [face one-of good
          fd 1
          ask patch-here[set active-guerrillas active-guerrillas + 1]
          ]
          [
           if random 1 > 0.5
           [face closest-inhospitable
             fd 1] 
          ]
        
      ]
    ]
    [
      ifelse count bad > 2
      [
        if closest-inhospitable != nobody [face closest-inhospitable]
        fd 3
      ]
      [
        ifelse any? good
          [face one-of good
          fd 1
          ask patch-here[set active-guerrillas active-guerrillas + 1]
          ]
          [
            if random 1 > 0.5
            [face closest-inhospitable
             fd 1]
          ] 
        
      ]
    ]
    
  ]
end
  

to reproduce-armies  ;; armies procedure
  
  ifelse soldiers > 20
  [ set soldiers (ceiling (soldiers / 2))
    set resources (resources / 2)                ;; divide energy between parent and offspring
    hatch 1 [ rt random-float 360 ] ]
  [if random-float 100 < armies-reproduce [  ;; throw "dice" to see if you will reproduce
    set soldiers (soldiers + ceiling (0.1 * resources))  
  ]]
end
  
to reproduce-guerrillas ;; armies procedure
  ifelse soldiers > 10
  [ set soldiers (ceiling (soldiers / 2))
    set resources (resources / 2)                ;; divide energy between parent and offspring
    hatch 1 [ rt random-float 360 ] ]
  [if random-float 100 < guerrillas-reproduce [  ;; throw "dice" to see if you will reproduce
    set soldiers (soldiers + ceiling (0.1 * resources))  
  ]]
end 

to lose-resources ;; patch procedure, the resources are depleted
  ifelse resources > 4
  [set resources resources - 4]
  [set resources 0]
end

to grow-resources ;; resources grow in the patch
  ifelse resources < max-resources-patches
  [set resources resources + 0.4]
  [set resources max-resources-patches]
end

to recolor
  if kind = "inhospitable"
  [
    set pcolor brown + resources * 0.01
  ]
  if kind = "hospitable"
  [ 
    set pcolor green -  resources * 0.02 
  ]
end

to kill ;;turtle procedure
    if soldiers <= 0
      [die]
  
end



to display-labels
  ask turtles [ set label "" ]
  if show-soldiers? [
    ask turtles [ set label round soldiers ]
    ;ask armies [ set label round soldiers ] ]
  ]
end



;;Creating the geography of the model

to create-geography
  while [ticks <= 3]
  [
  ask patches [ pick-new-color ]
  ask patches [ set pcolor new-color ]
  tick]
  reset-ticks
end

to pick-new-color  ;; patch procedure
  let activator count inner-neighbors with [pcolor = brown]
  let inhibitor count outer-neighbors with [pcolor = brown]
  let ratio 0.3
  ;; we don't need to multiply 'activator' by a coefficient because
  ;; the ratio variable keeps the proportion intact
  let difference activator - ratio * inhibitor
  ifelse difference > 0
    [ set new-color brown ]
    [ if difference < 0
        [ set new-color green ] ]
  ;; note that we did not deal with the case that difference = 0.
  ;; this is because we would then want cells not to change color.
end

;;; procedures for defining elliptical neighborhoods

to-report ellipse-in [x-radius y-radius]  ;; patch procedure
  report patches in-radius (max list x-radius y-radius)
           with [1.0 >= ((xdistance myself ^ 2) / (x-radius ^ 2)) +
                        ((ydistance myself ^ 2) / (y-radius ^ 2))]
end

to-report ellipse-ring [outx-radius outy-radius inx-radius iny-radius]  ;; patch procedure
  report patches in-radius (max list outx-radius outy-radius)
           with [1.0 >= ((xdistance myself ^ 2) / (outx-radius ^ 2)) +
                        ((ydistance myself ^ 2) / (outy-radius ^ 2))
             and 1.0 <  ((xdistance myself ^ 2) / (inx-radius ^ 2)) +
                        ((ydistance myself ^ 2) / (iny-radius ^ 2))
                ]
end

;; The following two reporter give us the x and y distance magnitude.
;; you can think of a point at the tip of a triangle determining how much
;; "to the left" it is from another point and how far "over" it is from
;; that same point. These two numbers are important for computing total distances
;; in elliptical "neighborhoods."

;; Note that it is important to use the DISTANCEXY primitive and not
;; just take the absolute value of the difference in coordinates,
;; because DISTANCEXY handles wrapping around world edges correctly,
;; if wrapping is enabled (which it is by default in this model)

to-report xdistance [other-patch]  ;; patch procedure
  report distancexy [pxcor] of other-patch
                    pycor
end

to-report ydistance [other-patch]  ;; patch procedure
  report distancexy pxcor
                    [pycor] of other-patch
end

to-report moore-offsets [n]; include-center?]
  let result [list pxcor pycor] of patches with [abs pxcor <= n and abs pycor <= n]
  ;ifelse include-center?
   report result 
    ; [report remove [0 0] result ]
end

; Copyright 1997 Uri Wilensky.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
375
26
697
369
15
15
10.065
1
14
1
1
1
0
1
1
1
-15
15
-15
15
1
1
1
ticks
30.0

SLIDER
4
255
176
288
initial-number-armies
initial-number-armies
0
500
500
20
1
NIL
HORIZONTAL

SLIDER
4
179
176
212
max-army-size
max-army-size
0.0
50.0
20
1.0
1
NIL
HORIZONTAL

SLIDER
4
217
176
250
armies-reproduce
armies-reproduce
1.0
100.0
20
1.0
1
%
HORIZONTAL

SLIDER
190
255
356
288
initial-number-guerrillas
initial-number-guerrillas
0
250
300
1
1
NIL
HORIZONTAL

SLIDER
190
179
356
212
max-guerrilla-size
max-guerrilla-size
0.0
100.0
10
1.0
1
NIL
HORIZONTAL

SLIDER
190
217
356
250
guerrillas-reproduce
guerrillas-reproduce
0.0
100.0
20
1.0
1
%
HORIZONTAL

SLIDER
4
140
176
173
max-resources-patches
max-resources-patches
0
100
100
1
1
NIL
HORIZONTAL

BUTTON
8
28
77
61
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
134
30
201
63
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
717
26
1009
223
Populations
time
pop.
0.0
100.0
0.0
1100.0
true
true
"" ""
PENS
"guerrilla" 1.0 0 -5298144 true "" "plot number-guerrillas"
"army" 1.0 0 -14730904 true "" "plot number-armies"

SWITCH
189
69
355
102
show-soldiers?
show-soldiers?
0
1
-1000

SLIDER
4
293
176
326
max-resources-army
max-resources-army
0
100
100
1
1
NIL
HORIZONTAL

PLOT
1021
26
1292
223
Resources
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"guerrilla" 1.0 0 -5298144 true "" "plot resources-guerrillas"
"army" 1.0 0 -14730904 true "" "plot resources-armies"

SLIDER
4
332
176
365
max-capacity
max-capacity
0
100
100
1
1
NIL
HORIZONTAL

SLIDER
190
293
356
326
max-resources-guerrilla
max-resources-guerrilla
0
100
30
1
1
NIL
HORIZONTAL

SLIDER
190
141
355
174
max-resources-global
max-resources-global
0
10000
5000
1
1
NIL
HORIZONTAL

PLOT
1021
235
1292
425
Body counts
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"army" 1.0 0 -14730904 true "" "plot body-count-armies"
"guerrilla" 1.0 0 -5298144 true "" "plot body-count-guerrillas"
"total" 1.0 0 -16777216 true "" "plot body-count-armies + body-count-guerrillas"

CHOOSER
8
69
176
114
what-geography
what-geography
"isolated" "ranges" "mountains" "islands"
3

SLIDER
4
371
176
404
paramilitary-threshold
paramilitary-threshold
500
1000
500
1
1
NIL
HORIZONTAL

SLIDER
190
371
357
404
high-mobility-threshold
high-mobility-threshold
0
500
100
1
1
NIL
HORIZONTAL

PLOT
717
234
1009
426
Clustering
Time
Clustering
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"guerrilla" 1.0 0 -5298144 true "" "plot clustering-guerrillas"
"army" 1.0 0 -14070903 true "" "plot clustering-armies"

@#$#@#$#@
## WHAT IS IT?

This model explores a simplification of guerrilla warfare inspired in Colombia's internal conflict. It resembles an ecological model, with populations of armies and guerrillas interacting with each other and getting resources from the land. The evolution of the populations, its resources, the number of dead soldiers and a clustering coefficient of each group are studied.

## HOW IT WORKS

There are 4 different geographies to choose from (ranges, mountains,islands and isolated), which have different levels of hospitable and inhospitable territories. Notwithstanding the chosen geography, groups behave in the same way. Armies main goal is to track down and kill guerrillas, while the latter try to control new rich territories, make quick attacks and escape from armies. The model is stopped when one kind has made the other one go extinct.

The construction of this model is described in a paper by Pardo referenced below.

## HOW TO USE IT

1. Select the geography you want to explore with the WHAT-GEOGRAPHY chooser.
2. Set the SHOW-SOLDIERS? switch to ON to be able to see the population of each group, or to FALSE if you don't want to see this information displayed.
3. Adjust the slider parameters (see below), or use the default settings.
4. Press the SETUP button.
5. Press the GO button to begin the simulation.
6. Look at the four different plots to see the evolution of populations, its resources, their number of killed soldiers and their clustering coefficient over time.

Parameters:
MAX-RESOURCES-PATCHES: The maximum amount of resource units a patch can posses.
MAX-RESOURCES-GLOBAL: The maximum amount of resource units that can exist in the entire world.
MAX-ARMY-SIZE: The maximum number of soldiers an army group can have.
MAX-GUERRILLA-SIZE: The maximum number of soldiers a guerrilla group can have.
ARMIES-REPRODUCE: The probability with which an army group will recruit new members.
GUERRILLAS-REPRODUCE: The probability with which a guerrilla group will recruit new members.
INITIAL-NUMBER-ARMIES: The initial number of army soldiers.
INITIAL-NUMBER-GUERRILLAS: The initial number of guerrilla soldiers.
MAX-RESOURCES-ARMY: The maximum number of resource units an army group can have.
MAX-RESOURCES-GUERRILLA: The maximum number of resource units a guerrilla group can have.
MAX-CAPACITY: The maximum population capacity of a patch.
PARAMILITARY-THRESHOLD: If the total guerrilla population goes over this threshold, paramilitary activity begins.
HIGH-MOBILITY-THRESHOLD: If the guerrilla population goes below this threshold, they activate the high-mobility mode.


## THINGS TO NOTICE

See the difference in guerrilla succes as the geographies are varied. Are they more succesful as inhospitable land extends as is to be expected?

Notice the variations in the clustering coefficients both for single runs and across geographies.

Explore the effects of the initial number of guerrillas.

Are there essentially different behaviors as the GUERRILLAS-REPRODUCE parameter is varied?



## THINGS TO TRY

How sensitive is the model to different changes in parameters?

Can you find any parameters or geographies where both armed groups can coexist?

Will changes in patch and group capacities have a noticeable effect in the outcomes?

What is the effect of varying the maximum size of guerrilla groups?

Try changing the attack rules, what happens if battle outcomes also depend on the amount of resources od each group?

## EXTENDING THE MODEL

Paramilitary groups and civilian population could be included as new kinds of agents. Agents could learn better strategies to accomplish their goals.

## NETLOGO FEATURES

The Fur model cited below was used to set the different geographies.

Different neighborhoods were defined.

## RELATED MODELS

The framework of this model is based on the Wolf Sheep predation model.

## CREDITS AND REFERENCES

* Wilensky, U. & Reisman, K. (1999). Connected Science: Learning Biology through Constructing and Testing Computational Theories -- an Embodied Modeling Approach. International Journal of Complex Systems, M. 234, pp. 1 - 12. (This model is a slightly extended version of the model described in the paper.)

* Wilensky, U. & Reisman, K. (2006). Thinking like a Wolf, a Sheep or a Firefly: Learning Biology through Constructing and Testing Computational Theories -- an Embodied Modeling Approach. Cognition & Instruction, 24(2), pp. 171-209. http://ccl.northwestern.edu/papers/wolfsheep.pdf

* Wilensky, U. (1997).  NetLogo Wolf Sheep Predation model.  http://ccl.northwestern.edu/netlogo/models/WolfSheepPredation.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

* Wilensky, U. (2003). NetLogo Fur model. http://ccl.northwestern.edu/netlogo/models/Fur. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.
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

person guerrilla
false
0
Rectangle -7500403 true true 127 79 172 94
Polygon -2674135 true false 105 90 60 195 90 210 135 105
Polygon -2674135 true false 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Polygon -2674135 true false 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -16777216 true false 120 90 105 90 180 195 180 165
Line -6459832 false 109 105 139 105
Line -6459832 false 122 125 151 117
Line -6459832 false 137 143 159 134
Line -6459832 false 158 179 181 158
Line -6459832 false 146 160 169 146
Rectangle -16777216 true false 120 193 180 201
Polygon -16777216 true false 122 4 107 16 102 39 105 53 148 34 192 27 189 17 172 2 145 0
Polygon -16777216 true false 183 90 240 15 247 22 193 90
Rectangle -16777216 true false 114 187 128 208
Rectangle -16777216 true false 177 187 191 208

person police
false
0
Polygon -1 true false 124 91 150 165 178 91
Polygon -13345367 true false 134 91 149 106 134 181 149 196 164 181 149 106 164 91
Polygon -13345367 true false 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -13345367 true false 120 90 105 90 60 195 90 210 116 158 120 195 180 195 184 158 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Rectangle -7500403 true true 123 76 176 92
Circle -7500403 true true 110 5 80
Polygon -13345367 true false 150 26 110 41 97 29 137 -1 158 6 185 0 201 6 196 23 204 34 180 33
Line -13345367 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Rectangle -16777216 true false 109 183 124 227
Rectangle -16777216 true false 176 183 195 205
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Polygon -1184463 true false 172 112 191 112 185 133 179 133
Polygon -1184463 true false 175 6 194 6 189 21 180 21
Line -1184463 false 149 24 197 24
Rectangle -16777216 true false 101 177 122 187
Rectangle -16777216 true false 179 164 183 186

person soldier
false
0
Rectangle -7500403 true true 127 79 172 94
Polygon -13345367 true false 105 90 60 195 90 210 135 105
Polygon -13345367 true false 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Polygon -13345367 true false 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -16777216 true false 120 90 105 90 180 195 180 165
Line -6459832 false 109 105 139 105
Line -6459832 false 122 125 151 117
Line -6459832 false 137 143 159 134
Line -6459832 false 158 179 181 158
Line -6459832 false 146 160 169 146
Rectangle -16777216 true false 120 193 180 201
Polygon -16777216 true false 122 4 107 16 102 39 105 53 148 34 192 27 189 17 172 2 145 0
Polygon -16777216 true false 183 90 240 15 247 22 193 90
Rectangle -16777216 true false 114 187 128 208
Rectangle -16777216 true false 177 187 191 208

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
setup
set grass? true
repeat 75 [ go ]
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>number-armies</metric>
    <metric>number-guerrillas</metric>
    <metric>body-count-armies</metric>
    <metric>body-count-guerrillas</metric>
    <enumeratedValueSet variable="initial-number-guerrillas">
      <value value="50"/>
    </enumeratedValueSet>
    <steppedValueSet variable="guerrillas-reproduce" first="1" step="1" last="20"/>
    <enumeratedValueSet variable="high-mobility-threshold">
      <value value="101"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-resources-army">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-army-size">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="what-geography">
      <value value="&quot;ranges&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-number-armies">
      <value value="226"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="armies-reproduce">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-resources-guerrilla">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="paramilitary-threshold">
      <value value="800"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-soldiers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-guerrilla-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-resources-patches">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-resources-global">
      <value value="6133"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="30" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>ticks</metric>
    <metric>number-armies</metric>
    <metric>number-guerrillas</metric>
    <metric>body-count-armies</metric>
    <metric>body-count-guerrillas</metric>
    <metric>clustering-armies</metric>
    <metric>clustering-guerrillas</metric>
    <enumeratedValueSet variable="guerrillas-reproduce">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="armies-reproduce">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-resources-guerrilla">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="paramilitary-threshold">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="what-geography">
      <value value="&quot;ranges&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-guerrilla-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-number-armies">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-resources-global">
      <value value="5000"/>
    </enumeratedValueSet>
    <steppedValueSet variable="initial-number-guerrillas" first="10" step="10" last="300"/>
    <enumeratedValueSet variable="high-mobility-threshold">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-resources-patches">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-capacity">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-resources-army">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-soldiers?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-army-size">
      <value value="20"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
