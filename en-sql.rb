require 'sqlite3'
require 'csv'
require '~/scripts/rubylibs/util'

# user settings
csv_out = './evernote.csv'
user_name = 'NAME'
db_path = "#{Dir.home()}/Library/Application Support/Evernote/accounts/Evernote/#{user_name}/Evernote.sql"
# End of user settings

def bind_row(bef, aft)
  unless bef.class == Array and aft.class == Array
    raise TypeError
  end
  bef + aft
end

def add_row(bef, aft)
  unless bef.class == Array and aft.class == Array
    raise TypeError
  end
  bef + [aft]
end

def exec(db, query)
  out = []
  db.execute query do |row|
    out = add_row out, row
  end
  out
end

def list_names(pk_list)
  out = []
  pk_list.each do |row|
    out = bind_row out, [row[1]]
  end
  out
end

q_tags = <<-EOF
SELECT
Z_PK, ZNAME2
FROM ZENATTRIBUTEDENTITY
WHERE Z_ENT=17
EOF

q_notebooks = <<-EOF
SELECT
Z_PK, ZNAME
FROM ZENATTRIBUTEDENTITY
WHERE Z_ENT=13
EOF

q_all_notes = <<-EOF
SELECT
Z_PK, ZNOTEBOOK1, ZCREATED
FROM ZENATTRIBUTEDENTITY
WHERE Z_ENT=12
EOF

q_tags_and_notebook = <<-EOF
SELECT
Z_12NOTES, Z_17TAGS
FROM Z_12TAGS
EOF

db = SQLite3::Database.new db_path
csv = ['PK', 'Date', 'Name']
csv_string = ''
pk_tags           = exec(db, q_tags)
pk_notebooks      = exec(db, q_notebooks)
pk_all_notes      = exec(db, q_all_notes)
tags_and_notebook = exec(db, q_tags_and_notebook)
tag_names      = list_names pk_tags
notebook_names = list_names pk_notebooks

# main
def find_pk_name(pk_list, pk)
  out = nil
  pk_list.each do |row|
    if row[0] == pk
      name = row[1]
      out = name
      break
    end
  end
  out
end

def fill_row(name_lists, name)
  row = []
  name_lists.each do |n|
    if n == name
      row = bind_row(row, [1])
    else
      row = bind_row(row, [0])
    end
  end
  row
end

def std_stamp(time)
  (time + 978307200).round
end

csv = add_row([], csv)
# csv = bind_row(csv, notebook_names)
# csv = add_row([], csv)

pk_all_notes.each do |note_row|
  row = []
  pk = note_row[0]
  notebook = note_row[1]
  created = note_row[2]
  row = bind_row(row, [pk])
  row = bind_row(row, [std_stamp(created)])

  row = bind_row(row, [find_pk_name(pk_notebooks, notebook)])

  # notebook looping
  # name = find_pk_name(pk_notebooks, notebook)
  # row = bind_row(row, fill_row(notebook_names, name))

  csv = add_row(csv, row)
end

csv.map do |row|
  p row[1]
end
p 'hello'
p csv

# csv.each do |row|
  # csv_string = csv_string << row.to_csv
# end

# Util.write_file(csv_out, csv_string)
