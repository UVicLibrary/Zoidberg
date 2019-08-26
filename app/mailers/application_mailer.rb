class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@uvic.ca'
  layout 'mailer'
  # content_type 'text/html'
end
