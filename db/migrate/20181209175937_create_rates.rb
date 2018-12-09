class CreateRates < ActiveRecord::Migration[5.2]
  def change
    create_table :rates do |t|
      t.datetime :date
      t.float :usd
      t.float :eur
      t.float :ars

      t.timestamps
    end
  end
end
