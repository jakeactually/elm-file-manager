module FileManager exposing (..)

import Browser exposing (element)
import Model exposing (..)
import Update exposing (..)
import View exposing (..)
import Port exposing (..)

main : Program Flags Model Msg
main = element
  { init = init
  , view = view
  , update = update
  , subscriptions = subscriptions
  }

subscriptions : Model -> Sub Msg
subscriptions _ = Sub.batch
  [ onOpen (EnvMsg << Open)
  , onFilesAmount FilesAmount
  , onProgress Progress
  , onUploaded Uploaded
  ]
