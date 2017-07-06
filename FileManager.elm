module FileManager exposing (..)

import Html
import FileManager.Model exposing (..)
import FileManager.Update exposing (..)
import FileManager.View exposing (..)
import FileManager.Port exposing (..)

main : Program Flags Model Msg
main = Html.programWithFlags
  { init = init
  , view = view
  , update = update
  , subscriptions = subscriptions
  }

subscriptions : Model -> Sub Msg
subscriptions _ = Sub.batch
  [ open (EnvMsg << Open)
  , boundsGotten (EnvMsg << BoundsGotten)
  , filesAmount FilesAmount
  , progress Progress
  , uploaded Uploaded
  ]
