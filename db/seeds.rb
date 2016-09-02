# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# rubocop:disable Style/IndentArray

chapters = Chapter.create([
  { chapter_name: 'Kigali' }
])

chapters[0].groups.create([
  { group_name: 'A' },
  { group_name: 'B' }
])

groups[0].students.create([
  { first_name: 'Innocent', last_name: 'Ngabo', dob: '2003-01-01', estimated_dob: 'true' },
  { first_name: 'Emmanuel', last_name: 'Ishimwe', dob: '2007-01-01', estimated_dob: 'true' },
  { first_name: 'Eric', last_name: 'Manirakize', dob: '2005-01-01', estimated_dob: 'true' },
  { first_name: 'Felix', last_name: 'Nyonkuru', dob: '2001-01-01', estimated_dob: 'true' },
  { first_name: 'Rene', last_name: 'Uwase', dob: '1999-01-01', estimated_dob: 'true' },
  { first_name: 'Patrick', last_name: 'Ishimwe', dob: '2005-11-28', estimated_dob: 'false' },
  { first_name: 'Jean', last_name: 'Musangemana', dob: '2003-01-01', estimated_dob: 'true' },
  { first_name: 'Jean de Dieu', last_name: 'Gihozo', dob: '2002-01-01', estimated_dob: 'true' },
  { first_name: 'Eugene', last_name: 'Herreimma', dob: '2002-01-01', estimated_dob: 'true' },
  { first_name: 'Musa', last_name: 'Byiringiro', dob: '2000-01-01', estimated_dob: 'true' },
  { first_name: 'Simon', last_name: 'Ndamage', dob: '2000-01-01', estimated_dob: 'true' },
  { first_name: 'Jean Paul', last_name: 'Kaysire', dob: '2002-07-15', estimated_dob: 'false' },
  { first_name: 'Andre', last_name: 'Iradukunda', dob: '2003-01-01', estimated_dob: 'true' },
  { first_name: 'Diel', last_name: 'Ndamage', dob: '2002-01-01', estimated_dob: 'true' },
  { first_name: 'Pacifique', last_name: 'Munykazi', dob: '2001-01-01', estimated_dob: 'true' }
])

groups[1].students.create([
  { first_name: 'Simon', last_name: 'Nubgazo', dob: '2001-01-01', estimated_dob: 'true' },
  { first_name: 'Moise', last_name: 'Izombigaze', dob: '2002-01-01', estimated_dob: 'true' },
  { first_name: 'Pacifique', last_name: 'Manireba', dob: '2008-01-01', estimated_dob: 'true' },
  { first_name: 'Fiston', last_name: 'Nyonkuza', dob: '2007-01-01', estimated_dob: 'true' },
  { first_name: 'Jean de Dieu', last_name: 'Umbawaze', dob: '1999-03-02', estimated_dob: 'false' },
  { first_name: 'Innocent', last_name: 'Ishimwe', dob: '1999-01-01', estimated_dob: 'true' },
  { first_name: 'Zidane', last_name: 'Musange', dob: '2003-01-01', estimated_dob: 'true' },
  { first_name: 'Jean Baptiste', last_name: 'Zabimogo', dob: '2001-01-01', estimated_dob: 'true' },
  { first_name: 'Yessin', last_name: 'Ibumina', dob: '2001-01-01', estimated_dob: 'true' },
  { first_name: 'Felix', last_name: 'Byiringira', dob: '1999-01-01', estimated_dob: 'true' },
  { first_name: 'Rene', last_name: 'Zabumazi', dob: '1999-01-01', estimated_dob: 'true' },
  { first_name: 'Eugene', last_name: 'Nyongazi', dob: '2000-01-01', estimated_dob: 'true' },
  { first_name: 'Ssali', last_name: 'Maniwarazi', dob: '2004-01-01', estimated_dob: 'true' },
  { first_name: 'Thierry', last_name: 'Isokazy', dob: '2005-01-01', estimated_dob: 'true' },
  { first_name: 'Diel', last_name: 'Munyakazi', dob: '2002-01-01', estimated_dob: 'true' }
])
