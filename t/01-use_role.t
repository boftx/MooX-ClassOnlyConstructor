package MyTest;

use Moo;
use MooX::ClassOnlyConstructor;

has foo => (
    is => 'ro',
    default => 'bar',
);

package main;

use Test::More;
use Test::Exception;

use_ok( 'MyTest' );

my $obj = new_ok( 'MyTest' );

throws_ok( sub { $obj->new() }, qr/class method only/, '$obj can not call new' );

done_testing();

exit;

__END__
