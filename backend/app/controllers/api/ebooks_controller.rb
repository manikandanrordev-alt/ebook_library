module Api
  class EbooksController < ApplicationController
    before_action :set_ebook, only: [:show, :download, :destroy]

    def index
      @ebooks = Ebook.with_attached_file.with_attached_cover_image.all
      @ebooks = @ebooks.filter_by_file_type(params[:file_type]) if params[:file_type].present?
      @ebooks = @ebooks.search_by_keyword(params[:q]) if params[:q].present?
      @ebooks = @ebooks.sorted_by(params[:sort_by])

      render json: serialize_ebooks(@ebooks), status: :ok
    end

    def search
      if params[:q].blank?
        return render json: { error: "Search query 'q' parameter is required" }, status: :bad_request
      end

      @ebooks = Ebook.with_attached_file.with_attached_cover_image.search_by_keyword(params[:q]).filter_by_file_type(params[:file_type]).sorted_by(params[:sort_by])

      render json: serialize_ebooks(@ebooks), status: :ok
    end

    def show
      render json: serialize_ebook(@ebook), status: :ok
    end

    def create
      file = params[:file]
      if file.blank?
        return render json: { error: "No file was uploaded. 'file' parameter is required." }, status: :unprocessable_entity
      end

      original_filename = file.original_filename
      file_extension = File.extname(original_filename).delete('.').downcase
      file_size = file.size

      title = params[:title].presence || File.basename(original_filename, ".*").titleize
      author = params[:author].presence || "Unknown Author"

      @ebook = Ebook.new(
        title: title,
        author: author,
        file_type: file_extension,
        file_size: file_size
      )

      @ebook.file.attach(file)

      if params[:cover_image].present?
        @ebook.cover_image.attach(params[:cover_image])
      end

      if @ebook.save
        render json: serialize_ebook(@ebook), status: :created
      else
        render json: { errors: @ebook.errors.full_messages }, status: :unprocessable_entity
      end
    rescue => e
      render json: { error: "An error occurred during upload: #{e.message}" }, status: :internal_server_error
    end

    def download
      if @ebook.file.attached?
        send_data @ebook.file.download,
                  filename: @ebook.file.filename.to_s,
                  type: @ebook.file.content_type,
                  disposition: "attachment"
      else
        render json: { error: "File attachment not found for this ebook." }, status: :not_found
      end
    end

    def destroy
      if @ebook.destroy
        render json: { message: "Ebook '#{@ebook.title}' was successfully deleted." }, status: :ok
      else
        render json: { error: "Failed to delete ebook." }, status: :unprocessable_entity
      end
    end

    private

    def set_ebook
      @ebook = Ebook.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Ebook not found with ID #{params[:id]}" }, status: :not_found
    end

    def serialize_ebooks(ebooks)
      ebooks.map { |ebook| serialize_ebook(ebook) }
    end

    def serialize_ebook(ebook)
      {
        id: ebook.id,
        title: ebook.title,
        author: ebook.author,
        file_type: ebook.file_type,
        file_size: ebook.file_size,
        upload_date: ebook.upload_date.iso8601,
        file_name: ebook.file.attached? ? ebook.file.filename.to_s : nil,
        file_url: ebook.file.attached? ? rails_blob_url(ebook.file, only_path: false) : nil,
        cover_image_url: ebook.cover_image.attached? ? rails_blob_url(ebook.cover_image, only_path: false) : nil
      }
    end
  end
end
