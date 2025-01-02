# Picky Eaters Recipe Keeper
by Jesse Kercheval
Launch School RB189 course project - for LS staff eyes only

## Personal Note
I had a blast with this project! So exciting to actually make a thing!
I know went beyond the minimum requirements as I have multiple many:many relationships, but I hope I didn't go overboard or make it hard to grade. I was challenged and motivated by this idea, I learned a ton, and I think my family and I will actually keep using it.
Credit to my daughter Hannah for drawing the image title and choosing the color scheme.

## About
Picky Eaters supports quick meal planning with just enough recipe info: family likes and key ingredients. Planning family dinners every week is tough. First we need to find or recall the many dinner recipes, then we need to narrow them down by ingredients on hand and picky family member tastes. Most recipe apps solve the problem of *how* to make a recipe. Picky Eaters focuses on *what* to make.

Picky Eaters allows users to save recipes, ingredients, and family members. Then each recipe can be associated with the key ingredients, and which family member enjoys the recipe. There are also text areas to add more detailed directions and notes. Seed data including a number of recipes, ingredients, and family members comes loaded with the web app at installation. These can be easily added to, deleted, or edited by an authorized user.

Picky Eaters web app uses PostgreSQL for data. The database is called "recipes" and there are three tables: recipes, ingredients, and members. Ingredients and members tables each have a many-to-many relationship to recipes. Any row can be viewed, deleted, or updated, and new rows can be added. 

For inspiration, use the Surprise Me! link to view a random recipe.

Future version add-on ideas
* meals table and attribute for recipes (breakfast, lunch, dinner, snack)
* sidebar to filter recipes by ingredients and family members
* search bar to search for recipes or other objects
* add ingredients to a separate shopping list

## Getting Started
I used the following to run and test this application:
- Ruby 3.2.2
- Mozilla Firefox 115.0.2
- PostgreSQL 14.8

## Installation
Download and unzip the `rb189_picky_eaters file`, and navigate into the `rb189_picky_eaters` directory
Install PostgreSQL, version 14.8 or higher is recommended
Install Ruby 3.2.2, or switch to 3.2.2 with Ruby version manager
Install required gems with `bundle install` in rb189_picky directory
Create a new database with `createdb recipes`
Create tables and insert seed data with `psql -d recipes < schema.sql`
Start web app with `ruby picky.rb`
Browse to http://localhost:4567 in web browser

## Usage
A list of all recipes appears on the homepage, under the title image, navigation links in pink, and action links in blue.

The top pink navigation bar has links for "ALL RECIPES", "ALL INGREDIENTS", and "FAMILY MEMBERS" that can be clicked on to view each list respectively.

Recipes, ingredients, and family member list pages limit results to 10 per page. If there are more than 10 items total, pagination controls will appear below the list to view additional results.

**View recipe** details by clicking on a recipe's title from the list. Each recipe detail lists which family members like it, the key ingredients used in the recipe, and any directions or notes. Detail pages allow viewing of all associated objects using horizontal scrolling in each section (rather than using pagination).

**View ingredient** or family member details by clicking on those items. Ingredients and family member detail pages show which recipes they are associated with.

**View a random recipe** with the "Surprise Me!" link at the far right of the top pink navigation bar.

**NOTE:** The following create, edit, and delete functions require signing in as an authorized user.

**Sign in** by clicking on the "Sign In" link in the pink top right rectangle available on any page. From the sign in page, enter username "developer" and password "letmein", and click the "SIGN IN" button.

**Sign out** using the "SIGN OUT" button, also located in the pink top right rectangle available on any page.

**Create a new recipe, ingredient, or family member** using the "+NEW" links from the top blue actions bar of each respective list page or the homepage.

**Edit a recipe, ingredient, or family member** by using the "EDIT" link from the top blue actions bar of each respective detail page.

**Delete a recipe, ingredient, or family member** by using the "DELETE" button from the top blue actions bar of each respective edit page. Please note that the delete button only appears on each edit page.

# picky-eaters
