---
title: "Public OR Private Azure Dns"
date: 2022-11-27T12:11:58-07:00
draft: false
---

# tl;dr 
The [code for this project is on github](https://github.com/gwynforthewyn/azure-dns-container/) if you want to figure it out.
Note there are multiple tags, each trying a different config setup.
The only config I could get working was exclusively forwarding to Azure DNS, not using any locally hosted zones.

In the github repo, the bind_container directory contains all the bind configuration. The Terraform and ansible are glue
to get it hosted inside azure, a requirement for forwarding requests to azure itself.

# Project Requirement: Forward DNS Request to An Azure Private Zone That Manages Name Resolution
I have this issue at work where I don't want to host my own DNS zones, so I'd like to let Azure DNS handle it, but I may not use 
public zones may due to a requirement in the NIST Secure DNS docs that you never use a public zone for internal-only names.

## Learnings About Primary/Secondary/Azure Nameserver Behaviour
In the course of this project, I learned:
* A primary nameserver _always_ looks for answers in the zonefile on the file system for the zone it is primary for.
* A secondary nameserver _always_ tries to retrieve from somewhere else a copy of the zone file. If that transfer
is denied, you see a message like this in the logs:
```bash
28-Nov-2022 00:30:50.613 transfer of 'private.azure.playtechnique.io/IN' from 150.171.10.35#53: connected using 150.171.10.35#53
28-Nov-2022 00:30:50.613 transfer of 'private.azure.playtechnique.io/IN' from 150.171.10.35#53: sent request data
28-Nov-2022 00:30:50.629 transfer of 'private.azure.playtechnique.io/IN' from 150.171.10.35#53: received 48 bytes
28-Nov-2022 00:30:50.629 received message from 150.171.10.35#53
;; ->>HEADER<<- opcode: QUERY, status: REFUSED, id:  12887
;; flags: qr; QUESTION: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 0
;; QUESTION SECTION:
;private.azure.playtechnique.io.	IN	AXFR


28-Nov-2022 00:30:50.629 transfer of 'private.azure.playtechnique.io/IN' from 150.171.10.35#53: failed while receiving responses: REFUSED
28-Nov-2022 00:30:50.629 zone private.azure.playtechnique.io/IN: zone transfer finished: REFUSED
```
* The Azure DNS servers _do not support zone transfers_. Because of this, you always delegate control of a zone to them,
and forward queries to them. [This](https://learn.microsoft.com/en-us/azure/dns/dns-faq#does-azure-dns-support-zone-transfers--axfr-ixfr--) is your
reference for that.
* An Azure Private Zone does not exist outside the Azure Virtual Network
* An Azure Private Zone does not publish NS records.
  
## How does a client use a private zone?
### A client in the Azure Virtual Network
a) Create the private zone. Connect it to the client's Virtual Network.

### A client outside the Azure Virtual Network
a) Create the private zone. Connect it to your virtual network.
b) Inside the virtual network, create a DNS server which forwards requests for that private zone to (the magic 168.63.129.16 address)[https://learn.microsoft.com/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16].
c) Outside of your virtual network, add the DNS server to your /etc/resolv.conf.
This is the same setup as in [Microsoft's example](https://github.com/Azure/azure-quickstart-templates/tree/master/demos/dns-forwarder)

## Failed setup: Configure Bind as a primary nameserver, with azure as a forwarding endpoint
For v1 of the project I really tried to make it so that I could serve some requests from my DNS server and some from azure, like this:

![image A bind server serving some requests from a zone file and some requests from a private azure zone](/azure/azure-dns-hypothetical.png)

The bind server's zonefile contained:
* type `primary`
* In the zonefile, an SOA record for private.azure.playtechnique.io
* a set of forwarders defined within that same zone forwarding to (the magic 168.63.129.16 address)[https://learn.microsoft.com/en-us/azure/virtual-network/what-is-ip-address-168-63-129-16].  

I hoped that the primary would see whether it could serve a request for  foo.private.azure.playtechnique.io and if not then
it would query the azure servers. In practice, the zonefile either contains the correct DNS name or the master considers 
there to be no record for that name.

I think I can be forgiven for this misthinking. [RFC 1034 tells us](https://datatracker.ietf.org/doc/html/rfc1034#section-3.7.1):
> Using the query domain name, QTYPE, and QCLASS, the name server looks
for matching RRs.  In addition to relevant records, the name server may
return RRs that point toward a name server that has the desired
information or RRs that are expected to be useful in interpreting the
relevant RRs.  For example, a name server that doesn't have the
requested information may know a name server that does; a name server
that returns a domain name in a relevant RR may also return the RR that
binds that domain name to an address.

However, remember that an Azure Private Zones do not publish their nameservers; you can't get that information, so you
can't forward requests on to those nameservers. You either forward 100% of queries to those nameservers, or nothing. 

This means the primary DNS server I set up never gets a chance to serve an SOA record, so it cannot be considered as having
authority for a subdomain.

I did also find the old bind google group, comp.protocols.dns.bind. One of the first questions/answers had a similar setup
to what I'm proposing here, and the [first response](https://groups.google.com/g/comp.protocols.dns.bind/c/oB7P6ku40sM/m/x1JTxVNYAQAJ)
contains the terse, but congruent, piece of information `forwarding is not used for zone other than "type forward".`

Beautiful.

# Remaining Mystery
![image The response from a DNS query, displayed in the Wireshark gui program. It shows that the standard response contains
the root servers](/azure/standard-dns-query-response.png)

Why does my standard response for an undiscovered A record include the root servers?
