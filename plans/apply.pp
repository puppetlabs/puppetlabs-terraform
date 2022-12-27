plan terraform::apply(
  Optional[String[1]]                            $dir           = undef,
  Optional[String[1]]                            $state         = undef,
  Optional[String[1]]                            $state_out     = undef,
  Optional[Variant[String[1], Array[String[1]]]] $target        = undef,
  Optional[Hash]                                 $var           = undef,
  Optional[Variant[String[1], Array[String[1]]]] $var_file      = undef,
  Optional[Boolean]                              $return_output = false,
  Optional[Boolean]                              $refresh_state = false
) {

  $apply_opts = {
    'dir'       => $dir,
    'state'     => $state,
    'state_out' => $state_out,
    'target'    => $target,
    'var'       => $var,
    'var_file'  => $var_file
  }

  $apply_logs = run_task('terraform::apply', 'localhost', $apply_opts)

  unless $return_output {
    return $apply_logs
  }

  $post_apply_opts = {
    'dir'   => $dir,
    'state' => $state
  }

  if $refresh_state {
    if $var_file {
      $refresh_opts = $post_apply_opts + { 'var_file' => $var_file }
    } else {
      $refresh_opts = $post_apply_opts
    }
    run_task('terraform::refresh', 'localhost', $refresh_opts)
  }

  $output = run_task('terraform::output', 'localhost', $post_apply_opts)
  return $output[0].value
}
