#!/usr/bin/env perl
# Auto-generated mutant test stubs
# Generated: 2026-05-25 13:15:07
# Generator: scripts/test-generator-index
#
# DO NOT COMMIT without completing the TODO sections.
#
# HIGH/MEDIUM difficulty survivors have TODO stubs — these need real tests.
# LOW difficulty survivors appear as comment hints — worth improving.
#
# Stubs call new() for modules with a constructor, or show a class method
# placeholder for modules without one. Add arguments as needed.

use strict;
use warnings;
use Test::More;

use_ok('Params::Validate::Strict');

################################################################
# FILE: lib/Params/Validate/Strict.pm
################################################################
# --- SURVIVORS (TODO stubs) ---

# --- SURVIVOR: NUM_BOUNDARY_1159_26_> (HIGH) line 1159 in validate_strict() ---
# Source:  if($look_for_default) {
# Hint:    Likely missing edge-case test (boundary value)
# Mutations on this line (3 variants — one test should kill all):
#   Numeric boundary flip < to >
#   Numeric boundary flip < to <=
#   Numeric boundary flip < to >=
TODO: {
    local $TODO = 'Complete: NUM_BOUNDARY_1159_26_> line 1159 in validate_strict()';
    # NOTE: Params::Validate::Strict has no constructor — call class methods directly.
    # e.g. my $result = Params::Validate::Strict->method(...);
    # TODO: exercise line 1159 in validate_strict() to detect the mutant
    fail('NUM_BOUNDARY_1159_26_>: replace with real assertion');
}

# --- SURVIVOR: COND_INV_1352_8 (MEDIUM) line 1352 in validate_strict() ---
# Source:  }
# Hint:    Add tests asserting both true and false outcomes
# Mutations on this line (1 variant):
#   Invert condition if to unless
TODO: {
    local $TODO = 'Complete: COND_INV_1352_8 line 1352 in validate_strict()';
    # NOTE: Params::Validate::Strict has no constructor — call class methods directly.
    # e.g. my $result = Params::Validate::Strict->method(...);
    # TODO: exercise line 1352 in validate_strict() to detect the mutant
    fail('COND_INV_1352_8: replace with real assertion');
}

# --- SURVIVOR: COND_INV_1416_8 (MEDIUM) line 1416 in validate_strict() ---
# Source:  $invalid_args{$key} = 1;
# Hint:    Add tests asserting both true and false outcomes
# Mutations on this line (1 variant):
#   Invert condition if to unless
TODO: {
    local $TODO = 'Complete: COND_INV_1416_8 line 1416 in validate_strict()';
    # NOTE: Params::Validate::Strict has no constructor — call class methods directly.
    # e.g. my $result = Params::Validate::Strict->method(...);
    # TODO: exercise line 1416 in validate_strict() to detect the mutant
    fail('COND_INV_1416_8: replace with real assertion');
}

# --- SURVIVOR: COND_INV_1453_8 (MEDIUM) line 1453 in validate_strict() ---
# Source:  $rule_value = $custom_types->{$type}->{'max'};
# Hint:    Add tests asserting both true and false outcomes
# Mutations on this line (1 variant):
#   Invert condition if to unless
TODO: {
    local $TODO = 'Complete: COND_INV_1453_8 line 1453 in validate_strict()';
    # NOTE: Params::Validate::Strict has no constructor — call class methods directly.
    # e.g. my $result = Params::Validate::Strict->method(...);
    # TODO: exercise line 1453 in validate_strict() to detect the mutant
    fail('COND_INV_1453_8: replace with real assertion');
}

# --- SURVIVOR: COND_INV_1494_8 (MEDIUM) line 1494 in validate_strict() ---
# Source:  _error($logger, $rules->{'error_msg'});
# Hint:    Add tests asserting both true and false outcomes
# Mutations on this line (1 variant):
#   Invert condition if to unless
TODO: {
    local $TODO = 'Complete: COND_INV_1494_8 line 1494 in validate_strict()';
    # NOTE: Params::Validate::Strict has no constructor — call class methods directly.
    # e.g. my $result = Params::Validate::Strict->method(...);
    # TODO: exercise line 1494 in validate_strict() to detect the mutant
    fail('COND_INV_1494_8: replace with real assertion');
}

done_testing();
