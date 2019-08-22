class PdfCreatedMailer < ApplicationMailer

  def pdf_ready
    @document = params[:document]
    @host = params[:account_host]
    @url = "#{ENV['BASE_URL']}/documents/#{@document.id}"

    mail(to: @document.email, subject: "#{@document.title.titleize} is Ready")
  end

end
