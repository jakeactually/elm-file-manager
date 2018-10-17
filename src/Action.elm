module Action exposing (..)

import Json.Decode as Decode
import Json.Decode exposing (Decoder)
import Http exposing (Body, Request, emptyBody, expectJson, header, request, stringBody)
import List exposing (head, map)
import Model exposing (..)
import String exposing (dropLeft, join)
import Url.Builder exposing (string, toQuery, QueryParameter)

get : String -> String -> Decoder a -> Request a
get jwtToken url decoder =
  request
    { method = "GET"
    , headers = [header "Authorization" ("Bearer " ++ jwtToken)]
    , url = url
    , body = emptyBody
    , expect = expectJson decoder
    , timeout = Nothing
    , withCredentials = False
    }

post : String -> String -> Body -> Decoder a -> Request a
post jwtToken url body decoder =
  request
    { method = "POST"
    , headers = [header "Authorization" ("Bearer " ++ jwtToken)]
    , url = url
    , body = body
    , expect = expectJson decoder
    , timeout = Nothing
    , withCredentials = False
    }

getLs : String -> String -> String -> Cmd Msg
getLs api jwtToken dir
   = Http.send (EnvMsg << LsGotten)
  <| get jwtToken (api ++ "/ls?dir=" ++ dir)
  <| Decode.list fileDecoder

fileDecoder : Decode.Decoder File
fileDecoder = Decode.map2 (\x y -> { name = x, isDir = y })
  (Decode.field "name" Decode.string)
  (Decode.field "isDir" Decode.bool)

move : String -> String -> String -> List File -> String -> Cmd Msg
move api jwtToken srcDir files dstDir
   = Http.send (EnvMsg << Refresh)
  <| post jwtToken (api ++ "/move") (urlBody <| [string "srcDir" srcDir, string "dstDir" dstDir] ++ encodeFiles files)
  <| Decode.succeed ()

urlBody : List QueryParameter -> Body
urlBody = stringBody "application/x-www-form-urlencoded" << dropLeft 1 << toQuery

encodeFiles : List File -> List QueryParameter
encodeFiles = map (string "files" << .name)

delete : String -> String -> String -> List File -> Cmd Msg
delete api jwtToken dir files
   =  Http.send (EnvMsg << Refresh)
  <|  post jwtToken (api ++ "/delete") (urlBody <| string "dir" dir :: encodeFiles files)
  <|  Decode.succeed ()

newDir : String -> String -> String -> String -> Cmd Msg
newDir api jwtToken dir name
   =  Http.send (EnvMsg << Refresh)
  <|  post jwtToken (api ++ "/newDir") (urlBody [string "dir" dir, string "name" name])
  <|  Decode.succeed ()

rename : String -> String -> String -> String -> String -> Cmd Msg
rename api jwtToken dir oldName newName
   =  Http.send (EnvMsg << Refresh)
  <|  post jwtToken (api ++ "/rename") (urlBody [string "dir" dir, string "oldName" oldName, string "newName" newName])
  <|  Decode.succeed ()
