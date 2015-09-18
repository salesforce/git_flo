require 'ostruct'
require 'rugged'

module Flo
  module Provider
    class GitFlo

      def initialize(opts={})
        @repo_location = opts[:repo_location] || '.'

      end

      def check_out_or_create_branch(opts={})
        name = opts[:name]
        ref = opts[:source] || 'master'

        if repo.branches.exist? name
          repo.checkout(name)
        else
          repo.branches.create(name, ref)
          repo.checkout(name)
        end
        OpenStruct.new(success?: true)
      end

      private

      def repo
        @repo ||= Rugged::Repository.discover(@repo_location)
      end

    end
  end
end
