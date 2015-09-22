require_relative '../../test_helper'
require 'flo/provider/git_flo'
require 'tmpdir'


module Flo
  module Provider
    class GitFloTest < ::GitFlo::UnitTest

      def subject
        @subject ||= begin
          opts = { repo_location: @repo_location }
          opts[:remote] = @remote if @remote
          ::Flo::Provider::GitFlo.new(opts)
        end
      end


      def in_a_temp_repo
        # Note: the temp directory is automatically removed at the end of the block
        Dir.mktmpdir do |dir|
          @repo_location = dir

          repo = initialize_repo(dir)

          yield(dir, repo)
        end
      end

      def initialize_repo(dir)
        repo = Rugged::Repository.init_at(File.join(dir, '.git'))
        initial_commit = create_empty_commit(repo: repo, initial_commit: true)
        repo.branches.create('master', initial_commit)

        repo
      end

      def create_empty_commit(opts={})
        message = opts[:message] || 'Empty commit message'
        branch = opts[:branch] || 'master'
        repo = opts[:repo]
        commit_options = {
          author: {
            email: "none@example.com",
            name: 'none'
          },
          message: message
        }
        if opts[:initial_commit]
          commit_options.merge!(tree: repo.index.write_tree, parents: [])
        else
          commit_options.merge!(
            tree: repo.branches[branch].target.tree,
            parents: [repo.branches[branch].target],
            update_ref: repo.branches[branch].canonical_name
          )
        end
        Rugged::Commit.create(repo, commit_options)
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
          assert repo.branches.exist?(existing_branch_name), 'Test setup failed, existing branch not created'
          refute repo.head.name.include?(existing_branch_name), 'Test setup failed, existing branch should not be checked out yet'

          subject.check_out_or_create_branch(name: existing_branch_name)

          assert repo.head.name.include?(existing_branch_name), "Did not check out the existing branch"
        end
      end

      def test_check_out_or_create_branch_fetches_from_origin
        @remote = {name: 'origin'}
        remote_branch_name = 'remote_branch'

        in_a_temp_repo do |remote_repo_dir, remote_repo|
          remote_repo.branches.create(remote_branch_name, 'master')

          commit_sha = create_empty_commit(repo: remote_repo, branch: remote_branch_name)

          in_a_temp_repo do |_, subject_repo|
            subject_repo.remotes.create('origin', remote_repo_dir)

            subject.check_out_or_create_branch(name: remote_branch_name)

            assert subject_repo.head.name.include?(remote_branch_name), "Did not check out the correct branch"
            assert_equal commit_sha, subject_repo.head.target.oid, "The branch target does not match the remote branch"
          end
        end
      end

      def test_check_out_or_create_branch_raises_when_ref_does_not_exist
        missing_ref = 'this_branch_does_not_exist'
        in_a_temp_repo do |dir, repo|
          refute repo.branches.exist?(missing_ref), 'Test setup failed, this branch should not exist'

          assert_raises(::GitFlo::MissingRefError) do
            subject.check_out_or_create_branch(name: 'new_branch', source: missing_ref)
          end
        end
      end

      def test_push_pushes_specific_branch_to_remote
        subject_branch = "branch_to_submit"

        in_a_temp_repo do |remote_repo_dir, remote_repo|

          in_a_temp_repo do |_, subject_repo|

            subject_repo.branches.create(subject_branch, 'master')

            commit_sha = create_empty_commit(repo: subject_repo, branch: subject_branch)

            assert_equal commit_sha, subject_repo.branches[subject_branch].target.oid, 'Test setup failed, commit was not created at the HEAD of the subject branch'

            subject_repo.remotes.create('origin', remote_repo_dir)

            refute remote_repo.branches.exist?(subject_branch), 'Test setup failed, branch should not yet exist on remote'
            refute remote_repo.include?(commit_sha), 'Test setup failed, new commit should not yet exist on remote'

            subject.push(branch: subject_branch)

            assert remote_repo.branches.exist?(subject_branch), 'The subject branch was not pushed to the remote repo'
            assert_equal commit_sha, remote_repo.branches[subject_branch].target.oid, "The branch on the remote repo does not match the local repo"
          end
        end
      end

    end
  end
end
