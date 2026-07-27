let test_new_patch_no_deps () =
  Sandbox.with_repo (fun () ->
      let upstream = Option.get (Sandbox.rev_parse "main") in
      let code, _, err = Sandbox.forkctl [ "patch"; "new"; "foo" ] in
      Alcotest.(check int) ("exit code: " ^ err) 0 code;
      Alcotest.(check (option string))
        "topic == upstream tip" (Some upstream)
        (Sandbox.rev_parse "refs/heads/t/foo");
      Alcotest.(check (option string))
        "base == upstream tip" (Some upstream)
        (Sandbox.rev_parse "refs/top-bases/foo");
      Alcotest.(check (option string))
        ".topdeps empty" (Some "")
        (Sandbox.show "t/foo:.topdeps");
      Alcotest.(check string)
        "HEAD checked out onto topic" "t/foo"
        (Sandbox.current_branch ()))

let test_new_patch_with_dep () =
  Sandbox.with_repo (fun () ->
      let upstream = Option.get (Sandbox.rev_parse "main") in
      ignore (Sandbox.forkctl [ "patch"; "new"; "foo" ]);
      let foo_tip = Option.get (Sandbox.rev_parse "refs/heads/t/foo") in
      let code, _, err =
        Sandbox.forkctl [ "patch"; "new"; "bar"; "--depends-on"; "foo" ]
      in
      Alcotest.(check int) ("exit code: " ^ err) 0 code;
      Alcotest.(check (option string))
        ".topdeps lists t/foo" (Some "t/foo")
        (Sandbox.show "t/bar:.topdeps");
      let base_bar = Option.get (Sandbox.rev_parse "refs/top-bases/bar") in
      let parents = Sandbox.parents_of base_bar in
      Alcotest.(check bool)
        "base(bar) merges upstream" true
        (List.mem upstream parents);
      Alcotest.(check bool)
        "base(bar) merges t/foo" true (List.mem foo_tip parents);
      Alcotest.(check bool)
        "t/bar descends from base(bar)" true
        (Sandbox.is_ancestor ~ancestor:base_bar ~descendant:"refs/heads/t/bar"))

let test_list_topo_order () =
  Sandbox.with_repo (fun () ->
      ignore (Sandbox.forkctl [ "patch"; "new"; "foo" ]);
      ignore (Sandbox.forkctl [ "patch"; "new"; "bar"; "--depends-on"; "foo" ]);
      ignore (Sandbox.forkctl [ "patch"; "new"; "baz"; "--depends-on"; "bar" ]);
      let code, out, err = Sandbox.forkctl [ "patch"; "list" ] in
      Alcotest.(check int) ("exit code: " ^ err) 0 code;
      let lines = String.split_on_char '\n' (String.trim out) in
      Alcotest.(check (list string)) "topo order" [ "foo"; "bar"; "baz" ] lines)

let () =
  Alcotest.run "forkctl-e2e"
    [
      ( "patch-stack",
        [
          ("new: no deps", `Quick, test_new_patch_no_deps);
          ("new: with dep", `Quick, test_new_patch_with_dep);
          ("list: topo order", `Quick, test_list_topo_order);
        ] );
    ]
