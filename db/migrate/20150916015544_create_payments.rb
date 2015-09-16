class CreatePayments < ActiveRecord::Migration
        def change
                create_table :payments do |t|
                        t.integer :type
                        t.reference :order
                        t.text :trade_info
                end
        end
end
