class AddSelectedCourseIdToTournaments2 < ActiveRecord::Migration[5.1]
  def change
    add_column :tournaments2_specs, :selected_course_id, :decimal, precision: 22, scale: 0
    add_column :tournaments2_events, :selected_course_id, :decimal, precision: 22, scale: 0
  end
end