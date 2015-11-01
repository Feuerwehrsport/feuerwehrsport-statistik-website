class CreateYears < ActiveRecord::Migration
  def up
    create_sql = Competition.select("EXTRACT(YEAR FROM DATE(competitions.date)) AS year").group("year").order("year").to_sql
    self.connection.execute "CREATE OR REPLACE VIEW years AS #{create_sql}"
  end

  def down
    self.connection.execute "DROP VIEW IF EXISTS years"
  end
end