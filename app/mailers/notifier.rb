class Notifier < ActionMailer::Base
  default :from => "from@example.com"

  def feedback(params)
    @params = params

    return mail(:to => Settings.tdl_feedback_address,
      :from => params[:email],
      :subject => Settings.tdl_feedback_subject).deliver;
  end
end
