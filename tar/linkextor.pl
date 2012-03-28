#!/usr/bin/perl

use common::sense;

use LWP::UserAgent;
use HTML::LinkExtor;
use URI::URL;

my %idx_urls = (
# sorted indices: binutils, gmp, mpfr, gdb
	BINUTILS => "http://ftpmirror.gnu.org/binutils/?C=M;O=D",
	GMP      => "http://ftpmirror.gnu.org/gmp/?C=M;O=D",
	MPFR     => "http://ftpmirror.gnu.org/mpfr/?C=M;O=D",
	GDB      => "http://ftpmirror.gnu.org/gdb/?C=M;O=D",
# first link on page: mpc, qemu
	MPC      => "http://www.multiprecision.org/index.php?prog=mpc&page=download",
	QEMU     => "http://wiki.qemu.org/Download",
# ftp: newlib, insight
	NEWLIB   => "ftp://sources.redhat.com/pub/newlib/index.html",
	# if you want another mirror, see http://sourceware.org/mirrors.html
	# note: sorted by size; timestamps are all the same ...
	INSIGHT  => "http://mirrors.kernel.org/sources.redhat.com/insight/releases/?C=S;O=D"
);
my %sf_urls = (
# sourceforge direct links (needs filename extraction): openocd, lpc21isp
	OPENOCD  => "http://sourceforge.net/projects/openocd/files/latest/download",
	LPC21ISP => "http://sourceforge.net/projects/lpc21isp/files/latest/download",
);
my %subdirs_urls = (
# uses subdirs: gcc
# note: sorting by date doesn't guarantee that we get the highest version
	GCC      => "http://ftp.easynet.be/ftp/gnu/gcc/?C=M;O=D"
);

my $p = HTML::LinkExtor->new;
my $ua = LWP::UserAgent->new;

# parse a document and return the first link matching the regex
sub getlinks {
	my ($url, $regex) = @_;
	my $req = HTTP::Request->new(GET => $url);
	$req->header(Accept => "text/html");
	my $res = $ua->request($req);
	$p->parse($res->decoded_content);
	# filter out the valid results
	foreach my $arr($p->links) {
		if ($arr->[0] eq 'a' and $arr->[1] eq 'href' and  $arr->[2] =~ $regex) {
			return url($arr->[2], $res->base)->abs;
		}
	}
}

sub SF_getfilename {
	return $ua->head(shift)->previous->header("Content-Disposition") =~ m!"(.*)"!g;
}

my @all_pkgs = ();
sub make_output {
	my ($name, $file, $url) = @_;
	print "$name=$file\n";
	print "${name}_URL=$url\n";
	push(\@all_pkgs, $name);
}

my $tar_regex = qr{.*\.tar\.(gz|xz|bz2)$};

# index pages
while (my ($name, $url) = each(%idx_urls)) {
	my $link = getlinks($url, $tar_regex);
	make_output($name, ($link->path_components)[-1], $link);
}

# sourceforge pages
while (my ($name, $url) = each %sf_urls) {
	make_output($name, SF_getfilename($url), $url);
}

# subdirs: gcc
# if you want a specific version, change the gcc release number
while (my ($name, $url) = each %subdirs_urls) {
	my $dirlink = getlinks($url, qr{gcc-4.6.*/});
	my $link = getlinks($dirlink, qr{gcc-core.*\.tar\.(gz|xz|bz2)$});
	make_output($name, ($link->path_components)[-1], $link);
}

print "ALL_PKGS_NAMES=", join(" ", @all_pkgs), "\n";
