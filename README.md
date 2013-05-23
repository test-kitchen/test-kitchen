# <a name="title"></a> Kitchen::Ec2: A Test Kitchen Driver for Amazon EC2

[![Gem Version](https://badge.fury.io/rb/kitchen-ec2.png)](http://badge.fury.io/rb/kitchen-ec2)
[![Build Status](https://travis-ci.org/opscode/kitchen-ec2.png)](https://travis-ci.org/opscode/kitchen-ec2)
[![Code Climate](https://codeclimate.com/github/opscode/kitchen-ec2.png)](https://codeclimate.com/github/opscode/kitchen-ec2)

A Test Kitchen Driver for Amazon EC2.

This driver uses the [fog gem][fog_gem] to provision and destroy EC2
instances. Use Amazon's cloud for your infrastructure testing!

## <a name="requirements"></a> Requirements

There are **no** external system requirements for this driver. However you
will need access to an [AWS][aws_site] account.

## <a name="installation"></a> Installation and Setup

Please read the [Driver usage][driver_usage] page for more details.

## <a name="config"></a> Configuration

### <a name="config-az"></a> availability\_zone

**Required** The AWS [availability zone][region_docs] to use.

The default is `"us-east-1b"`.

### <a name="config-aws-access-key-id"></a> aws\_access\_key\_id

**Required** The AWS [access key id][credentials_docs] to use.

The default is unset, or `nil`.

### <a name="config-aws-secret-access-key"></a> aws\_secret\_access\_key

**Required** The AWS [secret access key][credentials_docs] to use.

The default is unset, or `nil`.

### <a name="config-aws-ssh-key-id"></a> aws\_ssh\_key\_id

**Required** The EC2 [SSH key id][key_id_docs] to use.

The default is unset, or `nil`.

### <a name="config-flavor-id"></a> flavor\_id

The EC2 [instance type][instance_docs] (also known as size) to use.

The default is `"m1.small"`.

### <a name="config-groups"></a> groups

An Array of EC [security groups][group_docs] which will be applied to the
instance.

The default is `["default"]`.

### <a name="config-image-id"></a> image\_id

**Required** The EC2 [AMI id][ami_docs] to use.

The default is unset, or `nil`.

### <a name="config-port"></a> port

The SSH port number to be used when communicating with the instance.

The default is `22`.

### <a name="config-region"></a> region

**Required** The AWS [region][region_docs] to use.

The default is `"us-east-1"`.

### <a name="config-require-chef-omnibus"></a> require\_chef\_omnibus

Determines whether or not a Chef [Omnibus package][chef_omnibus_dl] will be
installed. There are several different behaviors available:

* `true` - the latest release will be installed. Subsequent converges
  will skip re-installing if chef is present.
* `latest` - the latest release will be installed. Subsequent converges
  will always re-install even if chef is present.
* `<VERSION_STRING>` (ex: `10.24.0`) - the desired version string will
  be passed the the install.sh script. Subsequent converges will skip if
  the installed version and the desired version match.
* `false` or `nil` - no chef is installed.

The default value is unset, or `nil`.

### <a name="config-ssh-key"></a> ssh\_key

Path to the private SSH key used to connect to the instance.

The default is unset, or `nil`.

### <a name="config-subnet-id"></a> subnet\_id

The EC2 [subnet][subnet_docs] to use.

The default is unset, or `nil`.

### <a name="config-sudo"></a> sudo

Whether or not to prefix remote system commands such as installing and
running Chef with `sudo`.

The default is `true`.

### <a name="config-tags"></a> tags

The Hash of EC tag name/value pairs which will be applied to the instance.

The default is `{ "created-by" => "test-kitchen" }`.

### <a name="config-username"></a> username

The SSH username that will be used to communicate with the instance.

The default is `"root"`.

## <a name="example"></a> Example

The following could be used in a `.kitchen.yml` or in a `.kitchen.local.yml`
to override default configuration.

```yaml
---
driver_plugin: ec2
driver_config:
  aws_access_key_id: KAS...
  aws_secret_access_key: 3UK...
  aws_ssh_key_id: id_rsa-aws
  ssh_key: /path/to/id_rsa-aws
  region: us-east-1
  availability_zone: us-east-1b
  require_chef_omnibus: true
  subnet_id: subnet-6d6...

platforms:
- name: ubuntu-12.04
  driver_config:
    image_id: ami-fd20ad94
    username: ubuntu
- name: centos-6.3
  driver_config:
    image_id: ami-ef5ff086
    username: ec2-user

suites:
# ...
```

Both `.kitchen.yml` and `.kitchen.local.yml` files are pre-processed through
ERB which can help to factor out secrets and credentials. For example:

```yaml
---
driver_plugin: ec2
driver_config:
  aws_access_key_id: <%= ENV['AWS_ACCESS_KEY_ID'] %>
  aws_secret_access_key: <%= ENV['AWS_SECRET_ACCESS_KEY'] %>
  aws_ssh_key_id: <%= ENV['AWS_SSH_KEY_ID'] %>
  ssh_key: <%= File.expand_path('~/.ssh/id_rsa') %>
  region: us-east-1
  availability_zone: us-east-1b
  require_chef_omnibus: true

platforms:
- name: ubuntu-12.04
  driver_config:
    image_id: ami-fd20ad94
    username: ubuntu
- name: centos-6.3
  driver_config:
    image_id: ami-ef5ff086
    username: ec2-user

suites:
# ...
```

## <a name="development"></a> Development

* Source hosted at [GitHub][repo]
* Report issues/questions/feature requests on [GitHub Issues][issues]

Pull requests are very welcome! Make sure your patches are well tested.
Ideally create a topic branch for every separate change you make. For
example:

1. Fork the repo
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## <a name="authors"></a> Authors

Created and maintained by [Fletcher Nichol][author] (<fnichol@nichol.ca>)

## <a name="license"></a> License

Apache 2.0 (see [LICENSE][license])


[author]:           https://github.com/fnichol
[issues]:           https://github.com/opscode/kitchen-ec2/issues
[license]:          https://github.com/opscode/kitchen-ec2/blob/master/LICENSE
[repo]:             https://github.com/opscode/kitchen-ec2
[driver_usage]:     http://docs.kitchen-ci.org/drivers/usage
[chef_omnibus_dl]:  http://www.opscode.com/chef/install/

[ami_docs]:         http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ComponentsAMIs.html
[aws_site]:         http://aws.amazon.com/
[credentials_docs]: http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/SettingUp_CommandLine.html#using-credentials-access-key
[fog_gem]:          http://fog.io/
[group_docs]:       http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-network-security.html
[instance_docs]:    http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html
[key_id_docs]:      http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/verifying-your-key-pair.html
[region_docs]:      http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html
[subnet_docs]:      http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-subnet.html
