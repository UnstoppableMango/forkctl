open Cmdliner

let status_cmd =
  let doc =
    "Show the current repo's status relative to its upstream fork remote."
  in
  Cmd.v (Cmd.info "status" ~doc) Term.(const Forkctl.Status.run $ const ())

let version_cmd =
  let doc = "Print the forkctl version." in
  let run () =
    print_endline Forkctl.Version.version;
    0
  in
  Cmd.v (Cmd.info "version" ~doc) Term.(const run $ const ())

let main_cmd =
  let doc = "Tooling to maintain a fleet of forked git repos" in
  let info = Cmd.info "forkctl" ~version:Forkctl.Version.version ~doc in
  Cmd.group info [ status_cmd; version_cmd ]

let () = exit (Cmd.eval' main_cmd)
