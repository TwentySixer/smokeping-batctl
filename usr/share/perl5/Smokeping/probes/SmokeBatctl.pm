package Smokeping::probes::SmokeBatctl;

=head1 301 Moved Permanently

This is a Smokeping probe module. Please use the command

C<smokeping -man Smokeping::probes::FPing>

to view the documentation or the command

C<smokeping -makepod Smokeping::probes::FPing>

to generate the POD document.

=cut

use strict;
use base qw(Smokeping::probes::base);
use IPC::Open3;
use Symbol;
use Carp;

sub pod_hash {
      return {
              name => <<DOC,
Smokeping::probes::SmokeBatctl - SmokeBatctl ping Probe for SmokePing
DOC
              description => <<DOC,
DOC
		authors => <<'DOC',
Tobias Oetiker <tobi@oetiker.ch>
TwentySixer  <ak@spickendorfer.de>
DOC


	}
}

sub new($$$)
{
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = $class->SUPER::new(@_);

    $self->{pingfactor} = 1000; # Gives us a good-guess default

    return $self;
}

sub ProbeDesc($){
    my $self = shift;
    my $bytes = $self->{properties}{packetsize}||56;
    return "ICMP Echo Pings ($bytes Bytes)";
}

# derived class (ie. RemoteFPing) can override this
sub binary {
	my $self = shift;
	return $self->{properties}{binary};
}

sub ping ($){
    my $self = shift;
    # do NOT call superclass ... the ping method MUST be overwriten

    # increment the internal 'rounds' counter
    $self->increment_rounds_count;

    my %upd;
    my $inh = gensym;
    my $outh = gensym;
    my $errh = gensym;
    # pinging nothing is pointless
    return unless @{$self->addresses};

    my $pings =  $self->pings;
    my @cmd = (
                    $self->binary,
                    '-c', $pings,
                    @{$self->addresses});
    $self->do_debug("Executing @cmd");
    my $pid = open3($inh,$outh,$errh, @cmd);
    $self->{rtts}={};
    my $fh = ( $self->{properties}{usestdout} || '') eq 'true' ? $outh : $errh;
    while (<$fh>){
        chomp;
	$self->do_debug("Got SmokeBatctl output: '$_'");
        next unless /^\S+\s+:\s+[-\d\.]/; #filter out error messages from fping
        my @times = split /\s+/;
        my $ip = shift @times;
        next unless ':' eq shift @times; #drop the colon
        if (($self->{properties}{blazemode} || '') eq 'true'){
             shift @times;
        }
        @times = map {sprintf "%.10e", $_ / $self->{pingfactor}} sort {$a <=> $b} grep /^\d/, @times;
        map { $self->{rtts}{$_} = [@times] } @{$self->{addrlookup}{$ip}} ;
    }
    waitpid $pid,0;
    close $inh;
    close $outh;
    close $errh;
}

sub probevars {
	my $class = shift;
	return $class->_makevars($class->SUPER::probevars, {
		_mandatory => [ 'binary' ],
		binary => {
			_sub => sub {
				my ($val) = @_;
        			return undef if $ENV{SERVER_SOFTWARE}; # don't check for fping presence in cgi mode
				return "ERROR: smokebatctl 'binary' does not point to an executable"
            				unless -f $val and -x _;
				return undef;
			},
			_doc => "The location of your smokebatctl  binary.",
			_example => '/usr/local/bin/smokebatctl.py',
		},
	});
}

1;
