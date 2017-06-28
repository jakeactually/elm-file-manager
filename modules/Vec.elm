module Vec exposing (..)

type Vec2 = Vec2 Int Int

type alias Bound =
  { x : Int
  , y : Int
  , w : Int
  , h : Int
  }

newBound : Bound
newBound = { x = 0, y = 0, w = 0, h = 0 }

toBound : Vec2 -> Vec2 -> Bound
toBound v1 v2 =
  let
    (Vec2 x1 y1) = v1
    (Vec2 x2 y2) = v2
    (x, y) = (min x1 x2, min y1 y2)
    (w, h) = (max x1 x2 - x, max y1 y2 - y)
  in
    { x = x, y = y, w = w, h = h }

isFar : Vec2 -> Vec2 -> Bool
isFar (Vec2 x1 y1) (Vec2 x2 y2) = abs (x1 - x2) > 3 || abs (y1 - y2) > 3 

touchesBound : Bound -> Bound -> Bool
touchesBound b1 b2 = not
  <| b1.x > b2.x + b2.w
  || b1.y > b2.y + b2.h
  || b1.x + b1.w < b2.x
  || b1.y + b1.h < b2.y
