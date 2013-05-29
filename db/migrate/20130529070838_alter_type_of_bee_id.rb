class AlterTypeOfBeeId < ActiveRecord::Migration
  def up
    change_column :photos, :bee_id, :string
  end

  def down
    change_column :photos, :bee_id, :integer
  end
end
