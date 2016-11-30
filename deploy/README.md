# Deployment

A brief guide to how deployment is setup for Mindleaps Tracker.

## Deploying

To deploy you'll need an inventory, e.g:

```
main ansible_host=10.0.0.1 ansible_user=root

[webservers]
main

[databases]
main
```

The deployment expects a DO volume. The device for this volume can be set in
your inventory like so:

```
[databases:vars]
data_volume_device=/dev/disk/by-id/scsi-0DO_Volume_volume-fra1-01
```

## Inventories

Since this is an open source project and we'd like to keep everything in one
place, we keep inventories encrypted. For vault passwords you'll need to speak
to one of the maintainers.

## Roles

 * _**server**_ - Server role is used on all servers, depends on ansible galaxy
   role `kamaln7.swapfile`.
 * _**db**_ - Database role, depends on ansible galaxy role
   `geerlingguy.ansible-role-postgresql`.
 * _**webserver**_ - Web server role, sets up nginx, rvm, the rails server etc.

Ansible galaxy roles have been vendored into `roles/` with the group as a prefix.
