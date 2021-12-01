Content-Type: multipart/mixed; boundary="===============0086047718136476635=="
MIME-Version: 1.0

--===============0086047718136476635==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="config"

config system sdn-connector
	edit AzureSDN
		set type azure
	end
end
config sys global
    set admintimeout 120
    set hostname "${fgt_vm_name}"
    set timezone 26
    set gui-theme mariner
end
config vpn ssl settings
    set port 7443
end
config router static
    edit 1
        set gateway ${fgt_external_gw}
        set device port1
    next
    edit 2
        set dst ${vnet_network}
        set gateway ${fgt_internal_gw}
        set device port2
    next
    edit 3
        set dst 168.63.129.16 255.255.255.255
        set device port2
        set gateway ${fgt_internal_gw}
    next
    edit 4
        set dst 168.63.129.16 255.255.255.255
        set device port1
        set gateway ${fgt_external_gw}
    next
end
config system probe-response
    set http-probe-value OK
    set mode http-probe
end
config system interface
    edit port1
        set mode static
        set ip ${fgt_external_ipaddr}/${fgt_external_mask}
        set description external
        set allowaccess probe-response ping https ssh ftm
    next
    edit port2
        set mode static
        set ip ${fgt_internal_ipaddr}/${fgt_internal_mask}
        set description internal
        set allowaccess probe-response ping https ssh ftm
    next
    edit port3
        set mode static
        set ip ${fgt_middle_ipaddr}/${fgt_middle_mask}
        set description middle
        set allowaccess probe-response ping https ssh ftm
    next
end

config firewall vip
    edit "${prefix}-WEB-1-VM-subnet-${web_subnet_number}"
        set extip ${public_ip_address_elb_ip}
        set mappedip "${web_instance_ip}"
        set extintf "any"
    next
end

config firewall ippool
    edit "port1"
        set startip ${fgt_external_ipaddr}
        set endip ${fgt_external_ipaddr}
    next
end

config firewall policy
    edit 0
        set name "Outbound-Internet"
        set srcintf "port2"
        set dstintf "port1"
        set action accept
        set srcaddr "all"
        set dstaddr "all"
        set schedule "always"
        set service "ALL"
        set logtraffic all        
        set nat enable
        set ippool enable
        set poolname "port1"
    next
    edit 0
        set name "WithIn_VNET"
        set srcintf "port2"
        set dstintf "port2"
        set action accept
        set srcaddr "all"
        set dstaddr "all"
        set schedule "always"
        set service "ALL"
        set logtraffic all
    next
    edit 0
        set name "Inbound-Internet"
        set srcintf "port1"
        set dstintf "port2"
        set action accept
        set srcaddr "all"
        set dstaddr "${prefix}-WEB-1-VM-subnet-${web_subnet_number}"
        set schedule "always"
        set service "ALL"
        set utm-status enable
        set ssl-ssh-profile "certificate-inspection"
        set ips-sensor "default"
        set logtraffic all        
        set nat disable
    next
end

config system api-user
    edit apiadmin
        set api-key "${fgt_api_key}"
        set accprofile "super_admin"
        config trusthost
            edit 0
                set ipv4-trusthost ${my_public_ip} 255.255.255.255
            next
        end
    next
end
%{ if fgt_ssh_public_key != "" }
config system admin
    edit "${fgt_username}"
        set ssh-public-key1 "${trimspace(file(fgt_ssh_public_key))}"
    next
end
%{ endif }
# Uncomment for FGSP to allow assymetric traffic
# Verify the README
config system ha
    set session-pickup enable
    set session-pickup-connectionless enable
    set session-pickup-expectation enable
    set session-pickup-nat enable
    set override disable
end
config system cluster-sync
    edit 0
        set peerip ${fgt_ha_peerip1}
    next
%{ if fgt_ha_peerip2 != "" }
    edit 0
        set peerip ${fgt_ha_peerip2}
    next
%{ endif }
%{ if fgt_ha_peerip3 != "" }
    edit 0
        set peerip ${fgt_ha_peerip3}
    next
%{ endif }
end
%{ if fgt_license_flexvm != "" }
exec vm-license ${fgt_license_flexvm}
%{ endif }

%{ if fgt_license_file != "" }
--===============0086047718136476635==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="${fgt_license_file}"

${file(fgt_license_file)}

%{ endif }
--===============0086047718136476635==--
