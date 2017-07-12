module FileManager.Action exposing (..)

import Json.Decode as Decode
import Http exposing (Body, encodeUri, stringBody)
import List exposing (head, map)
import FileManager.Model exposing (..)
import String exposing (join)

getLs : String -> String -> Cmd Msg
getLs fileApi dir
   = Http.send (EnvMsg << LsGotten)
  <| Http.get (fileApi ++ "/ls?dir=" ++ dir)
  <| Decode.list fileDecoder

fileDecoder : Decode.Decoder File
fileDecoder = Decode.map2 (\x y -> { name = x, isDir = y })
  (Decode.field "name" Decode.string)
  (Decode.field "isDir" Decode.bool)

move : String -> String -> String -> List File -> String -> Cmd Msg
move fileApi csrf srcDir files dstDir
   = Http.send (EnvMsg << Refresh)
  <| Http.post (fileApi ++ "/move") (url <| "srcDir=" ++ encodeUri srcDir ++ "&files=" ++ encodeFiles files ++ "&dstDir=" ++ encodeUri dstDir ++ "&csrfToken=" ++ csrf)
  <| Decode.succeed ()

url : String -> Body
url string = stringBody "application/x-www-form-urlencoded" string

encodeFiles : List File -> String
encodeFiles files = join "," <| map (encodeUri << .name) files

delete : String -> String -> String -> List File -> Cmd Msg
delete fileApi csrf dir files
   =  Http.send (EnvMsg << Refresh)
  <|  Http.post  (fileApi ++ "/delete") (url <| "dir=" ++ encodeUri dir ++ "&files=" ++ encodeFiles files ++ "&csrfToken=" ++ csrf)
  <|  Decode.succeed ()

newDir : String -> String -> String -> String -> Cmd Msg
newDir fileApi csrf dir newDir
   =  Http.send (EnvMsg << Refresh)
  <|  Http.post (fileApi ++ "/newDir") (url <| "dir=" ++ encodeUri dir ++ "&newDir=" ++ encodeUri newDir ++ "&csrfToken=" ++ csrf)
  <|  Decode.succeed ()

rename : String -> String -> String -> String -> String -> Cmd Msg
rename fileApi csrf dir oldName newName
   =  Http.send (EnvMsg << Refresh)
  <|  Http.post (fileApi ++ "/rename") (url <| "dir=" ++ encodeUri dir ++ "&oldName=" ++ encodeUri oldName ++ "&newName=" ++ encodeUri newName ++ "&csrfToken=" ++ csrf)
  <|  Decode.succeed ()
