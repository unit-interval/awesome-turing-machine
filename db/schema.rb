# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120320040114) do

  create_table "favorites", :force => true do |t|
    t.integer  "user_id"
    t.integer  "turing_machine_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "favorites", ["turing_machine_id"], :name => "index_favorites_on_turing_machine_id"
  add_index "favorites", ["user_id"], :name => "index_favorites_on_user_id"

  create_table "invitations", :force => true do |t|
    t.string   "code"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "invitations", ["code"], :name => "index_invitations_on_code", :unique => true
  add_index "invitations", ["user_id"], :name => "index_invitations_on_user_id"

  create_table "turing_machines", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "default_input"
    t.string   "definition"
    t.string   "short_url"
    t.integer  "users_count",   :default => 0
    t.integer  "user_id"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "turing_machines", ["short_url"], :name => "index_turing_machines_on_short_url"
  add_index "turing_machines", ["user_id"], :name => "index_turing_machines_on_user_id"
  add_index "turing_machines", ["users_count"], :name => "index_turing_machines_on_users_count"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "hashed_password"
    t.string   "salt"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

end
