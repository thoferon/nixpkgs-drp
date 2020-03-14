drp.start()

drp.wait_for_unit("network.target")
drp.wait_for_unit("docker-drp.service")

drp.wait_for_open_port(8091)
output = drp.wait_until_succeeds("curl 127.0.0.1:8091")
match = re.search("lxpelinux.0", output)
if not match:
    raise Exception("Can't find lpxelinux.0 in file list")
