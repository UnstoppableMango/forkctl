(** Thin wrapper around the [git] CLI *)

exception Error = Tool.Error

let run args = Tool.run "git" args
let run_opt args = Tool.run_opt "git" args

(** Name of the branch checked out in the current repo, e.g. "main". *)
let current_branch () = run [ "rev-parse"; "--abbrev-ref"; "HEAD" ]

(** Value of a git config key, or [None] if unset. *)
let config_get key = run_opt [ "config"; "--get"; key ]

(** Fetch URL of [remote], or [None] if no such remote is configured. *)
let remote_url remote = run_opt [ "remote"; "get-url"; remote ]

(** [remote]'s default branch, e.g. "upstream/main", resolved from the local
    [refs/remotes/<remote>/HEAD] symref. [None] if that symref isn't set (needs
    [git remote set-head <remote> -a] or a fresh clone). *)
let default_branch remote =
  run_opt
    [ "symbolic-ref"; "--short"; Printf.sprintf "refs/remotes/%s/HEAD" remote ]

(** [ahead_behind ~ours ~theirs] returns [(ahead, behind)]: commits on [ours]
    not on [theirs], and commits on [theirs] not on [ours]. *)
let ahead_behind ~ours ~theirs =
  let out =
    run [ "rev-list"; "--left-right"; "--count"; ours ^ "..." ^ theirs ]
  in
  match String.split_on_char '\t' out with
  | [ ahead; behind ] -> (int_of_string ahead, int_of_string behind)
  | _ -> raise (Error (Printf.sprintf "unexpected rev-list output: %S" out))
