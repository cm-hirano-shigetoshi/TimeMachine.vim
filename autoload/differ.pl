my $pre_hash = "--";
my $pre_comment = "(saved)";
while (<>) {
    s/[\r\n]//g;
    if (/^\s*(\w+)\s+(.*)$/) {
        print "$1 $pre_hash $pre_comment\n";
        $pre_hash = $1;
        $pre_comment = $2;
    }
}
