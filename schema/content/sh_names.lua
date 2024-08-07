local NAMES_FIRST = {
	"Aadya",
	"Aarav",
	"Aaron",
	"Aarya",
	"Abigail",
	"Adam",
	"Adeline",
	"Ahmed",
	"Aisha",
	"Akari",
	"Alexa",
	"Alexander",
	"Alexander",
	"Alexandra",
	"Ali",
	"Alice",
	"Alma",
	"Althea",
	"Amaira",
	"Amelia",
	"Amir",
	"Andrew",
	"Anna",
	"Anna",
	"Anthony",
	"Artem",
	"Arthur",
	"Arthur",
	"Astrid",
	"Aubrey",
	"Aurora",
	"Ava",
	"Ava",
	"Ayesha",
	"Ayush",
	"Barbara",
	"Bas",
	"Beatrice",
	"Benjamin",
	"Bonnie",
	"Brandon",
	"Brooklyn",
	"Bruce",
	"Camila",
	"Camilla",
	"Carl",
	"Caroline",
	"Charles",
	"Charlotte",
	"Charlotte",
	"Chiamaka",
	"Chloe",
	"Chukwuma",
	"Clara",
	"Daan",
	"Daniel",
	"David",
	"Deborah",
	"Denise",
	"Dennis",
	"Donald",
	"Edward",
	"Elif",
	"Elizabeth",
	"Ellie",
	"Emilia",
	"Emily",
	"Emily",
	"Emma",
	"Emma",
	"Eric",
	"Ethan",
	"Evelyn",
	"Eymen",
	"Faith",
	"Fatemeh",
	"Fatima",
	"Fatma",
	"Fiadh",
	"Francesco",
	"Frank",
	"Freja",
	"Gabriel",
	"Gabrielle",
	"Gary",
	"Genesis",
	"George",
	"Giulia",
	"Grace",
	"Grace",
	"Gregory",
	"Ha-eun",
	"Hana",
	"Harper",
	"Haruto",
	"Heitor",
	"Helena",
	"Henry",
	"Himari",
	"Hina",
	"Hiranur",
	"Hiroto",
	"Hugo",
	"Hyun-woo",
	"Isabella",
	"Isabella",
	"Jack",
	"Jacob",
	"Jade",
	"James",
	"James",
	"Jane",
	"Jannat",
	"Jason",
	"Jeffrey",
	"Jelle",
	"Jerry",
	"Jessica",
	"Ji-ho",
	"Ji-yoo",
	"Jia",
	"John",
	"Jonathan",
	"Jose",
	"Joseph",
	"Joshua",
	"Julia",
	"Julia",
	"Jun",
	"Justin",
	"Katherine",
	"Kenneth",
	"Kevin",
	"Kyle",
	"Kylie",
	"Lauren",
	"Layla",
	"Leah",
	"Leon",
	"Leonardo",
	"Liam",
	"Lorenzo",
	"Louis",
	"Luca",
	"Lucas",
	"Lucía",
	"Lucy",
	"Madelyn",
	"Madison",
	"María José",
	"Maria",
	"Maria",
	"Mark",
	"Martín",
	"Martina",
	"Maryam",
	"Mateo",
	"Matthew",
	"Melanie",
	"Mia",
	"Mia",
	"Michael",
	"Mick",
	"Miguel",
	"Mikhail",
	"Mila",
	"Min-jun",
	"Min",
	"Mira",
	"Mohammad",
	"Mohammed",
	"Muhammad",
	"Naomi",
	"Nathan",
	"Nicholas",
	"Noah",
	"Nora",
	"Oliver",
	"Olivia",
	"Olivia",
	"Omar",
	"Ömer",
	"Oscar",
	"Patrick",
	"Paul",
	"Paul",
	"Penelope",
	"Peter",
	"Pranav",
	"Priya",
	"Rahim",
	"Raphaël",
	"Raymond",
	"Rebecca",
	"Ren",
	"Ren",
	"Riley",
	"Robert",
	"Roger",
	"Ronald",
	"Ruby",
	"Ryan",
	"Saanvi",
	"Sadie",
	"Sakura",
	"Sam",
	"Samiksha",
	"Samuel",
	"Santiago",
	"Sarah",
	"Scarlett",
	"Scott",
	"Sebastián",
	"Sem",
	"Seo-yeon",
	"Sofia",
	"Sofía",
	"Sophia",
	"Sophia",
	"Stella",
	"Stephen",
	"Steven",
	"Theo",
	"Thomas",
	"Timothy",
	"Tyler",
	"Umar",
	"Valentina",
	"Valeria",
	"Victor",
	"Victoria",
	"Vihaan",
	"Violet",
	"Vivian",
	"Wei",
	"William",
	"Wim",
	"Xiao",
	"Yi",
	"Yui",
	"Yui",
	"Yuma",
	"Yusuf",
	"Yuto",
	"Zachary",
	"Zahra",
	"Zainab",
	"Zeynep",
	"Zoey",
}

local NAMES_LAST = {
	"Abbas",
	"Abbasi",
	"Abdalla",
	"Abdallah",
	"Abdel",
	"Abdi",
	"Abdo",
	"Abdou",
	"Abdul",
	"Abdullah",
	"Abdullahi",
	"Abe",
	"Abebe",
	"Abu",
	"Abubakar",
	"Acosta",
	"Adam",
	"Adamou",
	"Adams",
	"Adamu",
	"Adel",
	"Aden",
	"Adhikari",
	"Afzal",
	"Aguilar",
	"Aguirre",
	"Ahamad",
	"Ahamed",
	"Ahmad",
	"Ahmadi",
	"Ahmed",
	"Ai",
	"Akbar",
	"Akhtar",
	"Akhter",
	"Akpan",
	"Akram",
	"Aktar",
	"Akter",
	"Akther",
	"Al Numan",
	"Alam",
	"Alemayehu",
	"Ali",
	"Aliyu",
	"Allah",
	"Allen",
	"Almeida",
	"Alonso",
	"Alvarado",
	"Alvarez",
	"Alves",
	"Amadi",
	"Amadou",
	"Amin",
	"Aminu",
	"Amir",
	"An",
	"Anderson",
	"Andrade",
	"Anh",
	"Ansari",
	"António",
	"Anwar",
	"Ao",
	"Aquino",
	"Araujo",
	"Arias",
	"Arif",
	"Arshad",
	"Ashraf",
	"Asif",
	"Aslam",
	"Aung",
	"Avila",
	"Awad",
	"Ayala",
	"Aydın",
	"Aye",
	"Aziz",
	"Ba",
	"Baba",
	"Babu",
	"Bag",
	"Bagdi",
	"Bah",
	"Bahadur",
	"Bai",
	"Bailey",
	"Baker",
	"Bakhash",
	"Bala",
	"Balde",
	"Banda",
	"Banerjee",
	"Bano",
	"Banza",
	"Bao",
	"Barbosa",
	"Barik",
	"Barman",
	"Barrera",
	"Barrios",
	"Barros",
	"Barry",
	"Bashir",
	"Basumatary",
	"Batista",
	"Bauri",
	"Bautista",
	"Begam",
	"Begum",
	"Behera",
	"Bekele",
	"Bell",
	"Bello",
	"Benitez",
	"Bennett",
	"Bera",
	"Bezerra",
	"Bhagat",
	"Bhoi",
	"Bi",
	"Bian",
	"Bibi",
	"Biswas",
	"Blanco",
	"Bo",
	"Borges",
	"Bravo",
	"Brito",
	"Brown",
	"Bui",
	"Bux",
	"Caballero",
	"Cabrera",
	"Cai",
	"Calderon",
	"Camacho",
	"Camara",
	"Campbell",
	"Campos",
	"Cao",
	"Cardenas",
	"Cardoso",
	"Carrillo",
	"Carter",
	"Carvalho",
	"Castillo",
	"Castro",
	"Caudhari",
	"Cauhan",
	"Çelik",
	"Cen",
	"Ceng",
	"Cha",
	"Chai",
	"Chakraborty",
	"Chan",
	"Chand",
	"Chandra",
	"Chang",
	"Charles",
	"Chaudhari",
	"Chaudhary",
	"Chauhan",
	"Chavez",
	"Che",
	"Chen",
	"Cheng",
	"Chi",
	"Cho",
	"Choe",
	"Chon",
	"Chong",
	"Chowdhury",
	"Chu",
	"Cisse",
	"Clark",
	"Coelho",
	"Collins",
	"Conde",
	"Contreras",
	"Cook",
	"Cooper",
	"Correa",
	"Correia",
	"Cortes",
	"Cortez",
	"Costa",
	"Coulibaly",
	"Cruz",
	"Cui",
	"da Conceiçao",
	"da Costa",
	"da Cruz",
	"da Silva",
	"Dai",
	"Dan",
	"Dang",
	"Daniel",
	"Dao",
	"Das",
	"David",
	"Davis",
	"de Almeida",
	"de Araujo",
	"de Carvalho",
	"de Jesus",
	"de La Cruz",
	"de Lima",
	"de Oliveira",
	"de Sousa",
	"de Souza",
	"De",
	"Debnath",
	"Dei",
	"dela Cruz",
	"Delgado",
	"Dembele",
	"Demir",
	"Deng",
	"Devi",
	"Dey",
	"Di",
	"Diallo",
	"Diarra",
	"Dias",
	"Diaz",
	"Din",
	"Ding",
	"Dinh",
	"Diop",
	"Dlamini",
	"do Nascimento",
	"Do",
	"Doan",
	"Domingos",
	"Dominguez",
	"Dong",
	"dos Santos",
	"Dou",
	"Du",
	"Duan",
	"Duarte",
	"Dube",
	"Duong",
	"Duran",
	"Dutta",
	"Edwards",
	"Ei",
	"Elias",
	"Emmanuel",
	"Escobar",
	"Espinosa",
	"Espinoza",
	"Estrada",
	"Evans",
	"Eze",
	"Fan",
	"Fang",
	"Farah",
	"Farooq",
	"Fatima",
	"Fei",
	"Felix",
	"Feng",
	"Fernandes",
	"Fernandez",
	"Fernando",
	"Ferreira",
	"Figueroa",
	"Fischer",
	"Flores",
	"Fofana",
	"Fonseca",
	"Francis",
	"Francisco",
	"Franco",
	"Freitas",
	"Fu",
	"Fuentes",
	"Gabriel",
	"Gamal",
	"Gan",
	"Gao",
	"Garba",
	"Garcia",
	"Gayakwad",
	"Ge",
	"Geng",
	"George",
	"Getachew",
	"Ghosh",
	"Ghulam",
	"Gil",
	"Giri",
	"Girma",
	"Gogoi",
	"Gomes",
	"Gomez",
	"Gonçalves",
	"Gong",
	"Gonzales",
	"Gonzalez",
	"Gou",
	"Green",
	"Gu",
	"Guan",
	"Guerra",
	"Guerrero",
	"Guevara",
	"Gul",
	"Guo",
	"Gupta",
	"Gutierrez",
	"Guzman",
	"Ha",
	"Habib",
	"Hadi",
	"Haider",
	"Hailu",
	"Haji",
	"Halder",
	"Hall",
	"Hamad",
	"Hamed",
	"Hameed",
	"Hamid",
	"Hamza",
	"Han",
	"Hansen",
	"Hao",
	"Haque",
	"Harris",
	"Haruna",
	"Hasan",
	"Hassan",
	"Hayashi",
	"Hayat",
	"He",
	"Henrique",
	"Hernandez",
	"Herrera",
	"Hidayat",
	"Hill",
	"Hnin",
	"Ho",
	"Hoang",
	"Hong",
	"Hoque",
	"Hosen",
	"Hossain",
	"Hosseini",
	"Hossen",
	"Hou",
	"Hu",
	"Hua",
	"Huang",
	"Hughes",
	"Huo",
	"Husain",
	"Hussain",
	"Hussein",
	"Huynh",
	"Hwang",
	"I",
	"Ibarra",
	"Ibrahim",
	"Idris",
	"Ilunga",
	"Im",
	"Imran",
	"Inoue",
	"Iqbal",
	"Isa",
	"Isah",
	"Islam",
	"Ismail",
	"Issa",
	"Ito",
	"Ivanov",
	"Ivanova",
	"Jackson",
	"Jadhav",
	"Jahan",
	"Jain",
	"Jamal",
	"James",
	"Jan",
	"Jana",
	"Jang",
	"Jassim",
	"Javed",
	"Jean",
	"Jena",
	"Jha",
	"Ji",
	"Jia",
	"Jian",
	"Jiang",
	"Jiao",
	"Jie",
	"Jimenez",
	"Jin",
	"Jing",
	"John",
	"Johnson",
	"Jones",
	"Joseph",
	"Joshi",
	"Ju",
	"Juarez",
	"Juma",
	"Kabir",
	"Kadam",
	"Kale",
	"Kamal",
	"Kamara",
	"Kamble",
	"Kang",
	"Kanwar",
	"Karim",
	"Karmakar",
	"Kasongo",
	"Kato",
	"Kaur",
	"Kaya",
	"Kazem",
	"Ke",
	"Kebede",
	"Keita",
	"Kelly",
	"Khalaf",
	"Khaled",
	"Khalid",
	"Khalil",
	"Khan",
	"Khatoon",
	"Khatun",
	"Khaw",
	"Khin",
	"Khine",
	"Kim",
	"Kimura",
	"King",
	"Ko",
	"Kobayashi",
	"Koffi",
	"Konate",
	"Kone",
	"Kong",
	"Kouadio",
	"Kouakou",
	"Kouame",
	"Kouassi",
	"Kuang",
	"Kumar",
	"Kumari",
	"Kwon",
	"Lai",
	"Lal",
	"Lam",
	"Lan",
	"Lang",
	"Lara",
	"Latif",
	"Lawal",
	"Le",
	"Leal",
	"Lee",
	"Lei",
	"Leng",
	"Leon",
	"Lestari",
	"Lewis",
	"Li",
	"Lian",
	"Liang",
	"Liao",
	"Lim",
	"Lima",
	"Lin",
	"Ling",
	"Liu",
	"Long",
	"Lopes",
	"Lopez",
	"Lou",
	"Lozano",
	"Lu",
	"Lucas",
	"Luna",
	"Luo",
	"Luong",
	"Ly",
	"Ma",
	"Machado",
	"Magar",
	"Mahamat",
	"Mahato",
	"Mahdi",
	"Mahmood",
	"Mahmoud",
	"Mahmud",
	"Mahto",
	"Mai",
	"Majhi",
	"Makavan",
	"Mal",
	"Maldonado",
	"Mali",
	"Malik",
	"Mallik",
	"Mamani",
	"Mandal",
	"Mane",
	"Manjhi",
	"Manna",
	"Mansour",
	"Manuel",
	"Mao",
	"Marin",
	"Marques",
	"Marquez",
	"Martin",
	"Martinez",
	"Martins",
	"Maseeh",
	"Matsumoto",
	"Maung",
	"May",
	"Medina",
	"Mehmood",
	"Mei",
	"Mejia",
	"Mendes",
	"Mendez",
	"Mendoza",
	"Meng",
	"Mensah",
	"Mercado",
	"Meyer",
	"Meza",
	"Mi",
	"Mia",
	"Miah",
	"Miao",
	"Michael",
	"Miguel",
	"Miller",
	"Min",
	"Mir",
	"Miranda",
	"Mishra",
	"Mitchell",
	"Miya",
	"Mo",
	"Mohamed",
	"Mohammad",
	"Mohammadi",
	"Mohammed",
	"Mohsen",
	"Molina",
	"Molla",
	"Mondal",
	"Monteiro",
	"Montoya",
	"Moore",
	"Mora",
	"Morales",
	"More",
	"Moreira",
	"Moreno",
	"Morgan",
	"Mori",
	"Morris",
	"Moses",
	"Mostafa",
	"Mou",
	"Mousa",
	"Moussa",
	"Moyo",
	"Mu",
	"Muhammad",
	"Muhammed",
	"Mukherjee",
	"Müller",
	"Mun",
	"Munda",
	"Muñoz",
	"Murmu",
	"Murphy",
	"Musa",
	"Mustafa",
	"Na",
	"Nabi",
	"Nahar",
	"Naik",
	"Nair",
	"Nakamura",
	"Nam",
	"Narayan",
	"Nascimento",
	"Nasir",
	"Nasser",
	"Nath",
	"Navarro",
	"Nawaz",
	"Nayak",
	"Ndiaye",
	"Ndlovu",
	"Nelson",
	"Ngo",
	"Ngoy",
	"Nguyen",
	"Ni",
	"Nie",
	"Ning",
	"Nisha",
	"Niu",
	"Nong",
	"Noor",
	"Nunes",
	"Nuñez",
	"O",
	"Ochoa",
	"Oliveira",
	"Omar",
	"Omer",
	"Ono",
	"Oraon",
	"Orozco",
	"Ortega",
	"Ortiz",
	"Osman",
	"Osorio",
	"Otieno",
	"Ou yang",
	"Ou",
	"Ouattara",
	"Ouedraogo",
	"Oumarou",
	"Öztürk",
	"Pacheco",
	"Padilla",
	"Paek",
	"Pak",
	"Pal",
	"Palacios",
	"Pan",
	"Panda",
	"Pandey",
	"Pandit",
	"Pang",
	"Paramar",
	"Paredes",
	"Parker",
	"Parra",
	"Parveen",
	"Parvin",
	"Paswan",
	"Patal",
	"Patel",
	"Pathan",
	"Patil",
	"Patra",
	"Paul",
	"Pawar",
	"Pedro",
	"Pei",
	"Peña",
	"Peng",
	"Peralta",
	"Pereira",
	"Perera",
	"Perez",
	"Peter",
	"Petrov",
	"Petrova",
	"Pham",
	"Phan",
	"Phillips",
	"Phiri",
	"Phyo",
	"Pierre",
	"Pineda",
	"Pinheiro",
	"Pinto",
	"Pires",
	"Ponce",
	"Pradhan",
	"Prakash",
	"Pramanik",
	"Prasad",
	"Pu",
	"Qasim",
	"Qi",
	"Qian",
	"Qiao",
	"Qin",
	"Qiu",
	"Qu",
	"Quan",
	"Quintero",
	"Quispe",
	"Rahaman",
	"Rahim",
	"Rahman",
	"Rai",
	"Raj",
	"Ram",
	"Ramadan",
	"Ramirez",
	"Ramos",
	"Ramzan",
	"Ran",
	"Rana",
	"Rani",
	"Rao",
	"Rasheed",
	"Rashid",
	"Rasool",
	"Rathav",
	"Rathod",
	"Raut",
	"Ray",
	"Raza",
	"Reddy",
	"Rehman",
	"Ren",
	"Reyes",
	"Ri",
	"Riaz",
	"Ribeiro",
	"Richard",
	"Rios",
	"Rivas",
	"Rivera",
	"Roberts",
	"Robinson",
	"Robles",
	"Rocha",
	"Rodrigues",
	"Rodriguez",
	"Rogers",
	"Rojas",
	"Roman",
	"Romero",
	"Rong",
	"Rosa",
	"Rosales",
	"Roy",
	"Ruan",
	"Ruiz",
	"Saad",
	"Sadiq",
	"Saeed",
	"Sah",
	"Saha",
	"Sahani",
	"Şahin",
	"Sahoo",
	"Sahu",
	"Said",
	"Saidi",
	"Saito",
	"Salah",
	"Salam",
	"Salas",
	"Salazar",
	"Saleem",
	"Saleh",
	"Salem",
	"Salim",
	"Salinas",
	"Salisu",
	"Salman",
	"Samuel",
	"San",
	"Sanchez",
	"Sandoval",
	"Sangma",
	"Sani",
	"Santana",
	"Santiago",
	"Santos",
	"Sántos",
	"Saputra",
	"Sardar",
	"Sari",
	"Sarkar",
	"Sarker",
	"Sasaki",
	"Sato",
	"Saw",
	"Sawadogo",
	"Sayed",
	"Schmidt",
	"Schneider",
	"Scott",
	"Sekh",
	"Sekha",
	"Sen",
	"Serrano",
	"Setiawan",
	"Sha",
	"Shafi",
	"Shah",
	"Shahzad",
	"Shaik",
	"Shaikh",
	"Shang",
	"Shankar",
	"Shao",
	"Sharif",
	"Sharma",
	"Shaw",
	"Shehu",
	"Sheik",
	"Sheikh",
	"Shen",
	"Sheng",
	"Shi",
	"Shimizu",
	"Shinde",
	"Shu",
	"Si",
	"Siddique",
	"Sidibe",
	"Sih",
	"Silva",
	"Simon",
	"Sin",
	"Sing",
	"Singh",
	"Sinh",
	"Sinha",
	"Smith",
	"So",
	"Soares",
	"Soe",
	"Solanki",
	"Solis",
	"Solomon",
	"Son",
	"Song",
	"Sosa",
	"Soto",
	"Sousa",
	"Souza",
	"Sow",
	"Sresth",
	"Stewart",
	"Su",
	"Suarez",
	"Sui",
	"Sulaiman",
	"Suleiman",
	"Sultan",
	"Sultana",
	"Sun",
	"Sunday",
	"Suzuki",
	"Swain",
	"Sylla",
	"Ta",
	"Tadesse",
	"Taha",
	"Tahir",
	"Takahashi",
	"Tan",
	"Tanaka",
	"Tang",
	"Tao",
	"Tavares",
	"Taylor",
	"Teixeira",
	"Teng",
	"Tesfaye",
	"Thakor",
	"Thakur",
	"Than",
	"Thanh",
	"Thapa",
	"Thin",
	"Thomas",
	"Thompson",
	"Ti",
	"Tian",
	"Tiwari",
	"Tong",
	"Torres",
	"Toure",
	"Tran",
	"Traore",
	"Trinh",
	"Truong",
	"Tu",
	"Tudu",
	"Tun",
	"Turner",
	"Uddin",
	"Ullah",
	"Umar",
	"Umaru",
	"Usman",
	"Vaghel",
	"Valdez",
	"Valencia",
	"Valenzuela",
	"Van",
	"Vargas",
	"Varma",
	"Vasav",
	"Vasquez",
	"Vazquez",
	"Vega",
	"Velasquez",
	"Velazquez",
	"Vera",
	"Verma",
	"Vieira",
	"Villanueva",
	"Vo",
	"Vu",
	"Wagner",
	"Walker",
	"Wan",
	"Wang",
	"Ward",
	"Watanabe",
	"Wati",
	"Watson",
	"Weber",
	"Wei",
	"Wen",
	"Weng",
	"White",
	"Williams",
	"Wilson",
	"Win",
	"Wong",
	"Wood",
	"Wright",
	"Wu",
	"Xavier",
	"Xi",
	"Xia",
	"Xiang",
	"Xiao",
	"Xie",
	"Xin",
	"Xing",
	"Xiong",
	"Xu",
	"Xue",
	"Yadav",
	"Yahaya",
	"Yahya",
	"Yakubu",
	"Yamada",
	"Yamaguchi",
	"Yamamoto",
	"Yan",
	"Yang",
	"Yao",
	"Yar",
	"Ye",
	"Yi",
	"Yin",
	"Yıldırım",
	"Yıldız",
	"Yılmaz",
	"Yoshida",
	"You",
	"Young",
	"Younis",
	"Yousef",
	"Yousuf",
	"Yu",
	"Yuan",
	"Yue",
	"Yun",
	"Yusuf",
	"Zaman",
	"Zamora",
	"Zapata",
	"Zhan",
	"Zhang",
	"Zhao",
	"Zheng",
	"Zhong",
	"Zhou",
	"Zhu",
	"Zhuang",
	"Zhuo",
	"Zin",
	"Zou",
	"Zuo",
}

return NAMES_FIRST,
	NAMES_LAST
