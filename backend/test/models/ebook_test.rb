require "test_helper"

class EbookTest < ActiveSupport::TestCase
  setup do
    Ebook.delete_all
    @pdf_file = fixture_file_upload("dummy.pdf", "application/pdf")
    @epub_file = fixture_file_upload("dummy.epub", "application/epub+zip")
  end

  test "should be valid with valid attributes and file" do
    ebook = Ebook.new(
      title: "Clean Code",
      author: "Robert C. Martin",
      file_type: "pdf",
      file_size: @pdf_file.size
    )
    ebook.file.attach(@pdf_file)
    assert ebook.valid?
  end

  test "should be invalid without title" do
    ebook = Ebook.new(
      author: "Robert C. Martin",
      file_type: "pdf",
      file_size: 100
    )
    ebook.file.attach(@pdf_file)
    assert_not ebook.valid?
    assert_includes ebook.errors[:title], "can't be blank"
  end

  test "should be invalid without file attached" do
    ebook = Ebook.new(
      title: "Clean Code",
      author: "Robert C. Martin",
      file_type: "pdf",
      file_size: 100
    )
    assert_not ebook.valid?
    assert_includes ebook.errors[:file], "must be uploaded"
  end

  test "should reject unsupported file extensions" do
    ebook = Ebook.new(
      title: "Clean Code",
      author: "Robert C. Martin",
      file_type: "txt",
      file_size: 100
    )
    ebook.file.attach(@pdf_file)
    assert_not ebook.valid?
    assert_includes ebook.errors[:file_type], "format txt is not supported (PDF and EPUB only)"
  end

  test "should support search by keyword" do
    ebook_1 = Ebook.create!(
      title: "Design Patterns",
      author: "Gang of Four",
      file_type: "pdf",
      file_size: @pdf_file.size,
      file: @pdf_file
    )
    ebook_2 = Ebook.create!(
      title: "Refactoring",
      author: "Martin Fowler",
      file_type: "epub",
      file_size: @epub_file.size,
      file: @epub_file
    )

    results = Ebook.search_by_keyword("Design")
    assert_includes results, ebook_1
    assert_not_includes results, ebook_2

    results = Ebook.search_by_keyword("Fowler")
    assert_includes results, ebook_2
    assert_not_includes results, ebook_1

    results = Ebook.search_by_keyword("pattern")
    assert_includes results, ebook_1
  end

  test "should support sorting by different options" do
    ebook_a = Ebook.create!(
      title: "Architecture",
      author: "Bob",
      file_type: "pdf",
      file_size: @pdf_file.size,
      file: @pdf_file
    )
    ebook_c = Ebook.create!(
      title: "Compiler Design",
      author: "Alice",
      file_type: "pdf",
      file_size: @pdf_file.size,
      file: @pdf_file
    )

    sorted = Ebook.sorted_by("title_asc")
    assert_equal [ebook_a, ebook_c], sorted.to_a

    sorted = Ebook.sorted_by("title_desc")
    assert_equal [ebook_c, ebook_a], sorted.to_a
  end
end
