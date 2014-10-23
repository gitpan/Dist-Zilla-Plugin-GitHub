package Dist::Zilla::Plugin::GitHub::Update;
{
  $Dist::Zilla::Plugin::GitHub::Update::VERSION = '0.28';
}

use strict;
use warnings;

use JSON;
use Moose;

extends 'Dist::Zilla::Plugin::GitHub';

with 'Dist::Zilla::Role::Releaser';

has 'cpan' => (
	is	=> 'ro',
	isa	=> 'Bool',
	default	=> 1
);

has 'p3rl' => (
	is	=> 'ro',
	isa	=> 'Bool',
	default	=> 0
);

has 'metacpan' => (
	is	=> 'ro',
	isa	=> 'Bool',
	default	=> 0
);

has 'meta_home' => (
	is	=> 'ro',
	isa	=> 'Bool',
	default	=> 0
);

=head1 NAME

Dist::Zilla::Plugin::GitHub::Update - Update GitHub repo info on release

=head1 VERSION

version 0.28

=head1 SYNOPSIS

Configure git with your GitHub credentials:

    $ git config --global github.user LoginName
    $ git config --global github.password GitHubPassword

Alternatively you can install L<Config::Identity> and write your credentials
in the (optionally GPG-encrypted) C<~/.github> file as follows:

    login LoginName
    password GitHubpassword

(if only the login name is set, the password will be asked interactively)

then, in your F<dist.ini>:

    # default config
    [GitHub::Meta]

    # to override the repo name
    [GitHub::Meta]
    repo = SomeRepo

See L</ATTRIBUTES> for more options.

=head1 DESCRIPTION

This Dist::Zilla plugin updates the information of the GitHub repository
when C<dzil release> is run.

=cut

sub release {
	my $self	= shift;
	my ($opts)	= @_;
	my $dist_name	= $self -> zilla -> name;

	my ($login, $pass)  = $self -> _get_credentials(0);
	return if (!$login);

	my $repo_name = $self -> _get_repo_name($login);

	my $http = HTTP::Tiny -> new;

	$self -> log("Updating GitHub repository info");

	my ($params, $headers, $content);

	$repo_name =~ /\/(.*)$/;
	my $repo_name_only = $1;

	$params -> {'name'} = $repo_name_only;
	$params -> {'description'} = $self -> zilla -> abstract;

	my $meta_home = $self -> zilla -> distmeta
		-> {'resources'} -> {'homepage'};

	if ($meta_home && $self -> meta_home) {
		$self -> log("Using distmeta URL");
		$params -> {'homepage'} = $meta_home;
	} elsif ($self -> metacpan == 1) {
		$self -> log("Using MetaCPAN URL");
		$params -> {'homepage'} =
			"http://metacpan.org/release/$dist_name/"
	} elsif ($self -> p3rl == 1) {
		my $guess_name = $dist_name;
		$guess_name =~ s/\-/\:\:/g;

		$self -> log("Using P3rl URL");
		$params -> {'homepage'} = "http://p3rl.org/$guess_name"
	} elsif ($self -> cpan == 1) {
		$self -> log("Using CPAN URL");
		$params -> {'homepage'} =
			"http://search.cpan.org/dist/$dist_name/"
	}

	my $url = $self -> api."/repos/$repo_name";

	if ($pass) {
		require MIME::Base64;

		my $basic = MIME::Base64::encode_base64("$login:$pass", '');
		$headers -> {'Authorization'} = "Basic $basic";
	}

	$content = to_json $params;

	my $response	= $http -> request('PATCH', $url, {
		content => $content,
		headers => $headers
	});

	my $repo = $self -> _check_response($response);
	return if not $repo;
}

=head1 ATTRIBUTES

=over

=item C<repo>

The name of the GitHub repository. By default the dist name (from dist.ini)
is used.

=item C<cpan>

The GitHub homepage field will be set to the CPAN page of the module if this
option is set to true (default),

=item C<p3rl>

The GitHub homepage field will be set to the p3rl.org shortened URL (e.g.
C<http://p3rl.org/My::Module>) if this option is set to true (default is false).

This takes precedence over the C<cpan> option (if both are true, p3rl will
be used).

=item C<metacpan>

The GitHub homepage field will be set to the metacpan.org distribution URL (e.g.
C<http://metacpan.org/release/My-Module>) if this option is set to true (default
is false).

This takes precedence over the C<cpan> and C<p3rl> options (if all three are
true, metacpan will be used).

=item C<meta_home>

The GitHub homepage field will be set to the value present in the dist meta
(e.g. the one set by other plugins) if this option is set to true (default is
false). If no value is present in the dist meta, this option is ignored.

This takes precedence over the C<metacpan>, C<cpan> and C<p3rl> options (if all
four are true, meta_home will be used).

=back

=head1 AUTHOR

Alessandro Ghedini <alexbio@cpan.org>

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Alessandro Ghedini.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

no Moose;

__PACKAGE__ -> meta -> make_immutable;

1; # End of Dist::Zilla::Plugin::GitHub::Update
