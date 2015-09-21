require 'ostruct'
require 'rugged'

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

        if @remote
          repo.fetch(@remote[:name], credentials: credentials)
        end

        if repo.branches.exist? name
          repo.checkout(name)
        else
          repo.branches.create(name, ref)
          repo.checkout(name)
        end
        OpenStruct.new(success?: true)
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

    end
  end
end
