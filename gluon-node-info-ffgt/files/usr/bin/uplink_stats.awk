BEGIN{
 ipfam="";
}

/inet/ {
 iptype=$1;
 if(iptype=="inet") {
  split(substr($2, 1, index($2, "/")-1), octet, "\.");
  if((octet[1]==192 && octet[2]==168) || octet[1]==10 || (octet[1]=172 && (octet[2]>=16 && octet[2]<=31))) {iptype="RFC1918";}
  if(octet[1]==100 && (octet[2]>=64 && octet[2]<=127)) {iptype="RFC6598";}
 }
 if(iptype=="inet6") {
  if(substr($2, 1, 2)=="fd") {iptype="ULA";}
 }
 ipfam=sprintf("%s%s%s", iptype, length(ipfam)>0?" ": "", length(ipfam)?ipfam:"");
}

END{
 if(ipfam=="") ipfam="---";
 gsub(" ", ", ", ipfam);
 gsub("inet6", "IPv6", ipfam);
 gsub("inet", "IPv4", ipfam);
 print ipfam;
}
