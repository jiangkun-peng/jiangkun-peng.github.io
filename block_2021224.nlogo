breed [farmers farmer]
breed [middlemans middleman]
breed [retailers retailer]
breed [monitors monitor]

farmers-own [
  honesty  ;诚信度
  good ;产品
  blockchain? ;是否为区块链农户
  profit ;利润
  punishment? ;本期是否接受惩罚
  G ;阈值
  sell?  ;是否持有产品
]

middlemans-own [
  G ;阈值
  good ;产品
  blockchain? ;是否为区块链中间商
  profit ;利润
  punishment? ;本期是否接受惩罚
  sell? ;是否持有产品
]

retailers-own [
  G ;阈值
  good ;产品
  blockchain? ;是否为区块链零售商
  cost ;成本
  punishment? ;本期是否接受惩罚
]

globals [
  n ;农户数量
  m ;中间商数量
  k ;零售商数量
  s ;产品数量
  p1 ;价格1
  p2 ;价格2
  p3 ;价格3
  a ;权重参数
  Cs ;生产安全产品的成本
  Cu ;生产不安全产品的成本
  C_t ;区块链模型增加的单位成本
  eta
  type? ;产品种类：安全|不安全
  theta ;中间商每单位运输费用
  B1 ;生产不安全产品被发现的惩罚
  B2 ;生产不安全产品被发现的惩罚
  B3 ;生产不安全产品被发现的惩罚
  p ;权重系数
  r_mean ;周围相同主体的平均收益
  c_mean ;周围相同主体的平均成本
  f1 ;诚信度调整系数
  f2 ;诚信度调整系数
  v1p ;阈值调整系数
  v1n ;阈值调整系数
  v2p ;阈值调整系数
  v2n ;阈值调整系数
  efficiency ;流通效率
  tv ;流通产品总价值
  tc ;流通产品总成本
  qr ;产品质量（安全率）
  ki ;不同模式（普通|区块链）收益差
]

to setup
  clear-all
  setup-constants
  setup-turtles
  reset-ticks
end

to setup-turtles
  create-farmers n [
  set honesty random-float 1
  setxy random-xcor random-ycor
  set shape "person"
  set color green
  set blockchain? false
  set profit 0
  set G random-float 1
  set sell? "no"
  ]

  create-middlemans m [
  setxy random-xcor random-ycor
  set shape "person"
  set color  white
  set good []
  set blockchain? false
  set profit 0
  set G random-float 1
  set sell? "no"
  ]

  create-retailers k [
  setxy random-xcor random-ycor
  set shape "person"
  set color blue
  set good []
  set G random-float 1
  set blockchain? false
  set cost 0
  ]

  create-monitors 2 [
  setxy random-xcor random-ycor
  set shape "person"
  set color red
  ]


  if mode = "blockchain" [ask n-of (n / 2) farmers [set blockchain? true]]
  if mode = "blockchain" [ask n-of (m / 2) middlemans [set blockchain? true]]
  if mode = "blockchain" [ask n-of (k / 2) retailers [set blockchain? true]]
end


to go
  produce ;农户生产产品
  trade ;交易
  punishment ;抽查产品，检验是否安全
  calculate-profit ;计算主体利润
  if (mode = "blockchain") [transformation] ;主体模式转换
  ;calculate-efficiency ;计算流通效率
  update-honesty ;更新诚信度
  tick
  do-plot
end

to produce
  ask farmers [set good [] set punishment? false set profit 0]
  ask middlemans [set good [] set punishment? false set profit 0]
  ask retailers [set good [] set punishment? false set cost 0]
  ask farmers with [blockchain? = true] [
    production-decision ;生产决策
    set good (list who s type?)
    set sell? "yes"
  ]
  ask farmers with [blockchain? = false][
    production-decision ;生产决策
    set good (list "none" s type?)
    set sell? "yes"
  ]
end

to trade
  repeat 100 [
  ask farmers [rt random 360 fd 2]
  ask farmers with [blockchain? = false and sell? = "yes"] [let i middlemans in-radius 5 with [blockchain? = false] if count i > 0 [set sell? "no" ask one-of i [set good insert-item 0 good [good] of myself set sell? "yes"]]]
  ]
  repeat 100 [
  ask middlemans [rt random 360 fd 2]
  ask middlemans with [blockchain? = false and sell? = "yes"] [let i retailers in-radius 5 with [blockchain? = false ] if count i > 0 [set sell? "no" ask one-of i [set good insert-item 0 good [good] of myself ]]]
  ]
   if (mode = "blockchain") [
  repeat 100 [
  ask farmers [rt random 360 fd 2]
  ask farmers with [blockchain? = true and sell? = "yes"] [let i middlemans in-radius 5 with [blockchain? = true] if count i > 0 [set sell? "no" ask one-of i [set good insert-item 0 good [good] of myself set sell? "yes"]]]
    ]
  repeat 100 [
  ask middlemans [rt random 360 fd 2]
  ask middlemans with [blockchain? = true and sell? = "yes"] [let i retailers in-radius 5 with [blockchain? = true] if count i > 0 [set sell? "no" ask one-of i [set good insert-item 0 good [good] of myself ]]]
    ]
    ]
end

to punishment
  ask monitors [rt random 360 fd 2]
  ask monitors[
    if count farmers in-radius 5 > 0 [ask farmers in-radius 5 with [sell? = "no"][if (item 2 good = "unsafe") [set punishment? true ]]]
    if count middlemans in-radius 5 > 0 [ask middlemans in-radius 5 with [length good > 0][ifelse blockchain? = true [let i 0 while [i < length good] [let i_1 item i good if item 2 i_1 = "unsafe" [ask turtle item 0 i_1 [set punishment? true]] set i i + 1]] [let i 0 while [i < length good] [let i_1 item i good if item 2 i_1 = "unsafe"[set punishment? true] set i i + 1]]]]
    if count retailers in-radius 5 > 0  [ask retailers in-radius 5 with [length good > 0][ifelse blockchain? = true [let i 0 while [i < length good] [let i_1 item i good let i_2 0 while [i_2 < length i_1][let i_3 item i_2 i_1 if item 2 i_3 = "unsafe" [ask turtle item 0 i_3 [set punishment? true]] set i_2 i_2 + 1] set i i + 1]][let i 0 while [i < length good] [let i_1 item i good let i_2 0 while [i_2 < length i_1][let i_3 item i_2 i_1 if item 2 i_3 = "unsafe"[set punishment? true] set i_2 i_2 + 1] set i i + 1]]]]
  ]
end

to calculate-profit ;对于出售商品的农户才计算
  set p1 a * Cu + (1 - a) * Cs + random-normal 0 1
  set p2 a * Cu + (1 - a) * Cs + random-normal 0 1
  set p3 (1 + eta) * p1

  ask farmers with [blockchain? = false and sell? = "no"] [
  (ifelse (item 2 good = "unsafe" and punishment? = false)
    [set profit s * (p1 - Cu)]
    (item 2 good = "unsafe" and punishment? = true)
    [set profit s * (p1 - Cu - B1)]
    (item 2 good = "safe")
    [set profit s * (p1 - Cs)])
  ]

  ask farmers with [blockchain? = true and sell? = "no"] [
  (ifelse (item 2 good = "unsafe" and punishment? = false)
    [set profit s * (p2 - Cu - C_t)]
    (item 2 good = "unsafe" and punishment? = true)
    [set profit s * (p2 - Cu - C_t - B1)]
    (item 2 good = "safe")
    [set profit s * (p2 - Cs - C_t)])
  ]

;middleman
  ask middlemans with [blockchain? = false and length good > 0][
  ifelse  (punishment? = false)
    [set profit (p3 - p1)]
    [set profit (p3 - p1 - B2)]
  ]
  ask middlemans with [blockchain? = true and length good > 0][
  set profit (theta - C_t)
  ]
;retailer

  ask retailers with [blockchain? = false and length good > 0][
    ifelse (punishment? = false)
      [set cost p3]
      [set cost (p3 + B3)]
  ]

  ask retailers with [blockchain? = true and length good > 0]
      [set cost (p2 + theta + C_t)]
end

to production-decision
  let pr 0
  if  (count (farmers-on neighbors) > 0 ) [set pr count (farmers-on neighbors) with [punishment? = true]/ count (farmers-on neighbors)]
  ifelse (blockchain? = false )[set ki  (1 - pr) * s * (p1 - Cu) + pr * s * (p1 - Cu - B1) - s * (p1 - Cs)]
  [set ki  (1 - pr) * s * (p2 - Cu - C_t) + pr * s * (p2 - Cu - C_t - B1) - s * (p2 - Cs - C_t)]
  set a random-float 1
  set p random-float 1
  ifelse((a * ki + (1 - a) * p) > honesty )[set type? "unsafe"][set type? "safe"]
end

to transformation
  ask farmers [
    let neighbor1 farmers in-radius 5
    if (count neighbor1 with [blockchain? = true] != 0 and count neighbor1 with [blockchain? = false] != 0)[
      ifelse (blockchain? = true) [set r_mean mean [profit] of neighbor1 with [blockchain? = false]]
        [set r_mean mean [profit] of neighbor1 with [blockchain? = true]]
      if ((a * (r_mean - profit) / (r_mean + 0.00001)) + (1 - a) * p > G ) [set blockchain? not blockchain?]
      update-threshold
    ]
  ]

  ask middlemans [
    if (count middlemans with [blockchain? = true] != 0 and count middlemans with [blockchain? = false] != 0)[
      ifelse (blockchain? = true) [set r_mean mean [profit] of middlemans with [blockchain? = false]]
        [set r_mean mean [profit] of middlemans with [blockchain? = true]]
      if ((a * (r_mean - profit) / (r_mean + 0.00001)) + (1 - a) * p > G ) [set blockchain? not blockchain?]
       update-threshold
    ]
  ]

  ask retailers [
    if (count retailers with [blockchain? = true] != 0 and count retailers with [blockchain? = false] != 0)[
    ifelse (blockchain? = true) [set c_mean mean [cost] of retailers with [blockchain? = false]]
      [set c_mean mean [cost] of retailers with [blockchain? = true]]
    if ((a * (cost - c_mean) / (c_mean + 0.00001)) + (1 - a) * p > G ) [set blockchain? not blockchain?]
       update-threshold
    ]
  ]
end

to update-honesty
  let minimal_honesty min [honesty] of farmers
  ask farmers [ifelse (punishment? = false) [set honesty (1 - f1) * honesty + f1 * minimal_honesty][set honesty (1 - f2) * honesty + f2]]
end

to update-threshold
if (breed = "farmers" or breed = "middlemans") [
  (ifelse (profit >= r_mean and punishment? = false )
  [set G (1 - v1p) * G + v1p]
 (profit < r_mean and punishment? = false )
  [set G (1 - v1n) * G]
  (profit >= r_mean and punishment? = true )
  [set G (1 - v2p) * G + v2p]
  [set G (1 - v2n) * G ])
]
if (breed = "retailers") [
  (ifelse (cost >= c_mean and punishment? = false )
  [set G (1 - v1p) * G + v1p]
  (cost < c_mean and punishment? = false )
  [set G (1 - v1n) * G]
  (cost >= c_mean and punishment? = true )
  [set G (1 - v2p) * G + v2p]
  [set G (1 - v2n) * G ])
]
end

to do-plot
  let f_b farmers with [blockchain? = true]
  let f_n farmers with [blockchain? = false]
  let f_b_s count f_b with [item 2 good = "safe" ]
  let f_b_u count f_b with [item 2 good = "unsafe" ]
  let f_n_s count f_n with [item 2 good = "safe" ]
  let f_n_u count f_n with [item 2 good = "unsafe" ]

  set-current-plot "output"
  set-current-plot-pen "safe"
  plotxy ticks (f_b_s + f_n_s) / n
  set-current-plot-pen "unsafe"
  plotxy ticks (f_b_u + f_n_u) / n
end

to setup-constants
set Cs 2.5
set Cu 1.75
set C_t 0.2
set eta 0.5
set a 0.65
set p random-float 1
set s 30
set n 100
set m 10
set k 10
set f1 0.3
set f2 0.5 ;f2>f1
set v1p 0.4
set v1n 0.6
set v2p 0.2
set v2n 0.8 ;v2n>v1n>v1p>v2p
set B1 random-float 1
set B2 random-float 1
set B3 random-float 1
end

to calculate-efficiency
set efficiency tv / tc * 0.5 + qr * 0.5
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
-1
-1
13.0
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
26
69
92
102
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
28
119
91
152
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

CHOOSER
28
166
166
211
mode
mode
"normal" "blockchain"
1

PLOT
9
247
209
397
output
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"safe" 1.0 0 -13210332 true "" ""
"unsafe" 1.0 0 -5298144 true "" ""

MONITOR
853
100
942
145
blockchain?
count farmers with [blockchain? = true] / count farmers
17
1
11

MONITOR
859
176
948
221
punishment?
count farmers with [punishment? = true] / count farmers
17
1
11

BUTTON
724
73
787
106
NIL
go
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
873
249
990
294
blockchain?1
count middlemans with [blockchain? = true] / count middlemans
17
1
11

MONITOR
904
324
1000
369
blockchain?2
count retailers with [blockchain? = true] / count retailers
17
1
11

MONITOR
1092
109
1202
154
no blockchain?
count farmers with [blockchain? = false] / count farmers
17
1
11

MONITOR
1111
191
1228
236
no blockchain?2
count middlemans with [blockchain? = false] / count middlemans
17
1
11

MONITOR
1098
324
1215
369
no blockchain?3
count retailers with [blockchain? = false] / count retailers
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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
NetLogo 6.1.1
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
