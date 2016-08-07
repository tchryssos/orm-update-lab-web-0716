require_relative "../config/environment.rb"
require 'pry'

class Student

 attr_accessor :name, :grade, :id

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(name, grade, id=nil)
    @name=name
    @grade=grade
    @id=id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql= "DROP TABLE IF EXISTS students;"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)

      sql2= <<-SQL
      SELECT id FROM students
      WHERE id=(SELECT MAX(id) FROM students);
      SQL

      self.id=DB[:conn].execute(sql2)[0][0]
    end
  end

  def self.create(name, grade)
    student=Student.new(name, grade)
    student.save
  end

  def self.new_from_db(row)
    student=self.new(row[1],row[2], row[0])
    student
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students
      WHERE students.name = ?
    SQL

    results=DB[:conn].execute(sql, name)

    Student.new_from_db(results[0])
  end

  def update
    sql=<<-SQL
    UPDATE students SET name=?, grade=? WHERE id=?;
    SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end
end
