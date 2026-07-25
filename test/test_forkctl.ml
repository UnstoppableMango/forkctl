let test_version () = Alcotest.(check string) "version" "0.0.1" Forkctl.version

let unit_tests = [ ("version", `Quick, test_version) ]

let qcheck_tests =
  [ QCheck.Test.make ~name:"string length non-negative" QCheck.string
      (fun s -> String.length s >= 0)
  ]

let () =
  Alcotest.run "forkctl"
    [ ("unit", unit_tests);
      ("qcheck", List.map QCheck_alcotest.to_alcotest qcheck_tests)
    ]
