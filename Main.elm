import Html
import Main.Model exposing (..)
import Main.Update exposing (..)
import Main.View exposing (..)
import Port exposing (..)

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
