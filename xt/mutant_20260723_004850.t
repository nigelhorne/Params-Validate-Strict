#!/usr/bin/env perl
# Auto-generated mutant test stubs
# Generated: 2026-07-23 00:48:50
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

# --- SURVIVOR: COND_INV_1423_8 (MEDIUM) line 1423 in validate_strict() ---
# Source:  if(ref($value) ne 'ARRAY') {
# Hint:    Add tests asserting both true and false outcomes
# Mutations on this line (1 variant):
#   Invert condition if to unless
TODO: {
    local $TODO = 'Complete: COND_INV_1423_8 line 1423 in validate_strict()';
    # NOTE: Params::Validate::Strict has no constructor — call class methods directly.
    # e.g. my $result = Params::Validate::Strict->method(...);
    # TODO: exercise line 1423 in validate_strict() to detect the mutant
    fail('COND_INV_1423_8: replace with real assertion');
}

# --- SURVIVOR: COND_INV_1468_8 (MEDIUM) line 1468 in validate_strict() ---
# Source:  if($rules->{'error_msg'}) {
# Hint:    Add tests asserting both true and false outcomes
# Mutations on this line (1 variant):
#   Invert condition if to unless
TODO: {
    local $TODO = 'Complete: COND_INV_1468_8 line 1468 in validate_strict()';
    # NOTE: Params::Validate::Strict has no constructor — call class methods directly.
    # e.g. my $result = Params::Validate::Strict->method(...);
    # TODO: exercise line 1468 in validate_strict() to detect the mutant
    fail('COND_INV_1468_8: replace with real assertion');
}

# --- SURVIVOR: COND_INV_1505_8 (MEDIUM) line 1505 in validate_strict() ---
# Source:  if($rules->{'error_msg'}) {
# Hint:    Add tests asserting both true and false outcomes
# Mutations on this line (1 variant):
#   Invert condition if to unless
TODO: {
    local $TODO = 'Complete: COND_INV_1505_8 line 1505 in validate_strict()';
    # NOTE: Params::Validate::Strict has no constructor — call class methods directly.
    # e.g. my $result = Params::Validate::Strict->method(...);
    # TODO: exercise line 1505 in validate_strict() to detect the mutant
    fail('COND_INV_1505_8: replace with real assertion');
}

# --- SURVIVOR: COND_INV_1550_8 (MEDIUM) line 1550 in validate_strict() ---
# Source:  if($rules->{'error_msg'}) {
# Hint:    Add tests asserting both true and false outcomes
# Mutations on this line (1 variant):
#   Invert condition if to unless
TODO: {
    local $TODO = 'Complete: COND_INV_1550_8 line 1550 in validate_strict()';
    # NOTE: Params::Validate::Strict has no constructor — call class methods directly.
    # e.g. my $result = Params::Validate::Strict->method(...);
    # TODO: exercise line 1550 in validate_strict() to detect the mutant
    fail('COND_INV_1550_8: replace with real assertion');
}

done_testing();
