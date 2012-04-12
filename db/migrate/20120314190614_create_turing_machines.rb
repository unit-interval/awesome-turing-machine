class CreateTuringMachines < ActiveRecord::Migration
  def change
    create_table :turing_machines do |t|
      t.string :name
      t.string :description
      t.string :default_input
      t.string :definition
      t.string :short_url
      t.integer :users_count, :default => 0
      t.belongs_to :user

      t.timestamps
    end
    add_index :turing_machines, :user_id
    add_index :turing_machines, :short_url
    add_index :turing_machines, :users_count
  end
end
