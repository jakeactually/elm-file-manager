module Action exposing (..)

import File exposing (File)
import Json.Decode as Decode
import Json.Decode exposing (Decoder)
import Http exposing (Body, emptyBody, expectJson, header, request, stringBody)
import List exposing (map)
import Model exposing (..)
import String exposing (dropLeft)
import Url.Builder exposing (string, toQuery, QueryParameter)

get : String -> String -> Decoder a -> (Result Http.Error a -> msg) -> Cmd msg
get jwtToken url decoder handler =
  request
    { method = "GET"
    , headers = [header "Authorization" ("Bearer " ++ jwtToken)]
    , url = url
    , body = emptyBody
    , expect = expectJson handler decoder
    , timeout = Nothing
    , tracker = Nothing
    }

post : String -> String -> Body -> Decoder a -> (Result Http.Error a -> msg) -> Cmd msg
post jwtToken url body decoder handler =
  request
    { method = "POST"
    , headers = [header "Authorization" ("Bearer " ++ jwtToken)]
    , url = url
    , body = body
    , expect = expectJson handler decoder
    , timeout = Nothing
    , tracker = Nothing
    }

upload : String -> String -> String -> File -> Cmd Msg
upload api jwtToken dir file =
  request
    { method = "POST"
    , headers = [header "Authorization" ("Bearer " ++ jwtToken)]
    , url = api ++ "/upload"
    , body = Http.multipartBody [ Http.stringPart "dir" dir, Http.filePart "file" file ]
    , expect = Http.expectWhatever Uploaded
    , timeout = Nothing
    , tracker = Just "upload"
    }

getLs : String -> String -> String -> Cmd Msg
getLs api jwtToken dir = get
  jwtToken
  (api ++ "/ls?dir=" ++ dir)
  (Decode.list fileDecoder)
  (EnvMsg << LsGotten)

fileDecoder : Decode.Decoder FileMeta
fileDecoder = Decode.map2 (\x y -> { name = x, isDir = y })
  (Decode.field "name" Decode.string)
  (Decode.field "isDir" Decode.bool)

move : String -> String -> String -> List FileMeta -> String -> Cmd Msg
move api jwtToken srcDir files dstDir = post
  jwtToken
  (api ++ "/move")
  (urlBody <| [string "srcDir" srcDir, string "dstDir" dstDir] ++ encodeFiles files)
  (Decode.succeed ())
  (EnvMsg << Refresh)

urlBody : List QueryParameter -> Body
urlBody = stringBody "application/x-www-form-urlencoded" << dropLeft 1 << toQuery

encodeFiles : List FileMeta -> List QueryParameter
encodeFiles = map (string "files" << .name)

delete : String -> String -> String -> List FileMeta -> Cmd Msg
delete api jwtToken dir files = post
  jwtToken
  (api ++ "/delete")
  (urlBody <| string "dir" dir :: encodeFiles files)
  (Decode.succeed ())
  (EnvMsg << Refresh)

newDir : String -> String -> String -> String -> Cmd Msg
newDir api jwtToken dir name = post
  jwtToken
  (api ++ "/newDir")
  (urlBody [string "dir" dir, string "name" name])
  (Decode.succeed ())
  (EnvMsg << Refresh)

rename : String -> String -> String -> String -> String -> Cmd Msg
rename api jwtToken dir oldName newName = post
  jwtToken
  (api ++ "/rename")
  (urlBody [string "dir" dir, string "oldName" oldName, string "newName" newName])
  (Decode.succeed ())
  (EnvMsg << Refresh)
