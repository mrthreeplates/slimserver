package Slim::Plugin::RhapsodyDirect::Plugin;

# $Id$

# Browse Rhapsody Direct via SqueezeNetwork

use strict;
use base 'Slim::Plugin::OPMLBased';

use Slim::Networking::SqueezeNetwork;
use Slim::Plugin::RhapsodyDirect::ProtocolHandler;
use Slim::Plugin::RhapsodyDirect::RPDS ();

my $log = Slim::Utils::Log->addLogCategory({
	'category'     => 'plugin.rhapsodydirect',
	'defaultLevel' => $ENV{RHAPSODY_DEV} ? 'DEBUG' : 'WARN',
	'description'  => 'PLUGIN_RHAPSODY_DIRECT_MODULE_NAME',
});

sub initPlugin {
	my $class = shift;
	
	Slim::Player::ProtocolHandlers->registerHandler(
		rhapd => 'Slim::Plugin::RhapsodyDirect::ProtocolHandler'
	);
	
	Slim::Networking::Slimproto::addHandler( 
		RPDS => \&Slim::Plugin::RhapsodyDirect::RPDS::rpds_handler
	);

	$class->SUPER::initPlugin(
		feed => Slim::Networking::SqueezeNetwork->url('/api/rhapsody/opml'),
		tag  => 'rhapsodydirect',
		menu => 'music_on_demand',
		'icon-id' => 'http://localhost:9000/html/images/ServiceProviders/rhapsodydirect_56x56_p.png',
	);
}

sub playerMenu () {
	return 'MUSIC_ON_DEMAND';
}

sub getDisplayName () {
	return 'PLUGIN_RHAPSODY_DIRECT_MODULE_NAME';
}

sub handleError {
	my ( $error, $client ) = @_;
	
	$log->debug("Error during request: $error");
	
	# Strip long number string from front of error
	$error =~ s/\d+( : )?//;
	
	# Allow status updates again
	$client->suppressStatus(0);
	
	# XXX: Need to give error feedback for web requests

	if ( $client ) {
		$client->unblock;
		
		Slim::Buttons::Common::pushModeLeft( $client, 'INPUT.Choice', {
			header  => '{PLUGIN_RHAPSODY_DIRECT_ERROR}',
			listRef => [ $error ],
		} );
		
		if ( $ENV{SLIM_SERVICE} ) {
		    logError( $client, $error );
		}
	}
}

1;
