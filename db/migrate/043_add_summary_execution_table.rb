class AddSummaryExecutionTable < ActiveRecord::Migration
  def self.up
    create_table "execution_summaries", :id => false, :force => true do |t|
      t.date "date"
      t.integer  "playlist_id"
      t.integer  "passed"
      t.integer  "failed"
      t.integer  "blocked"
      t.integer  "nyied"
    end  
    add_index(:execution_summaries, [:playlist_id,:date], :unique => true)
    add_index(:execution_summaries, :playlist_id)
    ExecutionSummary.build_summary
  end

  def self.down
    drop_table :execution_summaries
  end
end
