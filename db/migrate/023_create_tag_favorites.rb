class CreateTagFavorites < ActiveRecord::Migration
  def self.up
    create_table :tag_favorites do |t|
      t.integer :tag_id

      t.timestamps 
    end
  end

  def self.down
    drop_table :tag_favorites
  end
end
