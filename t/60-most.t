use Test::Most;
use Params::Validate::Strict qw(validate_strict);
use Scalar::Util 'blessed';

# Mock logger for testing
{
	package Test::Logger;
	sub new { bless { messages => [] }, shift }
	sub error { push @{$_[0]->{messages}}, ['error', @_[1..$#_]] }
	sub warn { push @{$_[0]->{messages}}, ['warn', @_[1..$#_]] }
	sub debug { push @{$_[0]->{messages}}, ['debug', @_[1..$#_]] }
	sub get_messages { @{shift->{messages}} }
	sub clear { $_[0]->{messages} = [] }
}

subtest 'Basic validation failures' => sub {
	dies_ok {
		validate_strict(schema => 'not_a_hashref', input => {});
	} 'dies with non-hashref schema';
	
	dies_ok {
		validate_strict(schema => {}, args => 'not_a_hashref');
	} 'dies with non-hashref args';
	
	dies_ok {
		validate_strict(schema => {}, input => { unknown => 1 }, unknown_parameter_handler => 'invalid');
	} 'dies with invalid unknown_parameter_handler';
};

subtest 'Transform functionality' => sub {
	my $schema = {
		name => {
			type => 'string',
			transform => sub { uc $_[0] }
		}
	};
	
	my $result = validate_strict(
		schema => $schema,
		input => { name => 'john' }
	);
	
	is $result->{name}, 'JOHN', 'transform works correctly';
	
	dies_ok {
		validate_strict(
			schema => { test => { type => 'string', transform => 'not_code' } },
			input => { test => 'value' }
		);
	} 'dies with non-code transform';
};

subtest 'Optional parameters with code references' => sub {
	my $schema = {
		optional_field => {
			type => 'string',
			optional => sub { 
				my ($value, $all_params) = @_;
				return $all_params->{make_optional} ? 1 : 0;
			}
		},
		make_optional => { type => 'boolean' }
	};
	
	my $result = validate_strict(
		schema => $schema,
		input => { make_optional => 1 }
	);
	
	ok exists $result->{make_optional}, 'conditional optional works when true';
	ok !exists $result->{optional_field}, 'field is optional when condition met';
	
	dies_ok {
		validate_strict(
			schema => $schema,
			input => { make_optional => 0 }
		);
	} 'field is required when condition not met';
};

subtest 'Dynamic rule values with code references' => sub {
	my $schema = {
		age => {
			type => 'integer',
			min => sub {
				my ($value, $all_params) = @_;
				return $all_params->{country} eq 'US' ? 21 : 18;
			}
		},
		country => { type => 'string' }
	};
	
	my $result = validate_strict(
		schema => $schema,
		input => { age => 25, country => 'US' }
	);
	
	is $result->{age}, 25, 'dynamic min validation passes';
	
	dies_ok {
		validate_strict(
			schema => $schema,
			input => { age => 18, country => 'US' }
		);
	} 'dynamic min validation fails when condition not met';
};

subtest 'Boolean validation edge cases' => sub {
	my $schema = { flag => { type => 'boolean' } };
	
	# Test various boolean representations
	my $result = validate_strict(
		schema => $schema,
		input => { flag => 1 }
	);
	is $result->{flag}, 1, 'boolean 1 validated';
	
	$result = validate_strict(
		schema => $schema,
		input => { flag => 0 }
	);
	is $result->{flag}, 0, 'boolean 0 validated';
	
	dies_ok {
		validate_strict(
			schema => $schema,
			input => { flag => 'invalid' }
		);
	} 'invalid boolean fails validation';
};

subtest 'Custom types with transforms' => sub {
	my $custom_types = {
		email => {
			type => 'string',
			transform => sub { lc $_[0] },
			matches => qr/\@/
		}
	};
	
	my $schema = {
		email => { type => 'email' }
	};
	
	my $result = validate_strict(
		schema => $schema,
		input => { email => 'Test@Example.COM' },
		custom_types => $custom_types
	);
	
	is $result->{email}, 'test@example.com', 'custom type with transform works';
};

subtest 'Object validation' => sub {
	my $obj = bless {}, 'Test::Object';
	
	{
		no strict 'refs';
		*{"Test::Object::test_method"} = sub { 1 };
	}
	
	my $schema = {
		obj => {
			type => 'object',
			can => 'test_method'
		}
	};
	
	my $result = validate_strict(
		schema => $schema,
		input => { obj => $obj }
	);
	
	is blessed($result->{obj}), 'Test::Object', 'object validation passes';
	
	dies_ok {
		validate_strict(
			schema => { obj => { type => 'object', can => 'nonexistent' } },
			input => { obj => $obj }
		);
	} 'object validation fails for missing method';
	
	dies_ok {
		validate_strict(
			schema => { obj => { type => 'object', can => ['method1', 'nonexistent'] } },
			input => { obj => $obj }
		);
	} 'object validation fails for missing method in array';
};

subtest 'Array element validation' => sub {
	my $schema = {
		numbers => {
			type => 'arrayref',
			element_type => 'integer'
		}
	};
	
	my $result = validate_strict(
		schema => $schema,
		input => { numbers => [1, 2, 3] }
	);
	
	is_deeply $result->{numbers}, [1, 2, 3], 'array element validation passes';
	
	dies_ok {
		validate_strict(
			schema => $schema,
			input => { numbers => [1, 'invalid', 3] }
		);
	} 'array element validation fails for invalid element';
};

subtest 'Nested schema validation' => sub {
	my $schema = {
		user => {
			type => 'hashref',
			schema => {
				name => { type => 'string' },
				age => { type => 'integer', min => 0 }
			}
		}
	};
	
	my $result = validate_strict(
		schema => $schema,
		input => { user => { name => 'John', age => 25 } }
	);
	
	is $result->{user}{name}, 'John', 'nested schema validation passes';
	is $result->{user}{age}, 25, 'nested integer coercion works';
	
	dies_ok {
		validate_strict(
			schema => $schema,
			input => { user => { name => 'John', age => -5 } }
		);
	} 'nested validation fails for invalid data';
};

subtest 'Cross validation' => sub {
	my $schema = {
		password => { type => 'string' },
		confirm => { type => 'string' }
	};
	
	my $cross_validation = {
		passwords_match => sub {
			my $params = shift;
			return $params->{password} eq $params->{confirm} 
				? undef : "Passwords don't match";
		}
	};
	
	dies_ok {
		validate_strict(
			schema => $schema,
			input => { password => 'secret', confirm => 'different' },
			cross_validation => $cross_validation
		);
	} 'cross validation fails when passwords dont match';
	
	lives_ok {
		validate_strict(
			schema => $schema,
			input => { password => 'secret', confirm => 'secret' },
			cross_validation => $cross_validation
		);
	} 'cross validation passes when passwords match';
};

subtest 'Logger integration' => sub {
	my $logger = Test::Logger->new;
	
	# Test error logging
	eval {
		validate_strict(
			schema => { required => { type => 'string' } },
			input => {},
			logger => $logger
		);
	};
	
	my @messages = $logger->get_messages;
	ok @messages > 0, 'logger received messages';
	like $messages[0][4], qr/required.*missing/, 'error message logged correctly';
	
	$logger->clear;
	
	# Test warning for unknown parameters
	validate_strict(
		schema => {},
		input => { unknown => 1 },
		unknown_parameter_handler => 'warn',
		logger => $logger
	);
	
	@messages = $logger->get_messages;
	ok @messages > 0, 'warning message logged';
};

subtest 'Case sensitivity in memberof/notmemberof' => sub {
	my $schema = {
		status => {
			type => 'string',
			memberof => ['ACTIVE', 'INACTIVE'],
			case_sensitive => 0
		}
	};
	
	my $result = validate_strict(
		schema => $schema,
		input => { status => 'active' }
	);
	
	is $result->{status}, 'active', 'case insensitive memberof works';
	
	$schema->{status}{case_sensitive} = 1;
	
	dies_ok {
		validate_strict(
			schema => $schema,
			input => { status => 'active' }
		);
	} 'case sensitive memberof fails for wrong case';
};

subtest 'Validation with error_message' => sub {
	my $schema = {
		age => {
			type => 'integer',
			min => 18,
			error_message => 'You must be at least 18 years old'
		}
	};
	
	throws_ok {
		validate_strict(
			schema => $schema,
			input => { age => 16 }
		);
	} qr/You must be at least 18 years old/, 'custom error message used';
};

subtest 'Multiple type alternatives' => sub {
	my $schema = {
		id => [
			{ type => 'string', min => 3 },
			{ type => 'integer', min => 1 }
		]
	};
	
	my $result = validate_strict(
		schema => $schema,
		input => { id => 'user123' }
	);
	is $result->{id}, 'user123', 'string alternative works';
	
	$result = validate_strict(
		schema => $schema,
		input => { id => 42 }
	);
	is $result->{id}, 42, 'integer alternative works';
	
	dies_ok {
		validate_strict(
			schema => $schema,
			input => { id => [] }
		);
	} 'fails when no alternative matches';
};

done_testing();
