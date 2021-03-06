# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090925212944) do

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.string   "ancestor_cache"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "children_count", :default => 0
    t.integer  "group_id"
  end

  add_index "categories", ["parent_id"], :name => "index_categories_on_parent_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.string   "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "execution_summaries", :id => false, :force => true do |t|
    t.date    "date"
    t.integer "playlist_id"
    t.integer "passed"
    t.integer "failed"
    t.integer "blocked"
    t.integer "nyied"
  end

  add_index "execution_summaries", ["playlist_id", "date"], :name => "index_execution_summaries_on_playlist_id_and_date", :unique => true
  add_index "execution_summaries", ["playlist_id"], :name => "index_execution_summaries_on_playlist_id"

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

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "bug_url"
  end

  create_table "koala_test_case_versions", :force => true do |t|
    t.integer  "koala_test_case_id"
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
    t.boolean  "active",                :default => true
    t.string   "automation_class_path"
  end

  add_index "koala_test_case_versions", ["koala_test_case_id"], :name => "index_test_case_versions_on_test_case_id"

  create_table "koala_test_cases", :force => true do |t|
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
    t.integer  "version"
    t.string   "project_id"
    t.boolean  "active",                :default => true
    t.string   "automation_class_path"
  end

  add_index "koala_test_cases", ["category_id"], :name => "index_test_cases_on_category_id"

  create_table "milestones", :force => true do |t|
    t.text     "name"
    t.date     "due_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id"
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
    t.integer  "position"
  end

  add_index "playlist_test_cases", ["playlist_id"], :name => "index_playlist_test_cases_on_playlist_id"
  add_index "playlist_test_cases", ["test_case_id"], :name => "index_playlist_test_cases_on_test_case_id"

  create_table "playlists", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "user_id"
    t.integer  "milestone_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "dead",         :default => false
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
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
    t.integer  "group_id"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"
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

  add_index "test_case_executions", ["playlist_test_case_id"], :name => "index_test_case_executions_on_playlist_test_case_id"
  add_index "test_case_executions", ["test_case_id"], :name => "index_test_case_executions_on_test_case_id"

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
    t.integer  "role_id",                                 :default => 3
    t.integer  "group_id"
  end

end
