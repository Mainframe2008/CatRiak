#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 1;

use_ok( 'Catalyst::Model::Riak' );
use_ok( 'Catalyst::Helper::Model::Riak' );

diag( 'Testing Catalyst::Model::Riak' . $Catalyst::Model::Riak::VERSION );