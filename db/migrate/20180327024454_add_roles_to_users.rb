class AddRolesToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :roles, :text, default: [], array: true
  end
end
