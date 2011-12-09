class Notifier < ActionMailer::Base
  default :from => "from@example.com"

  def feedback(params)
    @params = params

    return mail(:to => "brian.goodmon@tufts.edu",
      :from => params[:email],
      :subject => "TDL Content Feedback").deliver;
  end
end
