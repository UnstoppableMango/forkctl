(** Thin wrapper around running external CLI tools as subprocesses *)

exception Error of string

let devnull () =
  Unix.openfile (if Sys.win32 then "NUL" else "/dev/null") [ Unix.O_WRONLY ] 0

let run ?(suppress_stderr = false) name args =
  let argv = Array.of_list (name :: args) in
  let stdout_r, stdout_w = Unix.pipe ~cloexec:false () in
  let stderr_fd = if suppress_stderr then devnull () else Unix.stderr in
  let pid = Unix.create_process name argv Unix.stdin stdout_w stderr_fd in
  Unix.close stdout_w;
  if suppress_stderr then Unix.close stderr_fd;
  let ic = Unix.in_channel_of_descr stdout_r in
  let output = In_channel.input_all ic in
  close_in ic;
  let _, status = Unix.waitpid [] pid in
  match status with
  | Unix.WEXITED 0 -> String.trim output
  | Unix.WEXITED code ->
      raise
        (Error (Printf.sprintf "%s %s exited %d" name (String.concat " " args) code))
  | Unix.WSIGNALED _ | Unix.WSTOPPED _ ->
      raise
        (Error (Printf.sprintf "%s %s was killed" name (String.concat " " args)))

let run_opt name args =
  try Some (run ~suppress_stderr:true name args) with Error _ -> None
