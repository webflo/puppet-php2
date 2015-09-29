class php2 {
  require php2::homebrew
  require php2::phpenv
  require php2::setup

  Php2::Version <| |> -> Php2::Extension <| |>
}
