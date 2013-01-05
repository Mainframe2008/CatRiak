package Catalyst::Model::Riak;
BEGIN {
	$Catalyst::Model::Riak::AUTHORITY = 'cpan:NLTBO';
}
BEGIN {
	$Catalyst::Model::Riak::VERSION = '0.01';
}

use Net::Riak;
use Moose;

BEGIN { extends 'Catalyst::Model' }

has host	=> ( isa => 'Str', is => 'ro', required => 1, default => sub { 'http://localhost:8098' } );
has ua_timeout	=> ( isa => 'Int', is => 'ro', required => 1, default => 900 );
has bucket	=> ( isa => 'Str', is => 'rw' );
has dw		=> ( isa => 'Int', is => 'rw', default => 1, trigger => \&_dw_set );
has w		=> ( isa => 'Int', is => 'rw', default => 1, trigger => \&_w_set );
has r		=> ( isa => 'Int', is => 'rw', default => 1, trigger => \&_r_set );

has 'client' => (
	isa => 'Net::Riak',
	is  => 'rw',
	lazy_build => 1,
);

sub _build_client {
	my($self) = @_;

	my $conn = Net::Riak->new(
		host => $self->host,
		ua_timeout => $self->ua_timeout,
	);
	if ( $self->dw != $conn->client->dw ) { $conn->client->dw($self->dw); }
	if ( $self->w != $conn->client->w ) { $conn->client->w($self->w); }
	if ( $self->r != $conn->client->r ) { $conn->client->r($self->r); }

	return $conn;
}

sub _bucket {
	my($self, $data) = @_;
	my $bucket = undef;

	if ( defined($data->{bucket}) ) {
		$bucket = $self->client->bucket($data->{bucket});
	} else {
		if ( defined($self->bucket) ) {
			$bucket = $self->_b;
		}
	}

	return $bucket;
}

sub buckets {
	my($self) = @_;
	return $self->client->all_buckets;
}

sub create {
	my($self, $data) = @_;


	if ( defined($data->{key}) && defined($data->{value}) ) 
	{
		my $object = $self->client->new_object;
		return $object->store;
	}
}

sub delete {
	my($self, $data) = @_;

	if ( defined($data->{key}) ) {
		my $object = $self->get($data);

		if ( defined($object) ) {
			return $object->delete;
		}
	}
}

sub get {
	my($self, $data) = @_;
	my $object = undef;

	my $bucket = $self->_bucket($data);

	if ( defined($data->{key}) ) {
		$object = $bucket->get($data->{key});
	}

	return $object;
}

sub read {
	my($self, $data) = @_;
	return $self->get($data);
}

sub update {
	my($self, $data) = @_;
	
	if ( defined($data->{key}) ) {
		my $object = $self->get($data);

		if ( defined($object) ) {
			$object->data($data->{value});
			return $object->store($self->w, $self->dw);
		}
	}
}

sub _dw_set
{
	my($self, $nr) = @_;
	return $self->client->client->dw($nr);
}

sub _w_set
{
	my($self, $nr) = @_;
	return $self->client->client->w($nr);
}

sub _r_set
{
	my($self, $nr) = @_;
	return $self->client->client->r($nr);
}

1;