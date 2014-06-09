# <a name="title"></a> Kitchen::Ec2: A Test Kitchen Driver for Amazon EC2

[![Gem Version](https://badge.fury.io/rb/kitchen-ec2.png)](http://badge.fury.io/rb/kitchen-ec2)
[![Build Status](https://travis-ci.org/test-kitchen/kitchen-ec2.png)](https://travis-ci.org/test-kitchen/kitchen-ec2)
[![Code Climate](https://codeclimate.com/github/test-kitchen/kitchen-ec2.png)](https://codeclimate.com/github/test-kitchen/kitchen-ec2)

A [Test Kitchen][kitchenci] Driver for Amazon EC2.

This driver uses the [fog gem][fog_gem] to provision and destroy EC2
instances. Use Amazon's cloud for your infrastructure testing!

## <a name="requirements"></a> Requirements

There are **no** external system requirements for this driver. However you
will need access to an [AWS][aws_site] account.

## <a name="installation"></a> Installation and Setup

Please read the [Driver usage][driver_usage] page for more details.

## <a name="default-config"></a> Default Configuration

This driver can determine AMI and username login for a select number of
platforms in each region. Currently, the following platform names are
supported:

```ruby
---
platforms:
  - name: ubuntu-10.04
  - name: ubuntu-12.04
  - name: ubuntu-12.10
  - name: ubuntu-13.04
  - name: centos-6.4
  - name: debian-7.1.0
```

This will effectively generate a configuration similar to:

```ruby
---
platforms:
  - name: ubuntu-10.04
    driver:
      image_id: ami-1ab3ce73
      username: ubuntu
  - name: ubuntu-12.04
    driver:
      image_id: ami-2f115c46
      username: ubuntu
  # ...
  - name: centos-6.4
    driver:
      image_id: ami-bf5021d6
      username: root
  # ...
```

For specific default values, please consult [amis.json][amis_json].

## <a name="config"></a> Configuration

### <a name="config-az"></a> availability\_zone

**Required** The AWS [availability zone][region_docs] to use.

The default is `"us-east-1b"`.

### <a name="config-aws-access-key-id"></a> aws\_access\_key\_id

**Required** The AWS [access key id][credentials_docs] to use.

The default will be read from the `AWS_ACCESS_KEY` environment variable if set,
or `nil` otherwise.

### <a name="config-aws-secret-access-key"></a> aws\_secret\_access\_key

**Required** The AWS [secret access key][credentials_docs] to use.

The default will be read from the `AWS_SECRET_KEY` environment variable if set,
or `nil` otherwise.

### <a name="config-aws-ssh-key-id"></a> aws\_ssh\_key\_id

**Required** The EC2 [SSH key id][key_id_docs] to use.

The default will be read from the `AWS_SSH_KEY_ID` environment variable if set,
or `nil` otherwise.

### <a name="config-aws-session-token"></a> aws\_session\_token

The AWS [session token][credentials_docs] to use.

The default will be read from the `AWS_SESSION_TOKEN` environment variable if set,
or `nil` otherwise.

### endpoint

The API endpoint for executing EC2 commands.

The default will be computed from the AWS region name for the instance.

### <a name="config-flavor-id"></a> flavor\_id

The EC2 [instance type][instance_docs] (also known as size) to use.

The default is `"m1.small"`.

### <a name="config-ebs-optimized"></a> ebs\_optimized

Option to launch EC2 instance with optimized EBS volume. See
[Amazon EC2 Instance Types](http://aws.amazon.com/ec2/instance-types/) to find
out more about instance types that can be launched as EBS-optimized instances.

The default is `false`.

### <a name="config-security-group-ids"></a> security_group_ids

An Array of EC2 [security groups][group_docs] which will be applied to the
instance.

The default is `["default"]`.

### <a name="config-image-id"></a> image\_id

**Required** The EC2 [AMI id][ami_docs] to use.

The default will be determined by the `aws_region` chosen and the Platform
name, if a default exists (see [amis.json][ami_json]). If a default cannot be
computed, then the default is `nil`.

### <a name="config-port"></a> port

The SSH port number to be used when communicating with the instance.

The default is `22`.

### <a name="interface"></a> interface

The place from which to derive the hostname for communicating with the instance.  May be `dns`, `public` or `private`.  If this is unset, the driver will derive the hostname by failing back in the following order:

1. DNS Name
2. Public IP Address
3. Private IP Address

The default is unset.


### <a name="config-region"></a> region

**Required** The AWS [region][region_docs] to use.

The default is `"us-east-1"`.

### <a name="config-ssh-key"></a> ssh\_key

Path to the private SSH key used to connect to the instance.

The default is unset, or `nil`.

### <a name="config-subnet-id"></a> subnet\_id

The EC2 [subnet][subnet_docs] to use.

The default is unset, or `nil`.

### <a name="config-tags"></a> tags

The Hash of EC tag name/value pairs which will be applied to the instance.

The default is `{ "created-by" => "test-kitchen" }`.

### <a name="config-username"></a> username

The SSH username that will be used to communicate with the instance.

The default will be determined by the Platform name, if a default exists (see
[amis.json][amis_json]). If a default cannot be computed, then the default is
`"root"`.

### <a name="config-iam-profile-name"></a> iam\_profile\_name

The EC2 IAM profile name to use.

The default is `nil`.

## <a name="example"></a> Example

The following could be used in a `.kitchen.yml` or in a `.kitchen.local.yml`
to override default configuration.

```yaml
---
driver:
  name: ec2
  aws_access_key_id: KAS...
  aws_secret_access_key: 3UK...
  aws_ssh_key_id: id_rsa-aws
  ssh_key: /path/to/id_rsa-aws
  security_group_ids: ["sg-1a2b3c4d"]
  region: us-east-1
  availability_zone: us-east-1b
  require_chef_omnibus: true
  subnet_id: subnet-6d6...
  iam_profile_name: chef-client

platforms:
  - name: ubuntu-12.04
    driver:
      image_id: ami-fd20ad94
      username: ubuntu
  - name: centos-6.3
    driver:
      image_id: ami-ef5ff086
      username: ec2-user

suites:
# ...
```

Both `.kitchen.yml` and `.kitchen.local.yml` files are pre-processed through
ERB which can help to factor out secrets and credentials. For example:

```yaml
---
driver:
  name: ec2
  aws_access_key_id: <%= ENV['AWS_ACCESS_KEY'] %>
  aws_secret_access_key: <%= ENV['AWS_SECRET_KEY'] %>
  aws_ssh_key_id: <%= ENV['AWS_SSH_KEY_ID'] %>
  ssh_key: <%= File.expand_path('~/.ssh/id_rsa') %>
  security_group_ids: ["sg-1a2b3c4d"]
  region: us-east-1
  availability_zone: us-east-1b
  require_chef_omnibus: true

platforms:
  - name: ubuntu-12.04
    driver:
      image_id: ami-fd20ad94
      username: ubuntu
  - name: centos-6.3
    driver:
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
[issues]:           https://github.com/test-kitchen/kitchen-ec2/issues
[license]:          https://github.com/test-kitchen/kitchen-ec2/blob/master/LICENSE
[repo]:             https://github.com/test-kitchen/kitchen-ec2
[driver_usage]:     http://docs.kitchen-ci.org/drivers/usage
[chef_omnibus_dl]:  http://www.getchef.com/chef/install/

[amis_json]:        https://github.com/test-kitchen/kitchen-ec2/blob/master/data/amis.json
[ami_docs]:         http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ComponentsAMIs.html
[aws_site]:         http://aws.amazon.com/
[credentials_docs]: http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/SettingUp_CommandLine.html#using-credentials-access-key
[fog_gem]:          http://fog.io/
[group_docs]:       http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-network-security.html
[instance_docs]:    http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html
[key_id_docs]:      http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/verifying-your-key-pair.html
[kitchenci]:        http://kitchen.ci/
[region_docs]:      http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html
[subnet_docs]:      http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ec2-subnet.html
