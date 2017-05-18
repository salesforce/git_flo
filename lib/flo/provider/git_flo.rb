# Copyright (c) 2017, Salesforce.com, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# * Neither the name of Salesforce.com nor the names of its contributors may be
# used to endorse or promote products derived from this software without
# specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

require 'ostruct'
require 'rugged'

module GitFlo
  MissingRefError = Class.new(StandardError)
end

module Flo
  module Provider
    class GitFlo

      def initialize(opts={})
        @repo_location = opts[:repo_location] || '.'

        @credentials = opts[:credentials]
      end

      def check_out_or_create_branch(opts={})
        name = opts[:name]
        ref = opts[:source] || 'master'
        remote = opts[:remote] || 'origin'

        validate_branch_exists(ref)

        if repo.remotes[remote]
          repo.fetch(remote, credentials: credentials)
        end

        if repo.branches.exist? name
          # noop
        elsif repo.branches.exist? "origin/#{name}"
          repo.create_branch(name, "origin/#{name}")
        else
          repo.create_branch(name, ref)
        end

        repo.checkout(name)
        OpenStruct.new(success?: true)
      end

      def push(opts={})
        remote = opts[:remote] || 'origin'
        branch_name = repo.branches[opts[:branch]].canonical_name
        repo.push(remote, branch_name)

        OpenStruct.new(success?: true)
      end

      private

      attr_reader :credentials, :remote

      def repo
        @repo ||= Rugged::Repository.discover(@repo_location)
      end

      def validate_branch_exists(branch)
        unless repo.branches.exist?(branch)
          raise ::GitFlo::MissingRefError.new("Cannot create branch, as source branch #{branch} does not exist")
        end
      end

    end
  end
end
