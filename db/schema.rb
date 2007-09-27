# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 9) do

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
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

  create_table "test_case_versions", :force => true do |t|
    t.integer  "test_case_id"
    t.integer  "version"
    t.string   "title"
    t.text     "body"
    t.integer  "user_id"
    t.integer  "priority_in_feature"
    t.integer  "prioirty_in_product"
    t.float    "estimate_in_hours"
    t.boolean  "automated"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "updated_by"
    t.integer  "category_id"
  end

  create_table "test_cases", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "user_id"
    t.integer  "priority_in_feature"
    t.integer  "prioirty_in_product"
    t.float    "estimate_in_hours"
    t.boolean  "automated"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version"
    t.integer  "updated_by"
    t.integer  "category_id"
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
  end

end
