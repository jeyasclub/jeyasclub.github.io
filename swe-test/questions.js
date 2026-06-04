const questions = [
  {
    "id": 1,
    "part": "structure",
    "partName": "Structure",
    "type": "Sentence Completion",
    "difficulty": "easy",
    "question": "_____ the damage caused by the storm, the city council decided to declare a state of emergency.",
    "options": [
      "Because",
      "Despite",
      "Because of",
      "Although"
    ],
    "correct": 2,
    "weight": 1,
    "explanation": "Jawaban C benar karena 'Because of' adalah preposisi yang harus diikuti noun phrase, bukan klausa lengkap. Setelah 'Because of' ada frasa 'the damage caused by the storm' yang merupakan noun phrase. Pilihan 'Because' dan 'Although' membutuhkan klausa dengan subjek dan kata kerja sendiri, sedangkan 'Despite' tidak cocok untuk menunjukkan sebab-akibat."
  },
  {
    "id": 2,
    "part": "structure",
    "partName": "Structure",
    "type": "Sentence Completion",
    "difficulty": "easy",
    "question": "Neither the manager nor the employees _____ aware of the policy change.",
    "options": [
      "was",
      "were",
      "has",
      "have"
    ],
    "correct": 1,
    "weight": 1,
    "explanation": "Dalam konstruksi 'Neither...nor', kata kerja harus mengikuti subjek yang paling dekat. Subjek terdekat adalah 'the employees' (plural), jadi kata kerja yang benar adalah 'were'. Aturan ini disebut proximity rule. Jika urutannya dibalik menjadi 'Neither the employees nor the manager', maka kata kerja yang dipakai adalah 'was'."
  },
  {
    "id": 3,
    "part": "structure",
    "partName": "Structure",
    "type": "Sentence Completion",
    "difficulty": "easy",
    "question": "The committee recommended that the project _____ before the deadline.",
    "options": [
      "completes",
      "completed",
      "be completed",
      "is completed"
    ],
    "correct": 2,
    "weight": 1,
    "explanation": "Kata kerja seperti 'recommend', 'suggest', 'insist', dan 'require' membutuhkan subjunctive mood pada klausa 'that'. Pola subjunctive adalah: subject + base verb (tanpa -s, -ed, atau to). Karena kalimat ini pasif, bentuk yang benar adalah 'be completed'. Pilihan lain salah karena 'completes' menambahkan -s, 'completed' adalah simple past, dan 'is completed' adalah indicative biasa."
  },
  {
    "id": 4,
    "part": "structure",
    "partName": "Structure",
    "type": "Sentence Completion",
    "difficulty": "easy",
    "question": "The course focuses on improving writing skills, developing critical thinking, and _____.",
    "options": [
      "communication skills are enhanced",
      "enhancing communication skills",
      "communication skill enhancement",
      "to enhance communication skills"
    ],
    "correct": 1,
    "weight": 1,
    "explanation": "Parallel structure (kesejajaran) berarti elemen-elemen dengan fungsi yang sama harus pakai bentuk yang sama. Kalimat ini sudah punya 'improving' dan 'developing', jadi elemen ketiga harus juga berbentuk V-ing yaitu 'enhancing communication skills'."
  },
  {
    "id": 5,
    "part": "structure",
    "partName": "Structure",
    "type": "Sentence Completion",
    "difficulty": "medium",
    "question": "Rarely _____ such a talented musician perform in such a small venue.",
    "options": [
      "we have seen",
      "have we seen",
      "we saw",
      "did we saw"
    ],
    "correct": 1,
    "weight": 2,
    "explanation": "Ketika kata negatif seperti 'Rarely', 'Never', atau 'Seldom' diletakkan di awal kalimat, urutan subjek dan kata kerja bantu harus dibalik (inversi). Kalimat ini memakai Present Perfect, jadi auxiliary-nya 'have' harus mendahului subjek: 'have we seen'. Pilihan 'we have seen' salah karena tidak ada inversi."
  },
  {
    "id": 6,
    "part": "structure",
    "partName": "Structure",
    "type": "Sentence Completion",
    "difficulty": "medium",
    "question": "The research findings, _____ were published last month, have attracted worldwide attention.",
    "options": [
      "that",
      "which",
      "who",
      "what"
    ],
    "correct": 1,
    "weight": 2,
    "explanation": "Klausa yang diapit tanda koma adalah non-restrictive relative clause yang memberi informasi tambahan. Untuk benda (bukan orang), kata penghubung yang wajib dipakai adalah 'which', bukan 'that'. 'That' hanya boleh dipakai tanpa koma (restrictive clause). 'Who' untuk orang, dan 'what' tidak tepat di sini."
  },
  {
    "id": 7,
    "part": "structure",
    "partName": "Structure",
    "type": "Sentence Completion",
    "difficulty": "medium",
    "question": "By the time the rescue team arrived, the survivors _____ for three days without food.",
    "options": [
      "had been waiting",
      "were waiting",
      "have been waiting",
      "waited"
    ],
    "correct": 0,
    "weight": 2,
    "explanation": "Kalimat ini membutuhkan Past Perfect Continuous ('had been + V-ing') karena menggambarkan aksi yang berlangsung terus-menerus selama periode tertentu di masa lalu, sebelum kejadian lain terjadi. 'Were waiting' tidak menekankan durasi, 'have been waiting' adalah Present Perfect yang tidak cocok dengan konteks masa lalu, dan 'waited' tidak punya nuansa durasi."
  },
  {
    "id": 8,
    "part": "structure",
    "partName": "Structure",
    "type": "Sentence Completion",
    "difficulty": "medium",
    "question": "The new regulation requires that all employees _____ safety training annually.",
    "options": [
      "undergo",
      "undergoes",
      "have undergone",
      "would undergo"
    ],
    "correct": 0,
    "weight": 2,
    "explanation": "Kata kerja 'require' memicu subjunctive mood pada klausa 'that'. Pola subjunctive mandatif adalah: subject + base verb tanpa perubahan. Jadi 'undergo' (base form tanpa -s) adalah benar. 'Undergoes' salah karena menambahkan -s. 'Have undergone' dan 'would undergo' tidak sesuai pola subjunctive."
  },
  {
    "id": 9,
    "part": "structure",
    "partName": "Structure",
    "type": "Sentence Completion",
    "difficulty": "medium",
    "question": "_____ she studied harder, she would have passed the final examination.",
    "options": [
      "If",
      "Had",
      "Should",
      "Were"
    ],
    "correct": 1,
    "weight": 2,
    "explanation": "Kalimat ini adalah conditional type 3 (unreal past) dengan inversi, yaitu 'if' dihilangkan dan auxiliary 'had' dipindah ke awal kalimat. Pola lengkapnya: 'If she had studied harder...' menjadi 'Had she studied harder...'. Pilihan 'Should' dan 'Were' dipakai untuk conditional type yang berbeda."
  },
  {
    "id": 10,
    "part": "structure",
    "partName": "Structure",
    "type": "Sentence Completion",
    "difficulty": "medium",
    "question": "No sooner _____ the speech than the audience began applauding.",
    "options": [
      "he had finished",
      "had he finished",
      "did he finish",
      "he finished"
    ],
    "correct": 1,
    "weight": 2,
    "explanation": "'No sooner' di awal kalimat memicu subject-auxiliary inversion. Pola yang benar: 'No sooner + had + subject + past participle + than + simple past'. Jadi 'had he finished' adalah jawaban yang benar. 'He had finished' salah karena tidak ada inversi. 'Did he finish' salah karena konstruksi ini membutuhkan Past Perfect, bukan Simple Past."
  },
  {
    "id": 11,
    "part": "structure",
    "partName": "Structure",
    "type": "Sentence Completion",
    "difficulty": "hard",
    "question": "The extent to _____ modern technology has transformed education is remarkable.",
    "options": [
      "that",
      "which",
      "what",
      "where"
    ],
    "correct": 1,
    "weight": 3,
    "explanation": "Frasa 'the extent to which' adalah ungkapan baku dalam bahasa Inggris formal yang artinya 'sejauh mana'. Setelah preposisi 'to', relative pronoun yang benar adalah 'which'. 'That' tidak bisa dipakai setelah preposisi dalam klausa relatif formal. 'What' dan 'where' tidak tepat di konteks ini."
  },
  {
    "id": 12,
    "part": "structure",
    "partName": "Structure",
    "type": "Sentence Completion",
    "difficulty": "hard",
    "question": "Only after the investigation was complete _____ the full extent of the fraud.",
    "options": [
      "they discovered",
      "did they discover",
      "they did discover",
      "discovered they"
    ],
    "correct": 1,
    "weight": 3,
    "explanation": "Ketika 'Only after...' diletakkan di awal kalimat, klausa utama harus mengalami subject-auxiliary inversion. Kalimat ini memakai Simple Past, sehingga auxiliary yang dipakai adalah 'did' dan kata kerja kembali ke base form: 'did they discover'. 'They discovered' salah karena tidak ada inversi. 'Discovered they' tidak gramatikal."
  },
  {
    "id": 13,
    "part": "structure",
    "partName": "Structure",
    "type": "Sentence Completion",
    "difficulty": "hard",
    "question": "The professor insisted that the dissertation _____ revised before the defense.",
    "options": [
      "be",
      "is",
      "was",
      "were"
    ],
    "correct": 0,
    "weight": 3,
    "explanation": "Kata kerja 'insist' yang bermakna permintaan atau perintah membutuhkan present subjunctive pada klausa 'that'. Bentuk present subjunctive selalu memakai base verb tanpa perubahan untuk semua subjek. Jadi yang benar adalah 'be', bukan 'is', 'was', atau 'were'. Jika 'insist' bermakna menyatakan fakta, baru bisa memakai 'is'."
  },
  {
    "id": 14,
    "part": "structure",
    "partName": "Structure",
    "type": "Sentence Completion",
    "difficulty": "hard",
    "question": "_____ with a more efficient engine, the new model consumes significantly less fuel.",
    "options": [
      "Equipping",
      "Equipped",
      "Being equipped",
      "Having equipping"
    ],
    "correct": 1,
    "weight": 3,
    "explanation": "'Equipped with a more efficient engine' adalah participial phrase pasif yang memodifikasi subjek 'the new model'. Artinya: karena mobil tersebut dilengkapi mesin lebih efisien. 'Equipping' salah karena subjek tidak melakukan tindakan, melainkan menerimanya. 'Equipped' lebih tepat dan ringkas daripada 'Being equipped'. 'Having equipping' tidak gramatikal."
  },
  {
    "id": 15,
    "part": "structure",
    "partName": "Structure",
    "type": "Sentence Completion",
    "difficulty": "hard",
    "question": "The more data scientists collect, _____ their predictive models become.",
    "options": [
      "the reliable more",
      "more the reliable",
      "the more reliable",
      "more reliable the"
    ],
    "correct": 2,
    "weight": 3,
    "explanation": "Kalimat ini memakai pola komparatif korelatif 'the more...the more'. Polanya: 'The more [noun], the more [adjective] [noun]'. Pilihan C 'the more reliable' benar karena mengikuti pola ini dengan tepat. Ketiga pilihan lain salah karena urutan katanya keliru. Ingat: 'the' harus mendahului kata komparatif, bukan setelahnya."
  },
  {
    "id": 16,
    "part": "written",
    "partName": "Written Expression",
    "type": "Error Identification",
    "difficulty": "easy",
    "question": "The researcher (A)has submitted her report (B)yesterday and (C)is now waiting for (D)feedback.",
    "options": [
      "(A) has submitted",
      "(B) yesterday",
      "(C) is now waiting for",
      "(D) feedback"
    ],
    "correct": 0,
    "weight": 1,
    "explanation": "'Yesterday' menunjukkan waktu lampau yang spesifik, sehingga kalimat harus memakai Simple Past: 'submitted'. Present Perfect ('has submitted') tidak bisa dipakai bersama penanda waktu spesifik seperti yesterday, last week, ago, atau in 2020. Present Perfect hanya dipakai untuk pengalaman umum atau kejadian yang masih relevan dengan sekarang."
  },
  {
    "id": 17,
    "part": "written",
    "partName": "Written Expression",
    "type": "Error Identification",
    "difficulty": "easy",
    "question": "She (A)speaks three languages (B)fluent and (C)can communicate (D)effectively.",
    "options": [
      "(A) speaks",
      "(B) fluent",
      "(C) can communicate",
      "(D) effectively"
    ],
    "correct": 1,
    "weight": 1,
    "explanation": "'Fluent' adalah kata sifat (adjektiva) yang hanya bisa memodifikasi kata benda. Di kalimat ini, kata tersebut seharusnya memodifikasi kata kerja 'speaks', sehingga harus berbentuk adverbia: 'fluently'. Perhatikan pilihan D 'effectively' sudah benar karena memang berbentuk adverbia. Hanya pilihan B yang harus diubah."
  },
  {
    "id": 18,
    "part": "written",
    "partName": "Written Expression",
    "type": "Error Identification",
    "difficulty": "easy",
    "question": "The children (A)were playing (B)happily in the park (C)when it (D)begun to rain.",
    "options": [
      "(A) were playing",
      "(B) happily",
      "(C) when it",
      "(D) begun"
    ],
    "correct": 3,
    "weight": 1,
    "explanation": "'Begun' adalah past participle (bentuk ketiga) dari 'begin'. Past participle dipakai bersama auxiliary seperti 'have/had'. Di kalimat ini tidak ada auxiliary, jadi harus memakai Simple Past: 'began'. Tiga bentuk 'begin': begin (present), began (simple past), begun (past participle)."
  },
  {
    "id": 19,
    "part": "written",
    "partName": "Written Expression",
    "type": "Error Identification",
    "difficulty": "easy",
    "question": "Each of the students (A)are required to (B)submit a (C)written report (D)by Friday.",
    "options": [
      "(A) are required",
      "(B) submit",
      "(C) written",
      "(D) by Friday"
    ],
    "correct": 0,
    "weight": 1,
    "explanation": "Kata 'each' selalu dianggap singular meskipun merujuk pada banyak orang. Frasa 'Each of the students' membutuhkan kata kerja singular: 'is required', bukan 'are required'. Hal yang sama berlaku untuk: every, either, neither, anyone, someone, dan everyone. Jangan terkecoh oleh kata 'students' yang plural."
  },
  {
    "id": 20,
    "part": "written",
    "partName": "Written Expression",
    "type": "Error Identification",
    "difficulty": "easy",
    "question": "The new policy will (A)effect (B)all departments (C)starting from (D)next quarter.",
    "options": [
      "(A) effect",
      "(B) all departments",
      "(C) starting from",
      "(D) next quarter"
    ],
    "correct": 0,
    "weight": 1,
    "explanation": "'Effect' sebagai kata kerja berarti 'mewujudkan sesuatu yang baru', bukan 'mempengaruhi'. Yang dibutuhkan di sini adalah 'affect' (kata kerja) yang berarti 'mempengaruhi'. Ingat pasangan ini: affect (verb) berarti mempengaruhi, sedangkan effect (noun) berarti dampak atau hasil."
  },
  {
    "id": 21,
    "part": "written",
    "partName": "Written Expression",
    "type": "Error Identification",
    "difficulty": "medium",
    "question": "The report (A)which was submitted (B)by the team (C)contain several (D)significant errors.",
    "options": [
      "(A) which was submitted",
      "(B) by the team",
      "(C) contain",
      "(D) significant"
    ],
    "correct": 2,
    "weight": 2,
    "explanation": "Subjek utama kalimat adalah 'The report' (singular). Klausa 'which was submitted by the team' hanyalah keterangan tambahan. Kata kerja utama harus mengikuti subjek utama: 'contains' (singular), bukan 'contain' (plural). Jangan terkecoh oleh kata 'team' yang berada dekat dengan kata kerja."
  },
  {
    "id": 22,
    "part": "written",
    "partName": "Written Expression",
    "type": "Error Identification",
    "difficulty": "medium",
    "question": "Not only (A)the manager attended the meeting, (B)but also (C)several senior (D)employees.",
    "options": [
      "(A) the manager attended",
      "(B) but also",
      "(C) several senior",
      "(D) employees"
    ],
    "correct": 0,
    "weight": 2,
    "explanation": "Ketika 'Not only' diletakkan di awal kalimat, klausa berikutnya harus mengalami inversi. Bentuk yang benar: 'Not only did the manager attend the meeting...'. Pola inversi ini juga berlaku untuk: Never, Rarely, Seldom, Hardly, Scarcely, No sooner, dan ekspresi pembatas lainnya."
  },
  {
    "id": 23,
    "part": "written",
    "partName": "Written Expression",
    "type": "Error Identification",
    "difficulty": "medium",
    "question": "The scientist (A)who made the discovery (B)was awarded a prize (C)for them (D)contribution.",
    "options": [
      "(A) who made",
      "(B) was awarded",
      "(C) them",
      "(D) contribution"
    ],
    "correct": 2,
    "weight": 2,
    "explanation": "Kata 'them' adalah object pronoun yang tidak bisa langsung diikuti kata benda. Yang dibutuhkan adalah possessive adjective untuk menunjukkan kepemilikan."
  },
  {
    "id": 24,
    "part": "written",
    "partName": "Written Expression",
    "type": "Error Identification",
    "difficulty": "medium",
    "question": "Hardly (A)had the ceremony begun (B)when the lights (C)went out (D)suddenly and unexpected.",
    "options": [
      "(A) had the ceremony begun",
      "(B) when the lights",
      "(C) went out",
      "(D) suddenly and unexpected"
    ],
    "correct": 3,
    "weight": 2,
    "explanation": "Kata 'suddenly' adalah adverbia, sedangkan 'unexpected' adalah adjektiva. Keduanya memodifikasi kata kerja 'went out', jadi keduanya harus berbentuk adverbia agar sejajar (parallel). Bentuk adverbia dari 'unexpected' adalah 'unexpectedly'. Jadi yang benar adalah 'suddenly and unexpectedly'."
  },
  {
    "id": 25,
    "part": "written",
    "partName": "Written Expression",
    "type": "Error Identification",
    "difficulty": "medium",
    "question": "The number of applicants (A)for the scholarship (B)have increased (C)significantly (D)this year.",
    "options": [
      "(A) for the scholarship",
      "(B) have increased",
      "(C) significantly",
      "(D) this year"
    ],
    "correct": 1,
    "weight": 2,
    "explanation": "Frasa 'The number of' selalu diikuti kata kerja singular karena kata intinya adalah 'number' (singular). Jadi yang benar adalah 'has increased'. Berbeda dengan 'A number of' yang berarti 'beberapa' dan diikuti kata kerja plural. Contoh: 'The number of students is...' vs 'A number of students are...'."
  },
  {
    "id": 26,
    "part": "written",
    "partName": "Written Expression",
    "type": "Error Identification",
    "difficulty": "medium",
    "question": "Everyone in the office (A)was surprised to learn (B)that the CEO (C)had resigned (D)sudden.",
    "options": [
      "(A) was surprised",
      "(B) that the CEO",
      "(C) had resigned",
      "(D) sudden"
    ],
    "correct": 3,
    "weight": 2,
    "explanation": "'Sudden' adalah kata sifat yang hanya bisa memodifikasi kata benda. Di kalimat ini, kata tersebut dipakai untuk memodifikasi kata kerja 'resigned', sehingga harus berbentuk adverbia: 'suddenly'. Ini adalah contoh adjective-adverb confusion yang sering muncul di TOEFL."
  },
  {
    "id": 27,
    "part": "written",
    "partName": "Written Expression",
    "type": "Error Identification",
    "difficulty": "medium",
    "question": "The data (A)collected by the researchers (B)suggests that (C)pollution levels (D)have rise.",
    "options": [
      "(A) collected",
      "(B) suggests",
      "(C) pollution levels",
      "(D) have rise"
    ],
    "correct": 3,
    "weight": 2,
    "explanation": "Setelah auxiliary 'have' dalam Present Perfect, kata kerja harus berbentuk past participle. 'Rise' adalah irregular verb dengan tiga bentuk: rise (present), rose (simple past), risen (past participle). Jadi 'have rise' salah karena memakai base form. Bentuk yang benar adalah 'have risen'."
  },
  {
    "id": 28,
    "part": "written",
    "partName": "Written Expression",
    "type": "Error Identification",
    "difficulty": "hard",
    "question": "The committee's decision to (A)postpone the project (B)were met (C)with widespread (D)criticism.",
    "options": [
      "(A) postpone",
      "(B) were met",
      "(C) with widespread",
      "(D) criticism"
    ],
    "correct": 1,
    "weight": 3,
    "explanation": "Subjek utama kalimat adalah 'The committee's decision' (singular) karena kata intinya adalah 'decision', bukan 'committee'. Kata kerja pasif yang tepat untuk subjek singular adalah 'was met', bukan 'were met'. Jangan terkecoh oleh frasa panjang antara subjek dan kata kerja."
  },
  {
    "id": 29,
    "part": "written",
    "partName": "Written Expression",
    "type": "Error Identification",
    "difficulty": "hard",
    "question": "The lawyer argued that her client (A)has been wrongful (B)accused and (C)deserved (D)compensation.",
    "options": [
      "(A) has been wrongful",
      "(B) accused",
      "(C) deserved",
      "(D) compensation"
    ],
    "correct": 0,
    "weight": 3,
    "explanation": "Kata 'wrongful' adalah adjektiva yang tidak bisa memodifikasi past participle 'accused'. Yang dibutuhkan adalah adverbia: 'wrongfully'. Bentuk yang benar adalah 'has been wrongfully accused'. Adjektiva hanya memodifikasi kata benda, sedangkan adverbia memodifikasi kata kerja dan participle."
  },
  {
    "id": 30,
    "part": "written",
    "partName": "Written Expression",
    "type": "Error Identification",
    "difficulty": "hard",
    "question": "Scarcely (A)had the new law been enacted (B)when several groups (C)began challenging (D)it's legality.",
    "options": [
      "(A) had the new law been enacted",
      "(B) when several groups",
      "(C) began challenging",
      "(D) it's legality"
    ],
    "correct": 3,
    "weight": 3,
    "explanation": "'It's' adalah singkatan dari 'it is' atau 'it has', bukan bentuk posesif. Yang dibutuhkan di sini adalah kata ganti posesif 'its' (tanpa apostrof) untuk menunjukkan kepemilikan. Berbeda dengan kata benda yang memakai apostrof untuk posesif, kata ganti posesif tidak pernah memakai apostrof: its, his, her, their, our, your."
  },
  {
    "id": 31,
    "part": "written",
    "partName": "Written Expression",
    "type": "Error Identification",
    "difficulty": "hard",
    "question": "The new library, (A) which was completed last year, (B) have become one of the most popular study locations on campus, (C) attracting hundreds of students every day (D) during exam periods.",
    "options": [
      "(A) which was completed last year",
      "(B) have become",
      "(C) attracting hundreds of students",
      "(D) during exam periods"
    ],
    "correct": 1,
    "weight": 3,
    "explanation": "Subjek utama kalimat adalah 'The new library' (singular). Meskipun ada klausa relatif 'which was completed last year', subjek tetap singular. Kata kerja yang benar adalah 'has become', bukan 'have become'."
  },
  {
    "id": 32,
    "part": "written",
    "partName": "Written Expression",
    "type": "Error Identification",
    "difficulty": "hard",
    "question": "The success of the program depends on whether participants (A)will commit (B)theirselves (C)to the (D)process.",
    "options": [
      "(A) will commit",
      "(B) theirselves",
      "(C) to the",
      "(D) process"
    ],
    "correct": 1,
    "weight": 3,
    "explanation": "'Theirselves' tidak ada dalam bahasa Inggris baku. Bentuk reflexive pronoun untuk 'they' adalah 'themselves'. Reflexive pronoun dibentuk dari possessive adjective ditambah self atau selves: myself, yourself, himself, herself, itself, ourselves, yourselves, themselves. Gunakan 'them-' bukan 'their-' sebagai awalan."
  },
  {
    "id": 33,
    "part": "written",
    "partName": "Written Expression",
    "type": "Error Identification",
    "difficulty": "hard",
    "question": "The article (A)implies that the rise of social media (B)have fundamentally altered (C)how people (D)perceive reality.",
    "options": [
      "(A) implies",
      "(B) have fundamentally altered",
      "(C) how people",
      "(D) perceive reality"
    ],
    "correct": 1,
    "weight": 3,
    "explanation": "Subjek klausa adalah 'the rise of social media'. Kata intinya adalah 'the rise' (singular), bukan 'social media'. Jadi kata kerja yang benar adalah 'has fundamentally altered'. Pola 'the rise/growth/decline of [noun]' selalu membutuhkan kata kerja singular karena inti frasanya adalah kata benda singular."
  },
  {
    "id": 34,
    "part": "written",
    "partName": "Written Expression",
    "type": "Error Identification",
    "difficulty": "hard",
    "question": "The delegations arrived (A)on schedule, presented (B)their findings, and (C)was given a standing (D)ovation.",
    "options": [
      "(A) on schedule",
      "(B) their findings",
      "(C) was given",
      "(D) ovation"
    ],
    "correct": 2,
    "weight": 3,
    "explanation": "Kalimat ini punya tiga predikat: 'arrived', 'presented', dan 'was given'. Untuk menjaga parallelism, ketiganya harus sejajar. 'Arrived' dan 'presented' adalah Simple Past aktif, jadi predikat ketiga juga harus konsisten. Selain itu, subjek 'The delegations' plural sehingga yang benar adalah 'were given'."
  },
  {
    "id": 35,
    "part": "written",
    "partName": "Written Expression",
    "type": "Error Identification",
    "difficulty": "hard",
    "question": "It is (A)essential that every candidate (B)submits a complete application (C)before the (D)deadline.",
    "options": [
      "(A) essential",
      "(B) submits",
      "(C) before the",
      "(D) deadline"
    ],
    "correct": 1,
    "weight": 3,
    "explanation": "Setelah 'It is essential/important/necessary/vital that...', bahasa Inggris formal memakai present subjunctive yaitu base verb tanpa perubahan untuk semua subjek. Jadi yang benar adalah 'submit' (bukan 'submits'). Pola 'It is + adjective + that + subject + base verb' adalah ciri khas subjunctive yang penting."
  },
  {
    "id": 36,
    "part": "written",
    "partName": "Written Expression",
    "type": "Error Identification",
    "difficulty": "hard",
    "question": "Having (A)been exposed to (B)extreme conditions, the equipment (C)malfunctioned (D)frequent.",
    "options": [
      "(A) been exposed to",
      "(B) extreme conditions",
      "(C) malfunctioned",
      "(D) frequent"
    ],
    "correct": 3,
    "weight": 3,
    "explanation": "'Frequent' adalah kata sifat yang hanya bisa memodifikasi kata benda. Di kalimat ini, kata tersebut dipakai untuk memodifikasi kata kerja 'malfunctioned', sehingga harus berbentuk adverbia: 'frequently'. Ini adalah salah satu kesalahan yang paling sering diuji di bagian Written Expression TOEFL."
  },
  {
    "id": 37,
    "part": "written",
    "partName": "Written Expression",
    "type": "Error Identification",
    "difficulty": "hard",
    "question": "The professor, (A)along with her research assistants, (B)are planning to (C)present their findings (D)next month.",
    "options": [
      "(A) along with her research assistants",
      "(B) are planning",
      "(C) present their findings",
      "(D) next month"
    ],
    "correct": 1,
    "weight": 3,
    "explanation": "Frasa 'along with her research assistants' yang diapit tanda koma adalah frasa penyela yang tidak mengubah subjek utama. Subjek utama tetap 'The professor' (singular). Frasa seperti 'along with', 'together with', dan 'as well as' tidak membuat subjek menjadi plural. Kata kerja yang benar adalah 'is planning', bukan 'are planning'."
  },
  {
    "id": 38,
    "part": "written",
    "partName": "Written Expression",
    "type": "Error Identification",
    "difficulty": "hard",
    "question": "The magnitude of the consequences (A)that resulted (B)from the decision (C)were not (D)anticipated.",
    "options": [
      "(A) that resulted",
      "(B) from the decision",
      "(C) were not",
      "(D) anticipated"
    ],
    "correct": 2,
    "weight": 3,
    "explanation": "Subjek utama kalimat adalah 'The magnitude' (singular). Semua frasa setelahnya ('of the consequences that resulted from the decision') adalah keterangan tambahan. Kata kerja yang benar adalah 'was not' (singular), bukan 'were not' (plural). Ini adalah pola klasik TOEFL di mana subjek dan kata kerja dipisahkan oleh frasa modifier yang panjang."
  },
  {
    "id": 39,
    "part": "written",
    "partName": "Written Expression",
    "type": "Error Identification",
    "difficulty": "hard",
    "question": "The board's refusal to (A)disclose financial records (B)have raised serious questions (C)about (D)transparency.",
    "options": [
      "(A) disclose financial records",
      "(B) have raised",
      "(C) about",
      "(D) transparency"
    ],
    "correct": 1,
    "weight": 3,
    "explanation": "Subjek kalimat adalah 'The board's refusal' (singular) karena kata intinya adalah 'refusal'. Meskipun 'board' merujuk pada kelompok, yang menjadi subjek di sini adalah 'refusal'. Kata kerja yang benar adalah 'has raised'."
  },
  {
    "id": 40,
    "part": "written",
    "partName": "Written Expression",
    "type": "Error Identification",
    "difficulty": "hard",
    "question": "Significant progress (A)in renewable energy (B)have been made possible (C)by recent (D)technological advances.",
    "options": [
      "(A) in renewable energy",
      "(B) have been made",
      "(C) by recent",
      "(D) technological advances"
    ],
    "correct": 1,
    "weight": 3,
    "explanation": "'Progress' adalah uncountable noun yang selalu diperlakukan sebagai singular. Kata kerja yang benar adalah 'has been made', bukan 'have been made'. Contoh uncountable nouns lain yang sering memicu kesalahan serupa: information, research, news, advice, equipment, dan knowledge. Semuanya selalu memakai kata kerja singular."
  }
];
