require "pg"

class DatabasePersistence
  def initialize(logger)
    @db = if Sinatra::Base.production?
            PG.connect(ENV['DATABASE_URL'])
          else
            PG.connect(dbname: "recipes")
          end
    @logger = logger
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end

  def all_recipes
    sql = "SELECT * FROM recipes ORDER BY name"

    result = query(sql)

    result.map do |tuple|
      tuple_to_recipe_hash(tuple)
    end
  end

  #Return all recipes except current, to check valid name on edit recipe page
  def all_other_recipes(id)
    sql = "SELECT * FROM recipes ORDER BY name"

    result = query(sql)

    all_recipes = result.map do |tuple|
      tuple_to_recipe_hash(tuple)
    end

    all_other_recipes = all_recipes.delete_if {|recipe| recipe[:recipe_id] == id}
  end

  def all_recipe_ids
    sql = "SELECT id FROM recipes ORDER BY id"
    result = query(sql)
    id_arr = result.values.flatten.map(&:to_i)
    id_arr
  end

  def all_ingredients
    sql = "SELECT * FROM ingredients ORDER BY name"

    ingredients_result = query(sql)

    ingredients_result.map do |ingredient_tuple|
      { id: ingredient_tuple["id"].to_i,
        name: ingredient_tuple["name"] }
    end
  end

  def all_ingredient_ids
    sql = "SELECT id FROM ingredients ORDER BY id"
    result = query(sql)
    id_arr = result.values.flatten.map(&:to_i)
    id_arr
  end

  def all_family_members
    sql = "SELECT * FROM members ORDER BY name"

    members_result = query(sql)

    members_result.map do |member_tuple|
      { id: member_tuple["id"].to_i,
        name: member_tuple["name"] }
    end
  end

  #Return family member names in array of strings 
  def all_family_member_names
    sql = "SELECT name FROM members ORDER BY name"

    names_result = query(sql)

    name_arr = names_result.values.flatten
    name_arr
  end

  def all_family_member_ids
    sql = "SELECT id FROM members ORDER BY id"
    result = query(sql)
    id_arr = result.values.flatten.map(&:to_i)
    id_arr
  end

  #Return up to 10 recipes for one page (pagination)
  def one_page_of_recipes(limit, offset)
    sql = "SELECT * FROM recipes ORDER BY recipes.name LIMIT $1 OFFSET $2"

    recipes_result = query(sql, limit, offset)

    one_page_of_recipes = recipes_result.map do |tuple|
      tuple_to_recipe_hash(tuple)
    end
  end

  #Return up to 10 ingredients for one page (pagination)
  def one_page_of_ingredients(limit, offset)
    sql = "SELECT * FROM ingredients ORDER BY ingredients.name LIMIT $1 OFFSET $2"

    ingredients_result = query(sql, limit, offset)

    ingredients_result.map do |ingredient_tuple|
      { id: ingredient_tuple["id"].to_i,
        name: ingredient_tuple["name"] }
    end
  end

  #Return up to 10 family members for one page (pagination)
  def one_page_of_family_members(limit, offset)
    sql = "SELECT * FROM members ORDER BY members.name LIMIT $1 OFFSET $2"

    members_result = query(sql, limit, offset)

    members_result.map do |family_member_tuple|
      { id: family_member_tuple["id"].to_i,
        name: family_member_tuple["name"] }
    end
  end



  def create_new_recipe(recipe_name, meal, directions, notes)
    sql = <<~SQL
      INSERT INTO recipes
      (name, meal, directions, notes, created_on)
      VALUES ($1, $2, $3, $4, NOW())
    SQL

    query(sql, recipe_name, meal, directions, notes)
  end

  #Update recipe name from edit recipe page
  def update_recipe_name(recipe_id, recipe_name)
    sql = "UPDATE recipes SET name=$1 WHERE id=$2;"
    query(sql, recipe_name, recipe_id)
  end

  #Update recipe directions, and notes, from edit recipe page (meal not used)
  def update_recipe_details(recipe_id, meal, directions, notes)
    sql = <<~SQL
      UPDATE recipes
        SET meal=$1, directions=$2, notes=$3
        WHERE id = $4;
    SQL
    query(sql, meal, directions, notes, recipe_id)
  end

  #Add and/or remove family member likes from one recipe, from edit recipe page
  def update_recipe_likes(recipe_id, new_likes)
    sql = <<~SQL
      SELECT name FROM members
      JOIN recipe_likes ON recipe_likes.member_id = members.id
      WHERE recipe_id = $1;
    SQL

    old_likes = query(sql, recipe_id).values.flatten
    add_likes = new_likes - old_likes
    rmv_likes = old_likes - new_likes

    add_likes.each do |add_name|
      sql = <<~SQL
        INSERT INTO recipe_likes
          (member_id, recipe_id) VALUES
          ( (SELECT id FROM members
          WHERE name = $1), $2 );
      SQL
      query(sql, add_name, recipe_id)
    end

    rmv_likes.each do |rmv_name|
      sql = <<~SQL
        DELETE FROM recipe_likes
          WHERE member_id = (SELECT id FROM members WHERE name = $1)
          AND recipe_id = $2;
      SQL
      query(sql, rmv_name, recipe_id)
    end

  end

  #Add and/or remove ingredients from one recipe, from edit recipe page
  def update_recipe_ingredients(recipe_id, new_ingredients)
    sql = <<~SQL
      SELECT name FROM ingredients
      JOIN recipe_ingredients ON recipe_ingredients.ingredient_id = ingredients.id
      WHERE recipe_id = $1;
    SQL

    old_ingredients = query(sql, recipe_id).values.flatten
    add_ingredients = new_ingredients - old_ingredients
    rmv_ingredients = old_ingredients - new_ingredients

    add_ingredients.each do |add_name|
      sql = <<~SQL
        INSERT INTO recipe_ingredients
          (ingredient_id, recipe_id) VALUES
          ( (SELECT id FROM ingredients
          WHERE name = $1), $2 );
      SQL
      query(sql, add_name, recipe_id)
    end

    rmv_ingredients.each do |rmv_name|
      sql = <<~SQL
        DELETE FROM recipe_ingredients
          WHERE ingredient_id = (SELECT id FROM ingredients WHERE name = $1)
          AND recipe_id = $2 ;
      SQL
      query(sql, rmv_name, recipe_id)
    end

  end

  def create_new_ingredient(ingredient_name)
    sql = "INSERT INTO ingredients (name) VALUES ($1)"
    query(sql, ingredient_name)
  end

  def create_new_family_member(family_member_name)
    sql = "INSERT INTO members (name) VALUES ($1)"
    query(sql, family_member_name)
  end

  #Add family member likes to a new recipe, using join table
  def new_recipe_likes(recipe_id, new_likes)

    new_likes.each do |add_name|
      sql = <<~SQL
        INSERT INTO recipe_likes
          (member_id, recipe_id) VALUES
          ( (SELECT id FROM members
          WHERE name = $1), $2 );
      SQL
      query(sql, add_name, recipe_id)
    end

  end

  #Add ingredients to a new recipe, using join table
  def new_recipe_ingredients(recipe_id, new_ingredients)
    new_ingredients.each do |add_name|
      sql = <<~SQL
        INSERT INTO recipe_ingredients
          (ingredient_id, recipe_id) VALUES
          ( (SELECT id FROM ingredients
          WHERE name = $1), $2 );
      SQL
      query(sql, add_name, recipe_id)
    end
  end

  #Update ingredient name, from edit ingredient page
  def update_ingredient_details(ingredient_id, new_name)
    sql = <<~SQL
      UPDATE ingredients
        SET name = $1
        WHERE id = $2;
    SQL
    query(sql, new_name, ingredient_id)
  end

  #Update family member name, from edit family member page
  def update_family_member_details(member_id, new_name)
    sql = <<~SQL
      UPDATE members
        SET name = $1
        WHERE id = $2;
    SQL
    query(sql, new_name, member_id)
  end

  #Add one ingredient to one recipe, from edit recipe page
  def add_ingredient_to_recipe(ingredient_name, recipe_id)
    sql = <<~SQL
      INSERT INTO recipe_ingredients
        (recipe_id, ingredient_id) VALUES
        ($1, (SELECT id FROM ingredients
        WHERE name = $2) );
    SQL

    query(sql, recipe_id, ingredient_name)
  end

  #Remove one ingredient from one recipe, from edit recipe page
  def remove_ingredient_from_recipe(ingredient_name, recipe_id)
    sql = <<~SQL
      DELETE FROM recipe_ingredients
        WHERE recipe_id = $1
        AND ingredient_id = 
          (SELECT id FROM ingredients
           WHERE name = $2);
    SQL

    query(sql, recipe_id, ingredient_name)
  end

  #Delete one recipe and any join table data
  def delete_recipe_and_relations(recipe_id)
    join_sql = "DELETE FROM recipe_ingredients WHERE recipe_id = $1"
    query(join_sql, recipe_id)

    join_sql = "DELETE FROM recipe_likes WHERE recipe_id = $1"
    query(join_sql, recipe_id)

    recipe_sql = "DELETE FROM recipes WHERE id = $1;"
    query(recipe_sql, recipe_id)
  end

  #Delete one ingredient based on id
  def delete_ingredient_and_relations(ingredient_id)
    join_sql = "DELETE FROM recipe_ingredients WHERE ingredient_id = $1"
    query(join_sql, ingredient_id)

    ingredient_sql = "DELETE FROM ingredients WHERE id = $1;"
    query(ingredient_sql, ingredient_id)
  end

  #Delete one family member based on id
  def delete_family_member_and_relations(member_id)
    join_sql = "DELETE FROM recipe_likes WHERE member_id = $1"
    query(join_sql, member_id)

    family_member_sql = "DELETE FROM members WHERE id = $1;"
    query(family_member_sql, member_id)
  end

  #Delete one recipe based on id
  def delete_ingredient(ingredient_id)
    sql = "DELETE FROM ingredients WHERE id = $1"
    query(sql, ingredient_id)
  end

  #Return one recipe based on id
  def find_recipe(recipe_id)
    sql = "SELECT * FROM recipes WHERE id = $1"
    result = query(sql, recipe_id)
    tuple_to_recipe_hash(result.first)
  end

  #Return one recipe based on name
  def find_recipe_id_by_name(recipe_name)
    sql = "SELECT id FROM recipes WHERE name = $1"
    result = query(sql, recipe_name)
    result.values.first.first.to_i
  end

  #Return one ingredient based on id 
  def find_ingredient(ingredient_id)
    sql = "SELECT * FROM ingredients WHERE id = $1"
    ingredient_result = query(sql, ingredient_id)
    ingredient_tuple = ingredient_result.first

    { ingredient_id: ingredient_tuple["id"].to_i,
      name: ingredient_tuple["name"] }
  end

  #Return one family member based on id 
  def find_family_member(family_member_id)
    sql = "SELECT * FROM members WHERE id = $1"
    family_member_result = query(sql, family_member_id)
    family_member_tuple = family_member_result.first

    { id: family_member_tuple["id"].to_i,
      name: family_member_tuple["name"] }
  end

  def update_recipe_name(recipe_id, new_name)
    sql = "UPDATE recipes SET name = $1 WHERE id = $2"
    query(sql, new_name, recipe_id)
  end

  #Return only ingredients included in a recipe
  def find_ingredients_for_recipe(recipe_id)
    ingredients_sql = <<~SQL
      SELECT ingredients.* FROM ingredients
        JOIN recipe_ingredients
        ON recipe_ingredients.ingredient_id = ingredients.id
        WHERE recipe_id = $1
        ORDER BY ingredients.name;
    SQL

    ingredients_result = query(ingredients_sql, recipe_id)
    ingredients_result.map do |ingredient_tuple|
      { ingredient_id: ingredient_tuple["id"].to_i,
        name: ingredient_tuple["name"] }
    end
  end

  #Return ingredients, with status as checked if included in recipe 
  def find_ingredients_for_edit_recipe(recipe_id)
    ingredients_sql = <<~SQL
      SELECT DISTINCT ingredients.id, ingredients.name,
        recipe_ingredients.ingredient_id IN
          ( SELECT ingredient_id FROM recipe_ingredients WHERE recipe_id = $1 ) AS included
        FROM ingredients
        LEFT JOIN recipe_ingredients
        ON ingredients.id = recipe_ingredients.ingredient_id
        ORDER BY ingredients.name;
    SQL

    ingredients_result = query(ingredients_sql, recipe_id)
    ingredients_result.map do |ingredient_tuple|
      check_status = ingredient_tuple["included"] == "t" ? "checked" : ""

      { id: ingredient_tuple["id"].to_i,
        name: ingredient_tuple["name"],
        check_status: check_status
         }
    end

  end

  #Return only family members who like a recipe
  def find_family_members_for_recipe(recipe_id)
    family_members_sql = <<~SQL
      SELECT members.* FROM members
        JOIN recipe_likes
        ON recipe_likes.member_id = members.id
        WHERE recipe_id = $1
        ORDER BY members.name;
    SQL

    family_members_result = query(family_members_sql, recipe_id)
    family_members_result.map do |family_member_tuple|
      { id: family_member_tuple["id"].to_i,
        name: family_member_tuple["name"] }
    end
  end

  #Return all family members and their checkbox status for edit recipe page
  def find_family_members_for_edit_recipe(recipe_id)
    family_members_sql = <<~SQL
      SELECT DISTINCT members.id, members.name,
        recipe_likes.member_id IN
          ( SELECT member_id FROM recipe_likes WHERE recipe_id = $1 ) AS likes
        FROM members
        LEFT JOIN recipe_likes
        ON members.id = recipe_likes.member_id
        ORDER BY members.name;
    SQL

    family_members_result = query(family_members_sql, recipe_id)
    family_members_result.map do |family_member_tuple|
      check_status = family_member_tuple["likes"] == "t" ? "checked" : ""

      { id: family_member_tuple["id"].to_i,
        name: family_member_tuple["name"],
        check_status: check_status
         }
    end
  end

  #Return recipes which include this key ingredient
  def find_recipes_for_ingredient(ingredient_id)
    recipes_sql = <<~SQL
      SELECT recipes.* FROM recipes
        JOIN recipe_ingredients
        ON recipe_ingredients.recipe_id = recipes.id
        WHERE ingredient_id = $1
        ORDER BY recipes.name;
    SQL

    recipe_results = query(recipes_sql, ingredient_id)
    recipe_results.map do |recipe_tuple|
      tuple_to_recipe_hash(recipe_tuple)
    end
  end

  #Return recipes which are liked by this family member
  def find_recipes_for_family_member(family_member_id)
    recipes_sql = <<~SQL
      SELECT recipes.* FROM recipes
        JOIN recipe_likes
        ON recipe_likes.recipe_id = recipes.id
        WHERE member_id = $1
        ORDER BY recipes.name;
    SQL

    recipe_results = query(recipes_sql, family_member_id)
    recipe_results.map do |recipe_tuple|
      tuple_to_recipe_hash(recipe_tuple)
    end
  end

  private

  def tuple_to_recipe_hash(tuple)
    { recipe_id: tuple["id"].to_i,
      name: tuple["name"],
      meal: tuple["meal"],
      directions: tuple["directions"],
      notes: tuple["notes"] }
  end
end
