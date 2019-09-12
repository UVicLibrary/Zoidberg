# Preview all emails at http://localhost:3000/rails/mailers/pdf_created_mailer
class PdfCreatedMailerPreview < ActionMailer::Preview
  def sample_mail_preview
    PdfCreatedMailer.with(host: ENV['BASE_URL'], document: Document.first).pdf_ready
  end
end
