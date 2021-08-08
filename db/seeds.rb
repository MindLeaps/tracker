# frozen_string_literal: true

require_relative 'seed_skills'
require_relative 'seed_random_grades'
require_relative 'seed_csv_grades'

ActiveRecord::Base.logger = Logger.new($stdout)

# rubocop:disable Metrics/BlockLength
Organization.transaction do
  mindleaps = Organization.create!({ organization_name: 'MindLeaps', mlid: 'ML1' })
  mindleaps.chapters.create!([
                               { mlid: 'C1', chapter_name: 'Random' },
                               { mlid: 'C2', chapter_name: 'Rwanda' },
                               { mlid: 'C3', chapter_name: 'Uganda' }
                             ])

  kigali_chapter = mindleaps.chapters[0]

  kigali_chapter.groups.create!([
                                  { mlid: 'G1', group_name: 'A' },
                                  { mlid: 'G2', group_name: 'B' }
                                ])

  kigali_chapter.groups[0].students.create!([
                                              { mlid: 'A1', first_name: 'Innocent', last_name: 'Ngabo', gender: 'male', dob: '2003-01-01', estimated_dob: 'true' },
                                              { mlid: 'A2', first_name: 'Emmanuel', last_name: 'Ishimwe', gender: 'male', dob: '2007-01-01', estimated_dob: 'true' },
                                              { mlid: 'A3', first_name: 'Eric', last_name: 'Manirakize', gender: 'male', dob: '2005-01-01', estimated_dob: 'true' },
                                              { mlid: 'A4', first_name: 'Felix', last_name: 'Nyonkuru', gender: 'male', dob: '2001-01-01', estimated_dob: 'true' },
                                              { mlid: 'A5', first_name: 'Rene', last_name: 'Uwase', gender: 'male', dob: '1999-01-01', estimated_dob: 'true' },
                                              { mlid: 'A6', first_name: 'Patrick', last_name: 'Ishimwe', gender: 'male', dob: '2005-11-28', estimated_dob: 'false' },
                                              { mlid: 'A7', first_name: 'Jean', last_name: 'Musangemana', gender: 'male', dob: '2003-01-01', estimated_dob: 'true' },
                                              { mlid: 'A8', first_name: 'Jean de Dieu', last_name: 'Gihozo', gender: 'male', dob: '2002-01-01', estimated_dob: 'true' },
                                              { mlid: 'A9', first_name: 'Eugene', last_name: 'Herreimma', gender: 'male', dob: '2002-01-01', estimated_dob: 'true' },
                                              { mlid: 'A10', first_name: 'Musa', last_name: 'Byiringiro', gender: 'male', dob: '2000-01-01', estimated_dob: 'true' },
                                              { mlid: 'A11', first_name: 'Simon', last_name: 'Ndamage', gender: 'male', dob: '2000-01-01', estimated_dob: 'true' },
                                              { mlid: 'A12', first_name: 'Jean Paul', last_name: 'Kaysire', gender: 'male', dob: '2002-07-15', estimated_dob: 'false' },
                                              { mlid: 'A13', first_name: 'Andre', last_name: 'Iradukunda', gender: 'male', dob: '2003-01-01', estimated_dob: 'true' },
                                              { mlid: 'A14', first_name: 'Diel', last_name: 'Ndamage', gender: 'male', dob: '2002-01-01', estimated_dob: 'true' },
                                              { mlid: 'A15', first_name: 'Pacifique', last_name: 'Munykazi', gender: 'male', dob: '2001-01-01', estimated_dob: 'true' }
                                            ])

  kigali_chapter.groups[1].students.create!([
                                              { mlid: 'B1', first_name: 'Simon', last_name: 'Nubgazo', gender: 'male', dob: '2001-01-01', estimated_dob: 'true' },
                                              { mlid: 'B2', first_name: 'Moise', last_name: 'Izombigaze', gender: 'male', dob: '2002-01-01', estimated_dob: 'true' },
                                              { mlid: 'B3', first_name: 'Pacifique', last_name: 'Manireba', gender: 'male', dob: '2008-01-01', estimated_dob: 'true' },
                                              { mlid: 'B4', first_name: 'Fiston', last_name: 'Nyonkuza', gender: 'male', dob: '2007-01-01', estimated_dob: 'true' },
                                              { mlid: 'B5', first_name: 'Jean de Dieu', last_name: 'Umbawaze', gender: 'male', dob: '1999-03-02', estimated_dob: 'false' },
                                              { mlid: 'B6', first_name: 'Innocent', last_name: 'Ishimwe', gender: 'male', dob: '1999-01-01', estimated_dob: 'true' },
                                              { mlid: 'B7', first_name: 'Zidane', last_name: 'Musange', gender: 'male', dob: '2003-01-01', estimated_dob: 'true' },
                                              { mlid: 'B8', first_name: 'Jean Baptiste', last_name: 'Zabimogo', gender: 'male', dob: '2001-01-01', estimated_dob: 'true' },
                                              { mlid: 'B9', first_name: 'Yessin', last_name: 'Ibumina', gender: 'male', dob: '2001-01-01', estimated_dob: 'true' },
                                              { mlid: 'B10', first_name: 'Felix', last_name: 'Byiringira', gender: 'male', dob: '1999-01-01', estimated_dob: 'true' },
                                              { mlid: 'B11', first_name: 'Rene', last_name: 'Zabumazi', gender: 'male', dob: '1999-01-01', estimated_dob: 'true' },
                                              { mlid: 'B12', first_name: 'Eugene', last_name: 'Nyongazi', gender: 'male', dob: '2000-01-01', estimated_dob: 'true' },
                                              { mlid: 'B13', first_name: 'Ssali', last_name: 'Maniwarazi', gender: 'male', dob: '2004-01-01', estimated_dob: 'true' },
                                              { mlid: 'B14', first_name: 'Thierry', last_name: 'Isokazy', gender: 'male', dob: '2005-01-01', estimated_dob: 'true' },
                                              { mlid: 'B15', first_name: 'Diel', last_name: 'Munyakazi', gender: 'male', dob: '2002-01-01', estimated_dob: 'true' }
                                            ])

  subjects = Subject.create([
                              { subject_name: 'Classical Dance', organization: mindleaps },
                              { subject_name: 'Contemporary Dance', organization: mindleaps }
                            ])

  subjects[0].skills = seed_mindleaps_skills mindleaps

  seed_group_random_grades(kigali_chapter.groups[0], subjects[0])

  CSVDataSeeder.new('./db/seed_data/rwanda_data.csv').seed_data mindleaps.chapters[1], subjects[0]
  CSVDataSeeder.new('./db/seed_data/uganda_data.csv').seed_data mindleaps.chapters[2], subjects[0]
end
# rubocop:enable Metrics/BlockLength
