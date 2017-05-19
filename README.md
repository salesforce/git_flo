# GitFlo
[![Gem Version](https://badge.fury.io/rb/flo.svg)](https://badge.fury.io/rb/git_flo) [![Code Climate](https://codeclimate.com/github/codeclimate/codeclimate/badges/gpa.svg)](https://codeclimate.com/github/codeclimate/codeclimate) [![Build Status](https://semaphoreci.com/api/v1/justinpowers/git_flo/branches/master/shields_badge.svg)](https://semaphoreci.com/justinpowers/git_flo)

GitFlo is a Git plugin for the Flo workflow automation library.  If you aren't familiar with Flo, then please start [here](https://github.com/salesforce/flo)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'git_flo'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install git_flo

## Compatibility

GitFlo uses the Rugged rubygem, which includes C bindings to the libgit2 C library.  For this reason, this gem is not expected to work with jruby.  For more information on Rugged, [check it out on Github](https://github.com/libgit2/rugged)

## Configuration

In your Flo configuration file, configure git inside the `config` block

```ruby
config do |cfg|
  cfg.provider :git_flo, { credentials: Rugged::Credentials::SshKeyFromAgent.new(username: 'git') }
end
```

If you will not be running flo within your local git repository, you can pass in a `:repo_location` option to specify where the git repo exists.

If you wish to push to a repo requiring authentication, you must specify a `credentials` provider.  See the [Rugged::Credentials module](https://github.com/libgit2/rugged/blob/master/lib/rugged/credentials.rb) for options.

## Usage

Specify the commands you wish to run in the `register_command` block.  For example
```ruby
# Checks out a branch with the name "my_new_branch".  If the branch does not exist, a new branch is created based off the master branch
perform :git_flo, :check_out_or_create_branch, { from: 'master', name: 'my_new_branch' }

# pushes the 'my_new_branch' up to the 'origin' remote repo.  This will raise an error if this would result in a force push
perform :git_flo, :push, { branch: 'my_new_branch' }
```

## Contributing

1. Fork it (http://github.com/your-github-username/flo/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## License

>Copyright (c) 2017, Salesforce.com, Inc.
>All rights reserved.
>
>Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
>
>* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
>
>* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
>
>* Neither the name of Salesforce.com nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
>
>THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
