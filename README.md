# Iblox-DNS-PTR
Finds A records missing matching PTRs and creates them
In order to run this, you will need to meet the following pre-requisites:
Perl 5.8.8 or later
Crypt::SSLeay .51 or later
LWP::UserAgent 5.813 or later
XML::Parser

Ipv6 requires:
Perl 5.14.2 or later
LWP::UserAgent 6.0.2 or later
Net::Inet6Glue
XML::Parser

Grab the Ibox API by going to
https://\<IBLOX-MASTER-IP\>/api/dist/CPAN/authors/id/INFOBLOX
Download the Infoblox-xxxxxxx.tar.gz package
tar -xvzf Infoblox-xxxxxxx.tar.gz
cd Infoblox-xxxxxxx
perl Makefile.PL
make
make install
make test

Note:  You will need root/sudo if you plan to make install against your local system.

This is also available for windows systems, but I do not cover that.  Download the Infoblox API Documentation for more information
