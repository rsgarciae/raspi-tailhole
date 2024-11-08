# Raspi-Tail-Hole
A simple tailscale pi-hole automated setup for debian based OS, tested on Raspbery Pi 3/4 and Raspberry Pi OS Lite (64-bit) (Debian Bookworm)

## Tailscale configuration 

## NOTE: 
This requires you to connect your raspberry pi to the ethernet cable in order to work properly.

## Pre-requisites
Before starting review [Log into tailscale](#log-into-tailscale), [Enable device approval](#enable-device-approval), [Configure OAUTH](#configure-oauth) and [configure ACL's](#configure-acls) sections follow those steps. 

## Log into tailscale 

[Log into tailscale or create your account] (https://tailscale.com/login)
once you create your account, you can add your devices such as your phone.

## Enable device approval
![https://login.tailscale.com/admin/settings/device-management](https://github.com/rsgarciae/raspi-tailhole/blob/main/images/device_approval.png?raw=true)

## Configure OAUTH
To generate OAUTH token you require to login into your tailscale account and go to [oauth-token creation](https://login.tailscale.com/admin/settings/oauth) then generate your own token with all permisons required, or additionally generate with your custom scope (at least you require permissons to create auth tokens)
set your client_id and client_secret environment variables in your raspberry.

```bash
echo "export TS_API_CLIENT_ID=<REPLACE_ME_WITH_YOUR_CLIENT_ID> " >> ~/.profile
echo "export TS_API_CLIENT_SECRET=<REPLACE_ME_WITH_YOUR_CLIENT_SECRET> " >> ~/.profile
source ~/.profile
```
## Configure ACL's
Add [sample_acl.json](sample_acl.json) to tailscale acls, to allow auto approve subnet routes and exit nodes

## Tailscale initial configuration
To configure your raspberry pi to use tailscale run the following command.

```bash
curl -sL https://raw.githubusercontent.com/rsgarciae/raspi-tailhole/main/bin/start.sh | bash -s -- NETWORK_RANGE=<REPLACEME_WITH_YOUR_SUBNET_RANGE>
```
this will

 1.- Enable vnc on your raspberry pi.

 2.- Set your raspberry static ip using the current ip of your device.

 3.- Enable ip forwarding.

 4.- Install necesary dependencies(packages, docker and go)

 5.- Use Oauth to automate auth token generation, automatically it will create a new docker container with a fresh token, and this will be executed each 90 days (when token expires).


## Pi-Hole initial configuration

[Customize wiht the Env vars you need](https://github.com/pi-hole/docker-pi-hole/blob/master/README.md#environment-variables)

### Replacing varibales 

DHCP variables can be found under your router admin page, this configuration is usually under settings -> LAN -> DHCP
there you will se start and end address range,

FTLCONF_LOCAL_IPV4 varibale can be replaced with your raspberry pi static ip 


```bash
docker run -d \
    --name pihole \
    -p 53:53/tcp -p 53:53/udp \
    -p 80:80 \
    -p "67:67/udp" \
    -v "${PIHOLE_BASE}/etc-pihole:/etc/pihole" \
    -v "${PIHOLE_BASE}/etc-dnsmasq.d:/etc/dnsmasq.d" \
    -e TZ="America/Monterrey" \
    -e VIRTUAL_HOST="pi.hole" \
    -e PROXY_LOCATION="pi.hole" \
    -e PIHOLE_DNS_="1.1.1.1;1.0.0.1" \
    -e DNSSEC=true \
    -e DHCP_ACTIVE=true \
    -e DHCP_START="<REPLACE_ME_WITH_START_IP>" \
    -e DHCP_END="<REPLACE_ME_WITH_END_IP>" \
    -e DHCP_ROUTER="<REPLACE_ME_WITH_ROUTER_IP>" \
    -e FTLCONF_LOCAL_IPV4="<REPLACE_WITH_STATIC_IP>" \
    -e WEBPASSWORD=admin \
    -e QUERY_LOGGING=true \
    -e WEBTHEME="default-darker" \
    -e WEB_PORT=80 \
    --dns=127.0.0.1 --dns=1.1.1.1 \
    --restart=unless-stopped \
    --network=host \
    --hostname=pi.hole \
    --cap-add=NET_ADMIN \
    pihole/pihole:2024.07.0
```

## DHCP configuration
To use your raspberry pi as DHCP you will need to configure your router to use your raspberry as dhcp server.
Todo so go to your router admin page, this configuration is ussually under settings -> LAN -> DHCP.
use your raspberry pi static address as only DNS server 

## Thanks for your support !

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://buymeacoffee.com/rsgarciae)
