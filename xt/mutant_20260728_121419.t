#!/usr/bin/env perl
# Auto-generated mutant test stubs
# Generated: 2026-07-28 12:14:19
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

# --- SURVIVOR: NUM_BOUNDARY_1443_117_< (HIGH) line 1443 in validate_strict() ---
# Source:  _error($logger, "$rule_description: Parameter '$key' must have at least $rule_value member" . (($rule_value > 1) ? 's' : ''));
# Hint:    Likely missing edge-case test (boundary value)
# Mutations on this line (3 variants — one test should kill all):
#   Numeric boundary flip > to <
#   Numeric boundary flip > to >=
#   Numeric boundary flip > to <=
TODO: {
    local $TODO = 'Complete: NUM_BOUNDARY_1443_117_< line 1443 in validate_strict()';
    # Suggested boundary values to test: 0, 1, 2
    # NOTE: Params::Validate::Strict has no constructor — call class methods directly.
    # e.g. my $result = Params::Validate::Strict->method(...);
    # TODO: exercise line 1443 in validate_strict() to detect the mutant
    fail('NUM_BOUNDARY_1443_117_<: replace with real assertion');
}

# --- SURVIVOR: COND_INV_1515_8 (MEDIUM) line 1515 in validate_strict() ---
# Source:  if($rules->{'error_msg'}) {
# Hint:    Add tests asserting both true and false outcomes
# Mutations on this line (1 variant):
#   Invert condition if to unless
TODO: {
    local $TODO = 'Complete: COND_INV_1515_8 line 1515 in validate_strict()';
    # NOTE: Params::Validate::Strict has no constructor — call class methods directly.
    # e.g. my $result = Params::Validate::Strict->method(...);
    # TODO: exercise line 1515 in validate_strict() to detect the mutant
    fail('COND_INV_1515_8: replace with real assertion');
}

# --- SURVIVOR: COND_INV_1560_8 (MEDIUM) line 1560 in validate_strict() ---
# Source:  if($rules->{'error_msg'}) {
# Hint:    Add tests asserting both true and false outcomes
# Mutations on this line (1 variant):
#   Invert condition if to unless
TODO: {
    local $TODO = 'Complete: COND_INV_1560_8 line 1560 in validate_strict()';
    # NOTE: Params::Validate::Strict has no constructor — call class methods directly.
    # e.g. my $result = Params::Validate::Strict->method(...);
    # TODO: exercise line 1560 in validate_strict() to detect the mutant
    fail('COND_INV_1560_8: replace with real assertion');
}

done_testing();
