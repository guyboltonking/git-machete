from pytest_mock import MockerFixture

from .base_test import BaseTest
from .mockers import launch_command, mock__run_cmd_and_forward_stdout


class TestLog(BaseTest):

    def test_log(self, mocker: MockerFixture) -> None:
        self.patch_symbol(mocker, 'git_machete.utils._run_cmd', mock__run_cmd_and_forward_stdout)

        self.repo_sandbox.new_branch('root')
        self.repo_sandbox.commit()
        roots_only_commit_hash = self.repo_sandbox.get_current_commit_hash()

        self.repo_sandbox.new_branch('child')
        self.repo_sandbox.commit()
        childs_first_commit_hash = self.repo_sandbox.get_current_commit_hash()
        self.repo_sandbox.commit()
        childs_second_commit_hash = self.repo_sandbox.get_current_commit_hash()

        log_contents = [launch_command('log'), launch_command('log', 'child'), launch_command('log', 'refs/heads/child')]

        assert all(childs_first_commit_hash in log_content for log_content in log_contents), \
            ("Verify that oldest commit from current branch is visible when "
             "executing `git machete log`.")
        assert all(childs_second_commit_hash in log_content for log_content in log_contents), \
            ("Verify that youngest commit from current branch is visible when "
             "executing `git machete log`.")
        assert all(roots_only_commit_hash not in log_content for log_content in log_contents), \
            ("Verify that commits from parent branch are not visible when "
             "executing `git machete log`.")
