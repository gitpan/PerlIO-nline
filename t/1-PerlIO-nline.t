# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl PerlIO-nline.t'

#########################

use Test::More tests => 4;

$/ = undef;

open my $W, ">:raw", "read" or die "can't create testfile: $!";
select((select($W), $|=1)[0]);
print $W "\cM\cJ\cJ\cM";

ok open(my $X, "<:nline", "read"), "open for read";
is <$X>, "\n\n\n",                 "read";

ok open(my $Y, ">:nline", "write"), "open for write";
print $Y "\n\cM\cJ\cJ\cM\cM";
print $Y "\cJa";
close $Y;

open my $Z, "<:raw", "write" or die "can't read testfile: $!";
is <$Z>, "\cM\cJ\cM\cJ\cM\cJ\cM\cJ\cM\cJa", "write";

unlink "read";
unlink "write";
