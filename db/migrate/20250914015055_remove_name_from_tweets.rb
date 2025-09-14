class RemoveNameFromTweets < ActiveRecord::Migration[7.1]
  def change
    remove_column :tweets, :name, :string
  end
end
