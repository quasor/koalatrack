class CreateFileAttachments < ActiveRecord::Migration
  def self.up
    create_table :file_attachments do |t|
      t.integer :parent_id
      t.integer :test_case_id
      t.string :content_type
      t.string :filename
      t.string :thumbnail
      t.integer :size
      t.integer :width
      t.integer :height

      t.timestamps 
    end
  end

  def self.down
    drop_table :file_attachments
  end
end
