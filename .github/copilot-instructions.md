# GitHub Copilot Instructions for Chef Test Kitchen Enterprise

## 🏗️ Repository Overview & Structure

**Chef Test Kitchen Enterprise** is a Ruby-based integration testing tool for developing and testing infrastructure code (particularly Chef cookbooks) on isolated target platforms. This is an enterprise fork of the open-source Test Kitchen project, maintained by Chef Software.

### Core Purpose
Test Kitchen provides a test harness to execute infrastructure code on one or more platforms in isolation. It creates, configures, tests, and destroys virtual machines and containers through a plugin-based architecture.

### Repository Structure Diagram
```
chef-test-kitchen-enterprise/
├── .expeditor/                   # Build automation & CI/CD configuration
│   ├── config.yml               # Main Expeditor configuration
│   ├── verify.pipeline.yml      # PR verification pipeline
│   └── *.sh, *.ps1              # Build scripts for Linux/Windows
├── .github/                     # GitHub-specific files
│   └── copilot-instructions.md  # This file
├── accessibility/               # Accessibility testing utilities
├── bin/
│   └── kitchen                  # Main CLI executable
├── coverage/                    # Test coverage reports
├── docs/                        # Hugo-based documentation site
├── examples/                    # Kitchen configuration examples
├── features/                    # Cucumber integration tests
│   ├── *.feature              # Cucumber feature files
│   └── step_definitions/       # Test step implementations
├── habitat/                     # Habitat package configuration
├── lib/                         # Main Ruby source code
│   ├── kitchen.rb              # Main module entry point
│   └── kitchen/                # Core library modules
│       ├── command/            # CLI command implementations
│       ├── driver/             # Infrastructure drivers (Vagrant, Docker, etc.)
│       ├── provisioner/        # Provisioners (Chef, Shell, etc.)
│       ├── transport/          # Transport layers (SSH, WinRM, etc.)
│       ├── verifier/           # Test frameworks (InSpec, etc.)
│       └── version.rb          # Version definition
├── spec/                        # RSpec/Minitest unit tests
│   ├── spec_helper.rb          # Test configuration
│   └── kitchen/                # Test files mirroring lib structure
├── support/                     # Installation scripts and helpers
├── templates/                   # Project scaffolding templates
├── test/                        # Integration test cookbooks
├── testing/                     # Test configurations
├── tmp/                         # Temporary build artifacts
├── chef-test-kitchen-enterprise.gemspec  # Gem specification
├── Gemfile                     # Ruby dependencies
├── kitchen.yml                 # Default Test Kitchen configuration
├── Rakefile                    # Build automation tasks
└── README.md                   # Project documentation
```

## 🛠️ Technology Stack & Languages

### Primary Technologies
- **Language**: Ruby (3.1+ required)
- **Testing Frameworks**: 
  - Minitest for unit tests (`spec/` directory)
  - Cucumber for integration tests (`features/` directory)
  - Chef InSpec for verification testing
- **Build System**: Rake with custom tasks
- **Documentation**: Hugo static site generator
- **Packaging**: RubyGems with Habitat for containerized distribution
- **CI/CD**: Expeditor with Buildkite pipelines

### Key Dependencies
- `mixlib-shellout`: Command execution
- `net-ssh`, `winrm`: Transport protocols
- `thor`: CLI framework
- `chef-utils`, `chef-licensing`: Chef ecosystem integration
- `berkshelf`: Cookbook dependency management

## 🔄 Development Workflow Integration

### Phase-Based Development Process

#### Phase 1: Initial Setup & Analysis
**Prompt**: "Let me analyze the Jira issue and repository to plan the implementation."

**Tasks**:
1. **Jira Analysis** (if Jira ID provided):
   - Use atlassian-mcp-server to fetch issue details
   - Read story requirements and acceptance criteria
   - Identify affected components and dependencies

2. **Repository Analysis**:
   - Examine current codebase structure
   - Identify related files and modules
   - Review existing tests and patterns

3. **Implementation Planning**:
   - Break down requirements into smaller tasks
   - Identify files to create/modify
   - Plan test strategy and coverage approach
   - Estimate complexity and dependencies

**Approval Gate**: "I've analyzed the requirements and created an implementation plan. The changes will affect [X files] and require [Y new tests]. Do you want me to continue with the implementation phase?"

#### Phase 2: Implementation Phase
**Prompt**: "I'll implement the required changes following Test Kitchen patterns and conventions."

**Tasks**:
1. **Core Implementation**:
   - Create/modify Ruby classes following existing patterns
   - Implement proper error handling and logging
   - Follow Test Kitchen plugin architecture
   - Add configuration options and validation

2. **Documentation Updates**:
   - Update inline code documentation
   - Add/modify configuration examples
   - Update CLI help text if needed

**Approval Gate**: "Implementation is complete. I've modified [X files] and added [Y features]. Do you want me to continue with the testing phase?"

#### Phase 3: Testing Phase (CRITICAL - Hard Requirement)
**Prompt**: "I'll create comprehensive tests to ensure >80% coverage and validate all functionality."

**Tasks**:
1. **Unit Test Creation** (MANDATORY):
   - Create Minitest-based unit tests in `spec/` directory
   - Test positive and negative scenarios
   - Mock external dependencies using Mocha
   - Ensure >80% test coverage (NON-NEGOTIABLE)

2. **Integration Test Creation**:
   - Add Cucumber features if needed (`features/` directory)
   - Create test fixtures and data
   - Test end-to-end workflows

3. **Test Execution & Validation**:
   - Run test suite: `bundle exec rake test`
   - Validate coverage: `bundle exec rake stats`
   - Fix any failing tests immediately

**Coverage Requirements** (CRITICAL):
- **Minimum 80% test coverage is MANDATORY**
- **All public methods must have tests**
- **Error paths must be tested**
- **Configuration validation must be tested**

**Approval Gate**: "All tests are passing with [X]% coverage (>80% required). [Y] new tests were added covering all scenarios. Do you want me to continue with PR creation?"

#### Phase 4: Pull Request Creation
**Prompt**: "I'll create a properly formatted pull request with all documentation and commit the changes."

**Tasks**:
1. **Git Operations**:
   - Create feature branch: `git checkout -b <JIRA_ID>`
   - Stage changes: `git add .`
   - Commit with DCO: `git commit --signoff -m "<JIRA_ID>: description"`
   - Push branch: `git push origin <JIRA_ID>`

2. **Pull Request Creation**:
   - Use GH CLI: `gh pr create --title "..." --body "..."`
   - Add appropriate labels from available repository labels
   - Include comprehensive HTML-formatted description

**Final Approval**: "Pull request created successfully. All phases completed with proper testing coverage and documentation."

## 🧪 Testing Requirements (CRITICAL)

### Coverage Requirements
- **>80% test coverage is MANDATORY and NON-NEGOTIABLE**
- **Every public method must have corresponding tests**
- **All error conditions must be tested**
- **Configuration validation must be thoroughly tested**

### Ruby Testing Patterns

#### Minitest Unit Tests (Primary)
```ruby
require_relative "../../spec_helper"
require "kitchen/your_module"

describe Kitchen::YourModule do
  let(:logged_output) { StringIO.new }
  let(:logger) { Logger.new(logged_output) }
  let(:config) { { test_base_path: "/test", kitchen_root: "/root" } }
  
  let(:instance) do
    stub(
      name: "test-instance",
      logger: logger,
      suite: stub(name: "default"),
      platform: stub(os_type: "unix")
    )
  end

  let(:subject) { Kitchen::YourModule.new(config).finalize_config!(instance) }

  describe "configuration" do
    it "has default values" do
      _(subject.config[:some_option]).must_equal "expected_value"
    end

    it "validates required options" do
      config.delete(:required_option)
      _(proc { subject }).must_raise Kitchen::UserError
    end
  end

  describe "#public_method" do
    it "returns expected result" do
      result = subject.public_method("input")
      _(result).must_equal "expected_output"
    end

    it "handles error conditions" do
      _(proc { subject.public_method(nil) }).must_raise ArgumentError
    end
  end

  describe "logging" do
    it "logs informational messages" do
      subject.some_action
      _(logged_output.string).must_match(/Expected log message/)
    end
  end
end
```

#### Cucumber Integration Tests
```gherkin
Feature: Kitchen Command Functionality
  Scenario: Running kitchen test command
    Given a test cookbook
    When I run `kitchen test`
    Then the exit status should be 0
    And the output should contain "Kitchen is finished"
```

### Test Execution Commands
```bash
# Run all tests
bundle exec rake test

# Run only unit tests
bundle exec rake unit

# Run only integration tests
bundle exec rake features

# Check code coverage and stats
bundle exec rake stats

# Run style checks
bundle exec rake style

# Run all quality checks
bundle exec rake quality
```

### Coverage Verification
```bash
# Generate coverage report
bundle exec rake test
open coverage/index.html  # View detailed coverage report

# Check coverage percentage
bundle exec rake stats    # Shows LOC and coverage metrics
```

## 📝 Pull Request Creation Process

### Git Workflow with DCO Compliance
```bash
# Create and switch to feature branch (use Jira ID as branch name)
git checkout -b PROJ-123

# Stage all changes
git add .

# Commit with DCO signoff (REQUIRED)
git commit --signoff -m "PROJ-123: Add new provisioner functionality

- Implement XYZ provisioner with configuration validation
- Add comprehensive unit tests with >80% coverage
- Update documentation and examples"

# Push to remote
git push origin PROJ-123

# Create pull request with GH CLI
gh pr create \
  --title "PROJ-123: Add new provisioner functionality" \
  --body "$(cat <<EOF
<h2>Summary</h2>
<p>This PR implements a new XYZ provisioner for Test Kitchen with comprehensive configuration validation and error handling.</p>

<h2>Jira Ticket</h2>
<p><a href="https://yourorg.atlassian.net/browse/PROJ-123">PROJ-123: Implement XYZ Provisioner</a></p>

<h2>Changes Made</h2>
<ul>
<li>Added new XYZ provisioner class with full configuration support</li>
<li>Implemented validation for all required configuration options</li>
<li>Added comprehensive error handling and user-friendly error messages</li>
<li>Created extensive unit test suite with >80% coverage</li>
<li>Updated documentation and configuration examples</li>
</ul>

<h2>Testing Performed</h2>
<ul>
<li>Unit tests: 45 new tests added, 87% coverage achieved</li>
<li>Integration tests: All existing tests pass</li>
<li>Manual testing: Validated on Ubuntu 20.04 and Windows Server 2019</li>
</ul>

<h2>Files Modified</h2>
<ul>
<li><code>lib/kitchen/provisioner/xyz.rb</code> - New provisioner implementation</li>
<li><code>spec/kitchen/provisioner/xyz_spec.rb</code> - Comprehensive unit tests</li>
<li><code>templates/init/kitchen.yml.erb</code> - Updated template</li>
<li><code>docs/content/docs/provisioners/xyz.md</code> - Documentation</li>
</ul>
EOF
)" \
  --label "enhancement" \
  --label "ruby"
```

### DCO (Developer Certificate of Origin) Compliance

**CRITICAL**: All commits MUST include DCO signoff or builds will fail.

#### Required Git Commands
```bash
# Always commit with signoff
git commit --signoff -m "Your commit message"
# OR
git commit -s -m "Your commit message"

# If you forget signoff, amend the commit
git commit --amend --signoff --no-edit

# For multiple commits, rebase and sign all
git rebase --exec 'git commit --amend --signoff --no-edit' HEAD~3
```

#### DCO Requirements
- Every commit must be signed off with your real name and email
- Signoff certifies you have rights to submit the code under project license
- Missing signoff will cause build failures in CI/CD pipeline

## 🏗️ Build System Integration (Expeditor)

### Available Expeditor Labels (Repository-Specific)
- **Expeditor: Skip All** - Skip all merge actions (use for documentation-only changes)
- **Expeditor: Skip Version Bump** - Skip version bumping (use for test-only changes)
- **Expeditor: Skip Changelog** - Skip changelog updates (use sparingly)
- **Expeditor: Skip Habitat** - Skip Habitat package builds
- **Expeditor: Skip Omnibus** - Skip Omnibus package builds
- **Expeditor: Bump Version Minor** - Force minor version bump
- **Expeditor: Bump Version Major** - Force major version bump

### Label Selection Guide
| Change Type | Recommended Labels |
|-------------|-------------------|
| New feature | `enhancement`, `ruby`, `Expeditor: Bump Version Minor` |
| Bug fix | `bug`, `ruby` |
| Documentation only | `documentation`, `Expeditor: Skip All` |
| Test improvements | `ruby`, `Expeditor: Skip Version Bump` |
| Dependency updates | `dependencies`, `ruby` |
| Breaking changes | `enhancement`, `ruby`, `Expeditor: Bump Version Major` |

### Build Channels
- **unstable**: All builds go here first
- **chef-dke-lts2024**: Production channel for Chef Desktop Experience

### Release Process
1. PR merged to main → automatic version bump (unless skipped)
2. Version bump → triggers Habitat build
3. Habitat build → promotes to unstable channel
4. Manual promotion → moves to chef-dke-lts2024 channel

## 🎯 Repository-Specific Guidelines

### File Modification Guidelines

#### Safe to Modify
- `lib/kitchen/**/*.rb` - Core library files
- `spec/**/*.rb` - Unit and integration tests
- `features/**/*` - Cucumber features and steps
- `examples/**/*` - Configuration examples
- `docs/content/**/*` - Documentation content
- `templates/**/*` - Project scaffolding templates

#### Modify with Caution
- `kitchen.yml` - Default configuration (affects CI)
- `Gemfile` - Dependencies (may affect compatibility)
- `chef-test-kitchen-enterprise.gemspec` - Gem specification
- `Rakefile` - Build tasks

#### Prohibited Modifications
- `lib/kitchen/version.rb` - Managed by Expeditor
- `.expeditor/config.yml` - Build configuration (requires approval)
- `CHANGELOG.md` - Managed by Expeditor
- `bin/kitchen` - CLI entry point (rarely changed)

### Code Quality Standards

#### Ruby Style Guidelines
```bash
# Run style checks
bundle exec rake style

# Auto-fix style issues (where possible)
bundle exec chefstyle --auto-correct lib/ spec/
```

#### Chefstyle Configuration
- Follows Chefstyle 2.2.3 conventions
- Configured in `.chefstyle.yml` (if present)
- Required for all Ruby code

#### Error Handling Patterns
```ruby
module Kitchen
  module Provisioner
    class YourProvisioner < Kitchen::Provisioner::Base
      def validate_config
        raise UserError, "Required option 'foo' is missing" unless config[:foo]
        raise ClientError, "Unable to connect to service" if connection_failed?
      end

      def install_command
        info("Installing packages...")
        shell_out!(command) or raise ActionFailed, "Installation failed"
      rescue Errno::ENOENT => e
        raise UserError, "Command not found: #{e.message}"
      end
    end
  end
end
```

### Plugin Architecture Patterns

#### Driver Implementation
```ruby
module Kitchen
  module Driver
    class YourDriver < Kitchen::Driver::Base
      kitchen_driver_api_version 2

      plugin_version Kitchen::VERSION

      default_config :some_option, "default_value"

      def create(state)
        info("Creating instance...")
        # Implementation
        state[:server_id] = created_server_id
      end

      def destroy(state)
        return if state[:server_id].nil?
        info("Destroying instance...")
        # Implementation
        state.delete(:server_id)
      end
    end
  end
end
```

#### Provisioner Implementation
```ruby
module Kitchen
  module Provisioner
    class YourProvisioner < Kitchen::Provisioner::Base
      kitchen_provisioner_api_version 2

      plugin_version Kitchen::VERSION

      def create_sandbox
        super
        prepare_cookbooks if config[:cookbooks_path]
        prepare_config_files
      end

      def run_command
        [
          sudo(chef_command),
          *chef_args
        ].join(" ")
      end
    end
  end
end
```

## 🔧 Development Environment Setup

### Local Development Requirements
```bash
# Ruby 3.1+ required
ruby --version

# Install dependencies
bundle install

# Run tests to verify setup
bundle exec rake test

# Start development with watch mode
bundle exec guard start
```

### Available Build Commands
```bash
# Unit tests only (fast)
bundle exec rake unit

# Integration tests only (slower)
bundle exec rake features

# All tests
bundle exec rake test

# Code quality checks
bundle exec rake quality

# Generate documentation
cd docs && hugo serve

# Build gem locally
gem build chef-test-kitchen-enterprise.gemspec

# Install local gem
gem install chef-test-kitchen-enterprise-1.1.4.gem
```

### Docker Development (using Kitchen-Dokken)
```yaml
---
driver:
  name: dokken
  chef_version: unstable

provisioner:
  name: dokken

transport:
  name: dokken

platforms:
  - name: ubuntu-20.04
```

### Cross-Platform Considerations
- **Linux**: Primary development platform
- **macOS**: Supported development platform
- **Windows**: Supported via PowerShell and WinRM transport
- Habitat builds support multi-platform packaging

## 🔒 Security & Compliance

### License Requirements
- **License**: Apache 2.0
- All files must include Apache 2.0 license header
- DCO signoff required for all commits
- Chef licensing integration for enterprise features

### License Header Template
```ruby
#
# Author:: Your Name (<your.email@domain.com>)
#
# Copyright:: Copyright (c) $(date +%Y) Chef Software Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
```

### Security Considerations
- No hardcoded credentials or secrets
- Secure handling of SSH keys and certificates
- Proper input validation and sanitization
- Safe shell command execution using `mixlib-shellout`

## 📚 Integration & Dependencies

### Chef Ecosystem Integration
- **Chef Infra Client**: Primary provisioning target
- **Chef Licensing**: Enterprise license validation
- **Berkshelf**: Cookbook dependency management
- **InSpec**: Verification and compliance testing
- **Habitat**: Packaging and distribution

### External Service Dependencies
- **SSH/WinRM**: Remote system access
- **Cloud Providers**: AWS, Azure, GCP via driver plugins
- **Virtualization**: Vagrant, Docker, VMware
- **CI/CD**: Azure DevOps, GitHub Actions integration

### MCP Server Integration
For Jira workflow integration, configure atlassian-mcp-server:
```json
{
  "mcpServers": {
    "atlassian": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-atlassian"],
      "env": {
        "ATLASSIAN_API_TOKEN": "your-token",
        "ATLASSIAN_DOMAIN": "your-domain.atlassian.net",
        "ATLASSIAN_EMAIL": "your-email@domain.com"
      }
    }
  }
}
```

## 🚀 Prompt-Based Execution Protocol

### Interaction Pattern Example

**User Request**: "Implement PROJ-456: Add support for custom timeout configuration in SSH transport"

**Copilot Phase 1 Response**:
```
I'll help you implement custom timeout configuration for the SSH transport. Let me start by analyzing the Jira issue and current codebase.

[Performs analysis...]

## Analysis Complete

**Jira Issue Summary**: Add configurable connection and command timeouts for SSH transport to handle slow networks and long-running commands.

**Implementation Plan**:
1. Add timeout configuration options to SSH transport base class
2. Update connection and command execution methods
3. Add validation for timeout values
4. Create comprehensive unit tests (targeting >80% coverage)
5. Update documentation and examples

**Files to Modify**:
- `lib/kitchen/transport/ssh.rb` - Add timeout configuration
- `spec/kitchen/transport/ssh_spec.rb` - Add comprehensive tests
- `docs/content/docs/transports/ssh.md` - Update documentation

**Estimated Changes**: 150+ lines of code, 200+ lines of tests

Do you want me to continue with the implementation phase?
```

**User**: "Yes, proceed with implementation"

**Copilot Phase 2 Response**:
```
## Implementation Phase Starting

I'll implement the timeout configuration following Test Kitchen patterns...

[Implements changes...]

## Implementation Complete

**Changes Made**:
- Added `:connection_timeout` and `:command_timeout` configuration options
- Updated SSH connection establishment to use configurable timeouts
- Modified command execution to respect timeout settings
- Added proper error handling and user-friendly messages
- Maintained backward compatibility with default values

**Files Modified**:
- `lib/kitchen/transport/ssh.rb`: Added timeout support (89 lines changed)
- Enhanced error handling with timeout-specific messages

Do you want me to continue with the testing phase?
```

**User**: "Yes, create the tests"

**Copilot Phase 3 Response**:
```
## Testing Phase Starting

Creating comprehensive unit tests to ensure >80% coverage...

[Creates tests...]

## Testing Complete ✅

**Test Results**:
- Created 23 new unit tests covering all timeout scenarios
- Coverage: 91% (exceeds 80% requirement ✅)
- All tests passing ✅
- Positive cases: Valid timeout configurations
- Negative cases: Invalid timeout values, connection failures
- Edge cases: Zero timeouts, very large timeouts

**Test Coverage Breakdown**:
- Configuration validation: 100%
- Connection timeout handling: 95%
- Command timeout handling: 88%
- Error scenarios: 92%

Do you want me to continue with PR creation?
```

**User**: "Yes, create the pull request"

**Copilot Phase 4 Response**:
```
## Creating Pull Request

Executing git operations with DCO compliance...

[Performs git operations...]

## Pull Request Created Successfully 🎉

**Git Operations Completed**:
✅ Branch created: `PROJ-456`
✅ Changes committed with DCO signoff
✅ Branch pushed to origin
✅ Pull Request created with comprehensive description

**PR Details**:
- Title: "PROJ-456: Add configurable SSH transport timeouts"
- Labels: enhancement, ruby
- Comprehensive HTML description with testing results
- All files documented and changes explained

**PR URL**: https://github.com/chef/chef-test-kitchen-enterprise/pull/XXX

All phases completed successfully with proper testing coverage (91%) and full documentation! 🚀
```

### Phase Transition Prompts

#### Phase 1 → Phase 2
"I've analyzed the requirements and created a detailed implementation plan. The changes will affect [X] files and require [Y] new features. Do you want me to continue with the implementation phase?"

#### Phase 2 → Phase 3  
"Implementation is complete with [X] files modified and [Y] features added. Code follows all Test Kitchen patterns and conventions. Do you want me to continue with the comprehensive testing phase?"

#### Phase 3 → Phase 4
"All tests are passing with [X]% coverage (>80% requirement met). [Y] new tests cover all positive/negative scenarios and edge cases. Do you want me to continue with pull request creation?"

#### Final Confirmation
"Pull request created successfully with proper DCO compliance and comprehensive documentation. All development phases completed according to Test Kitchen standards!"

## 🔍 Code Review & Ownership

### CODEOWNERS Structure
- **@test-kitchen/maintainers**: All files (global ownership)
- Core maintainers review all changes
- Enterprise-specific changes may require additional Chef approval

### Review Requirements
- Minimum 1 approving review from maintainers
- All CI checks must pass (including DCO validation)
- Test coverage must meet 80% minimum
- Style checks must pass (chefstyle)

## 🆘 Troubleshooting & Common Issues

### Test Failures
```bash
# If tests fail due to missing gems
bundle install

# If style checks fail
bundle exec chefstyle --auto-correct lib/ spec/

# If coverage is too low
# Add more unit tests to cover edge cases and error paths

# If DCO check fails
git commit --amend --signoff --no-edit
```

### Development Issues
```bash
# Kitchen command not found
bundle exec kitchen help

# Permission issues on Linux
sudo chown -R $(whoami):$(whoami) .kitchen/

# Windows-specific issues
# Ensure PowerShell execution policy allows scripts
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Build Issues
- **Expeditor build failures**: Check label configuration
- **Habitat build issues**: Verify plan.sh/plan.ps1 syntax  
- **Gem conflicts**: Use `bundle exec` prefix for all commands

## 📋 Quality Checklist

### Pre-PR Checklist
- [ ] All tests passing: `bundle exec rake test`
- [ ] Coverage >80%: `bundle exec rake stats`
- [ ] Style checks pass: `bundle exec rake style`
- [ ] DCO signoff on all commits
- [ ] Proper license headers on new files
- [ ] Documentation updated if needed
- [ ] Examples updated if needed
- [ ] Backward compatibility maintained

### Code Quality Standards
- [ ] Error handling for all failure modes
- [ ] Proper logging with appropriate levels
- [ ] Input validation and sanitization
- [ ] Thread-safety considerations
- [ ] Performance implications considered
- [ ] Security implications reviewed

## 🔄 Example Complete Workflow

### Scenario: Adding New Configuration Option

**Step 1: User Request**
"Add support for custom SSH port configuration in kitchen.yml"

**Step 2: Analysis Phase**
```
Let me analyze the current SSH transport implementation and plan the changes needed.

[Analysis shows current SSH transport in lib/kitchen/transport/ssh.rb]

## Implementation Plan:
1. Add :ssh_port configuration option with default 22
2. Update SSH connection to use configured port
3. Add validation for port range (1-65535)
4. Create comprehensive tests
5. Update documentation

Files to modify:
- lib/kitchen/transport/ssh.rb
- spec/kitchen/transport/ssh_spec.rb  
- docs/content/docs/transports/ssh.md

Do you want me to continue with implementation?
```

**Step 3: Implementation Phase**
```ruby
# In lib/kitchen/transport/ssh.rb
module Kitchen
  module Transport
    class Ssh < Kitchen::Transport::Base
      default_config :ssh_port, 22

      def connection_options(state)
        opts = super
        opts[:port] = config[:ssh_port]
        opts
      end

      private

      def validate_config
        super
        port = config[:ssh_port]
        unless port.is_a?(Integer) && port.between?(1, 65535)
          raise UserError, "ssh_port must be an integer between 1 and 65535"
        end
      end
    end
  end
end
```

**Step 4: Testing Phase**
```ruby
# In spec/kitchen/transport/ssh_spec.rb
describe "ssh_port configuration" do
  it "defaults to port 22" do
    _(transport.config[:ssh_port]).must_equal 22
  end

  it "accepts valid port numbers" do
    config[:ssh_port] = 2222
    _(transport.config[:ssh_port]).must_equal 2222
  end

  it "rejects invalid port numbers" do
    config[:ssh_port] = 70000
    _(proc { transport }).must_raise Kitchen::UserError
  end

  it "includes port in connection options" do
    config[:ssh_port] = 2222
    opts = transport.connection_options({})
    _(opts[:port]).must_equal 2222
  end
end
```

**Step 5: PR Creation**
```bash
git checkout -b PROJ-789
git add .
git commit --signoff -m "PROJ-789: Add configurable SSH port support

- Add ssh_port configuration option with default value 22
- Update connection options to use configured port
- Add validation for port range (1-65535)
- Create comprehensive unit tests with 95% coverage
- Maintain backward compatibility"

git push origin PROJ-789

gh pr create \
  --title "PROJ-789: Add configurable SSH port support" \
  --body "..." \
  --label "enhancement" \
  --label "ruby"
```

---

## 📝 Summary

This copilot-instructions.md provides comprehensive guidance for contributing to Chef Test Kitchen Enterprise. Key requirements:

1. **>80% test coverage is MANDATORY**
2. **DCO signoff required for all commits** 
3. **Follow prompt-based development phases**
4. **Use repository-specific labels and build system**
5. **Maintain Test Kitchen architectural patterns**
6. **Ensure security and licensing compliance**

For questions or clarifications, engage with the Test Kitchen community via:
- GitHub Issues: https://github.com/chef/chef-test-kitchen-enterprise/issues
- Chef Community Slack: #test-kitchen channel

Remember: All work is performed locally with proper testing, documentation, and compliance with enterprise standards.
