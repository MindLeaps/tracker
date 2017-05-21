# frozen_string_literal: true

# rubocop:disable Style/IndentArray
# rubocop:disable Metrics/LineLength
# rubocop:disable Metrics/MethodLength
def seed_mindleaps_skills(organization)
  Skill.create([
    { skill_name: 'Memorization', skill_description: 'Ability to learn and recall sequences or patterns of information.', organization: organization, grade_descriptors: GradeDescriptor.create([
      { mark: 1, grade_description: 'Student cannot recall a sequence of 4 steps even after prompted at least three times' },
      { mark: 2, grade_description: 'Student can recall a sequence of 4 steps with 1 or no prompts' },
      { mark: 3, grade_description: 'Student can recall at least 2 sections of the warm up from class to class' },
      { mark: 4, grade_description: 'Student can recall entire warm up sequence, moving in time with the teacher, and can repeat diagonal steps after one prompt from the teacher' },
      { mark: 5, grade_description: 'Student can recall entire warm up sequence without teacher guidance, at least four diagonal steps, and at least 16 counts of choreography without teacher prompts' },
      { mark: 6, grade_description: 'Student can recall entire warm up, at least eight diagonal steps, all of choreography and name at least 6 muscles without teacher prompts' },
      { mark: 7, grade_description: 'Student can memorize a new sequence of choreography given in one class and do all of the above' }
    ]) },
    { skill_name: 'Grit', skill_description: 'Perseverance and passion for long-term goals.', organization: organization, grade_descriptors: GradeDescriptor.create([
      { mark: 1, grade_description: 'Student arrives at the center but does not participate in dance class even with teacher or peer encouragement' },
      { mark: 2, grade_description: 'Student participates in less than half of the class' },
      { mark: 3, grade_description: 'Student is present but not actively trying throughout the entire class' },
      { mark: 4, grade_description: 'Student participates in warm up, recognizes change in directions, understands number repetitions, and completes at least 1/2 of diagonal or choreography sections of class' },
      { mark: 5, grade_description: 'Student participates in the entire class and noticeably demonstrates persistence when struggling' },
      { mark: 6, grade_description: 'All of the above and student asks or answers questions' },
      { mark: 7, grade_description: 'Student shows an extraordinary level of commitment by either practicing before/after class (self-initiated), asking questions that suggest a deeper analysis, or asking for more opportunities to practice' }
    ]) },
    { skill_name: 'Teamwork', skill_description: 'Ability to work and/or create with other students.', organization: organization, grade_descriptors: GradeDescriptor.create([
      { mark: 1, grade_description: 'Student refuses to hold hands or interact with partner in a required sequence across the floor' },
      { mark: 2, grade_description: 'Student will do above, but is unable to work or communicate with his/her peer in any piece of choreography or another part of class, even when encouraged by the teacher' },
      { mark: 3, grade_description: 'Student can work together with his/her peer in 2 or 3 simple steps in diagonal (two by two) or choreography when demonstrated/encouraged by the teacher with two verbal prompts' },
      { mark: 4, grade_description: 'Student can work together with his/her peer in a section of diagonal (two by two) and complete at least four partnered/group movements in choreography' },
      { mark: 5, grade_description: 'Student can work in a group to create a short choreographic piece with teacher coaching' },
      { mark: 6, grade_description: 'Student can work in a group to create a short choreographic piece without teacher coaching' },
      { mark: 7, grade_description: 'Student can work in a group to create a piece that is presented to the rest of class' }
    ]) },
    { skill_name: 'Discipline', skill_description: 'Ability to obey rules and/or a code of conduct.', organization: organization, grade_descriptors: GradeDescriptor.create([
      { mark: 1, grade_description: 'Student repeatedly talks back, fights, hits or argues with peers and teachers and does not stop even when asked repeatedly; student is sent out of the class for 5-10 minutes by the teacher' },
      { mark: 2, grade_description: 'Student has to be reminded at least twice by name to respect his peers and/or pay attention to the teacher' },
      { mark: 3, grade_description: 'Student has to be reminded once by name to respect his peers or pay attention to the teacher' },
      { mark: 4, grade_description: 'Student respects/pays attention to the teacher, but bothers his peers, or vice versa (with no comments/prompts by teacher)' },
      { mark: 5, grade_description: 'Student works well with others and no teacher intervention is needed' },
      { mark: 6, grade_description: 'Student actively encourages others to pay attention and improve their behavior' },
      { mark: 7, grade_description: 'Student actively becomes a role model of exceptional, respectful behavior to the others' }
    ]) },
    { skill_name: 'Self-Esteem', skill_description: 'Confidence in one’s own abilities.', organization: organization, grade_descriptors: GradeDescriptor.create([
      { mark: 1, grade_description: 'Student cannot perform any movement isolated (by himself)' },
      { mark: 2, grade_description: 'Student can perform a sequence of 2-4 steps on his own' },
      { mark: 3, grade_description: 'Student can continue through warm up sections and repetition of diagonal steps without encouragement from the teacher' },
      { mark: 4, grade_description: 'Student can demonstrate by himself steps of the diagonal and volunteer parts of the choreography when asked by the teacher' },
      { mark: 5, grade_description: 'Student can demonstrate the warm up, diagonal steps and all of the choreography by himself with confidence and no prompts' },
      { mark: 6, grade_description: 'Student can verbally explain movement in the warm up, diagonal and choreography' },
      { mark: 7, grade_description: 'Student demonstrates confidence as a person and dancer through extending full use of body in space ' }
    ]) },
    { skill_name: 'Creativity & Self-Expression', skill_description: 'Use of imagination.', organization: organization, grade_descriptors: GradeDescriptor.create([
      { mark: 1, grade_description: 'Student is unable to demonstrate personal creativity by making up any pose or movement of his own' },
      { mark: 2, grade_description: 'Student can only demontrate creative movement in a single step or movement with teacher\'s prompts' },
      { mark: 3, grade_description: 'Student can make up his own arms for a sequence of steps' },
      { mark: 4, grade_description: 'Student can only demonstrate creative movement in a series of steps by copying the teacher or peer\'s earlier demonstration' },
      { mark: 5, grade_description: 'Student can create his own movements that have not been taught before and differ from standard hip hop moves' },
      { mark: 6, grade_description: 'Student can create his own choreography' },
      { mark: 7, grade_description: 'Student can create his own choreography and present it' }
    ]) },
    { skill_name: 'Language', skill_description: 'The process to understand and communicate.', organization: organization, grade_descriptors: GradeDescriptor.create([
      { mark: 1, grade_description: 'Student is unable to count in a foreign language (eg English)' },
      { mark: 2, grade_description: 'Student can count with teacher prompting, and can recall some basic words with one prompt' },
      { mark: 3, grade_description: 'Student can count without prompts and recall some words' },
      { mark: 4, grade_description: 'Student can recite positions in the warm up, at least six of the diagonal steps\' names and positions' },
      { mark: 5, grade_description: 'Student can recite positions in warm up, diagonal steps, and muscle names' },
      { mark: 6, grade_description: 'Student can recite simple phrases (minimum of 3 words)' },
      { mark: 7, grade_description: 'Student can make himself understood to ask questions or make comments' }
    ]) }
  ])
end
