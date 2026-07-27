let read_all ic =
  let buf = Buffer.create 256 in
  (try
     while true do
       Buffer.add_channel buf ic 1
     done
   with End_of_file -> ());
  Buffer.contents buf

let run prog args =
  let argv = Array.of_list (prog :: args) in
  let stdout, stdin, stderr =
    Unix.open_process_args_full prog argv (Unix.environment ())
  in
  close_out stdin;
  let out = read_all stdout in
  let err = read_all stderr in
  let status = Unix.close_process_full (stdout, stdin, stderr) in
  let code = match status with Unix.WEXITED c -> c | _ -> -1 in
  (code, out, err)

let git args = run "git" args
let forkctl_exe = Filename.concat (Sys.getcwd ()) "../../bin/main.exe"
let forkctl args = run forkctl_exe args

let mktempdir () =
  let base = Filename.temp_file "forkctl_e2e_" "" in
  Sys.remove base;
  Unix.mkdir base 0o700;
  base

let with_repo (f : unit -> unit) =
  let dir = mktempdir () in
  let prev = Sys.getcwd () in
  Sys.chdir dir;
  Fun.protect
    ~finally:(fun () ->
      Sys.chdir prev;
      ignore (run "rm" [ "-rf"; dir ]))
    (fun () ->
      ignore (git [ "init"; "-q"; "-b"; "main" ]);
      ignore (git [ "config"; "user.email"; "test@example.com" ]);
      ignore (git [ "config"; "user.name"; "Test" ]);
      ignore (git [ "commit"; "--allow-empty"; "-q"; "-m"; "upstream initial" ]);
      f ())

let rev_parse ref_ =
  let code, out, _ = git [ "rev-parse"; ref_ ] in
  if code <> 0 then None else Some (String.trim out)

let show ref_path =
  let code, out, _ = git [ "show"; ref_path ] in
  if code <> 0 then None else Some out

let parents_of commit =
  let _, out, _ = git [ "log"; "-1"; "--pretty=%P"; commit ] in
  String.split_on_char ' ' (String.trim out) |> List.filter (( <> ) "")

let is_ancestor ~ancestor ~descendant =
  let code, _, _ =
    git [ "merge-base"; "--is-ancestor"; ancestor; descendant ]
  in
  code = 0

let current_branch () =
  let _, out, _ = git [ "symbolic-ref"; "--short"; "HEAD" ] in
  String.trim out
