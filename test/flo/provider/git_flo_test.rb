require_relative '../../test_helper'
require 'flo/provider/git_flo'
require 'tmpdir'


module Flo
  module Provider
    class GitFloTest < ::GitFlo::UnitTest

      def subject
        @subject ||= ::Flo::Provider::GitFlo.new
      end


      def in_a_temp_repo
        # Note: the temp directory is automatically removed at the end of the block
        Dir.mktmpdir do |dir|

          repo = initialize_repo(dir)

          @subject = ::Flo::Provider::GitFlo.new(repo_location: dir)
          yield(dir, repo)
        end
      end

      def initialize_repo(dir)
        repo = Rugged::Repository.init_at(File.join(dir, '.git'))
        initial_commit = Rugged::Commit.create(repo, { author: { email: "none@example.com", name: 'none'}, message: "Empty commit", tree: repo.index.write_tree, parents: [] } )
        repo.branches.create('master', initial_commit)
        repo
      end

      def test_check_out_or_create_branch_creates_branch_when_none_exist
        expected_branch_name = "foo"
        in_a_temp_repo do |dir, repo|
          refute repo.branches.exist?(expected_branch_name), "The new branch already exists before test setup"

          subject.check_out_or_create_branch(name: expected_branch_name)

          assert repo.branches.exist?(expected_branch_name), "The new branch was not created"
        end
      end

      def test_check_out_or_create_branch_checks_out_branch_when_it_exists
        existing_branch_name = "foo"
        in_a_temp_repo do |dir, repo|
          repo.branches.create(existing_branch_name, 'master')
          assert repo.branches.exist?(existing_branch_name)
          refute repo.head.name.include? existing_branch_name

          subject.check_out_or_create_branch(name: existing_branch_name)

          assert repo.head.name.include? existing_branch_name

        end

      end

    end
  end
end