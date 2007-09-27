class CreateTestCases < ActiveRecord::Migration
  def self.up
    create_table :test_cases do |t|
      t.string :title
      t.text :body
      t.integer :owner_id
      t.integer :priority_in_feature
      t.integer :prioirty_in_product
      t.float :estimate_in_hours
      t.boolean :automated

      t.timestamps 
    end
  end

  def self.down
    drop_table :test_cases
  end
end
