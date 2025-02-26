package Params::Validate::Strict;

use strict;
use warnings;
use Carp;

our @ISA = qw(Exporter);
our %EXPORT_OK = qw(validate_strict);
our $VERSION = '0.01';

# This function takes two arguments:
#
# $schema A reference to a hash that defines the validation rules for each parameter.  The keys of the hash are the parameter names, and the values are either a string representing the parameter type or a reference to a hash containing more detailed rules.
# $params A reference to a hash containing the parameters to be validated.  The keys of the hash are the parameter names, and the values are the parameter values.
#
# The schema can define the following rules for each parameter:
#
# type The data type of the parameter.  Valid types are string, integer, and number.
# min The minimum length (for strings) or value (for numbers).
# max The maximum length (for strings) or value (for numbers).
# matches A regular expression that the parameter value must match.
# callback A code reference to a subroutine that performs custom validation logic. The subroutine should accept the parameter value as an argument and return true if the value is valid, false otherwise.
# optional A boolean value indicating whether the parameter is optional. If true, the parameter is not required.  If false or omitted, the parameter is required.
#
# If a parameter is optional and its value is `undef`, validation will be skipped for that parameter.
#
# If the validation fails, the function will croak with an error message describing the validation failure.
#
# If the validation is successful, the function will return a reference to a new hash containing the validated and (where applicable) coerced parameters.  Integer and number parameters will be coerced to their respective types.

# For example:
#	my $schema = {
#		username => { type => 'string', min => 3, max => 50 },
#		age => { type => 'integer', min => 0, max => 150 },
#	};
#
# my $params = {
#	username => 'john_doe',
#	age => '30', # Will be coerced to integer
# };
#
# my $validated_params = validate_strict($schema, $params);
#
# if (defined $validated_params) {
#	print "Example 1: Validation successful!\n";
#	print 'Username: ' . $validated_params->{username} . "\n";
#	print 'Age: ' . $validated_params->{age} . "\n"; # It's an integer now!
# } else {
#	print "Example 1: Validation failed: $@\n";
# }

sub validate_strict
{
	my ($schema, $params) = @_;

	# Check if schema and params are references to hashes
	unless((ref($schema) eq 'HASH') && (ref($params) eq 'HASH')) {
		croak 'validate_strict: schema and params must be hash references';
	}

	my %validated_params;

	foreach my $key (keys %$schema) {
		my $rules = $schema->{$key};
		my $value = $params->{$key};

		# Check if the parameter is required
		if((ref($rules) eq 'HASH') && (!exists($rules->{optional})) && (!exists($params->{$key}))) {
			croak "validate_strict: Required parameter '$key' is missing";
		}

		# Handle optional parameters
		next if((ref($rules) eq 'HASH') && exists($rules->{optional}) && (!defined($value)));

		# If rules are a simple type string
		if(ref($rules) eq '') {
			$rules = { type => $rules };
		}

		# Validate based on rules
		if(ref($rules) eq 'HASH') {
			foreach my $rule_name (keys %$rules) {
				my $rule_value = $rules->{$rule_name};

				if($rule_name eq 'type') {
					my $type = lc($rule_value);

					if($type eq 'string') {
						unless((ref($value) eq '') || (defined($value) && ($value =~ /^.*$/))) { # Allow undef for optional strings
							croak(__PACKAGE__, "::validate_strict: Parameter '$key' must be a string");
						}
					} elsif($type eq 'integer') {
						if($value !~ /^-?\d+$/) {
							croak "validate_strict: Parameter '$key' must be an integer";
						}
						$value = int($value); # Coerce to integer
					} elsif($type eq 'number') {
						if($value !~ /^-?\d+(?:\.\d+)?$/) {
							croak(__PACKAGE__, "::validate_strict: Parameter '$key' must be a number");
						}
						$value = eval $value; # Coerce to number (be careful with eval)

					} else {
						croak "validate_strict: Unknown type '$type'";
					}
				} elsif($rule_name eq 'min') {
					if($rules->{'type'} eq 'string') {
						if(!defined($value)) {
							next;	# Skip if string is undefined
						}
						if(length($value) < $rule_value) {
							croak("validate_strict: Parameter '$key' must be at least length $rule_value");
						}
					} elsif($rules->{'type'} eq 'integer') {
						if($value < $rule_value) {
							croak(__PACKAGE__, "::validate_strict: Parameter '$key' must be at least $rule_value");
						}
					} else {
						croak(__PACKAGE__, "::validate_strict: Parameter '$key' has meaningless min value $rule_value");
					}
				} elsif($rule_name eq 'max') {
					if($rules->{'type'} eq 'string') {
						if(!defined($value)) {
							next;	# Skip if string is undefined
						}
						if(length($value) > $rule_value) {
							croak("validate_strict: Parameter '$key' must be no longer than $rule_value");
						}
					} elsif($rules->{'type'} eq 'integer') {
						if($value > $rule_value) {
							croak(__PACKAGE__, "::validate_strict: Parameter '$key' must be no more than $rule_value");
						}
					} else {
						croak(__PACKAGE__, "::validate_strict: Parameter '$key' has meaningless max value $rule_value");
					}
				} elsif($rule_name eq 'matches') {
					unless ($value =~ $rule_value) {
						croak "validate_strict: Parameter '$key' must match '$rule_value'";
					}
				} elsif ($rule_name eq 'callback') {
					unless (defined &$rule_value) {
						croak(__PACKAGE__, "::validate_strict: callback for '$key' must be a code reference");
					}
					my $res = $rule_value->($value);
					unless ($res) {
						croak "validate_strict: Parameter '$key' failed callback validation";
					}
				} elsif($rule_name eq 'optional') {
					# Already handled at the beginning of the loop
				} else {
					croak "validate_strict: Unknown rule '$rule_name'";
				}
			}
		}

		$validated_params{$key} = $value;
	}

	return \%validated_params;
}

1;
