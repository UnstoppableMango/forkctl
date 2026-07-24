(** [forkctl status]: report the current repo's position relative to its
    fork's upstream remote. *)

let default_remote = "upstream"

let run () =
  let remote = Option.value (Git.config_get "forkctl.upstream-remote") ~default:default_remote in
  match Git.remote_url remote with
  | None ->
    Printf.eprintf
      "no '%s' remote configured (set forkctl.upstream-remote if it's named differently)\n"
      remote;
    1
  | Some _ -> (
    match Git.default_branch remote with
    | None ->
      Printf.eprintf "can't resolve %s's default branch; run: git remote set-head %s -a\n" remote
        remote;
      1
    | Some upstream_branch ->
      let branch = Git.current_branch () in
      let ahead, behind = Git.ahead_behind ~ours:"HEAD" ~theirs:upstream_branch in
      Printf.printf "%s...%s: %d ahead, %d behind\n" branch upstream_branch ahead behind;
      0)
