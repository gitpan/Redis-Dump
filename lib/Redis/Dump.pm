
package Redis::Dump;

use Moose;
with 'MooseX::Getopt';

use Redis 1.904;

# ABSTRACT: Backup and restore your Redis data to and from JSON.
our $VERSION = '0.002'; # VERSION

has server => (
    is => 'rw',
    isa => 'Str',
    default => '127.0.0.1:6379'
);

has conn => (
    is => 'rw',
    isa => 'Redis',
    lazy => 1,
    default => sub { Redis->new( server => shift->server ) }
);

sub _get_keys {
    shift->conn->keys("*");
}

sub _get_values_by_keys {
    my $self = shift;
    my %keys;
    foreach my $key ($self->_get_keys) {
        my $type = $self->conn->type($key);
        $keys{$key} = $self->conn->get($key) if $type eq 'string';
        $keys{$key} = $self->conn->lrange($key, 0, -1) if $type eq 'list';

        if ($type eq 'hash') {
            my %hash;
            my @hashs = $self->conn->hkeys($key);
            foreach my $item (@hashs) {
                $hash{$item} = $self->conn->hget($key, $item);
            }
            $keys{$key} = { %hash } ;
        }
    }
    return %keys;
}


sub run {
    my $self = shift;

    return $self->_get_values_by_keys;
}

1;


__END__
=pod

=head1 NAME

Redis::Dump - Backup and restore your Redis data to and from JSON.

=head1 VERSION

version 0.002

=head1 DESCRIPTION

Backup and restore your Redis data to and from JSON.

=head2 run

Run app

=head1 AUTHOR

Thiago Rondon <thiago@nsms.com.br>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Thiago Rondon.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

