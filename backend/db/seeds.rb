require "open-uri"

Ebook.destroy_all

20.times do |i|
  title = "PDF Book #{i + 1}"
  author = ["Uncle Bob", "Martin Fowler", "Kent Beck", "Erich Gamma", "Richard Helm"].sample
  ebook = Ebook.find_or_initialize_by(title: title)
  next if ebook.persisted?

  ebook.author = author
  ebook.file_type = "pdf"
  ebook.file_size = 1024

  pdf_content = "%PDF-1.4\n1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n2 0 obj\n<< /Type /Pages /Kids [3 0 R 6 0 R] /Count 2 >>\nendobj\n3 0 obj\n<< /Type /Page /Parent 2 0 R /Resources << /Font << /F1 4 0 R >> >> /MediaBox [0 0 595.275 841.889] /Contents 5 0 R >>\nendobj\n4 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>\nendobj\n5 0 obj\n<< /Length 50 >>\nstream\nBT /F1 24 Tf 100 700 Td (Page 1 of #{title} Content) Tj ET\nendstream\nendobj\n6 0 obj\n<< /Type /Page /Parent 2 0 R /Resources << /Font << /F1 4 0 R >> >> /MediaBox [0 0 595.275 841.889] /Contents 7 0 R >>\nendobj\n7 0 obj\n<< /Length 50 >>\nstream\nBT /F1 24 Tf 100 700 Td (Page 2 of #{title} Content) Tj ET\nendstream\nendobj\nxref\n0 8\n0000000000 65535 f \n0000000009 00000 n \n0000000052 00000 n \n0000000109 00000 n \n0000000236 00000 n \n0000000301 00000 n \n0000000402 00000 n \n0000000529 00000 n \ntrailer\n<< /Size 8 /Root 1 0 R >>\nstartxref\n629\n%%EOF"

  ebook.file.attach(
    io: StringIO.new(pdf_content),
    filename: "pdf_book_#{i + 1}.pdf",
    content_type: "application/pdf"
  )
  ebook.save!
end

3.times do |i|
  title = "EPUB Book #{i + 1}"
  author = ["J.K. Rowling", "George Orwell", "J.R.R. Tolkien"].sample
  ebook = Ebook.find_or_initialize_by(title: title)
  next if ebook.persisted?

  ebook.author = author
  ebook.file_type = "epub"
  ebook.file_size = 512

  epub_content = "This is Page 1 of the ebook content for #{title}.\n\n" \
                 "EPUB is an XML-based reflowable format that enables readers to customize font scales. " \
                 "This custom viewer splits paragraphs into readable chunks so you can click Next and Previous. " \
                 "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt.\n\n" \
                 "This is Page 2 of the ebook content for #{title}.\n\n" \
                 "You can verify page count indicators at the bottom showing exactly 2 pages. " \
                 "All features including dynamic resizing work flawlessly on the web bookshelf library layout. " \
                 "End of book demo."

  ebook.file.attach(
    io: StringIO.new(epub_content),
    filename: "epub_book_#{i + 1}.epub",
    content_type: "application/epub+zip"
  )
  ebook.save!
end
