CREATE TABLE recipes (
  id serial PRIMARY KEY,
  name varchar(40) NOT NULL UNIQUE,
  meal text NOT NULL CHECK (meal IN ('breakfast', 'lunch', 'dinner')),
  directions text,
  notes text,
  created_on date
);

CREATE TABLE ingredients (
  id serial PRIMARY KEY,
  name varchar(30) NOT NULL UNIQUE
);

CREATE TABLE recipe_ingredients (
  id serial PRIMARY KEY,
  recipe_id integer REFERENCES recipes(id),
  ingredient_id integer REFERENCES ingredients(id)
);

CREATE TABLE members (
  id serial PRIMARY KEY,
  name varchar(40) NOT NULL UNIQUE
);

CREATE TABLE recipe_likes (
  id serial PRIMARY KEY,
  member_id integer REFERENCES members(id),
  recipe_id integer REFERENCES recipes(id)
);

INSERT INTO recipes (name, meal, directions, notes, created_on) VALUES ('Korean Bibimbap', 'dinner', E'1. Cook all ingredients separately, with some sesame oil\r\n2. Top a bowl of rice with all ingredients', 'Don''t forget the kimchi!', NOW());
INSERT INTO recipes (name, meal, directions, notes, created_on) VALUES ('Wild Rice Stuffed Butternut', 'dinner', E'1. Saute wild rice with vegetables\r\n2. Stuff butternut squash and bake at 350 until done', '', '2023-07-18');
INSERT INTO recipes (name, meal, directions, notes, created_on) VALUES ('Chana Masala Curry', 'dinner', E'1. Saute onions and garlic until soft\r\n2. Add canned tomatoes, spices, and water and heat through.\r\n3. Add chickpeas, heat, and serve', 'Don''t forget to make naan ahead of time!', NOW());
INSERT INTO recipes (name, meal, directions, notes, created_on) VALUES ('Nachos', 'dinner', E'1. Bake tortilla chips and cheese at 350 until melted\r\n2. Cover with meat, beans, and other toppings', '', NOW());
INSERT INTO recipes (name, meal, directions, notes, created_on) VALUES ('Herring Pasta', 'dinner', E'1. Boil pasta\r\n2. Fry garlic, onion, and herring\r\n3. Toss pasta and toppings with tomatoes, olive oil, and lemon juice', 'Serve with parmesan', NOW());
INSERT INTO recipes (name, meal, directions, notes, created_on) VALUES ('Falafel', 'dinner', E'1. Use food processor to combine ingredients with tahini\r\n2. Form into balls or patties\r\n3. Fry or bake until browned', 'Serve in pita with yogurt sauce, cucumbers, tomatoes, and mint to taste', NOW());
INSERT INTO recipes (name, meal, directions, notes, created_on) VALUES ('Lasagna', 'dinner', E'1. Chop veggies and cook with onions, garlic and canned tomatoes until sauce\r\n2. Assemble ingredients in layers of sauce, noodles, cheese, repeat \r\n3. Bake at 350F for at least 45min', '1. No bake noodles are best, but make plenty of tomato sauce!\r\n2. Cover with tinfoil halfway through cooking if top gets dry', NOW());
INSERT INTO recipes (name, meal, directions, notes, created_on) VALUES ('Spring Rolls', 'dinner', E'1. Chop ingredients and saute with onion and garlic until soft\r\n2. Stuff spring roll papers and fry until crispy', '', '2023-07-18');
INSERT INTO recipes (name, meal, directions, notes, created_on) VALUES ('Kale chips', 'dinner', E'1. Toss with olive oil, salt, nutritional yeast\r\n2. Bake at 300F until crispy', '', NOW());
INSERT INTO recipes (name, meal, directions, notes, created_on) VALUES ('Tabbouleh Salad', 'dinner', E'1. Cook quinoa\r\n2. Chop other ingredients\r\n3. Toss together with lemon juice and olive oil', '', NOW());
INSERT INTO recipes (name, meal, directions, notes, created_on) VALUES ('Mac & Cheese', 'dinner', E'1. Boil pasta\r\n2. Mix with cheese and butter until melted', 'Breadcrumbs on top for grown-ups', NOW());
INSERT INTO recipes (name, meal, directions, notes, created_on) VALUES ('Lentil Red Sauce Pasta', 'dinner', E'1. Soak lentils overnight\r\n2. Saute garlic and onion, and add tomatoes and lentils until soft', 'Serve over pasta with parmesan', NOW());
INSERT INTO recipes (name, meal, directions, notes, created_on) VALUES ('Taco Bowl', 'dinner', E'1. Cook soy meat and heat black beans\r\n2. Chop all ingredients\r\n3. Serve on brown rice, cabbage, romaine, or a combination', 'Don''t forget the hot sauce!', NOW());
INSERT INTO recipes (name, meal, directions, notes, created_on) VALUES ('Coconut Turmeric Lentil Soup', 'dinner', E'1. Soak lentils overnight, then boil until soft\r\n2. Saute onion and garlic with carrots\r\n3. Mix in lentils, water, and spices', 'Serve with cilantro and toasted coconut', NOW());
INSERT INTO recipes (name, meal, directions, notes, created_on) VALUES ('Caesar Salad', 'dinner', E'1. Chop romaine\r\n2. Shred cabbage, carrots, green onions, and parsley\r\n3. Toss with dressing', 'Dressing is cashews, lemon juice, seaweed, salt, water, vinegar, mustard blended until creamy', NOW());
INSERT INTO recipes (name, meal, directions, notes, created_on) VALUES ('Miso Soup', 'dinner', E'1. Boil veggies with dashi until soft\r\n2. Cut heat and mix in miso until smooth', '', NOW());
INSERT INTO recipes (name, meal, directions, notes, created_on) VALUES ('Crispy Tofu Broccoli', 'dinner', E'1. Drain tofu and cut into cubes\r\n2. Coat cubes in corn starch and fry until crispy\r\n3. Add ginger, garlic and soy sauce to pan and cook just until thick\r\n3. Serve over rice with steamed broccoli and sesame seeds', 'Don''t make sauce too salty!', NOW());
INSERT INTO recipes (name, meal, directions, notes, created_on) VALUES ('Tacos', 'dinner', E'1. Cook meat and heat black beans\r\n2. Chop other ingredients\r\n3. Serve together in corn tortillas', 'Don''t forget the hot sauce!', NOW());
INSERT INTO recipes (name, meal, directions, notes, created_on) VALUES ('Thai Spicy Eggplant', 'dinner', E'1. Chop veggies and tofu\r\n2. Fry tofu until crispy\r\n3. Saute veggies with onion and garlic until soft\r\n4. Add cooked tofu and thai basil to veggies, cook just until heated through', 'Serve with cashew nuts and sriracha over jasmine rice', NOW());
INSERT INTO recipes (name, meal, directions, notes, created_on) VALUES ('Cabbage Salad', 'dinner', E'Shred all ingredients and toss with sesame dressing', 'Sesame dressing is soy sauce, rice vinegar, maple syrup, sesame oil, avocado oil, sesame seeds', NOW());

INSERT INTO ingredients (name) VALUES ('eggplant');
INSERT INTO ingredients (name) VALUES ('red pepper');
INSERT INTO ingredients (name) VALUES ('chickpeas');
INSERT INTO ingredients (name) VALUES ('parsley');
INSERT INTO ingredients (name) VALUES ('smoked herring');
INSERT INTO ingredients (name) VALUES ('cherry tomatoes');
INSERT INTO ingredients (name) VALUES ('tofu');
INSERT INTO ingredients (name) VALUES ('canned tomatoes');
INSERT INTO ingredients (name) VALUES ('thai basil');
INSERT INTO ingredients (name) VALUES ('green cabbage');
INSERT INTO ingredients (name) VALUES ('butternut squash');
INSERT INTO ingredients (name) VALUES ('zucchini');
INSERT INTO ingredients (name) VALUES ('red cabbage');
INSERT INTO ingredients (name) VALUES ('black eyed peas');
INSERT INTO ingredients (name) VALUES ('cilantro');
INSERT INTO ingredients (name) VALUES ('jalapeño');
INSERT INTO ingredients (name) VALUES ('kale');
INSERT INTO ingredients (name) VALUES ('romaine lettuce');
INSERT INTO ingredients (name) VALUES ('carrots');
INSERT INTO ingredients (name) VALUES ('bean sprouts');
INSERT INTO ingredients (name) VALUES ('soy meat');
INSERT INTO ingredients (name) VALUES ('tomatoes');
INSERT INTO ingredients (name) VALUES ('black beans');
INSERT INTO ingredients (name) VALUES ('red lentils');
INSERT INTO ingredients (name) VALUES ('arugula');
INSERT INTO ingredients (name) VALUES ('okra');
INSERT INTO ingredients (name) VALUES ('broccoli');
INSERT INTO ingredients (name) VALUES ('coconut milk');
INSERT INTO ingredients (name) VALUES ('quinoa');
INSERT INTO ingredients (name) VALUES ('cheese');
INSERT INTO ingredients (name) VALUES ('wild rice');
INSERT INTO ingredients (name) VALUES ('celery');
INSERT INTO ingredients (name) VALUES ('basil');
INSERT INTO ingredients (name) VALUES ('spinach');
INSERT INTO ingredients (name) VALUES ('daikon radish');
INSERT INTO ingredients (name) VALUES ('avocado');
INSERT INTO ingredients (name) VALUES ('mushrooms');

INSERT INTO members (name) VALUES ('Lizzie');
INSERT INTO members (name) VALUES ('Mommy');
INSERT INTO members (name) VALUES ('Daddy');
INSERT INTO members (name) VALUES ('Mark');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (20, 19);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (20, 15);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (20, 10);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (8, 19);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (8, 10);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (8, 17);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (8, 37);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (8, 21);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (18, 23);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (18, 30);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (18, 15);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (18, 10);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (18, 16);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (18, 21);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (18, 22);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (13, 36);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (13, 23);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (13, 30);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (13, 15);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (13, 10);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (13, 16);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (13, 13);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (13, 21);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (13, 22);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (18, 36);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (11, 30);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (15, 19);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (15, 3);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (15, 10);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (15, 13);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (15, 18);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (10, 6);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (10, 4);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (10, 29);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (17, 27);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (17, 7);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (12, 33);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (12, 8);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (12, 19);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (12, 24);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (3, 8);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (3, 3);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (3, 15);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (3, 28);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (5, 25);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (5, 6);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (5, 5);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (19, 19);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (19, 1);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (19, 2);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (19, 9);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (19, 7);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (2, 11);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (2, 17);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (2, 37);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (2, 31);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (1, 20);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (1, 19);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (1, 17);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (1, 21);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (14, 19);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (14, 15);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (14, 28);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (14, 24);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (6, 3);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (6, 4);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (6, 22);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (9, 17);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (4, 36);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (4, 23);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (4, 30);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (4, 15);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (4, 16);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (4, 21);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (4, 22);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (16, 19);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (16, 3);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (16, 35);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (16, 17);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (16, 7);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (7, 8);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (7, 19);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (7, 30);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (7, 37);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (7, 34);
INSERT INTO recipe_ingredients (recipe_id, ingredient_id) VALUES (8, 32);

INSERT INTO recipe_likes (member_id, recipe_id) VALUES (3, 20);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (1, 20);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (4, 20);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (2, 20);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (3, 8);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (1, 8);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (4, 8);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (2, 8);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (3, 18);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (1, 18);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (4, 18);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (2, 18);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (3, 13);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (1, 13);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (4, 13);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (2, 13);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (1, 11);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (4, 11);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (1, 15);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (4, 15);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (3, 10);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (2, 10);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (3, 17);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (1, 17);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (2, 17);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (3, 12);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (1, 12);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (4, 12);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (2, 12);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (3, 3);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (1, 3);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (2, 3);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (3, 5);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (1, 5);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (4, 5);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (2, 5);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (3, 19);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (2, 19);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (3, 2);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (1, 2);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (4, 2);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (2, 2);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (3, 1);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (1, 1);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (4, 1);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (2, 1);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (3, 14);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (1, 14);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (2, 14);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (3, 6);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (1, 6);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (4, 6);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (2, 6);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (3, 9);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (1, 9);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (4, 9);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (2, 9);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (3, 4);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (1, 4);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (4, 4);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (2, 4);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (3, 16);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (4, 16);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (2, 16);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (3, 7);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (1, 7);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (4, 7);
INSERT INTO recipe_likes (member_id, recipe_id) VALUES (2, 7);
