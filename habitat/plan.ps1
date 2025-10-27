$ErrorActionPreference = "Stop"
$PSDefaultParameterValues['*:ErrorAction']='Stop'

$env:HAB_BLDR_CHANNEL = "base-2025"
$env:HAB_REFRESH_CHANNEL = "base-2025"
$pkg_name="chef-test-kitchen-enterprise"
$pkg_origin="chef"
$pkg_version=$(Get-Content "$PLAN_CONTEXT/../VERSION")
$pkg_maintainer="The Chef Maintainers <humans@chef.io>"

$pkg_deps=@(
  "core/ruby3_4-plus-devkit"
  "core/git"
)
$pkg_bin_dirs=@("bin"
                "vendor/bin")
$project_root= (Resolve-Path "$PLAN_CONTEXT/../").Path

function pkg_version {
    Get-Content "$SRC_PATH/VERSION"
}

function Invoke-Before {
    Set-PkgVersion
}
function Invoke-SetupEnvironment {
    Push-RuntimeEnv -IsPath GEM_PATH "$pkg_prefix/vendor"

    Set-RuntimeEnv APPBUNDLER_ALLOW_RVM "true" # prevent appbundler from clearing out the carefully constructed runtime GEM_PATH
    Set-RuntimeEnv FORCE_FFI_YAJL "ext"
    Set-RuntimeEnv LANG "en_US.UTF-8"
    Set-RuntimeEnv LC_CTYPE "en_US.UTF-8"
}

function Invoke-Build {
    try {
        $env:Path += ";c:\\Program Files\\Git\\bin"
        Push-Location $project_root
        $env:GEM_HOME = "$HAB_CACHE_SRC_PATH/$pkg_dirname/vendor"

        Write-BuildLine " ** Configuring bundler for this build environment"
        bundle config --local without deploy maintenance
        bundle config --local jobs 4
        bundle config --local retry 5
        bundle config --local silence_root_warning 1
        Write-BuildLine " ** Using bundler to retrieve the Ruby dependencies"
        bundle install
	    bundle lock --local
        gem build chef-test-kitchen-enterprise.gemspec
	    Write-BuildLine " ** Using gem to  install"
	    gem install chef-test-kitchen-enterprise*.gem --no-document

        ruby ./post-bundle-install.rb
        If ($lastexitcode -ne 0) { Exit $lastexitcode }

        # Install chef-official-distribution AFTER post-bundle-install
        Install-ChefOfficialDistribution

        Write-BuildLine " ** Build complete"
    } finally {
        Pop-Location
    }

}
function Invoke-Install {
    Write-BuildLine "** Copy built & cached gems to install directory"
    Copy-Item -Path "$HAB_CACHE_SRC_PATH/$pkg_dirname/*" -Destination $pkg_prefix -Recurse -Force -Exclude @("gem_make.out", "mkmf.log", "Makefile",
                     "*/latest", "latest",
                     "*/JSON-Schema-Test-Suite", "JSON-Schema-Test-Suite")

    try {
        Push-Location $pkg_prefix
        bundle config --local gemfile $project_root/Gemfile
         Write-BuildLine "** generating binstubs for chef-test-kitchen-enterprise with precise version pins"
	 Write-BuildLine "** generating binstubs for chef-test-kitchen-enterprise with precise version pins $project_root $pkg_prefix/bin " 
            Invoke-Expression -Command "appbundler.bat $project_root $pkg_prefix/bin chef-test-kitchen-enterprise"
            If ($lastexitcode -ne 0) { Exit $lastexitcode }
	Write-BuildLine " ** Running the chef-test-kitchen-enterprise project's 'rake install' to install the path-based gems so they look like any other installed gem."

        If ($lastexitcode -ne 0) { Exit $lastexitcode }
    } finally {
        Pop-Location
    }
}

function Invoke-After {
    # We don't need the cache of downloaded .gem files ...
    Remove-Item $pkg_prefix/vendor/cache -Recurse -Force
    # We don't need the gem docs.
    Remove-Item $pkg_prefix/vendor/doc -Recurse -Force
    # We don't need to ship the test suites for every gem dependency,
    # only inspec's for package verification.
    Get-ChildItem $pkg_prefix/vendor/gems -Filter "spec" -Directory -Recurse -Depth 1 `
        | Where-Object -FilterScript { $_.FullName -notlike "*test-kitchen*" }             `
        | Remove-Item -Recurse -Force
    # Remove the byproducts of compiling gems with extensions
    Get-ChildItem $pkg_prefix/vendor/gems -Include @("gem_make.out", "mkmf.log", "Makefile") -File -Recurse `
        | Remove-Item -Force
}

function Install-ChefOfficialDistribution {
    Write-BuildLine "Installing chef-official-distribution gem from Artifactory"

    $artifactorySource = "https://artifactory-internal.ps.chef.co/artifactory/omnibus-gems-local/"

    try {
        # Add Artifactory as gem source
        gem sources --add $artifactorySource
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to add Artifactory gem source"
        }

        # Install the gem
        gem install chef-official-distribution --no-document
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to install chef-official-distribution gem"
        }

        Write-BuildLine "Successfully installed chef-official-distribution"
    }
    catch {
        Write-Error "Error installing chef-official-distribution: $_"
        exit 1
    }
    finally {
        # Always clean up gem sources
        try {
            gem sources --remove $artifactorySource
        } catch {
            # Ignore errors during cleanup
        }
    }
}
