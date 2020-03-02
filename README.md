# Zoidberg
Built on Ruby version 2.6.3.

PDFs are stored in `public/pdfs` directory. Working files are created in `working/*pdf title*` directory and then deleted once the final PDF is complete.

## Overview
1. User fills out `views/documents/_form` with PDF title, path to source on Q: Drive, email address (for sending notification).
2. Checks DPI of images (see `documents_controller#create` and MiniMagick):
    * if under 600, prints warning message but continues
    * if over 600, resamples image to 600 DPI
3. If title (i.e. filename) has spaces, replaces them with underscores and prints warning message
4. Redirects user to a "in progress" page on `views/documents/show`, displays any warning messages
5. Enqueues `CreatePDFJob`
    * Grabs file locally from mounted drive and copy TIFFs into JPGs.
    * Sorts and embed each JPG into a page and write the PDF(HexaPDF) and a thumbnail to the `public` directory.
    * [Linearizes](https://www.pdfen.com/faq/linearized-pdf) (i.e. make web-ready) the PDF with QPDF.
    * Cleans up the working files, which we don't need anymore.
    * Sets the document's `completed` attribute to true, which updates `views/documents/show` with a download link to the PDF.
    * Sends an email (`pdf_created_mailer`) to the user email address listed earlier.
6. Schedules a job to delete the document (files & from database) a week after creation (see `app/workers/delete_document_worker.rb`).
7. Runs a CRON job every week to delete ImageMagick temp files in `tmp`.

## Gems
**TIF (to JPG to) PDF conversion**
* [MiniMagick](https://github.com/minimagick/minimagick)
* [HexaPDF](https://github.com/gettalong/hexapdf)

**Styling and Interface**
* [Octicons](https://github.com/primer/octicons)
* [Octicons Helper](https://github.com/primer/octicons/tree/master/lib/octicons_helper)
* [Bootstrap 4](https://github.com/twbs/bootstrap-rubygem)
* [jQuery Rails](https://github.com/rails/jquery-rails)

**Managing Jobs**
* [Sidekiq](https://github.com/mperham/sidekiq)
* [Sidekiq-Cron](https://github.com/ondrejbartas/sidekiq-cron)

## Other Dependencies
(Installed via command line)
* [ImageMagick](https://imagemagick.org/)
* [QPDF](http://qpdf.sourceforge.net/)
