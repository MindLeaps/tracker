# frozen_string_literal: true

# rubocop:disable Style/IndentArray

require_relative 'seed_skills'
require_relative 'seed_random_grades'
require_relative 'seed_csv_grades'

mindleaps = Organization.create organization_name: 'MindLeaps'
mindleaps.chapters.create([
  { chapter_name: 'Random' },
  { chapter_name: 'Rwanda' },
  { chapter_name: 'Uganda' }
])

kigali_chapter = mindleaps.chapters[0]

kigali_chapter.groups.create([
  { group_name: 'A' },
  { group_name: 'B' }
])

kigali_chapter.groups[0].students.create([
  { mlid: 'A1', first_name: 'Innocent', last_name: 'Ngabo', dob: '2003-01-01', estimated_dob: 'true', organization: mindleaps },
  { mlid: 'A2', first_name: 'Emmanuel', last_name: 'Ishimwe', dob: '2007-01-01', estimated_dob: 'true', organization: mindleaps },
  { mlid: 'A3', first_name: 'Eric', last_name: 'Manirakize', dob: '2005-01-01', estimated_dob: 'true', organization: mindleaps },
  { mlid: 'A4', first_name: 'Felix', last_name: 'Nyonkuru', dob: '2001-01-01', estimated_dob: 'true', organization: mindleaps },
  { mlid: 'A5', first_name: 'Rene', last_name: 'Uwase', dob: '1999-01-01', estimated_dob: 'true', organization: mindleaps },
  { mlid: 'A6', first_name: 'Patrick', last_name: 'Ishimwe', dob: '2005-11-28', estimated_dob: 'false', organization: mindleaps },
  { mlid: 'A7', first_name: 'Jean', last_name: 'Musangemana', dob: '2003-01-01', estimated_dob: 'true', organization: mindleaps },
  { mlid: 'A8', first_name: 'Jean de Dieu', last_name: 'Gihozo', dob: '2002-01-01', estimated_dob: 'true', organization: mindleaps },
  { mlid: 'A9', first_name: 'Eugene', last_name: 'Herreimma', dob: '2002-01-01', estimated_dob: 'true', organization: mindleaps },
  { mlid: 'A10', first_name: 'Musa', last_name: 'Byiringiro', dob: '2000-01-01', estimated_dob: 'true', organization: mindleaps },
  { mlid: 'A11', first_name: 'Simon', last_name: 'Ndamage', dob: '2000-01-01', estimated_dob: 'true', organization: mindleaps },
  { mlid: 'A12', first_name: 'Jean Paul', last_name: 'Kaysire', dob: '2002-07-15', estimated_dob: 'false', organization: mindleaps },
  { mlid: 'A13', first_name: 'Andre', last_name: 'Iradukunda', dob: '2003-01-01', estimated_dob: 'true', organization: mindleaps },
  { mlid: 'A14', first_name: 'Diel', last_name: 'Ndamage', dob: '2002-01-01', estimated_dob: 'true', organization: mindleaps },
  { mlid: 'A15', first_name: 'Pacifique', last_name: 'Munykazi', dob: '2001-01-01', estimated_dob: 'true', organization: mindleaps }
])

kigali_chapter.groups[1].students.create([
  { mlid: 'B1', first_name: 'Simon', last_name: 'Nubgazo', dob: '2001-01-01', estimated_dob: 'true', organization: mindleaps },
  { mlid: 'B2', first_name: 'Moise', last_name: 'Izombigaze', dob: '2002-01-01', estimated_dob: 'true', organization: mindleaps },
  { mlid: 'B3', first_name: 'Pacifique', last_name: 'Manireba', dob: '2008-01-01', estimated_dob: 'true', organization: mindleaps },
  { mlid: 'B4', first_name: 'Fiston', last_name: 'Nyonkuza', dob: '2007-01-01', estimated_dob: 'true', organization: mindleaps },
  { mlid: 'B5', first_name: 'Jean de Dieu', last_name: 'Umbawaze', dob: '1999-03-02', estimated_dob: 'false', organization: mindleaps },
  { mlid: 'B6', first_name: 'Innocent', last_name: 'Ishimwe', dob: '1999-01-01', estimated_dob: 'true', organization: mindleaps },
  { mlid: 'B7', first_name: 'Zidane', last_name: 'Musange', dob: '2003-01-01', estimated_dob: 'true', organization: mindleaps },
  { mlid: 'B8', first_name: 'Jean Baptiste', last_name: 'Zabimogo', dob: '2001-01-01', estimated_dob: 'true', organization: mindleaps },
  { mlid: 'B9', first_name: 'Yessin', last_name: 'Ibumina', dob: '2001-01-01', estimated_dob: 'true', organization: mindleaps },
  { mlid: 'B10', first_name: 'Felix', last_name: 'Byiringira', dob: '1999-01-01', estimated_dob: 'true', organization: mindleaps },
  { mlid: 'B11', first_name: 'Rene', last_name: 'Zabumazi', dob: '1999-01-01', estimated_dob: 'true', organization: mindleaps },
  { mlid: 'B12', first_name: 'Eugene', last_name: 'Nyongazi', dob: '2000-01-01', estimated_dob: 'true', organization: mindleaps },
  { mlid: 'B13', first_name: 'Ssali', last_name: 'Maniwarazi', dob: '2004-01-01', estimated_dob: 'true', organization: mindleaps },
  { mlid: 'B14', first_name: 'Thierry', last_name: 'Isokazy', dob: '2005-01-01', estimated_dob: 'true', organization: mindleaps },
  { mlid: 'B15', first_name: 'Diel', last_name: 'Munyakazi', dob: '2002-01-01', estimated_dob: 'true', organization: mindleaps }
])

subjects = Subject.create([
  { subject_name: 'Classical Dance', organization: mindleaps },
  { subject_name: 'Contemporary Dance', organization: mindleaps }
])

subjects[0].skills = seed_mindleaps_skills mindleaps

seed_group_random_grades(kigali_chapter.groups[0], subjects[0])

CSVDataSeeder.new('./db/seed_data/rwanda_data.csv').seed_data mindleaps.chapters[1], subjects[0]
CSVDataSeeder.new('./db/seed_data/uganda_data.csv').seed_data mindleaps.chapters[2], subjects[0]
