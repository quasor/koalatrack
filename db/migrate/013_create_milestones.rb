class CreateMilestones < ActiveRecord::Migration
  def self.up
    create_table :milestones do |t|
      t.text :name
      t.date :due_on

      t.timestamps 
    end
  end

  def self.down
    drop_table :milestones
  end
end
