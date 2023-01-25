globals
[ day

  colors
  color-names
  num-colors
  used-colors
  moneyissue
  layoutissue
  qualityissue
  serviceissue

  n/a
]

patches-own [ ]

breed [ houses house ]
breed [ customers customer ]

customers-own [
	customer-layout
	customer-service
	customer-quality
	customer-money

  booked?
  checked
  my-house
  appeal
]

houses-own [
  houseid

  owner-balance
	owner-bankrupt?

  house-color

  house-layout
	house-service
	house-quality
	house-money

  days-revenue
  days-cost
  days-profit
  num-customers
  profit-customer	

  available?

]

to startup
	setup
end

to setup
	clear-patches
	clear-turtles
	clear-output
	reset
end

to reset
	setup-globals
	setup-customers
	clear-all-plots
  ask houses
  [ reset-owner-variables ]
end

to setup-globals
	reset-ticks
	set day 0
	set-default-shape customers "person"
	
	;; Set the available colors  and their names
  	set colors      [ lime   orange   brown   yellow  turquoise  cyan   sky   blue
                   violet   magenta   pink  red  green  gray  12 62 102 38 ]
  	set color-names ["lime" "orange" "brown" "yellow" "turquoise" "cyan" "sky" "blue"
                   "violet" "magenta" "pink" "red" "green" "gray" "maroon" "hunter green" "navy" "sand"]
  	set used-colors []
  	set num-colors length colors
  	set n/a "n/a"
end

to setup-customers
	ask customers
	[die]
	create-customers world-customers
	[set booked? false
  set my-house -1
	set checked 0
	
	setxy random-xcor random-ycor

  set appeal 0

	let layout (1 + random 3)

	set customer-money (20 + random 81)
	;;set customer-layout (1 + random 3)
	set customer-quality (1 + random 9)
	set customer-service (1 + random 9)

	ifelse (layout = 1)
	[	set color red
	 	set customer-layout "1-room" ]
	[ifelse (layout = 2)
	[	set color yellow
		set customer-layout "2-room"]
	[	set color cyan
		set customer-layout "3-room"]]]
end

to create-new-houses
	create-houses num-houses
  [	set houseid one-of ["Dwight" "Michael" "Jim" "Pam" "Kevin" ]
	reset-owner-variables
  setup-house
  setup-location
  ]
end

to setup-house
  let layout (1 + random 3)
  ;;set house-layout (1 + random-normal 2)
  ifelse (layout = 1)
	[	set color red
    set size 2
    set shape "house"
	 	set house-layout "1-room" ]
	[ifelse (layout = 2)
	[	set color yellow
    set size 2
    set shape "house"
		set house-layout "2-room"]
	[	set color cyan
    set size 2
    set shape "house"
    set house-layout "3-room"]]
  reset-owner-variables
end

to setup-location
  setxy ((random (world-width - 2)) + 1)
        ((random (world-height - 2)) + 1)
  if any? other houses in-radius 3
  [ setup-location ]
end

to reset-owner-variables
  set available? true
  set owner-bankrupt? false
  set owner-balance 6000
  set days-revenue 0
  set days-cost layout-cost
  set days-profit 0
  set profit-customer 100
  set num-customers 0
  set house-money random 50
	;;set house-layout (1 + random 3)
	set house-quality 50 + random 50
	set house-service 50 + random 50
end

to-report color->string [ color-value ]
  report item (position color-value colors) color-names
end



to setup-prompt
 if user-yes-or-no? (word "Are you sure? ")
 [ user-message (word "As you say")
   setup ]
end

to go

  if not any? houses
  [ user-message "There are no houses."
    stop ]

  ask houses with [ owner-bankrupt? = true ]
  [ die ]
  ask houses with [ owner-bankrupt? = false and available? = false ]
  ;;ask houses with [ available? = false ]
  [ serve-customers ]
  ask houses with [ owner-bankrupt? = false and available? = true ]
  ;;ask houses with [ available? = true ]
  [ attract-customers ]
  ask customers
  [ move-customers ]
  ;;ask customers with booked = true
  ;;[ stay-customers ]
  if (ticks mod day-length) = 0
  [ set day day + 1
    plot-disgruntled-customers
    plot-house-statistics
    ask houses with [ owner-bankrupt? = false ]
    [ end-day ]]
  tick
end

to attract-customers
  let house# houseid
  let r-x xcor
  let r-y ycor
  let r-layout house-layout
  let r-service house-service
  let r-quality house-quality
  let r-money house-money
  ;;let adj-price (restaurant-price - 0.15 * restaurant-service)
  ;;let adj-quality (restaurant-quality + 0.15 * restaurant-service)
  ;;let util-price false
  ;;let util-quality false
  ;;let restaurant-appeal false

  ask customers with [ (booked? = false)] in-radius 7
  [
    set checked checked + 1
    ifelse (r-money < customer-money)
    [ set appeal appeal + 10
      ifelse (customer-layout = r-layout)
    [ set appeal appeal + 10
      ifelse (customer-service <= r-service)
    [ set appeal appeal + 10
      ifelse (customer-quality <= r-quality)
    [ set booked? true
      set appeal appeal + 10
      set my-house house#
      facexy r-x r-y
    ]
      [set qualityissue (qualityissue + 1)]]
      [ set serviceissue serviceissue + 1
          move-customers ]]
      [ set layoutissue layoutissue + 1
        move-customers ]]
      [ set moneyissue moneyissue + 1
          move-customers]
  ]
  set available? false
end

to serve-customers
  let house# houseid
  let new-customers 0
  set available? true
  ask customers with [ (booked? = true) and (my-house = house#)] in-radius 1
  [ set booked? false
	set checked 0
	set appeal 0
	setxy random-xcor random-ycor

	let layout (1 + random 3)

	set customer-money (20 + random 81)
	;;set customer-layout (1 + random 3)
	set customer-quality (1 + random 9)
	set customer-service (1 + random 9)

	ifelse (layout = 1)
	[	set color red
	 	set customer-layout "1-room" ]
	[ifelse (layout = 2)
	[	set color yellow
		set customer-layout "2-room"]
	[	set color cyan
        set customer-layout "3-room"]]

    set new-customers new-customers + 1

    set my-house -1

  ]
  set num-customers (num-customers + new-customers)
  set days-revenue (days-revenue + (new-customers * house-money))
  set days-cost round (days-cost + (new-customers * service-cost * house-service) + (new-customers * quality-cost * house-quality))
  set days-profit round (days-revenue - days-cost)

end

to move-customers
  if booked? = false
 [ rt random-float 45 - random-float 45 ]
  fd 1
end

to end-day
  set owner-balance round (owner-balance + days-profit)
  set days-cost layout-cost
  set days-revenue 0
  set days-profit (days-revenue - days-cost)
  set num-customers 0

  if (bankruptcy?) ;; If the owner is bankrupt shut his restaurant down
  [ if (owner-balance < 0)
  [ set owner-bankrupt? true ] ]

  ask houses
  [ set house-money random 50
	;;set house-layout (1 + random 3)
	set house-quality 50 + random 50
	set house-service 50 + random 50

  setup-house
  setup-location
  ]
end

to plot-disgruntled-customers
  set-current-plot "Disgruntled Customers"
  plot disgruntled-consumers
end

to plot-house-statistics

    set-current-plot "Profits"
    set-current-plot-pen "avg-profit"
    plot mean [days-profit] of houses

    set-current-plot "# Customers"
    set-current-plot-pen "avg-custs"
    plot mean [num-customers] of houses
    ;;plot num-customers

  set-current-plot "Appeal"
    set-current-plot-pen "min."
    plot min [appeal] of customers
    set-current-plot-pen "avg."
    plot mean [appeal] of customers
    set-current-plot-pen "max."
    plot max [appeal] of customers
end

;; reports the avg profit from all the owners on the current day
to-report avg-profit/owner
  report mean [ days-profit ] of houses
end

to-report avg-customers/owner
  report mean [ num-customers ] of houses
end

to-report disgruntled-consumers
  report count customers with [ checked > 15 ]
end

to-report #1-room
  report count houses with [ house-layout = "1-room" ]
end

;; reports the number of fine dining restaurants in the marketplace
to-report #2-room
  report count houses with [ house-layout = "2-room" ]
end

;; reports the number of fast food restaurants in the marketplace
to-report #3-room
  report count houses with [ house-layout = "3-room" ]
end
@#$#@#$#@
GRAPHICS-WINDOW
0
10
633
644
-1
-1
29.8
1
10
1
1
1
0
1
1
1
-10
10
-10
10
1
1
1
ticks
30.0

SLIDER
1251
203
1531
236
world-customers
world-customers
0
500
366.0
1
1
NIL
HORIZONTAL

BUTTON
191
669
255
735
Setup
setup-prompt
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
268
670
346
736
Go
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

SWITCH
1564
337
1690
370
bankruptcy?
bankruptcy?
0
1
-1000

PLOT
653
547
1165
737
Profits
Days
$$
0.0
10.0
0.0
100.0
true
false
"" ""
PENS
"avg-profit" 1.0 0 -16777216 true "" ""

PLOT
653
10
1163
189
Appeal
Day
Satis.
0.0
10.0
0.0
100.0
true
false
"" ""
PENS
"max." 1.0 0 -955883 true "" ""
"avg." 1.0 0 -2674135 true "" ""
"min." 1.0 0 -7500403 true "" ""

PLOT
652
198
1164
365
Disgruntled Customers
Day
Custs.
0.0
10.0
0.0
50.0
true
false
"" ""
PENS
"custs." 1.0 0 -13345367 true "" ""

MONITOR
543
681
630
726
Day
day
3
1
11

BUTTON
361
672
522
733
Re-Run
reset
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
1259
255
1473
288
service-cost
service-cost
0.01
0.5
0.08
0.01
1
$
HORIZONTAL

SLIDER
1259
365
1473
398
quality-cost
quality-cost
0.01
1
0.13
0.01
1
$
HORIZONTAL

SLIDER
1258
312
1472
345
layout-cost
layout-cost
0
200
20.0
10
1
$
HORIZONTAL

SLIDER
1562
203
1835
236
num-houses
num-houses
1
20
20.0
1
1
NIL
HORIZONTAL

BUTTON
0
666
176
734
Create-Houses
create-new-houses
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1564
271
1628
316
1-room
#1-room
3
1
11

MONITOR
1630
271
1694
316
2-room
#2-room
3
1
11

PLOT
653
372
1164
539
# Customers
Day
Cust.
0.0
10.0
0.0
20.0
true
false
"" ""
PENS
"avg-custs" 1.0 0 -16777216 true "" ""

TEXTBOX
1580
253
1766
271
Number of houses by layout
11
0.0
0

SLIDER
1564
371
1690
404
day-length
day-length
1
50
50.0
1
1
NIL
HORIZONTAL

MONITOR
1695
271
1759
316
3-room
#3-room
3
1
11

@#$#@#$#@
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

restaurant american
false
0
Circle -6459832 true false 88 13 123
Rectangle -6459832 true false 38 204 261 275
Circle -6459832 true false 19 49 79
Circle -6459832 true false 200 49 83
Rectangle -955883 true false 8 95 293 247
Rectangle -1 true false 46 75 253 117
Rectangle -955883 true false 57 86 240 128
Rectangle -955883 true false 32 95 269 139
Rectangle -1 true false 23 236 278 263
Rectangle -955883 true false 15 214 286 246
Rectangle -955883 true false 37 237 259 255
Rectangle -955883 true false 42 73 254 110
Rectangle -955883 true false 18 235 282 265
Rectangle -1184463 true false 17 105 283 235
Rectangle -1184463 true false 31 225 267 252
Rectangle -1184463 true false 58 84 236 119
Circle -1184463 true false 94 49 110
Rectangle -2674135 true false 15 105 284 235
Rectangle -2674135 true false 55 83 239 121
Rectangle -2674135 true false 27 227 270 254
Circle -2674135 true false 96 41 105
Circle -7500403 true true 99 114 95
Circle -16777216 false false 105 120 90

restaurant asian
false
0
Circle -6459832 true false 88 13 123
Rectangle -6459832 true false 38 204 261 275
Circle -6459832 true false 19 49 79
Circle -6459832 true false 200 49 83
Rectangle -955883 true false 8 95 293 247
Rectangle -1 true false 46 75 253 117
Rectangle -955883 true false 57 86 240 128
Rectangle -955883 true false 32 95 269 139
Rectangle -1 true false 23 236 278 263
Rectangle -955883 true false 15 214 286 246
Rectangle -955883 true false 37 237 259 255
Rectangle -955883 true false 42 73 254 110
Rectangle -955883 true false 18 235 282 265
Rectangle -1184463 true false 17 105 283 235
Rectangle -1184463 true false 31 225 267 252
Rectangle -1184463 true false 58 84 236 119
Circle -1184463 true false 94 49 110
Circle -7500403 true true 105 118 89
Circle -16777216 false false 105 120 90

restaurant european
false
0
Circle -6459832 true false 88 13 123
Rectangle -6459832 true false 38 204 261 275
Circle -6459832 true false 19 49 79
Circle -6459832 true false 200 49 83
Rectangle -955883 true false 8 95 293 247
Rectangle -1 true false 46 75 253 117
Rectangle -955883 true false 57 86 240 128
Rectangle -955883 true false 32 95 269 139
Rectangle -1 true false 23 236 278 263
Rectangle -955883 true false 15 214 286 246
Rectangle -955883 true false 37 237 259 255
Rectangle -955883 true false 42 73 254 110
Rectangle -955883 true false 18 235 282 265
Rectangle -2674135 true false 7 94 293 247
Rectangle -2674135 true false 41 73 254 101
Rectangle -2674135 true false 16 243 282 265
Rectangle -11221820 true false 16 104 282 238
Rectangle -11221820 true false 52 81 241 112
Rectangle -11221820 true false 26 229 270 258
Circle -11221820 true false 101 46 94
Circle -7500403 true true 100 118 93
Circle -16777216 false false 105 120 90

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
NetLogo 6.3.0
@#$#@#$#@
need-to-manually-make-preview-for-this-model
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
VIEW
349
11
727
389
0
0
0
1
1
1
1
1
0
1
1
1
-10
10
-10
10

SLIDER
6
167
134
200
Service
Service
1.0
100.0
50
1.0
1
NIL
HORIZONTAL

SLIDER
6
237
134
270
Price
Price
1.0
100.0
50
1.0
1
NIL
HORIZONTAL

SLIDER
6
202
134
235
Quality
Quality
1.0
100.0
50
1.0
1
NIL
HORIZONTAL

CHOOSER
6
120
134
165
Cuisine
Cuisine
\"American\" \"Asian\" \"European\"
0

MONITOR
9
10
113
59
Restaurant Color
NIL
0
1

MONITOR
114
10
216
59
Account Balance
NIL
0
1

MONITOR
145
122
279
171
Number of Customers
NIL
0
1

MONITOR
9
63
59
112
Day
NIL
0
1

MONITOR
264
64
341
113
Day's Profit
NIL
0
1

MONITOR
218
10
281
59
Bankrupt?
NIL
3
1

MONITOR
145
173
279
222
Profit / Customer
NIL
2
1

PLOT
173
272
344
392
Profits
Days
$$
0.0
20.0
0.0
10.0
true
false
"" ""
PENS
"avg-profit" 1.0 0 -16777216 true "" ""

MONITOR
284
10
341
59
Rank
NIL
3
1

PLOT
6
272
170
392
# Customers
Day
Cust.
0.0
10.0
0.0
100.0
true
false
"" ""
PENS
"avg-custs" 1.0 0 -16777216 true "" ""

MONITOR
86
64
183
113
Day's Revenue
NIL
0
1

MONITOR
184
64
257
113
Day's Cost
NIL
0
1

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
