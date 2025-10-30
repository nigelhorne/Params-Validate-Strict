#!/usr/bin/env perl

# Test positional arguments

use strict;
use warnings;

use Test::Most;
use Params::Validate::Strict qw(validate_strict);

my $schema = {
	username => { type => 'string', optional => 1, 'default' => 'xyzzy', position => 0 }
};

my $result = validate_strict({ schema => $schema, args => [ 'foo' ] });

is_deeply($result, [ 'foo' ], 'positional arg works');

$result = validate_strict({ schema => $schema, args => [ ] });

is_deeply($result, [ 'xyzzy' ], 'positional default arg works');

done_testing();
