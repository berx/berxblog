use DBI;

# Database connection details
$hostname = "127.0.0.1";
$port = "1521";
$service_name = "freepdb1";
$username = "berx";
$password = "berx";

# Connect to the database
my $dbh = DBI->connect("dbi:Oracle:host=$hostname;port=$port;service_name=$service_name", $username, $password)
    or die "Couldn't connect to database: $DBI::errstr";

# Prepare and execute the query
my $sql = "SELECT id, B LOB_LOCATOR FROM T WHERE ROWNUM = 1";
my $sth = $dbh->prepare($sql, { ora_auto_lob => 0 })
    or die "Couldn't prepare statement: $DBI::errstr";
$sth->execute() or die "Couldn't execute statement: $DBI::errstr";

# Get the first row
my ($id, $lob_locator) = $sth->fetchrow_array();

print "id: $id \n";

# Close the first connection
$sth->finish;
$dbh->disconnect;

print "ll: $lob_locator \n";
print " --- \n";


# Connect to the database again for LOB fetching
$dbh2 = DBI->connect("dbi:Oracle:host=$hostname;port=$port;service_name=$service_name", $username, $password)
    or die "Couldn't connect to database: $DBI::errstr";

   my $chunk_size = 1034;   # Arbitrary chunk size, for example
   my $offset = 1;   # Offsets start at 1, not 0
   my $data = $dbh2->ora_lob_read( $lob_locator, $offset, $chunk_size ) ;
   print "lob: $data \n";

# Close the second connection
$dbh2->disconnect;

# Combine the chunks and process the LOB data
my $lob_content = join("", @data);
