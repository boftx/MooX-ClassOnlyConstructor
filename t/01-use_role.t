package MyTest;

use Moo;
use MooX::ClassOnlyConstructor;

has foo => (
    is      => 'ro',
    default => 'bar',
);

package main;

use Test::More;
use Test::Exception;

use_ok('MyTest');

my $test_obj = new_ok( MyTest => [], '$test_obj');

throws_ok( sub { $test_obj->new() }, qr/class method only/,
    '$test_obj can not call new' );

done_testing();

exit;

__END__
