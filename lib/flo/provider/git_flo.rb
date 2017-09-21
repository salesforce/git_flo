# Copyright © 2017, Salesforce.com, Inc.
# All Rights Reserved.
# Licensed under the BSD 3-Clause license.
# For full license text, see LICENSE.txt file in the repo root or https://opensource.org/licenses/BSD-3-Clause

require 'ostruct'
require 'rugged'
require 'flo/provider/base'

module GitFlo
  MissingRefError = Class.new(StandardError)
end

module Flo
  module Provider
    class GitFlo < Flo::Provider::Base

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
        repo.push(remote, branch_name, credentials: credentials)

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
