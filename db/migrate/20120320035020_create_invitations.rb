class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.string :code
      t.belongs_to :user

      t.timestamps
    end
    add_index :invitations, :code, :unique => true
    add_index :invitations, :user_id
  end
end
