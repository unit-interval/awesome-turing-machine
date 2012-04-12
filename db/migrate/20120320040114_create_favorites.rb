class CreateFavorites < ActiveRecord::Migration
  def change
    create_table :favorites do |t|
      t.belongs_to :user
      t.belongs_to :turing_machine

      t.timestamps
    end
    add_index :favorites, :user_id
    add_index :favorites, :turing_machine_id
  end
end
