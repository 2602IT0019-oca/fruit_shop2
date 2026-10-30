
# frozen_string_literal: true

class AddTrackableToDevise < ActiveRecord::Migration[8.0]
  def change
    # Trackable関連のカラムはDeviseCreateUsersで作成済み
  end
end
