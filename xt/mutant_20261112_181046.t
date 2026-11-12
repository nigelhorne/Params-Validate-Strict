#!/usr/bin/env perl
# Auto-generated mutant test stubs
# Generated: 2026-11-12 18:10:46
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

# --- SURVIVOR: NUM_BOUNDARY_1676_154_!= (HIGH) line 1676 in validate_strict() ---
# Source:  if($rule_value > 0 && !$is_optional) {
# Hint:    Likely missing edge-case test (boundary value)
# Mutations on this line (1 variant):
#   Numeric boundary flip == to !=
TODO: {
    local $TODO = 'Complete: NUM_BOUNDARY_1676_154_!= line 1676 in validate_strict()';
    # Suggested boundary values to test: -1, 0, 1
    # NOTE: Params::Validate::Strict has no constructor — call class methods directly.
    # e.g. my $result = Params::Validate::Strict->method(...);
    # TODO: exercise line 1676 in validate_strict() to detect the mutant
    fail('NUM_BOUNDARY_1676_154_!=: replace with real assertion');
}

# --- SURVIVOR: NUM_BOUNDARY_1693_153_< (HIGH) line 1693 in validate_strict() ---
# Source:  }
# Hint:    Likely missing edge-case test (boundary value)
# Mutations on this line (3 variants — one test should kill all):
#   Numeric boundary flip > to <
#   Numeric boundary flip > to >=
#   Numeric boundary flip > to <=
TODO: {
    local $TODO = 'Complete: NUM_BOUNDARY_1693_153_< line 1693 in validate_strict()';
    # NOTE: Params::Validate::Strict has no constructor — call class methods directly.
    # e.g. my $result = Params::Validate::Strict->method(...);
    # TODO: exercise line 1693 in validate_strict() to detect the mutant
    fail('NUM_BOUNDARY_1693_153_<: replace with real assertion');
}

# --- SURVIVOR: NUM_BOUNDARY_1699_134_< (HIGH) line 1699 in validate_strict() ---
# Source:  _error($logger, "$rule_description: Parameter $param_label ($value) must be a positive number");
# Hint:    Likely missing edge-case test (boundary value)
# Mutations on this line (3 variants — one test should kill all):
#   Numeric boundary flip > to <
#   Numeric boundary flip > to >=
#   Numeric boundary flip > to <=
TODO: {
    local $TODO = 'Complete: NUM_BOUNDARY_1699_134_< line 1699 in validate_strict()';
    # NOTE: Params::Validate::Strict has no constructor — call class methods directly.
    # e.g. my $result = Params::Validate::Strict->method(...);
    # TODO: exercise line 1699 in validate_strict() to detect the mutant
    fail('NUM_BOUNDARY_1699_134_<: replace with real assertion');
}

# --- SURVIVOR: COND_INV_2012_9 (MEDIUM) line 2012 in validate_strict() ---
# Source:  _error($logger, "$rule_description: Parameter $param_label has meaningless element_type value $rule_value");
# Hint:    Add tests asserting both true and false outcomes
# Mutations on this line (1 variant):
#   Invert condition if to unless
TODO: {
    local $TODO = 'Complete: COND_INV_2012_9 line 2012 in validate_strict()';
    # NOTE: Params::Validate::Strict has no constructor — call class methods directly.
    # e.g. my $result = Params::Validate::Strict->method(...);
    # TODO: exercise line 2012 in validate_strict() to detect the mutant
    fail('COND_INV_2012_9: replace with real assertion');
}

# --- SURVIVOR: COND_INV_2530_2 (MEDIUM) line 2530 in _rule_error() ---
# Source:  sub _rule_error
# Hint:    Add tests asserting both true and false outcomes
# Mutations on this line (1 variant):
#   Invert condition if to unless
TODO: {
    local $TODO = 'Complete: COND_INV_2530_2 line 2530 in _rule_error()';
    # NOTE: Params::Validate::Strict has no constructor — call class methods directly.
    # e.g. my $result = Params::Validate::Strict->method(...);
    # TODO: exercise line 2530 in _rule_error() to detect the mutant
    fail('COND_INV_2530_2: replace with real assertion');
}

done_testing();
