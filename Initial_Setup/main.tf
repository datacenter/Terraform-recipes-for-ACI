#############################################################################
# ACI initial setup - Fabric Essentials                                     #
#                                                                           #
# This plan configures configures many of the essential fabric              #
# configuration elements as defined in variables.tf                         #
#                                                                           #
# Tailor as you see fit. If you remove specific variables because you do    #
# not need them, make sure to also remove those resources from main.tf      #
#############################################################################

terraform {
  required_providers {
    aci = {
      source  = "CiscoDevNet/aci"
      version = "2.5.2"
    }
  }
}

provider "aci" {
  username = var.credentials.apic_username
  password = var.credentials.apic_password
  url      = var.credentials.apic_url
}

resource "aci_mgmt_preference" "mgmtConnectivityPref" {
  interface_pref = var.apic_conn_pref.apic_conn_pref
}

resource "aci_rest_managed" "systemAliasBanner" {
  dn         = "uni/userext/preloginbanner"
  class_name = "aaaPreLoginBanner"
  content = {
    guiTextMessage = var.system_alias_banner.alias
    message        = var.system_alias_banner.apic_banner
    switchMessage  = var.system_alias_banner.switch_banner
  }
}

resource "aci_rest_managed" "systemResponseTime" {
  dn         = "uni/fabric/comm-default/apiResp"
  class_name = "commApiRespTime"
  content = {
    enableCalculation = var.system_response_time.state
    respTimeThreshold = var.system_response_time.resp_threshold
    calcWindow        = var.system_response_time.frequency
    topNRequests      = var.system_response_time.top_slow_requests
  }
}

resource "aci_encryption_key" "key" {
  passphrase                = var.global_aes_encryption.passphrase
  strong_encryption_enabled = var.global_aes_encryption.strong_encryption_enabled
}

resource "aci_rest_managed" "controlPlaneMtu" {
  dn         = "uni/infra/CPMtu"
  class_name = "infraCPMtuPol"
  content = {
    CPMtu = can(var.control_plane_mtu.control_plane_mtu) ? var.control_plane_mtu.control_plane_mtu : null
  }
}

resource "aci_endpoint_loop_protection" "endpointLoopProtection" {
  action   = var.endpoint_controls.ep_loop_protection.action
  admin_st = var.endpoint_controls.ep_loop_protection.state
}

resource "aci_endpoint_controls" "endpointRogueControl" {
  admin_st              = var.endpoint_controls.rogue_ep_control.state
  hold_intvl            = var.endpoint_controls.rogue_ep_control.hold_interval
  rogue_ep_detect_intvl = var.endpoint_controls.rogue_ep_control.detection_interval
  rogue_ep_detect_mult  = var.endpoint_controls.rogue_ep_control.multiplication_factor
}

resource "aci_endpoint_ip_aging_profile" "endpointIpAging" {
  admin_st = var.endpoint_controls.ip_aging.state
}

resource "aci_rest_managed" "fabricWideSettings" {
  dn         = "uni/infra/settings"
  class_name = "infraSetPol"
  content = {
    unicastXrEpLearnDisable    = var.fabric_wide.disable_remote_ep_learn
    enforceSubnetCheck         = var.fabric_wide.enforce_subnet_check
    validateOverlappingVlans   = var.fabric_wide.enforce_epg_vlan_validation
    domainValidation           = var.fabric_wide.enforce_domain_validation
    enableRemoteLeafDirect     = var.fabric_wide.enable_remote_leaf_direct
    opflexpAuthenticateClients = var.fabric_wide.opflex_client_auth
    reallocateGipo             = var.fabric_wide.reallocate_gipo
  }
}

resource "aci_port_tracking" "aciPortTrack" {
  admin_st = var.port_tracking.state
  delay    = var.port_tracking.delay
  minlinks = var.port_tracking.links
}

resource "aci_rest_managed" "systemGIPo" {
  dn         = "uni/infra/systemgipopol"
  class_name = "fmcastSystemGIPoPol"
  content = {
    useConfiguredSystemGIPo = var.system_gipo.use_system_gipo
  }
}

resource "aci_rest_managed" "dateTime" {
  dn         = "uni/fabric/format-default"
  class_name = "datetimeFormat"
  content = {
    displayFormat = var.date_time.format
    tz            = var.date_time.timezone
    showOffset    = var.date_time.offset
  }
}

resource "aci_rest_managed" "coopPol" {
  dn         = "uni/fabric/pol-default"
  class_name = "coopPol"
  content = {
    type = var.coop_group_policy.mode
  }
}

resource "aci_rest_managed" "loadBalancer" {
  dn         = "uni/fabric/lbp-default"
  class_name = "lbpPol"
  content = {
    dlbMode = var.load_balancer.dlb
    pri     = var.load_balancer.dpp
    mode    = var.load_balancer.lb_mode
    hashGtp = var.load_balancer.gtp
  }
}

resource "aci_rest_managed" "ptp" {
  dn         = "uni/fabric/ptpmode"
  class_name = "latencyPtpMode"
  content = {
    state            = var.ptp.state
    systemResolution = var.ptp.resolution
  }
}

resource "aci_rest_managed" "ntp" {
  dn         = "uni/fabric/time-${var.pod_policies.date_time.name}/ntpprov-${var.pod_policies.date_time.ntp.name}"
  class_name = "datetimeNtpProv"
  content = {
    name      = var.pod_policies.date_time.ntp.name
    minPoll   = var.pod_policies.date_time.ntp.min_poll
    maxPoll   = var.pod_policies.date_time.ntp.max_poll
    preferred = var.pod_policies.date_time.ntp.preferred
    descr     = var.pod_policies.date_time.ntp.description
  }
  child {
    rn         = "rsNtpProvToEpg"
    class_name = "datetimeRsNtpProvToEpg"
    content = {
      tDn = "uni/tn-mgmt/mgmtp-default/${var.pod_policies.date_time.ntp.mgmt_epg}"
    }
  }
}

resource "aci_rest_managed" "snmp" {
  dn         = "uni/fabric/snmppol-${var.pod_policies.snmp.name}"
  class_name = "snmpPol"
  content = {
    name = var.pod_policies.snmp.name
    adminSt : var.pod_policies.snmp.state
  }
}


resource "aci_rest_managed" "snmpClientGroup" {
  depends_on = [aci_rest_managed.snmp]
  dn         = "uni/fabric/snmppol-${var.pod_policies.snmp.name}/clgrp-${var.pod_policies.snmp.client_group.name}"
  class_name = "snmpClientGrpP"
  content = {
    name = var.pod_policies.snmp.client_group.name
  }
}

resource "aci_rest_managed" "snmpClientGroupRsEpg" {
  depends_on = [aci_rest_managed.snmpClientGroup]
  dn         = "${aci_rest_managed.snmpClientGroup.dn}/rsepg"
  class_name = "snmpRsEpg"
  content = {
    tDn = "uni/tn-mgmt/mgmtp-default/${var.pod_policies.snmp.client_group.mgmt_epg}"
  }
}

resource "aci_rest_managed" "snmpClientGroupClientP" {
  depends_on = [aci_rest_managed.snmpClientGroup]
  dn         = "${aci_rest_managed.snmpClientGroup.dn}/client-${var.pod_policies.snmp.client_group.client.ip}"
  class_name = "snmpClientP"
  content = {
    name = var.pod_policies.snmp.client_group.client.name
    addr = var.pod_policies.snmp.client_group.client.ip
  }
}

resource "aci_rest_managed" "snmpCommunityPol" {
  depends_on = [aci_rest_managed.snmp]
  dn         = "uni/fabric/snmppol-${var.pod_policies.snmp.name}/community-${var.pod_policies.snmp.community.name}"
  class_name = "snmpCommunityP"
  content = {
    name = var.pod_policies.snmp.community.name
  }
}

resource "aci_rest_managed" "managedAccess" {
  dn         = "uni/fabric/comm-${var.management_access.name}"
  class_name = "commPol"
  content = {
    name = var.management_access.name
  }
}

resource "aci_rest_managed" "managedAccessCommTelnet" {
  depends_on = [aci_rest_managed.managedAccess]
  dn         = "uni/fabric/comm-${var.management_access.name}/telnet"
  class_name = "commTelnet"
  content = {
    adminSt = var.management_access.telnet.state
    port    = var.management_access.telnet.port
  }
}

resource "aci_rest_managed" "managedAccessSsh" {
  depends_on = [aci_rest_managed.managedAccess]
  dn         = "uni/fabric/comm-${var.management_access.name}/ssh"
  class_name = "commSsh"
  content = {
    adminSt      = var.management_access.ssh.state
    port         = var.management_access.ssh.port
    passwordAuth = var.management_access.ssh.password_auth
    sshCiphers   = join(",", var.management_access.ssh.ciphers)
    sshMacs      = join(",", var.management_access.ssh.macs)
  }
}

resource "aci_rest_managed" "managedAccessSshWeb" {
  depends_on = [aci_rest_managed.managedAccess]
  dn         = "uni/fabric/comm-${var.management_access.name}/shellinabox"
  class_name = "commShellinabox"
  content = {
    adminSt = var.management_access.ssh_web.state
  }
}

resource "aci_rest_managed" "managedAccessHttp" {
  depends_on = [aci_rest_managed.managedAccess]
  dn         = "uni/fabric/comm-${var.management_access.name}/http"
  class_name = "commHttp"
  content = {
    adminSt                      = var.management_access.http.state
    port                         = var.management_access.http.port
    redirectSt                   = var.management_access.http.redirect
    accessControlAllowOrigins    = var.management_access.http.allow_origins
    accessControlAllowCredential = var.management_access.http.allow_credentials
    globalThrottleSt             = var.management_access.http.throttle
  }
}

resource "aci_rest_managed" "managedAccessHttps" {
  depends_on = [aci_rest_managed.managedAccess]
  dn         = "uni/fabric/comm-${var.management_access.name}/https"
  class_name = "commHttps"
  content = {
    adminSt                      = var.management_access.https.state
    port                         = var.management_access.https.port
    accessControlAllowOrigins    = var.management_access.https.allow_origins
    accessControlAllowCredential = var.management_access.https.allow_credentials
    sslProtocols                 = join(",", var.management_access.https.ssl_protocols)
    dhParam                      = var.management_access.https.dh_param
    globalThrottleSt             = var.management_access.https.throttle
  }
}

resource "aci_rest_managed" "managedAccessKeyring" {
  depends_on = [aci_rest_managed.managedAccessHttps]
  dn         = "uni/fabric/comm-${var.management_access.name}/https/rsKeyRing"
  class_name = "commRsKeyRing"
  content = {
    tnPkiKeyRingName = var.management_access.https.keyring
  }
}

resource "aci_rest_managed" "sslCiphers" {
  depends_on = [aci_rest_managed.managedAccessHttps]
  for_each   = var.management_access.ssl_ciphers
  dn         = "uni/fabric/comm-${var.management_access.name}/https/cph-${each.key}"
  class_name = "commCipher"
  content = {
    id    = each.key
    state = each.value.state
  }
}

# # This only works on real APICs, not on a simulator
# # resource "aci_isis_domain_policy" "isis" {
# #   mtu                 = var.isis.mtu
# #   redistrib_metric    = var.isis.metric
# #   lsp_fast_flood      = var.isis.lsp_fastflood
# #   lsp_gen_init_intvl  = var.isis.lsp_init
# #   lsp_gen_max_intvl   = var.isis.lsp_max
# #   lsp_gen_sec_intvl   = var.isis.lsp_sec
# #   spf_comp_init_intvl = var.isis.spf_init
# #   spf_comp_max_intvl  = var.isis.spf_max
# #   spf_comp_sec_intvl  = var.isis.spf_sec
# #   isis_level_type     = "l1"
# # }

resource "aci_rest_managed" "globalDns" {
  dn         = "uni/fabric/dnsp-${var.global_dns_policy.dns.name}"
  class_name = "dnsProfile"
  content = {
    name = var.global_dns_policy.dns.name
  }
}

resource "aci_rest_managed" "globalDnsToEpg" {
  depends_on = [aci_rest_managed.globalDns]
  dn         = "uni/fabric/dnsp-${var.global_dns_policy.dns.name}/rsProfileToEpg"
  class_name = "dnsRsProfileToEpg"
  content = {
    tDn = "uni/tn-mgmt/mgmtp-default/${var.global_dns_policy.dns.management}"
  }
}

resource "aci_rest_managed" "globalDnsProvider" {
  depends_on = [aci_rest_managed.globalDns]
  dn         = "uni/fabric/dnsp-${var.global_dns_policy.dns.name}/prov-${var.global_dns_policy.dns.provider.addr}"
  class_name = "dnsProv"
  content = {
    addr      = var.global_dns_policy.dns.provider.addr
    preferred = var.global_dns_policy.dns.provider.preferred
  }
}

resource "aci_rest_managed" "globalDnsDomain" {
  depends_on = [aci_rest_managed.globalDns]
  dn         = "uni/fabric/dnsp-${var.global_dns_policy.dns.name}/dom-${var.global_dns_policy.dns.domain.name}"
  class_name = "dnsDomain"
  content = {
    name      = var.global_dns_policy.dns.domain.name
    isDefault = var.global_dns_policy.dns.domain.default
  }
}

resource "aci_rest_managed" "fabricPodPolicyGroup" {
  dn         = "uni/fabric/funcprof/podpgrp-${var.pod_policy_group.name}"
  class_name = "fabricPodPGrp"
  content = {
    name = var.pod_policy_group.name
  }
}

resource "aci_rest_managed" "fabricPodPolicyGroupSnmp" {
  depends_on = [aci_rest_managed.fabricPodPolicyGroup]
  dn         = "uni/fabric/funcprof/podpgrp-${var.pod_policy_group.name}/rssnmpPol"
  class_name = "fabricRsSnmpPol"
  content = {
    tnSnmpPolName = var.pod_policy_group.snmp
  }
}

resource "aci_rest_managed" "fabricPodPolicyGroupPodPGrpIsisDomP" {
  depends_on = [aci_rest_managed.fabricPodPolicyGroup]
  dn         = "uni/fabric/funcprof/podpgrp-${var.pod_policy_group.name}/rspodPGrpIsisDomP"
  class_name = "fabricRsPodPGrpIsisDomP"
  content = {
    tnIsisDomPolName = var.pod_policy_group.isis
  }
}

resource "aci_rest_managed" "fabricPodPolicyGroupCoop" {
  depends_on = [aci_rest_managed.fabricPodPolicyGroup]
  dn         = "uni/fabric/funcprof/podpgrp-${var.pod_policy_group.name}/rspodPGrpCoopP"
  class_name = "fabricRsPodPGrpCoopP"
  content = {
    tnCoopPolName = var.pod_policy_group.coop
  }
}

resource "aci_rest_managed" "fabricPodPolicyGroupDateTime" {
  depends_on = [aci_rest_managed.fabricPodPolicyGroup]
  dn         = "uni/fabric/funcprof/podpgrp-${var.pod_policy_group.name}/rsTimePol"
  class_name = "fabricRsTimePol"
  content = {
    tnDatetimePolName = var.pod_policy_group.date_time
  }
}

resource "aci_rest_managed" "fabricPodPolicyGroupMacSec" {
  depends_on = [aci_rest_managed.fabricPodPolicyGroup]
  dn         = "uni/fabric/funcprof/podpgrp-${var.pod_policy_group.name}/rsmacsecPol"
  class_name = "fabricRsMacsecPol"
  content = {
    tnMacsecFabIfPolName = var.pod_policy_group.macsec
  }
}

resource "aci_rest_managed" "fabricPodPolicyGroupMgmtAccess" {
  depends_on = [aci_rest_managed.fabricPodPolicyGroup]
  dn         = "uni/fabric/funcprof/podpgrp-${var.pod_policy_group.name}/rsCommPol"
  class_name = "fabricRsCommPol"
  content = {
    tnCommPolName = var.pod_policy_group.management_access
  }
}

resource "aci_rest_managed" "fabricPodProfile" {
  depends_on = [aci_rest_managed.fabricPodPolicyGroup]
  dn         = "uni/fabric/podprof-${var.pod_profile.name}"
  class_name = "fabricPodP"
  content = {
    name = var.pod_profile.name
  }
}

resource "aci_rest_managed" "fabricPodProfileSelector" {
  depends_on = [aci_rest_managed.fabricPodPolicyGroup]
  dn         = "uni/fabric/podprof-${var.pod_profile.name}/pods-${var.pod_profile.selector.name}-typ-${var.pod_profile.selector.type}"
  class_name = "fabricPodS"
  content = {
    name = var.pod_profile.selector.name
    type = var.pod_profile.selector.type
  }
}

resource "aci_rest_managed" "fabricPodProfileSelectorToGrp" {
  depends_on = [aci_rest_managed.fabricPodProfileSelector]
  dn         = "uni/fabric/podprof-${var.pod_profile.name}/pods-${var.pod_profile.selector.name}-typ-${var.pod_profile.selector.type}/rspodPGrp"
  class_name = "fabricRsPodPGrp"
  content = {
    tDn = "uni/fabric/funcprof/podpgrp-${var.pod_profile.selector.pod_policy_group}"
  }
}