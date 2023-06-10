# frozen_string_literal: true

require 'sqlite3'

# Dsidx(index file for docset) file handling class
class Dsidx
  def initialize(path = 'docSet.dsidx')
    @db = SQLite3::Database.new(path)
    @db.execute('CREATE TABLE searchIndex(id INTEGER PRIMARY KEY, name TEXT, type TEXT, path TEXT)')
    @db.execute('CREATE UNIQUE INDEX anchor ON searchIndex (name, type, path)')
  end

  def close
    @db.close
  end

  def insert(name, type, path)
    sql = 'INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES (?, ?, ?)'
    @db.execute(sql, name, type, path)
  end
end
