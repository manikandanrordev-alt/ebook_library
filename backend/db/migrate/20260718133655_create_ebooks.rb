class CreateEbooks < ActiveRecord::Migration[8.1]
  def change
    create_table :ebooks do |t|
      t.string :title, null: false
      t.string :author
      t.string :file_type, null: false
      t.bigint :file_size, null: false  # Use bigint for large files if needed

      t.timestamps
    end

    add_index :ebooks, :title
    add_index :ebooks, :author
  end
end
