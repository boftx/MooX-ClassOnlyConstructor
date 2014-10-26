use strict;
use warnings;

use Test::More;

my $non_Moo_pkg = q{
package MyTest;
use MooX::ClassOnlyConstructor;
1;
};

eval $non_Moo_pkg;
like( $@, qr/can only be used/, 'rejects non-Moo package' );

my $Moo_before_pkg = q{
package MyTest;
use Moo;
use MooX::ClassOnlyConstructor;
1;
};

eval $Moo_before_pkg;
is( $@, '', 'accepts Moo first being used' );

my $Moo_after_pkg = q{
package MyTest;
use MooX::ClassOnlyConstructor;
use Moo;
1;
};

eval $Moo_after_pkg;
is( $@, '', 'accepts Moo being used later' );

done_testing();

exit;

__END__
