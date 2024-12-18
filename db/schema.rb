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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20_160_218_074_219) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'activations', force: true do |t|
    t.string   'title'
    t.string   'name'
    t.string   'phone'
    t.string   'email'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'status'
  end

  create_table 'active_admin_comments', force: true do |t|
    t.string   'namespace'
    t.text     'body'
    t.string   'resource_id',   null: false
    t.string   'resource_type', null: false
    t.integer  'author_id'
    t.string   'author_type'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'active_admin_comments', %w[author_type author_id], name: 'index_active_admin_comments_on_author_type_and_author_id', using: :btree
  add_index 'active_admin_comments', ['namespace'], name: 'index_active_admin_comments_on_namespace', using: :btree
  add_index 'active_admin_comments', %w[resource_type resource_id], name: 'index_active_admin_comments_on_resource_type_and_resource_id', using: :btree

  create_table 'admin_users', force: true do |t|
    t.string   'email',                  default: '', null: false
    t.string   'encrypted_password',     default: '', null: false
    t.string   'reset_password_token'
    t.datetime 'reset_password_sent_at'
    t.datetime 'remember_created_at'
    t.integer  'sign_in_count', default: 0, null: false
    t.datetime 'current_sign_in_at'
    t.datetime 'last_sign_in_at'
    t.inet     'current_sign_in_ip'
    t.inet     'last_sign_in_ip'
    t.datetime 'created_at',                          null: false
    t.datetime 'updated_at',                          null: false
  end

  add_index 'admin_users', ['email'], name: 'index_admin_users_on_email', unique: true, using: :btree
  add_index 'admin_users', ['reset_password_token'], name: 'index_admin_users_on_reset_password_token', unique: true, using: :btree

  create_table 'donations', force: true do |t|
    t.string   'name'
    t.string   'email'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'kiosk_id'
    t.decimal  'amount'
    t.string   'cardconnectref'
  end

  add_index 'donations', ['kiosk_id'], name: 'index_donations_on_kiosk_id', using: :btree

  create_table 'kiosks', force: true do |t|
    t.string   'title'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'user_id'
  end

  add_index 'kiosks', ['user_id'], name: 'index_kiosks_on_user_id', using: :btree

  create_table 'users', force: true do |t|
    t.string   'email',                  default: '', null: false
    t.string   'encrypted_password',     default: '', null: false
    t.string   'reset_password_token'
    t.datetime 'reset_password_sent_at'
    t.datetime 'remember_created_at'
    t.integer  'sign_in_count', default: 0, null: false
    t.datetime 'current_sign_in_at'
    t.datetime 'last_sign_in_at'
    t.string   'current_sign_in_ip'
    t.string   'last_sign_in_ip'
    t.datetime 'created_at',                          null: false
    t.datetime 'updated_at',                          null: false
    t.string   'unconfirmed_email'
    t.string   'confirmation_token'
    t.datetime 'confirmed_at'
    t.datetime 'confirmation_sent_at'
    t.string   'username', default: '', null: false
    t.string   'publishable_key'
    t.string   'provider'
    t.string   'uid'
    t.string   'access_code'
    t.string   'merchid'
  end

  add_index 'users', ['confirmation_token'], name: 'index_users_on_confirmation_token', unique: true, using: :btree
  add_index 'users', ['email'], name: 'index_users_on_email', unique: true, using: :btree
  add_index 'users', ['reset_password_token'], name: 'index_users_on_reset_password_token', unique: true, using: :btree
  add_index 'users', ['username'], name: 'index_users_on_username', unique: true, using: :btree
end
