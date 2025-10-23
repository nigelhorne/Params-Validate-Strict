# NAME

Params::Validate::Strict - Validates a set of parameters against a schema

# VERSION

Version 0.20

# SYNOPSIS

    my $schema = {
        username => { type => 'string', min => 3, max => 50 },
        age => { type => 'integer', min => 0, max => 150 },
    };

    my $input = {
         username => 'john_doe',
         age => '30',   # Will be coerced to integer
    };

    my $validated_input = validate_strict(schema => $schema, input => $input);

    if(defined($validated_input)) {
        print "Example 1: Validation successful!\n";
        print 'Username: ', $validated_input->{username}, "\n";
        print 'Age: ', $validated_input->{age}, "\n";   # It's an integer now
    } else {
        print "Example 1: Validation failed: $@\n";
    }

Upon first reading this may seem overly complex and full of scope creep in a sledgehammer to crack a nut sort of way,
however two use cases make use of the extensive logic that comes with this code
and I have a couple of other reasons for writing it.

- Black Box Testing

    The schema can be plumbed into [App::Test::Generator](https://metacpan.org/pod/App%3A%3ATest%3A%3AGenerator) to automatically create a set of black-box test cases.

- WAF

    The schema can be plumbed into a WAF to protect from random user input.

- Improved API Documentation

    Even if you don't use this module,
    the specification syntax can help with documentation.

- I like it

    I find it fun to write this,
    even if nobody else finds it useful,
    though I hope you will.

# METHODS

## validate\_strict

Validates a set of parameters against a schema.

This function takes two mandatory arguments:

- `schema`

    A reference to a hash that defines the validation rules for each parameter.
    The keys of the hash are the parameter names, and the values are either a string representing the parameter type or a reference to a hash containing more detailed rules.

- `args` || `input`

    A reference to a hash containing the parameters to be validated.
    The keys of the hash are the parameter names, and the values are the parameter values.

It takes three optional arguments:

- `unknown_parameter_handler`

    This parameter describes what to do when a parameter is given that is not in the schema of valid parameters.
    It must be one of `die` (the default), `warn`, or `ignore`.

- `logger`

    A logging object that understands messages such as `error` and `warn`.

- `custom_types`

    A reference to a hash that defines reusable custom types.
    Custom types allow you to define validation rules once and reuse them throughout your schema,
    making your validation logic more maintainable and readable.

    Each custom type is defined as a hash reference containing the same validation rules available for regular parameters
    (`type`, `min`, `max`, `matches`, `memberof`, `callback`, etc.).

        my $custom_types = {
          email => {
            type => 'string',
            matches => qr/^[\w\.\-]+@[\w\.\-]+\.\w+$/,
            error_message => 'Invalid email address format'
          }, phone => {
            type => 'string',
            matches => qr/^\+?[1-9]\d{1,14}$/,
            min => 10,
            max => 15
          }, percentage => {
            type => 'number',
            min => 0,
            max => 100
          }, status => {
            type => 'string',
            memberof => ['draft', 'published', 'archived']
          }
        };

        my $schema = {
          user_email => { type => 'email' },
          contact_number => { type => 'phone', optional => 1 },
          completion => { type => 'percentage' },
          post_status => { type => 'status' }
        };

        my $validated = validate_strict(
          schema => $schema,
          input => $input,
          custom_types => $custom_types
        );

    Custom types can be extended or overridden in the schema by specifying additional constraints:

        my $schema = {
          admin_username => {
            type => 'username',  # Uses custom type definition
            min => 5,            # Overrides custom type's min value
            max => 15            # Overrides custom type's max value
          }
        };

    Custom types work seamlessly with nested schemas, optional parameters, and all other validation features.

The schema can define the following rules for each parameter:

- `type`

    The data type of the parameter.
    Valid types are `string`, `integer`, `number`, `float` `boolean`, `hashref`, `arrayref`, `object` and `coderef`.

    A type can be an arrayref when a parameter could have different types (e.g. a string or an object).

        $schema = {
          username => [
            { type => 'string', min => 3, max => 50 },        # Name
            { type => 'integer', 'min' => 1 },        # UID that isn't root
          ]
        };

- `can`

    The parameter must be an object that understands the method `can`.
    `can` can be a simple scalar string of a method name,
    or an arrayref of a list of method names, all of which must be supported by the object.

- `isa`

    The parameter must be an object of type `isa`.

- `memberof`

    The parameter must be a member of the given arrayref.

- `min`

    The minimum length (for strings), value (for numbers) or number of keys (for hashrefs).

- `max`

    The maximum length (for strings), value (for numbers) or number of keys (for hashrefs).

- `matches`

    A regular expression that the parameter value must match.
    Checks all members of arrayrefs.

- `nomatch`

    A regular expression that the parameter value must not match.
    Checks all members of arrayrefs.

- `callback`

    A code reference to a subroutine that performs custom validation logic.
    The subroutine should accept the parameter value as an argument and return true if the value is valid, false otherwise.

- `optional`

    A boolean value indicating whether the parameter is optional.
    If true, the parameter is not required.
    If false or omitted, the parameter is required.

- `default`

    Populate missing optional parameters with the specified value.
    Note that this value is not validated.

        username => {
          type => 'string',
          optional => 1,
          default => 'guest'
        }

- `element_type`

    Extends the validation to individual elements of arrays.

        tags => {
          type => 'arrayref',
          element_type => 'number',   # Float means the same
          min => 1,   # this is the length of the array, not the min value for each of the numbers. For that, add a C<schema> rule
          max => 5
        }

- `error_message`

    The custom error message to be used in the event of a validation failure.

        age => {
          type => 'integer',
          min => 18,
          error_message => 'You must be at least 18 years old'
        }

- `schema`

    You can validate nested hashrefs and arrayrefs using the `schema` property:

        my $schema = {
            user => {       # 'user' is a hashref
                type => 'hashref',
                schema => { # Specify what the elements of the hash should be
                    name => { type => 'string' },
                    age => { type => 'integer', min => 0 },
                    hobbies => {    # 'hobbies' is an array ref that this user has
                        type => 'arrayref',
                        schema => { type => 'string' }, # Validate each hobby
                        min => 1 # At least one hobby
                    }
                }
            },
            metadata => {
                type => 'hashref',
                schema => {
                    created => { type => 'string' },
                    tags => {
                        type => 'arrayref',
                        schema => {
                            type => 'string',
                            matches => qr/^[a-z]+$/ # Or you can say matches => '^[a-z]+$'
                        }
                    }
                }
            }
        };

- `validate`

    A snippet of code that validates the input.
    It's passed the input arguments,
    and return a string containing a reason for rejection,
    or undef if it's allowed.

        my $schema = {
          user => {
            type => 'string',
            validate => sub {
              if($_[0]->{'password'} eq 'bar') {
                return undef;
              }
              return 'Invalid password, try again';
            }
          }, password => {
             type => 'string'
          }
        };

- `transform`

    A code reference to a subroutine that transforms/sanitizes the parameter value before validation.
    The subroutine should accept the parameter value as an argument and return the transformed value.
    The transformation is applied before any validation rules are checked, allowing you to normalize
    or clean data before it is validated.

    Common use cases include trimming whitespace, normalizing case, formatting phone numbers,
    sanitizing user input, and converting between data formats.

        # Simple string transformations
        username => {
          type => 'string',
          transform => sub { lc(trim($_[0])) },  # lowercase and trim
          matches => qr/^[a-z0-9_]+$/
        }

        email => {
          type => 'string',
          transform => sub { lc(trim($_[0])) },  # normalize email
          matches => qr/^[\w\.\-]+@[\w\.\-]+\.\w+$/
        }

        # Array transformations
        tags => {
          type => 'arrayref',
          transform => sub { [map { lc($_) } @{$_[0]}] },  # lowercase all elements
          element_type => 'string'
        }

        keywords => {
          type => 'arrayref',
          transform => sub {
            my @arr = map { lc(trim($_)) } @{$_[0]};
            my %seen;
            return [grep { !$seen{$_}++ } @arr];  # remove duplicates
          }
        }

        # Numeric transformations
        quantity => {
          type => 'integer',
          transform => sub { int($_[0] + 0.5) },  # round to nearest integer
          min => 1
        }

        # Sanitization
        slug => {
          type => 'string',
          transform => sub {
            my $str = lc(trim($_[0]));
            $str =~ s/[^\w\s-]//g;  # remove special characters
            $str =~ s/\s+/-/g;      # replace spaces with hyphens
            return $str;
          },
          matches => qr/^[a-z0-9-]+$/
        }

        phone => {
          type => 'string',
          transform => sub {
            my $str = $_[0];
            $str =~ s/\D//g;  # remove all non-digits
            return $str;
          },
          matches => qr/^\d{10}$/
        }

    The `transform` function is applied to the value before any validation checks (`min`, `max`,
    `matches`, `callback`, etc.), ensuring that validation rules are checked against the cleaned data.

    Transformations work with all parameter types including nested structures:

        user => {
          type => 'hashref',
          schema => {
            name => {
              type => 'string',
              transform => sub { trim($_[0]) }
            },
            email => {
              type => 'string',
              transform => sub { lc(trim($_[0])) }
            }
          }
        }

    Transformations can also be defined in custom types for reusability:

        my $custom_types = {
          email => {
            type => 'string',
            transform => sub { lc(trim($_[0])) },
            matches => qr/^[\w\.\-]+@[\w\.\-]+\.\w+$/
          }
        };

    Note that the transformed value is what gets returned in the validated result and is what
    subsequent validation rules will check against. If a transformation might fail, ensure it
    handles edge cases appropriately.
    It is the responsibilty of the transformer to ensure that the type of the returned value is correct,
    since that is what will be validated.

    Many validators also allow a code ref to be passed so that you can create your own, conditional validation rule, e.g.:

        $schema = {
          age => {
            type => 'integer',
            min => sub {
                my ($value, $all_params) = @_;
                return $all_params->{country} eq 'US' ? 21 : 18;
            }
          }
        }

- `cross_validation`

    A reference to a hash that defines validation rules that depend on more than one parameter.
    Cross-field validations are performed after all individual parameter validations have passed,
    allowing you to enforce business logic that requires checking relationships between different fields.

    Each cross-validation rule is a key-value pair where the key is a descriptive name for the validation
    and the value is a code reference that accepts a hash reference of all validated parameters.
    The subroutine should return `undef` if the validation passes, or an error message string if it fails.

        my $schema = {
          password => { type => 'string', min => 8 },
          password_confirm => { type => 'string' }
        };

        my $cross_validation = {
          passwords_match => sub {
            my $params = shift;
            return $params->{password} eq $params->{password_confirm}
              ? undef : "Passwords don't match";
          }
        };

        my $validated = validate_strict(
          schema => $schema,
          input => $input,
          cross_validation => $cross_validation
        );

    Common use cases include password confirmation, date range validation, numeric comparisons,
    and conditional requirements:

        # Date range validation
        my $cross_validation = {
          date_range_valid => sub {
            my $params = shift;
            return $params->{start_date} le $params->{end_date}
              ? undef : "Start date must be before or equal to end date";
          }
        };

        # Price range validation
        my $cross_validation = {
          price_range_valid => sub {
            my $params = shift;
            return $params->{min_price} <= $params->{max_price}
              ? undef : "Minimum price must be less than or equal to maximum price";
          }
        };

        # Conditional required field
        my $cross_validation = {
          address_required_for_delivery => sub {
            my $params = shift;
            if ($params->{shipping_method} eq 'delivery' && !$params->{delivery_address}) {
              return "Delivery address is required when shipping method is 'delivery'";
            }
            return undef;
          }
        };

    Multiple cross-validations can be defined in the same hash, and they are all checked in order.
    If any cross-validation fails, the function will `croak` with the error message returned by the validation:

        my $cross_validation = {
          passwords_match => sub {
            my $params = shift;
            return $params->{password} eq $params->{password_confirm}
              ? undef : "Passwords don't match";
          },
          emails_match => sub {
            my $params = shift;
            return $params->{email} eq $params->{email_confirm}
              ? undef : "Email addresses don't match";
          },
          age_matches_birth_year => sub {
            my $params = shift;
            my $current_year = (localtime)[5] + 1900;
            my $calculated_age = $current_year - $params->{birth_year};
            return abs($calculated_age - $params->{age}) <= 1
              ? undef : "Age doesn't match birth year";
          }
        };

    Cross-validations receive the parameters after individual validation and transformation have been applied,
    so you can rely on the data being in the correct format and type:

        my $schema = {
          email => { 
            type => 'string',
            transform => sub { lc($_[0]) }  # Lowercased before cross-validation
          },
          email_confirm => { 
            type => 'string',
            transform => sub { lc($_[0]) }
          }
        };

        my $cross_validation = {
          emails_match => sub {
            my $params = shift;
            # Both emails are already lowercased at this point
            return $params->{email} eq $params->{email_confirm}
              ? undef : "Email addresses don't match";
          }
        };

    Cross-validations can access nested structures and optional fields:

        my $cross_validation = {
          guardian_required_for_minors => sub {
            my $params = shift;
            if ($params->{user}{age} < 18 && !$params->{guardian}) {
              return "Guardian information required for users under 18";
            }
            return undef;
          }
        };

    All cross-validations must pass for the overall validation to succeed.

If a parameter is optional and its value is `undef`,
validation will be skipped for that parameter.

If the validation fails, the function will `croak` with an error message describing the validation failure.

If the validation is successful, the function will return a reference to a new hash containing the validated and (where applicable) coerced parameters.  Integer and number parameters will be coerced to their respective types.

# MIGRATION FROM LEGACY VALIDATORS

## From [Params::Validate](https://metacpan.org/pod/Params%3A%3AValidate)

    # Old style
    validate(@_, {
        name => { type => SCALAR },
        age => { type => SCALAR, regex => qr/^\d+$/ }
    });

    # New style
    validate_strict(
        schema => {
            name => 'string',
            age => { type => 'integer', min => 0 }
        },
        args => { @_ }
    );

## From [Type::Params](https://metacpan.org/pod/Type%3A%3AParams)

    # Old style
    my ($name, $age) = validate_positional \@_, Str, Int;

    # New style - requires converting to named parameters first
    my %args = (name => $_[0], age => $_[1]);
    my $validated = validate_strict(
        schema => { name => 'string', age => 'integer' },
        args => \%args
    );

# AUTHOR

Nigel Horne, `<njh at nigelhorne.com>`

# FORMAL SPECIFICATION

    [PARAM_NAME, VALUE, TYPE_NAME, CONSTRAINT_VALUE]

    ValidationRule ::= SimpleType | ComplexRule

    SimpleType ::= string | integer | number | arrayref | hashref | coderef | object

    ComplexRule == [
        type: TYPE_NAME;
        min: ℕ₁;
        max: ℕ₁;
        optional: 𝔹;
        matches: REGEX;
        nomatch: REGEX;
        memberof: seq VALUE;
        callback: FUNCTION;
        isa: TYPE_NAME;
        can: METHOD_NAME
    ]

    Schema == PARAM_NAME ⇸ ValidationRule

    Arguments == PARAM_NAME ⇸ VALUE

    ValidatedResult == PARAM_NAME ⇸ VALUE

    │ ∀ rule: ComplexRule • rule.min ≤ rule.max
    │ ∀ schema: Schema; args: Arguments •
    │   dom(validate_strict(schema, args)) ⊆ dom(schema) ∪ dom(args)

    validate_strict: Schema × Arguments → ValidatedResult

    ∀ schema: Schema; args: Arguments •
      let result == validate_strict(schema, args) •
        (∀ name: dom(schema) ∩ dom(args) •
          name ∈ dom(result) ⇒
          type_matches(result(name), schema(name))) ∧
        (∀ name: dom(schema) •
          ¬optional(schema(name)) ⇒ name ∈ dom(args))

    type_matches: VALUE × ValidationRule → 𝔹

# BUGS

# SEE ALSO

- Test coverage report: [https://nigelhorne.github.io/Params-Validate-Strict/coverage/](https://nigelhorne.github.io/Params-Validate-Strict/coverage/)
- [Params::Get](https://metacpan.org/pod/Params%3A%3AGet)
- [Params::Validate](https://metacpan.org/pod/Params%3A%3AValidate)
- [Return::Set](https://metacpan.org/pod/Return%3A%3ASet)
- [App::Test::Generator](https://metacpan.org/pod/App%3A%3ATest%3A%3AGenerator)

# SUPPORT

This module is provided as-is without any warranty.

Please report any bugs or feature requests to `bug-params-validate-strict at rt.cpan.org`,
or through the web interface at
[http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Params-Validate-Strict](http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Params-Validate-Strict).
I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

You can find documentation for this module with the perldoc command.

    perldoc Params::Validate::Strict

You can also look for information at:

- MetaCPAN

    [https://metacpan.org/dist/Params-Validate-Strict](https://metacpan.org/dist/Params-Validate-Strict)

- RT: CPAN's request tracker

    [https://rt.cpan.org/NoAuth/Bugs.html?Dist=Params-Validate-Strict](https://rt.cpan.org/NoAuth/Bugs.html?Dist=Params-Validate-Strict)

- CPAN Testers' Matrix

    [http://matrix.cpantesters.org/?dist=Params-Validate-Strict](http://matrix.cpantesters.org/?dist=Params-Validate-Strict)

- CPAN Testers Dependencies

    [http://deps.cpantesters.org/?module=Params::Validate::Strict](http://deps.cpantesters.org/?module=Params::Validate::Strict)

# LICENSE AND COPYRIGHT

Copyright 2025 Nigel Horne.

This program is released under the following licence: GPL2
