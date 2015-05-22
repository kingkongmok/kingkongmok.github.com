  #!/usr/bin/perl

  use Term::ProgressBar 2.00;

  use constant MAX => 100_000;

  my $progress = Term::ProgressBar->new(MAX);

  for (0..MAX) {
      $progress->update($_);
  }
