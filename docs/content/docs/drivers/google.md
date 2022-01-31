---
title: Google Cloud Platform
menu:
  docs:
    parent: drivers
    weight: 15
---

kitchen-google is a Test Kitchen *driver* for Google Cloud Platform.

## Requirements

### Google Cloud Platform (GCP) Project

A [Google Cloud Platform](https://cloud.google.com) account is
required.  If you do not already have an appropriate "project" in
which to run your test-kitchen instances, create one, noting the
"project id".

### Authentication and Authorization

The [underlying API](https://github.com/google/google-api-ruby-client) this plugin uses relies on the
[Google Auth Library](https://github.com/google/google-auth-library-ruby) to handle authentication to the
Google Cloud API. The auth library expects that there is a JSON credentials file located at:

`~/.config/gcloud/application_default_credentials.json`

The easiest way to create this is to download and install the [Google Cloud SDK](https://cloud.google.com/sdk/) and run the
`gcloud auth application-default login` command which will create the credentials file for you.

If you already have a file you'd like to use that is in a different location, set the
`GOOGLE_APPLICATION_CREDENTIALS` environment variable with the full path to that file.

### SSH Keys

#### Project Level Keys

In order to bootstrap Linux nodes, you will first need to ensure your SSH
keys are set up correctly. Ensure your SSH public key is properly entered
into your project's Metadata tab in the GCP Console. GCE will add your key
to the appropriate user's `~/.ssh/authorized_keys` file when Chef first
connects to perform the bootstrap process.

 * If you don't have one, create a key using `ssh-keygen`
 * Log in to the GCP console, select your project, go to Compute Engine, and go to the Metadata tab.
 * Select the "SSH Keys" tab.
 * Add a new item, and paste in your public key.
    * Note: to change the username automatically detected for the key, prefix your key with the username
      you plan to use to connect to a new instance. For example, if you plan to connect
      as "chefuser", your key should look like: `chefuser:ssh-rsa AAAAB3N...`
 * Click "Save".

Alternatively, the Google Cloud SDK (a.k.a. `gcloud`) will create a SSH key
for you when you create and access your first instance:

 1. Create a small test instance:
    `gcloud compute instances create instance1 --zone us-central1-f --image-family=debian-8 --image-project=debian-cloud --machine-type g1-small`
 1. Ensure your SSH keys allow access to the new instance
    `gcloud compute ssh instance1 --zone us-central1-f`
 1. Log out and delete the instance
    `gcloud compute instances delete instance1 --zone us-central1-f`

You will now have a local SSH keypair, `~/.ssh/google_compute_engine[.pub]` that
will be used for connecting to your GCE Linux instances for this local username
when you use the `gcloud compute ssh` command. You can tell Test Kitchen to use
this key by adding it to the transport section of your .kitchen.yml:

```yaml
transport:
  ssh_key:
    - ~/.ssh/google_compute_engine
```

You can find [more information on configuring SSH keys](https://cloud.google.com/compute/docs/instances/adding-removing-ssh-keys) in
the Google Compute Engine documentation.

#### Instance Level Keys

It is possible to [add keys](https://cloud.google.com/compute/docs/storing-retrieving-metadata#default)
that are not included in the project's metadata to an instance. Do this by
listing additional keys in custom metadata (see below for more about [setting
metadata](#metadata)).

For example, given a workspace that has environment variables set for `USER`
(the username to connect as) and `SSH_KEY` (the path to the private key to use):

```yaml
driver:
  name: gce
  ...
  metadata:
    ssh-keys: <%= ENV['USER'] + ':' + IO.binread("#{ENV['SSH_KEY']}.pub").rstrip! %>

transport:
  username: <%= ENV['USER'] %>
  ssh_key: <%= ENV['SSH_KEY'] %>
```

## Example **kitchen.yml**

```yaml
---
driver:
  name: gce
  project: mycompany-test
  zone: us-east1-c
  email: me@mycompany.com
  tags:
    - devteam
    - test-kitchen
  service_account_scopes:
    - devstorage.read_write
    - userinfo.email

provisioner:
  name: chef_infra

verifier:
  name: inspec

transport:
  username: chefuser

platforms:
  - name: centos-7
    driver:
      image_project: centos-cloud
      image_name: centos-7-v20170124
      metadata:
        application: centos
        release: a
        version: 7
  - name: ubuntu-16.04
    driver:
      image_project: ubuntu-os-cloud
      image_family: ubuntu-1604-lts
      metadata:
        application: ubuntu
        release: a
        version: 1604
  - name: windows
    driver:
      image_project: windows-cloud
      image_name: windows-server-2012-r2-dc-v20170117
      disk_size: 50
      metadata:
        application: windows
        release: a
        version: cloud

suites:
  - name: default
    run_list:
      - recipe[my_cookbook::default]
    attributes:
```
