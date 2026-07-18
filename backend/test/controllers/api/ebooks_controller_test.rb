require "test_helper"

class Api::EbooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    Ebook.delete_all
    @pdf_file = fixture_file_upload("dummy.pdf", "application/pdf")
    @epub_file = fixture_file_upload("dummy.epub", "application/epub+zip")
    @ebook = Ebook.create!(
      title: "Clean Code",
      author: "Robert C. Martin",
      file_type: "pdf",
      file_size: @pdf_file.size,
      file: @pdf_file
    )
  end

  test "should get index" do
    get api_ebooks_url
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 1, json.length
    assert_equal @ebook.id, json.first["id"]
  end

  test "should get search results" do
    get search_api_ebooks_url, params: { q: "Clean" }
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 1, json.length
    assert_equal "Clean Code", json.first["title"]
  end

  test "should return bad request for empty search query" do
    get search_api_ebooks_url
    assert_response :bad_request
    json = JSON.parse(response.body)
    assert_equal "Search query 'q' parameter is required", json["error"]
  end

  test "should show ebook details" do
    get api_ebook_url(@ebook)
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal @ebook.id, json["id"]
  end

  test "should return 404 for non-existent ebook" do
    get api_ebook_url(id: 99999)
    assert_response :not_found
    json = JSON.parse(response.body)
    assert_equal "Ebook not found with ID 99999", json["error"]
  end

  test "should create ebook with valid file" do
    assert_difference("Ebook.count") do
      post api_ebooks_url, params: {
        file: @pdf_file,
        title: "Test Book",
        author: "Test Author"
      }
    end
    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "Test Book", json["title"]
    assert_equal "Test Author", json["author"]
    assert_equal "pdf", json["file_type"]
  end

  test "should default to filename and Unknown Author if parameters missing" do
    assert_difference("Ebook.count") do
      post api_ebooks_url, params: { file: @epub_file }
    end
    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "Dummy", json["title"]
    assert_equal "Unknown Author", json["author"]
    assert_equal "epub", json["file_type"]
  end

  test "should fail to create ebook without file" do
    assert_no_difference("Ebook.count") do
      post api_ebooks_url, params: { title: "No File Book" }
    end
    assert_response :unprocessable_entity
    json = JSON.parse(response.body)
    assert_equal "No file was uploaded. 'file' parameter is required.", json["error"]
  end

  test "should download ebook file" do
    get download_api_ebook_url(@ebook)
    assert_response :success
    assert_equal "application/pdf", response.headers["Content-Type"]
    assert_match /dummy\.pdf/, response.headers["Content-Disposition"]
  end

  test "should destroy ebook" do
    assert_difference("Ebook.count", -1) do
      delete api_ebook_url(@ebook)
    end
    assert_response :ok
    json = JSON.parse(response.body)
    assert_match /successfully deleted/, json["message"]
  end
end
