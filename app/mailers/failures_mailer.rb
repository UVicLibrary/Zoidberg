class FailuresMailer < ApplicationMailer

  def no_such_file
    @user_email = params[:user_email]
    @windows_path = params[:windows_path]
    @title = params[:title]
    mail(to: @user_email, subject: "Zoidberg can't find a file")
  end

  def other_failures
    @user_email = params[:user_email]
    @error_message = params[:error_message]
    @document_id = params[:document_id]
    mail(to: @user_email, subject: 'File Creation Error')
  end

end