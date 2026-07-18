class Ebook < ApplicationRecord
  has_one_attached :file
  has_one_attached :cover_image

  validates :title, presence: true
  validates :file_type, presence: true, inclusion: { in: %w[pdf epub], message: "format %{value} is not supported (PDF and EPUB only)" }
  validates :file_size, presence: true, numericality: { greater_than: 0 }
  
  validate :must_have_file_attached, on: :create

  scope :sorted_by, ->(sort_option) {
    case sort_option.to_s
    when 'recently_uploaded'
      order(created_at: :desc)
    when 'title_asc'
      order(Arel.sql("LOWER(title) ASC"))
    when 'title_desc'
      order(Arel.sql("LOWER(title) DESC"))
    when 'author_asc'
      order(Arel.sql("LOWER(author) ASC"))
    when 'author_desc'
      order(Arel.sql("LOWER(author) DESC"))
    else
      order(created_at: :desc)
    end
  }

  scope :filter_by_file_type, ->(type) {
    where(file_type: type.to_s.downcase) if type.present?
  }

  scope :search_by_keyword, ->(query) {
    if query.present?
      cleaned_query = "%#{sanitize_sql_like(query)}%"
      left_joins(file_attachment: :blob)
        .where(
          "ebooks.title ILIKE :q OR ebooks.author ILIKE :q OR active_storage_blobs.filename ILIKE :q",
          q: cleaned_query
        )
    end
  }

  def upload_date
    created_at
  end

  private

  def must_have_file_attached
    errors.add(:file, "must be uploaded") unless file.attached?
  end
end
