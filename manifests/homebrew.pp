class php2::homebrew {
  ensure_resource('homebrew::tap', 'homebrew/php', { 'ensure' => 'present' })
}
