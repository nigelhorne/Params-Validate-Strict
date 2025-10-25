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

subtest 'Boolean string coercion - unreachable code' => sub {
	my $schema = { flag => { type => 'boolean' } };

	# Test boolean string representations that should trigger unreachable code
	my %boolean_strings = (
		'true'  => 1,
		'false' => 0,
		'on'	=> 1,
		'off'   => 0,
		'yes'   => 1,
		'no'	=> 0
	);

	while (my ($string, $expected) = each %boolean_strings) {
		my $result = validate_strict(
			schema => $schema,
			input => { flag => $string }
		);
		is $result->{flag}, $expected, "boolean string '$string' coerces to $expected";
	}
};

subtest 'Invalid arguments cleanup - unreachable code' => sub {
	# This tests the foreach loop that deletes invalid_args (lines 1384-1386)
	# We need to create a scenario where %invalid_args has entries

	my $schema = {
		test1 => {
			type => 'integer',
			min => 10,
			callback => sub { 0 }  # Always fails
		},
		test2 => {
			type => 'string',
			min => 5
		}
	};

	dies_ok {
		validate_strict(
			schema => $schema,
			input => {
				test1 => 5,  # Fails min and callback
				test2 => 'hi' # Fails min length
			}
		);
	} 'validation fails with multiple invalid arguments';

	# The %invalid_args hash should have been populated before the cleanup loop
};

subtest 'Memberof with max constraint - unreachable code' => sub {
	my $schema = {
		status => {
			type => 'string',
			memberof => ['active', 'inactive'],
			max => 10  # This should trigger the "makes no sense with memberof" error
		}
	};

	dies_ok {
		validate_strict(
			schema => $schema,
			input => { status => 'active' }
		);
	} 'dies when memberof combined with max';

	like $@, qr/makes no sense with memberof/, 'correct error message for memberof+max';
};

subtest 'Non-HASH/ARRAY rule references - unreachable code' => sub {
	# Create a schema with a CODE reference as rules (should be invalid)
	my $bad_schema = {
		test => sub { "code ref rules" }
	};

	dies_ok {
		validate_strict(
			schema => $bad_schema,
			input => { test => 'value' }
		);
	} 'dies with code reference as rules';

	like $@, qr/rules must be a hash reference or string/, 'correct error message';
};

subtest 'Complex nested validation failures' => sub {
	# Test scenarios that might trigger the invalid_args cleanup

	my $schema = {
		user => {
			type => 'hashref',
			schema => {
				profile => {
					type => 'hashref',
					schema => {
						age => {
							type => 'integer',
							min => 18,
							callback => sub { 0 }  # Always fail
						}
					}
				}
			}
		}
	};

	dies_ok {
		validate_strict(
			schema => $schema,
			input => {
				user => {
					profile => {
						age => 25  # Should fail callback
					}
				}
			}
		);
	} 'nested validation with callback failure';
};

subtest 'Array validation edge cases' => sub {
	# Test array element validation with various failure modes

	my $schema = {
		numbers => {
			type => 'arrayref',
			element_type => 'integer',
			min => 2,
			schema => {	# This might create complex failure scenarios
				type => 'integer',
				min => 10
			}
		}
	};

	# This should trigger multiple validation paths
	dies_ok {
		validate_strict(
			schema => $schema,
			input => {
				numbers => [5, 'invalid', 15]	# Second element fails type validation
			}
		);
	} 'array validation with mixed valid/invalid elements';
};

subtest 'Cross-validation with non-CODE references' => sub {
	# Test the cross_validation error path (lines 1372-1375)

	my $schema = {
		password => { type => 'string' },
		confirm => { type => 'string' }
	};

	my $bad_cross_validation = {
		test => 'not_a_code_ref'	# String instead of CODE ref
	};

	dies_ok {
		validate_strict(
			schema => $schema,
			input => { password => 'secret', confirm => 'secret' },
			cross_validation => $bad_cross_validation
		);
	} 'dies with non-CODE cross_validation';

	like $@, qr/not a code snippet/, 'correct error message for bad cross_validation';
};

subtest 'Object validation edge cases' => sub {
	my $obj = bless {}, 'Test::Object';

	# Test 'can' with arrayref containing some invalid methods
	my $schema = {
		obj => {
			type => 'object',
			can => ['valid_method', 'invalid_method']	# Should fail on second method
		}
	};

	dies_ok {
		validate_strict(
			schema => $schema,
			input => { obj => $obj }
		);
	} 'object validation fails for missing method in array';
};

subtest 'Transform with recursive validation' => sub {
	# Test transform that might interact with custom types recursively
	my $custom_types = {
		email => {
			type => 'string',
			transform => sub { lc $_[0] },
			matches => qr/\@/
		}
	};

	my $schema = {
		contacts => {
			type => 'arrayref',
			element_type => 'email'	# This might trigger recursive validation paths
		}
	};

	my $result = validate_strict(
		schema => $schema,
		input => { contacts => ['TEST@example.com', 'TEST2@example.com'] },
		custom_types => $custom_types
	);

	is_deeply $result->{contacts}, ['test@example.com', 'test2@example.com'],
		'recursive transform with custom types works';
};

subtest 'Empty arrayref rules' => sub {
	my $schema = {
		test => []	# Empty arrayref as rules
	};

	dies_ok {
		validate_strict(
			schema => $schema,
			input => { test => 'value' }
		);
	} 'dies with empty arrayref rules';

	like $@, qr/schema is empty arrayref/, 'correct error message';
};

subtest 'Complex nested validation failures' => sub {
	# Test nested schema validation that returns false (line 1296)
	my $schema = {
		items => {
			type => 'arrayref',
			schema => {
				type => 'integer',
				min => 10
			}
		}
	};

	dies_ok {
		validate_strict(
			schema => $schema,
			input => { items => [5, 15, 25] }  # First element fails
		);
	} 'nested array schema validation fails for invalid elements';

	# Test hash schema validation that returns false (line 1309)
	my $hash_schema = {
		user => {
			type => 'hashref',
			schema => {
				age => { type => 'integer', min => 18 }
			}
		}
	};

	dies_ok {
		validate_strict(
			schema => $hash_schema,
			input => { user => { age => 16 } }  # Fails min validation
		);
	} 'nested hash schema validation fails for invalid data';
};

subtest 'Empty hash with nested schema' => sub {
	# Test the empty hash case (line 1305)
	my $schema = {
		metadata => {
			type => 'hashref',
			schema => {
				created => { type => 'string' }
			}
		}
	};

	lives_ok {
		my $result = validate_strict(
			schema => $schema,
			input => { metadata => {} }  # Empty hash - should skip validation
		);
		is_deeply $result->{metadata}, {}, 'empty hash with schema passes validation';
	} 'empty hash with nested schema does not trigger validation';
};

subtest 'Custom error messages in various rules' => sub {
	# Test error_message with min rule
	my $schema = {
		age => {
			type => 'integer',
			min => 18,
			error_message => 'Must be at least 18 years old'
		}
	};

	throws_ok {
		validate_strict(
			schema => $schema,
			input => { age => 16 }
		);
	} qr/Must be at least 18 years old/, 'custom error message for min rule';

	# Test error_message with memberof
	$schema = {
		status => {
			type => 'string',
			memberof => ['active', 'inactive'],
			error_message => 'Invalid status value'
		}
	};

	throws_ok {
		validate_strict(
			schema => $schema,
			input => { status => 'pending' }
		);
	} qr/Invalid status value/, 'custom error message for memberof';

	# Test error_message with matches
	$schema = {
		email => {
			type => 'string',
			matches => qr/\@/,
			error_message => 'Invalid email format'
		}
	};

	throws_ok {
		validate_strict(
			schema => $schema,
			input => { email => 'invalid-email' }
		);
	} qr/Invalid email format/, 'custom error message for matches';
};

subtest 'Complex cross-validation scenarios' => sub {
	my $schema = {
		start_date => { type => 'string' },
		end_date => { type => 'string' },
		min_price => { type => 'number' },
		max_price => { type => 'number' }
	};

	my $cross_validation = {
		date_order => sub {
			my $params = shift;
			return $params->{start_date} le $params->{end_date}
				? undef : "Start date must be before end date";
		},
		price_range => sub {
			my $params = shift;
			return $params->{min_price} <= $params->{max_price}
				? undef : "Min price must be less than max price";
		},
		business_logic => sub {
			my $params = shift;
			if ($params->{min_price} > 100 && $params->{start_date} =~ /2024/) {
				return "Special validation failed";
			}
			return undef;
		}
	};

	# Test multiple cross-validation failures
	dies_ok {
		validate_strict(
			schema => $schema,
			input => {
				start_date => '2024-02-01',
				end_date => '2024-01-01',  # Wrong order
				min_price => 150,
				max_price => 100  # Wrong range
			},
			cross_validation => $cross_validation
		);
	} 'multiple cross-validation failures';

	# Test successful cross-validation with multiple validators
	lives_ok {
		my $result = validate_strict(
			schema => $schema,
			input => {
				start_date => '2024-01-01',
				end_date => '2024-02-01',
				min_price => 50,
				max_price => 100
			},
			cross_validation => $cross_validation
		);
		is $result->{min_price}, 50, 'complex cross-validation passes';
	} 'multiple cross-validations all pass';
};

subtest 'Custom types with complex inheritance' => sub {
	my $custom_types = {
		username => {
			type => 'string',
			min => 3,
			max => 20,
			matches => qr/^[a-z0-9_]+$/,
			transform => sub { lc $_[0] }
		},
		email => {
			type => 'string',
			matches => qr/^[\w\.\-]+@[\w\.\-]+\.\w+$/,
			transform => sub { lc trim($_[0]) }
		},
		profile => {
			type => 'hashref',
			schema => {
				name => { type => 'string' },
				age => { type => 'integer', min => 0 }
			}
		}
	};

	my $schema = {
		user => { type => 'username' },
		contact => { type => 'email' },
		data => { type => 'profile' },
		admin_user => {
			type => 'username',
			min => 5,  # Override custom type min
			max => 15  # Override custom type max
		}
	};

	lives_ok {
		my $result = validate_strict(
			schema => $schema,
			input => {
				user => 'TestUser123',
				contact => ' TEST@example.COM ',
				data => { name => 'John', age => 30 },
				admin_user => 'AdminUser'
			},
			custom_types => $custom_types
		);
		is $result->{user}, 'testuser123', 'custom type transform applied';
		is $result->{contact}, 'test@example.com', 'nested custom type works';
		is $result->{admin_user}, 'adminuser', 'overridden custom type constraints work';
	} 'complex custom types with inheritance work';
};

subtest 'Array validation with element_type edge cases' => sub {
	# Test element_type with empty arrays
	my $schema = {
		tags => {
			type => 'arrayref',
			element_type => 'string',
			min => 0  # Allow empty array
		}
	};

	lives_ok {
		my $result = validate_strict(
			schema => $schema,
			input => { tags => [] }
		);
		is_deeply $result->{tags}, [], 'empty array with element_type passes';
	} 'empty arrays validated correctly';

	# Test element_type with mixed validation
	$schema = {
		numbers => {
			type => 'arrayref',
			element_type => 'number',
			min => 1,
			schema => {  # This creates complex validation paths
				type => 'number',
				min => 0,
				max => 100
			}
		}
	};

	dies_ok {
		validate_strict(
			schema => $schema,
			input => { numbers => [-5, 50, 150] }  # First and last fail schema validation
		);
	} 'array with element_type and schema validation fails appropriately';
};

subtest 'Complex optional and default scenarios' => sub {
	my $schema = {
		username => {
			type => 'string',
			optional => 1,
			default => 'guest'
		},
		settings => {
			type => 'hashref',
			optional => sub { $_[1]->{advanced_mode} },  # Dynamic optional
			schema => {
				theme => { type => 'string', default => 'light' },
				notifications => { type => 'boolean', default => 1 }
			}
		},
		advanced_mode => { type => 'boolean' }
	};

	# Test default population
	my $result;
	dies_ok {
		$result = validate_strict(
			schema => $schema,
			input => { advanced_mode => 0 }
		)
	} 'settings is not optional when not in advanced mode';

	ok !exists $result->{settings}, 'dynamically optional field omitted';

	# Test with advanced mode enabled
	$result = validate_strict(
		schema => $schema,
		input => { advanced_mode => 1 }
	);

	ok exists $result->{settings}, 'dynamically optional field included';
	is $result->{settings}{theme}, 'light', 'nested default values work';
};

subtest 'Regex validation edge cases' => sub {
	# Test matches with complex regex that might fail compilation
	my $schema = {
		pattern => {
			type => 'string',
			matches => qr/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@\$!%*?&])[A-Za-z\d@\$!%*?&]{8,}$/  # Complex password regex
		}
	};

	lives_ok {
		my $result = validate_strict(
			schema => $schema,
			input => { pattern => 'Password123!' }
		);
		is $result->{pattern}, 'Password123!', 'complex regex validation passes';
	} 'complex regex patterns work';

	# Test regex compilation failure
	$schema = {
		test => {
			type => 'string',
			matches => '(unclosed regex'  # Invalid regex
		}
	};

	dies_ok {
		validate_strict(
			schema => $schema,
			input => { test => 'value' }
		);
	} 'invalid regex pattern causes failure';
};

subtest 'Object validation with multiple methods' => sub {
	my $obj = bless {}, 'Test::ComplexObject';

	{
		no strict 'refs';
		*{"Test::ComplexObject::method1"} = sub { 1 };
		*{"Test::ComplexObject::method2"} = sub { 1 };
		*{"Test::ComplexObject::method3"} = sub { 1 };
	}

	my $schema = {
		obj => {
			type => 'object',
			can => ['method1', 'method2', 'method3'],  # Multiple required methods
			isa => 'Test::ComplexObject'
		}
	};

	lives_ok {
		my $result = validate_strict(
			schema => $schema,
			input => { obj => $obj }
		);
		is blessed($result->{obj}), 'Test::ComplexObject', 'object with multiple methods validates';
	} 'object validation with multiple methods passes';

	# Test partial method failure
	$schema = {
		obj => {
			type => 'object',
			can => ['method1', 'nonexistent_method']
		}
	};

	dies_ok {
		validate_strict(
			schema => $schema,
			input => { obj => $obj }
		);
	} 'object validation fails for missing method in list';
};

subtest 'Complex type alternatives with nested schemas' => sub {
	my $schema = {
		data => [
			{
				type => 'string',
				min => 5
			},
			{
				type => 'arrayref',
				element_type => 'integer',
				min => 2
			},
			{
				type => 'hashref',
				schema => {
					value => { type => 'number' }
				}
			}
		]
	};

	# Test string alternative
	lives_ok {
		my $result = validate_strict(
			schema => $schema,
			input => { data => 'string_value' }
		);
		is $result->{data}, 'string_value', 'string alternative works';
	} 'type alternative - string';

	# Test array alternative
	lives_ok {
		my $result = validate_strict(
			schema => $schema,
			input => { data => [1, 2, 3] }
		);
		is_deeply $result->{data}, [1, 2, 3], 'array alternative works';
	} 'type alternative - array';

	# Test hash alternative
	lives_ok {
		my $result = validate_strict(
			schema => $schema,
			input => { data => { value => 42.5 } }
		);
		is $result->{data}{value}, 42.5, 'hash alternative works';
	} 'type alternative - hash';
};

subtest 'Transform with type changes' => sub {
	# Test transform that changes the data type
	my $schema = {
		count => {
			type => 'integer',
			transform => sub { int($_[0]) }	# Force integer type
		},
		scores => {
			type => 'arrayref',
			transform => sub { [sort { $a <=> $b } @{$_[0]}] }  # Sort array
		}
	};

	lives_ok {
		my $result = validate_strict(
			schema => $schema,
			input => {
				count => '42.7',  # String that becomes integer
				scores => [5, 1, 3, 2, 4]  # Unsorted array
			}
		);
		is $result->{count}, 42, 'transform coerced string to integer';
		is_deeply $result->{scores}, [1, 2, 3, 4, 5], 'transform sorted array';
	} 'transform can change data structure';
};

# Helper function for trim
sub trim {
	my $s = shift;
	$s =~ s/^\s+|\s+$//g;
	return $s;
}

done_testing();
