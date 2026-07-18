require "open-uri"

books_data = [
  { title: "Clean Code", author: "Robert C. Martin", filename: "clean_code.pdf" },
  { title: "The Pragmatic Programmer", author: "Andy Hunt & Dave Thomas", filename: "pragmatic_programmer.pdf" },
  { title: "Refactoring", author: "Martin Fowler", filename: "refactoring.pdf" }
]

books_data.each do |data|
  ebook = Ebook.find_or_initialize_by(title: data[:title])
  next if ebook.persisted?

  ebook.author = data[:author]
  ebook.file_type = "pdf"
  ebook.file_size = 1024

  pdf_content = "%PDF-1.4\n%âãÏÓ\n1 0 obj\n<<\n/Type /Catalog\n/Pages 2 0 R\n>>\nendobj\n2 0 obj\n<<\n/Type /Pages\n/Kids [3 0 R]\n/Count 1\n>>\nendobj\n3 0 obj\n<<\n/Type /Page\n/Parent 2 0 R\n/Resources <<\n/Font <<\n/F1 4 0 R\n>>\n>>\n/MediaBox [0 0 595.275 841.889]\n/Contents 5 0 R\n>>\nendobj\n4 0 obj\n<<\n/Type /Font\n/Subtype /Type1\n/BaseFont /Helvetica\n>>\nendobj\n5 0 obj\n<<\n/Length 44\n>>\nstream\nBT\n/F1 24 Tf\n100 700 Td\n(Clean Code Demo PDF) Tj\nET\nendstream\nendobj\nxref\n0 6\n0000000000 65535 f \n0000000015 00000 n \n0000000068 00000 n \n0000000120 00000 n \n0000000253 00000 n \n0000000326 00000 n \ntrailer\n<<\n/Size 6\n/Root 1 0 R\n>>\nstartxref\n421\n%%EOF"
  
  ebook.file.attach(
    io: StringIO.new(pdf_content),
    filename: data[:filename],
    content_type: "application/pdf"
  )

  ebook.save!
end
