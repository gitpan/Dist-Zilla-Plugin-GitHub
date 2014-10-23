package Dist::Zilla::Plugin::GitHub;
BEGIN {
  $Dist::Zilla::Plugin::GitHub::VERSION = '0.04';
}

use Moose;

use warnings;
use strict;

has 'repo' => (
	is      => 'ro',
	isa     => 'Maybe[Str]'
);

=head1 NAME

Dist::Zilla::Plugin::GitHub - Set of plugins for working with GitHub

=head1 VERSION

version 0.04

=head1 DESCRIPTION

The following is a list of Plugin in this distribution to help you
integrate GitHub and Dist::Zilla:

=over 4

=item * L<Dist::Zilla::Plugin::GitHub::Create> Create GitHub repo on dzil new

=item * L<Dist::Zilla::Plugin::GitHub::Update> Update GitHub repo info on release

=item * L<Dist::Zilla::Plugin::GitHub::Meta> Add GitHub repo info to META.{yml,json}

=back

Both GitHub::Create and GitHub::Update used to be standalone modules
(named respectively L<Dist::Zilla::Plugin::GithubCreate> and
L<Dist::Zilla::Plugin::GithubUpdate>) that are now deprecated.

=head1 AUTHOR

Alessandro Ghedini <alexbio@cpan.org>

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Alessandro Ghedini.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1; # End of Dist::Zilla::Plugin::GitHub