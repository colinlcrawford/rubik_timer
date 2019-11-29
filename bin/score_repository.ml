open Core
open Async

type t = { file_name : string }

let create ?(file_name = "rubiks_scores.txt") () = { file_name }

let save_score repo score =
  let serialized_score = Score.to_string score in
  let write_scores writer =
    return (Writer.write_line writer serialized_score)
  in
  let%map () = Writer.with_file ~append:true repo.file_name ~f:write_scores in
  score

let get_scores repo =
  let%bind file_exists = Async.Sys.file_exists repo.file_name in
  match file_exists with
  | `Yes ->
      let%map file_content = Reader.file_contents repo.file_name in
      let serialized_scores = String.split ~on:'\n' file_content in
      List.map ~f:Score.of_string serialized_scores
  | _ -> return []
