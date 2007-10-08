# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 28) do

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "file_attachments", :force => true do |t|
    t.integer  "parent_id"
    t.integer  "test_case_id"
    t.string   "content_type"
    t.string   "filename"
    t.string   "thumbnail"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "milestones", :force => true do |t|
    t.text     "name"
    t.date     "due_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "playlist_test_cases", :force => true do |t|
    t.integer  "playlist_id"
    t.integer  "test_case_id"
    t.integer  "test_case_version"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "test_case_executions_count", :default => 0
    t.integer  "last_result",                :default => 0
  end

  create_table "playlists", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "user_id"
    t.integer  "milestone_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :default => "", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "tag_favorites", :force => true do |t|
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "test_case_executions", :force => true do |t|
    t.integer  "playlist_test_case_id"
    t.integer  "test_case_id"
    t.integer  "test_case_version"
    t.integer  "user_id"
    t.integer  "result"
    t.string   "bug_id"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "test_case_versions", :force => true do |t|
    t.integer  "test_case_id"
    t.integer  "version"
    t.string   "title"
    t.text     "body"
    t.integer  "user_id"
    t.integer  "priority_in_feature"
    t.integer  "priority_in_product"
    t.float    "estimate_in_hours"
    t.boolean  "automated"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "updated_by"
    t.integer  "category_id"
    t.string   "tag"
    t.integer  "qatraq_id"
    t.string   "project_id"
  end

  create_table "test_cases", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "user_id"
    t.integer  "priority_in_feature"
    t.integer  "priority_in_product"
    t.float    "estimate_in_hours"
    t.boolean  "automated"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version"
    t.integer  "updated_by"
    t.integer  "category_id"
    t.string   "tag"
    t.integer  "qatraq_id"
    t.string   "project_id"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.boolean  "admin",                                   :default => false
  end

end