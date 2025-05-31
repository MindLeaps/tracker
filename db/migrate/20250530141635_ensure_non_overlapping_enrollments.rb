class EnsureNonOverlappingEnrollments < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
        create extension if not exists btree_gist;

        alter table enrollments
        add constraint non_overlapping_enrollments
        exclude using gist (
            student_id with =,
            group_id with =,
            tsrange(active_since, inactive_since) with &&
        );
    SQL
  end

  def down
    execute <<-SQL
        alter table enrollments
        drop constraint non_overlapping_enrollments;
    SQL
  end
end
