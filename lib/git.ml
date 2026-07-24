(** Thin wrapper around the [git] CLI. Shells out via [Unix.create_process]
    with an argv array (no [/bin/sh]/[cmd.exe]), so arguments are never
    subject to shell quoting or injection. *)

exception Error of string

let devnull () =
  Unix.openfile (if Sys.win32 then "NUL" else "/dev/null") [ Unix.O_WRONLY ] 0

let run ?(suppress_stderr = false) args =
  let argv = Array.of_list ("git" :: args) in
  let stdout_r, stdout_w = Unix.pipe ~cloexec:false () in
  let stderr_fd = if suppress_stderr then devnull () else Unix.stderr in
  let pid = Unix.create_process "git" argv Unix.stdin stdout_w stderr_fd in
  Unix.close stdout_w;
  if suppress_stderr then Unix.close stderr_fd;
  let ic = Unix.in_channel_of_descr stdout_r in
  let output = In_channel.input_all ic in
  close_in ic;
  let _, status = Unix.waitpid [] pid in
  match status with
  | Unix.WEXITED 0 -> String.trim output
  | Unix.WEXITED code ->
    raise (Error (Printf.sprintf "git %s exited %d" (String.concat " " args) code))
  | Unix.WSIGNALED _ | Unix.WSTOPPED _ ->
    raise (Error (Printf.sprintf "git %s was killed" (String.concat " " args)))

let run_opt args = try Some (run ~suppress_stderr:true args) with Error _ -> None

(** Name of the branch checked out in the current repo, e.g. "main". *)
let current_branch () = run [ "rev-parse"; "--abbrev-ref"; "HEAD" ]

(** Value of a git config key, or [None] if unset. *)
let config_get key = run_opt [ "config"; "--get"; key ]

(** Fetch URL of [remote], or [None] if no such remote is configured. *)
let remote_url remote = run_opt [ "remote"; "get-url"; remote ]

(** [remote]'s default branch, e.g. "upstream/main", resolved from the local
    [refs/remotes/<remote>/HEAD] symref. [None] if that symref isn't set
    (needs [git remote set-head <remote> -a] or a fresh clone). *)
let default_branch remote =
  run_opt [ "symbolic-ref"; "--short"; Printf.sprintf "refs/remotes/%s/HEAD" remote ]

(** [ahead_behind ~ours ~theirs] returns [(ahead, behind)]: commits on
    [ours] not on [theirs], and commits on [theirs] not on [ours]. *)
let ahead_behind ~ours ~theirs =
  let out = run [ "rev-list"; "--left-right"; "--count"; ours ^ "..." ^ theirs ] in
  match String.split_on_char '\t' out with
  | [ ahead; behind ] -> (int_of_string ahead, int_of_string behind)
  | _ -> raise (Error (Printf.sprintf "unexpected rev-list output: %S" out))
