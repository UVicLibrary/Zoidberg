class PdfCreatedMailer < ApplicationMailer

  def pdf_created_email
    @email = params[:email]
    @document = Document.find(params[:id])
    host = params[:account_host]

    # Send email
    mail(to: @email, subject: "#{@document.title} is Ready")
  end

end
