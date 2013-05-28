class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.integer :bee_id
      t.integer :retakeable
      t.integer :accessibility

      t.timestamps
    end
  end
end
