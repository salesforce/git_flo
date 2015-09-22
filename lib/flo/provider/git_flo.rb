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
        @remote = opts[:remote]
        if @remote
          @credentials = opts[:credentials]

          @credentials ||= determine_creds_from_args(opts[:remote])
        end
      end

      def check_out_or_create_branch(opts={})
        name = opts[:name]
        ref = opts[:source] || 'master'

        validate_branch_exists(ref)

        if @remote
          repo.fetch(@remote[:name], credentials: credentials)
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
        branch_name = opts[:branch]
        raise NotImplementedError.new('This should probably get implemented to get the tests green')
      end

      private

      attr_reader :credentials, :remote

      def repo
        @repo ||= Rugged::Repository.discover(@repo_location)
      end

      def determine_creds_from_args(args={})
        if args[:use_agent]
          Rugged::Credentials::SshKeyFromAgent.new(username: @remote[:user])
        end
      end

      def validate_branch_exists(branch)
        unless repo.branches.exist?(branch)
          raise ::GitFlo::MissingRefError.new("Cannot create branch, as source branch #{branch} does not exist")
        end
      end

    end
  end
end
