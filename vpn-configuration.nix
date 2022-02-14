
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    openvpn
    networkmanager-openvpn
  ];

  services.openvpn.servers = {

    office = {
      # create /etc/VPN/rise and put vpn.rz01.riseops.at-linux.ovpn there
      #  * delete the lines defining up and down
      #  * insert: auth-user-pass /etc/VPN/rise/cred
      # create a cred file and put usr and pwd in distinct lines
      # start with systemctl start openvpn.rise
      config = ''config /etc/VPN/rise/vpn.rz01.riseops.at-udp1194.ovpn'';
      autoStart = false;
      updateResolvConf = true;
    };

    private = {
      # add line and file:
      # auth-user-pass /etc/VPN/expressVPN/cred
      # config = ''config /etc/VPN/expressVPN/my_expressvpn_austria_udp.ovpn'';
      config = ''config /etc/VPN/mullvard/mullvard_at_vie.conf'';

      # modify the up/down config in the provided conf to point to 
      # /etc/VPN/mullvard/update-resolv-conf

      autoStart = false;
      updateResolvConf = true;
    };

  };


}
