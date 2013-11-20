class HookController < ApplicationController
  unloadable

  def create
    @user = User.find_by_mail(Setting.plugin_chiliproject_gitlab_hook['gitlab_user_email'])
    params[:commits].each do |c|
      process_commit(c)
    end
    render :nothing => true
  end

  private

    def process_commit(commit)
      @issues = find_issues_from_commit_message(commit[:message])
      @issues.each do |i|
        create_journal_for(i, commit)
      end
    end

    def find_issues_from_commit_message(message)
      re = ReferenceExtractor.new
      re.analyze(message)
      re.related_issues
    end

    def create_journal_for(issue, commit)
      JournalObserver.instance.send_notification = false
      author = commit[:author][:name]
      message = "\"#{author} referenced this issue in a commit.\":#{commit[:url]}"
      version = issue.init_journal.version
      issue.journals.create({:notes => message, :version => version+1, :user => @user})
    end
end