#!/usr/bin/env perl
# Auto-generated mutant test stubs
# Generated: 2026-08-20 00:04:17
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

# --- SURVIVOR: NUM_BOUNDARY_1408_128_< (HIGH) line 1408 in validate_strict() ---
# Source:  _rule_error($logger, $rules, "$rule_description: Parameter '$key' must have at least $rule_value member" . (($rule_value > 1) ? 's' : ''));
# Hint:    Likely missing edge-case test (boundary value)
# Mutations on this line (3 variants — one test should kill all):
#   Numeric boundary flip > to <
#   Numeric boundary flip > to >=
#   Numeric boundary flip > to <=
TODO: {
    local $TODO = 'Complete: NUM_BOUNDARY_1408_128_< line 1408 in validate_strict()';
    # Suggested boundary values to test: 0, 1, 2
    # NOTE: Params::Validate::Strict has no constructor — call class methods directly.
    # e.g. my $result = Params::Validate::Strict->method(...);
    # TODO: exercise line 1408 in validate_strict() to detect the mutant
    fail('NUM_BOUNDARY_1408_128_<: replace with real assertion');
}

# --- SURVIVOR: COND_INV_2083_2 (MEDIUM) line 2083 in _value_in_list() ---
# Source:  if(defined($entry) && !defined($entry->[0])) {
# Hint:    Add tests asserting both true and false outcomes
# Mutations on this line (1 variant):
#   Invert condition if to unless
TODO: {
    local $TODO = 'Complete: COND_INV_2083_2 line 2083 in _value_in_list()';
    # NOTE: Params::Validate::Strict has no constructor — call class methods directly.
    # e.g. my $result = Params::Validate::Strict->method(...);
    # TODO: exercise line 2083 in _value_in_list() to detect the mutant
    fail('COND_INV_2083_2: replace with real assertion');
}

done_testing();
