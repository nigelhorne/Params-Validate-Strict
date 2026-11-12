#!/usr/bin/env perl
# Auto-generated mutant test stubs
# Generated: 2026-11-12 19:06:13
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

# --- SURVIVOR: NUM_BOUNDARY_1675_154_!= (HIGH) line 1675 in validate_strict() ---
# Source:  if(ref($rules) eq 'HASH' && ref($rules->{'type'}) eq 'ARRAY') {
# Hint:    Likely missing edge-case test (boundary value)
# Mutations on this line (1 variant):
#   Numeric boundary flip == to !=
TODO: {
    local $TODO = 'Complete: NUM_BOUNDARY_1675_154_!= line 1675 in validate_strict()';
    # NOTE: Params::Validate::Strict has no constructor — call class methods directly.
    # e.g. my $result = Params::Validate::Strict->method(...);
    # TODO: exercise line 1675 in validate_strict() to detect the mutant
    fail('NUM_BOUNDARY_1675_154_!=: replace with real assertion');
}

# --- SURVIVOR: NUM_BOUNDARY_1692_153_< (HIGH) line 1692 in validate_strict() ---
# Hint:    Likely missing edge-case test (boundary value)
# Mutations on this line (3 variants — one test should kill all):
#   Numeric boundary flip > to <
#   Numeric boundary flip > to >=
#   Numeric boundary flip > to <=
TODO: {
    local $TODO = 'Complete: NUM_BOUNDARY_1692_153_< line 1692 in validate_strict()';
    # NOTE: Params::Validate::Strict has no constructor — call class methods directly.
    # e.g. my $result = Params::Validate::Strict->method(...);
    # TODO: exercise line 1692 in validate_strict() to detect the mutant
    fail('NUM_BOUNDARY_1692_153_<: replace with real assertion');
}

# --- SURVIVOR: NUM_BOUNDARY_1698_134_< (HIGH) line 1698 in validate_strict() ---
# Source:  if(defined(my $max = $rules->{'max'})) {
# Hint:    Likely missing edge-case test (boundary value)
# Mutations on this line (3 variants — one test should kill all):
#   Numeric boundary flip > to <
#   Numeric boundary flip > to >=
#   Numeric boundary flip > to <=
TODO: {
    local $TODO = 'Complete: NUM_BOUNDARY_1698_134_< line 1698 in validate_strict()';
    # NOTE: Params::Validate::Strict has no constructor — call class methods directly.
    # e.g. my $result = Params::Validate::Strict->method(...);
    # TODO: exercise line 1698 in validate_strict() to detect the mutant
    fail('NUM_BOUNDARY_1698_134_<: replace with real assertion');
}

# --- SURVIVOR: COND_INV_2030_9 (MEDIUM) line 2030 in validate_strict() ---
# Source:  if(($rules->{'type'} eq 'arrayref') || ($rules->{'type'} eq 'ArrayRef')) {
# Hint:    Add tests asserting both true and false outcomes
# Mutations on this line (1 variant):
#   Invert condition if to unless
TODO: {
    local $TODO = 'Complete: COND_INV_2030_9 line 2030 in validate_strict()';
    # NOTE: Params::Validate::Strict has no constructor — call class methods directly.
    # e.g. my $result = Params::Validate::Strict->method(...);
    # TODO: exercise line 2030 in validate_strict() to detect the mutant
    fail('COND_INV_2030_9: replace with real assertion');
}

# --- SURVIVOR: COND_INV_2604_2 (MEDIUM) line 2604 in compile_schema() ---
# Source:  my %params = (schema => $schema, %opts);
# Hint:    Add tests asserting both true and false outcomes
# Mutations on this line (1 variant):
#   Invert condition if to unless
TODO: {
    local $TODO = 'Complete: COND_INV_2604_2 line 2604 in compile_schema()';
    # NOTE: Params::Validate::Strict has no constructor — call class methods directly.
    # e.g. my $result = Params::Validate::Strict->method(...);
    # TODO: exercise line 2604 in compile_schema() to detect the mutant
    fail('COND_INV_2604_2: replace with real assertion');
}

done_testing();
