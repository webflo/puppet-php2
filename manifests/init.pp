class php2 {
  require php2::homebrew
  require php2::phpenv
  require php2::setup
  require php2::composer
  require php2::xdebug

  Php2::Version <| |> -> Php2::Extension <| |>
}
