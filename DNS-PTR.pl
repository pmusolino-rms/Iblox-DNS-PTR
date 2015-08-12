# Finds missing PTR records and adds them
# for multiple records pointing to the same name, the user is prompted to input which should be chosen
use Infoblox;

my $fh = "DNS-PTR.out";
open STDOUT, '| tee -ai DNS-PTR.out';
#$SIG{INT} = "cleanup";

#sub cleanup {
#	$session->logout();
#	print "Caught SIGNAL INT\n";
#	exit(1);
#}
sub addPTR {
	my $ip = shift;
	my $fqdn = shift;
	my $ibloxSession = shift;
	print "Creating PTR Record for " . $ip . " pointing to " . $fqdn . "\n";
	my $bind_ptr = Infoblox::DNS::Record::PTR->new(
	 	ptrdname => $fqdn,
		comment => "Created by pmusolino.su script",
		ipv4addr => $ip
		);
	unless ($bind_ptr) {
		$ibloxSession->logout();
		die("Contruct DNS record PTR failed: ",
			Infoblox::status_code() . ":" . Infoblox::status_detail());
	}
	print "DNS PTR object created successfully\n";
	$ibloxSession->add($bind_ptr)
		or die("Add record PTR failed: ",
			$ibloxSession->status_code() . ":" . $ibloxSession->status_detail());
	print "DNS PTR object added to server successfully\n";
	return;
}

my $session = Infoblox::Session->new(
	master => "IBLOX-MASTER-IP",
	username => "USER",
	password => "PASSWORD" 
	);
my %missing_ptrs = ();

if ($session->status_code() ) {
	close(STDOUT);
	die("Construct session failed: ", 
		session0>status_code() . ":" . $session->status_detail());
}
print "Session created successfully\n\n";

print "Retreiving records...";
my @result_array = $session->search(
	"object" => "Infoblox::DNS::Record::A",
	#"name"   => "TEST", 
	"view"   => "VIEW" );

unless (@result_array) {
	close(STDOUT);
	$session->logout();
	die("Search DNS record A failed: ",
	$session->status_code() . ":" . $session->status_detail());
}
print "\nFinished retreiving records\n";

if (!@result_array) {
	close(STDOUT);
	$session->logout();
	die "No results\n"
}

print "Finding missing PTRs...\n";
foreach my $a_record (@result_array)
{
	my @ptr_result = $session ->search(
		"object" => "Infoblox::DNS::Record::PTR",
		"view"   => "INTERNAL-CLOUD",
		"ipv4addr" => $a_record->ipv4addr()
		);
	unless (@ptr_result) {
		if( exists $missing_ptrs{$a_record->ipv4addr()}) {
			push @{ $missing_ptrs{$a_record->ipv4addr()} }, $a_record->name();	
		}
		else {
			$missing_ptrs{$a_record->ipv4addr()} = [$a_record->name()];
		}
	}
}
print "Found " . scalar(keys %missing_ptrs) . " IPs needing a PTR\n";

if (scalar(keys %missing_ptrs) == 0) {
	print "Nothing to modify.  Logging out of session\n\n";
	$session->logout();
	close(STDOUT);
	exit(0);
}

foreach my $key ( keys %missing_ptrs) {
	my @a_array = @{$missing_ptrs{$key}};
	#print $key . " - " . join(",",@a_array) . "\n";
	#print scalar(@a_array) . "\n";
	if (scalar(@a_array) == 1) {
		&addPTR($key,$a_array[0],$session);
		#print "Creating PTR Reccord for " . $key . " pointing to " . $a_array[0] . "\n";
	}
	else {
		#In SKip mode.  Commend the next two lines and uncoment the rest to allow for interactive selection
		# of records
		print "There are multiple A records for this IP.  Skipping:\n";
		next;
		#print "There are multiple A records for this IP.  Please chose from the following:\n";
		# my $seq=0;
		# foreach $aname (@a_array) {
		# 	$seq++;
		# 	print $seq . ". " . $aname . "\n";			
		# }
		# my $input = <STDIN>;

		# unless ($a_array[$input - 1]) {
		# 	close(STDOUT);
		# 	$session->logout();
		# 	die "Not a valid array input\n";
		# }
		# else {
		# 	&addPTR($key,$a_array[$input-1],$session);			
		# }
	}
}

print "Logging out of session\n\n";
$session->logout();
close(STDOUT);
exit(0);