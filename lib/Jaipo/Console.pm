package Jaipo::Console;
use warnings;
use strict;
use Jaipo;
use utf8;
use feature qw(:5.10);

my $jobj;

$|=1;
=encoding utf8

=head1 SYNOPSIS

to enter Jaipo console:

    $ jaipo console

    > use Twitter           # enable Twitter service plugin
    > use Plurk             # enable Plurk service plugin
    > use RSS               # enable RSS plugin
    > use IRC               # enable IRC plugin

Jaipo will automatically save your configuration, you only need to use 'use'
at first time.

to read all messeges
    > r

    Service |   User   | Message
    twitter    c9s       oh hohoho !
    plurk      xxx       剛喝完咖啡.
    ...
    ...
    ...

to read messages on Jaiku.com

    > :jaiku :r

to read someone's messages on Jaiku.com

    > :jaiku :r UnitedNation

to read public timeline

    > p

to check user's profile

    > w|who IsYourDaddy

setup location on Jaiku
    > :jaiku l 我在墾丁，天氣情。

to reply to someone's post on plurk.com

    > :plurk #2630 呆丸朱煮好棒

to send direct message to someone on twitter

    > :twitter d mama 媽，我阿雄啦！

to send a message to a channel on Jaiku

    > :jaiku #TVshow 媽，我上電視了！(揮手)

create a regular expression filter for twitter timeline

    > filter /cor[a-z]*s/i  :twitter


=head1 Command Reference

=head2 Global Commands

r
p
...

=head2 Service Commands 

:[service]  [message]

:[service]  :[action] [arguments]

=head2 


=cut


sub new {
	my $class = shift;
	my %args = @_;

	my $self = {};
	bless $self, $class;

	$self->_pre_init;
	return $self;
}


sub _pre_init {
	my $self = shift;
    binmode STDOUT,":utf8";

}


# setup service
sub setup_service {
	my ( $self , $args , $opt ) = @_;

	print "Init " , $args->{package_name} , ":\n";
	for my $column ( @{ $args->{require_args} } ) {
		my ($column_name , $column_option )  = each %$column;

		print $column_option->{label} , ":" ;
		my $val = <STDIN>;
		chomp $val;

		$opt->{$column_name} = $val;
	}

}


sub init {
	my $self = shift;
	$self->print_welcome;

	# init Jaipo here
	$jobj = Jaipo->new;
	$jobj->init( $self );


}

sub print_help {
    my $self = shift;

    print <<HELP ;

r       to read all messages


:[service]  [message]
:[service]  :[action]  [arguments]

HELP

}

sub print_welcome {
	print <<'END';
_________________________________________
Jaipo Console

version 0.1
Type ? for help
Type :[service] :? for service plugin help

END

}

sub parse {
	my $self = shift;
	my $line = shift;

    $line =~ s/^\s*//g;
    $line =~ s/\s*$//g;

	return unless $line;

    # XXX: add trigger 
	given ($line) {

        when ( m/^:/ ) {
            # dispatch to service
            my ($service_tg,$rest_line) = ( $line =~ m/^:(\w+)\s*(.*)/i );
            # $jobj->dispatch_to_service( $service_tg , $rest_line );

            # find a servcie plugin by trigger 

            # parse line 
            # if find sub command , execute the sub command
            # if not, we should posting text to service

        }


        # eval code
        # such like:   eval $jobj->_list_trigger;
        when ( m/^eval (.*)$/i ) {
            # eval a code
            my $code = $1;
            eval $1;
        }

        when ( m/^conf\s+edit$/i ) { 
			my $editor = $ENV{EDITOR} || 'nano' ;
			my $file = Jaipo->config->app_config_path;

			print "Launching editor .. $editor\n";
			qx{$editor $file};

        }

        when ( m/^conf\s+save$/i ) {
            # TODO
            # save configuration 

        }

        when ( m/^conf\s+load$/i ) {
            # TODO
            # load configuration
            # when user modify configuration by self, user can reload
            # configuration


        }


        # built-in commands
        # TODO:
        #
        # use twitter twitter
        when ( m/^(u|use)\s+(.+?)(?:\s(.*))?;?$/i ) {
            # init service plugins
            # TODO: 
            # check if user specify trigger name
            my $name = ucfirst $2;
            my $trigger_name = $3 || lc $name;
            print "Trying to load $name\n";
			$jobj->runtime_load_service( $self, $name , $trigger_name );
            print "Done\n";
			# runtime_load_service $jobj , $self , $name;
        }


        when ( m/^(r|read)/i ) {  
            $jobj->action ( "read_user_timeline", $line );

        }

        when ( m/^(p|public)/i ) { 
            $jobj->action ( "read_public_timeline", $line );

        }

        when ( m/^(g|global)/i ) { 
            $jobj->action ( "read_global_timeline", $line );

        }


        # something like filter create /regexp/  :twitter:public
        when ( m/^(f|filter)\s/i ) { 
            my ($cmd,$action,@params) = split /\s+/ , $line;

        }

		when ( '?' ) { 
            $self->print_help 
        }

        # default action is send message
		default {

			# do update status message if @_ is empty
            $jobj->action ( "send_msg", $line );
		}
	}

}



sub run {
	my $self = shift;


	# read command from STDIN
    binmode STDIN,":utf8";
	while (1) {
		print "jaipo> ";
		my $line = <STDIN>;
		chomp $line;
		$self->parse ( $line );
	}
}



1;
