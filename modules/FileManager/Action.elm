module FileManager.Action exposing (..)

import Json.Decode as Decode
import Json.Decode exposing (Decoder)
import Http exposing (Body, Request, encodeUri, emptyBody, expectJson, header, request, stringBody)
import List exposing (head, map)
import FileManager.Model exposing (..)
import String exposing (join)

get : String -> String -> Decoder a -> Request a
get jwt url decoder =
  request
    { method = "GET"
    , headers = [header "Authorization" ("Bearer " ++ jwt)]
    , url = url
    , body = emptyBody
    , expect = expectJson decoder
    , timeout = Nothing
    , withCredentials = False
    }

post : String -> String -> Body -> Decoder a -> Request a
post jwt url body decoder =
  request
    { method = "GET"
    , headers = [header "Authorization" ("Bearer " ++ jwt)]
    , url = url
    , body = emptyBody
    , expect = expectJson decoder
    , timeout = Nothing
    , withCredentials = False
    }

getLs : String -> String -> String -> Cmd Msg
getLs fileApi jwt dir
   = Http.send (EnvMsg << LsGotten)
  <| get jwt (fileApi ++ "/ls?dir=" ++ dir)
  <| Decode.list fileDecoder

fileDecoder : Decode.Decoder File
fileDecoder = Decode.map2 (\x y -> { name = x, isDir = y })
  (Decode.field "name" Decode.string)
  (Decode.field "isDir" Decode.bool)

move : String -> String -> String -> List File -> String -> Cmd Msg
move fileApi jwt srcDir files dstDir
   = Http.send (EnvMsg << Refresh)
  <| post jwt (fileApi ++ "/move") (url <| "srcDir=" ++ encodeUri srcDir ++ "&files=" ++ encodeFiles files ++ "&dstDir=" ++ encodeUri dstDir)
  <| Decode.succeed ()

url : String -> Body
url string = stringBody "application/x-www-form-urlencoded" string

encodeFiles : List File -> String
encodeFiles files = join "," <| map (encodeUri << .name) files

delete : String -> String -> String -> List File -> Cmd Msg
delete fileApi jwt dir files
   =  Http.send (EnvMsg << Refresh)
  <|  post jwt (fileApi ++ "/delete") (url <| "dir=" ++ encodeUri dir ++ "&files=" ++ encodeFiles files)
  <|  Decode.succeed ()

newDir : String -> String -> String -> String -> Cmd Msg
newDir fileApi jwt dir newDir
   =  Http.send (EnvMsg << Refresh)
  <|  post jwt (fileApi ++ "/newDir") (url <| "dir=" ++ encodeUri dir ++ "&newDir=" ++ encodeUri newDir)
  <|  Decode.succeed ()

rename : String -> String -> String -> String -> String -> Cmd Msg
rename fileApi jwt dir oldName newName
   =  Http.send (EnvMsg << Refresh)
  <|  post jwt (fileApi ++ "/rename") (url <| "dir=" ++ encodeUri dir ++ "&oldName=" ++ encodeUri oldName ++ "&newName=" ++ encodeUri newName)
  <|  Decode.succeed ()
