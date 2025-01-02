require "bcrypt"
require "sinatra"
require "sinatra/content_for"
require "tilt/erubis"
require "yaml"

require_relative "database_persistence"

configure do
  enable :sessions
  set :erb, :escape_html => true
end

configure(:development) do
  require "sinatra/reloader"
  also_reload "database_persistence.rb"
end

before do
  @storage = DatabasePersistence.new(logger)
end

helpers do
  # Output multi-line text area data to screen 
  def output_textarea(string, &block)
    lines = string ? string.split("\r\n") : [""]
    lines.each { |line| yield line }
  end

  # Set class for pagination as "active" for current page number
  def active_class(current, page)
   if current == page
     "active"
   else
     ""
   end
  end
end

# View homepage => view all recipes
get '/' do
  session[:requested_url] = "/"
  require_signed_in_user

  redirect "/recipes"
end

# View user sign in page
get "/users/signin" do
  erb :signin
end

def user_signed_in?
  session.key?(:username)
end

def require_signed_in_user
  unless user_signed_in?
    session[:error] = "You must be signed in to do that."
    redirect "/users/signin"
  end
end

def valid_credentials?(username, password)
  credentials = load_user_credentials

  if credentials.key?(username)
    bcrypt_password = BCrypt::Password.new(credentials[username])
    bcrypt_password == password
  else
    false
  end
end

# Sign in user, if credentials valid
post "/users/signin" do
  username = params[:username]
  requested_url = params[:requested_url] ? params[:requested_url] : "/"

  if valid_credentials?(username, params[:password])
    session[:username] = username
    session[:success] = "Welcome!"

    redirect requested_url
  else
    session[:error] = "Incorrect username or password."
    status 422
    erb :signin
  end
end

# Sign out user
post "/users/signout" do
  session.delete(:username)
  session[:success] = "You have been signed out."
  redirect "/users/signin"
end

# Return total page count and current page number
def pagination(all_recipes, page_num)
  if all_recipes.empty?
    total_pages = 1
    current = 1
  else
    recipe_count = all_recipes.map {|hash| hash[:recipe_id]}.count
    total_pages = 1 + ((recipe_count - 1)/10)
    if page_num.nil?
      current = 1
    else
      current = page_num.to_i.abs
    end
  end

  [total_pages, current]
end

# View list of recipes, with pagination number if valid
get '/recipes' do
  session[:requested_url] = "/recipes"
  require_signed_in_user

  all_recipes = @storage.all_recipes
  page_num = params['page']
  @total_page_count, @current_page = pagination(all_recipes, page_num)

  error = error_for_page_number(@current_page, @total_page_count)
  if error
    session[:error] = error
    redirect "/recipes"
  else
    @prev_page = @current_page == 1 ? @total_page_count : @current_page - 1
    @next_page = @current_page == @total_page_count ? 1 : @current_page + 1
    limit = 10
    offset = (@current_page - 1) * 10
    @recipes = @storage.one_page_of_recipes(limit, offset)

    erb :recipes, layout: :layout
  end
end

# View list of family members
get '/family_members' do
  session[:requested_url] = "/family_members"
  require_signed_in_user

  all_family_members = @storage.all_family_members
  page_num = params['page']
  @total_page_count, @current_page = pagination(all_family_members, page_num)

  error = error_for_page_number(@current_page, @total_page_count)
  if error
    session[:error] = error
    redirect "/family_members"
  else
    @prev_page = @current_page == 1 ? @total_page_count : @current_page - 1
    @next_page = @current_page == @total_page_count ? 1 : @current_page + 1
    limit = 10
    offset = (@current_page - 1) * 10
    @family_members = @storage.one_page_of_family_members(limit, offset)

    erb :family_members
  end
end

# Render new ingredient form
get '/ingredients/new' do
  session[:requested_url] = "/ingredients/new"
  require_signed_in_user

  erb :new_ingredient, layout: :layout
end

# Render new family member form
get '/family_members/new' do
  session[:requested_url] = "/family_members/new"
  require_signed_in_user

  erb :new_family_member, layout: :layout
end

# View list of ingredients, with page number if valid 
get '/ingredients' do
  session[:requested_url] = "/ingredients"
  require_signed_in_user

  all_ingredients = @storage.all_ingredients
  page_num = params['page']
  @total_page_count, @current_page = pagination(all_ingredients, page_num)

  error = error_for_page_number(@current_page, @total_page_count)
  if error
    session[:error] = error
    redirect "/ingredients"
  else
    @prev_page = @current_page == 1 ? @total_page_count : @current_page - 1
    @next_page = @current_page == @total_page_count ? 1 : @current_page + 1
    limit = 10
    offset = (@current_page - 1) * 10
    @ingredients = @storage.one_page_of_ingredients(limit, offset)

    erb :ingredients, layout: :layout
  end
end

# View a random recipe, by recipe id
get '/recipes/surprise' do
  session[:requested_url] = "/recipes/surprise"
  require_signed_in_user

  recipe_id_list = @storage.all_recipe_ids
  recipe_id = recipe_id_list.sample

  if recipe_id
    redirect "/recipes/#{recipe_id}"
  else
    session[:error] = "<< You don't have any recipes yet >>"
    redirect "/recipes"
  end
end

#Load user accounts from external yaml file
def load_user_credentials
  credentials_path = if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/users.yml", __FILE__)
  else
    File.expand_path("../users.yml", __FILE__)
  end
  YAML.load_file(credentials_path)
end

# Return error message if new recipe name, directions, notes, or ingredients invalid
def error_for_new_recipe(recipe_name, ingredients, directions)
  if !(1..40).cover? recipe_name.size
    "Recipe name must be between 1 and 40 characters"
  elsif recipe_name =~ /[^a-zA-ZÀ-ÿ0-9\s]/
    "Recipe name can only contain letters and numbers"
  elsif @storage.all_recipes.any? {|recipe| recipe[:name].downcase == recipe_name.downcase}
    "There's already a recipe with that name"
  elsif ingredients.empty?
    "Recipes must include at least one ingredient"    
  elsif directions.strip == ""
    "Recipes must include directions"
  end
end

# Return error message if edit recipe name invalid
def error_for_edit_recipe(recipe_name, id, ingredients, directions)
  if !(1..40).cover? recipe_name.size
    "Recipe name must be between 1 and 40 characters."
  elsif recipe_name =~ /[^a-zA-ZÀ-ÿ0-9\s]/
    "Recipe name can only contain letters and numbers"
  elsif @storage.all_other_recipes(id).any? {|recipe| recipe[:name].downcase == recipe_name.downcase}
    "There's already a recipe with that name."
  elsif ingredients.empty?
    "Recipes must include at least one ingredient"
  elsif directions.strip == ""
    "Recipes must include directions"
  end
end

# Return error message if ingredient name invalid
def error_for_ingredient_name(ingredient_name)
  if !(1..30).cover? ingredient_name.size
    "Ingredient must be between 1 and 25 characters."
  elsif ingredient_name =~ /[^a-zA-ZÀ-ÿ0-9\s]/
    "Ingredient name can only contain letters and numbers"
  elsif @storage.all_ingredients.any? {|ingredient| ingredient[:name].downcase == ingredient_name.downcase}
    "There's already an ingredient with that name."
  end
end

# Return error message if family member name invalid
def error_for_family_member_name(member_name)
  if !(1..40).cover? member_name.size
    "Name must be between 1 and 25 characters."
  elsif member_name =~ /[^a-zA-ZÀ-ÿ0-9\s]/
    "Family member name can only contain letters and numbers"
  elsif @storage.all_family_members.any? {|family_member| family_member[:name].downcase == member_name.downcase}
    "There's already a family member with that name."
  end
end

# Return error message if page param is invalid
def error_for_page_number(requested_page, page_count)
  if !(1..page_count).cover? requested_page
    "The requested page doesn't exist."
  end
end

# Render new recipe form
get '/recipes/new' do
  session[:requested_url] = "/recipes/new"
  require_signed_in_user


  @family_members = @storage.all_family_members
  @ingredients = @storage.all_ingredients

  erb :new_recipe, layout: :layout
end

#Keep valid family member selections, even if name is invalid for edit recipe
def check_family_members(family_members, recipe_likes)
  family_members.map do |family_member|
    check_status = recipe_likes.include?(family_member[:name]) ? "checked" : ""

    { id: family_member[:id],
      name: family_member[:name],
      check_status: check_status
       }
  end
end

#Keep valid ingredient selections, even if name is invalid for edit recipe
def check_ingredients(ingredients, recipe_ingredients)
  ingredients.map do |ingredient|
    check_status = recipe_ingredients.include?(ingredient[:name]) ? "checked" : ""

    { id: ingredient[:id],
      name: ingredient[:name],
      check_status: check_status
       }
  end
end

# Create a new recipe
post '/recipes' do
  session[:requested_url] = "/recipes"
  require_signed_in_user

  @recipe_name = params[:recipe_name].strip.capitalize
  recipe_meal = params[:recipe_meal]
  recipe_likes = params[:recipe_likes].nil? ? [] : params[:recipe_likes]

  recipe_ingredients = params[:recipe_ingredients].nil? ? [] : params[:recipe_ingredients]

  @recipe_directions = params[:recipe_directions].strip

  @recipe_notes = params[:recipe_notes].strip

  error = error_for_new_recipe(@recipe_name, recipe_ingredients, @recipe_directions)
  if error
    session[:error] = error
    require_signed_in_user

    @recipe_name
    @family_members = check_family_members(@storage.all_family_members, recipe_likes)
    @ingredients = check_ingredients(@storage.all_ingredients, recipe_ingredients)

    erb :new_recipe, layout: :layout
  else
    @storage.create_new_recipe(@recipe_name, recipe_meal, @recipe_directions, @recipe_notes)
    recipe_id = load_recipe_id_by_name(@recipe_name)
    @storage.new_recipe_likes(recipe_id, recipe_likes)
    @storage.new_recipe_ingredients(recipe_id, recipe_ingredients)

    session[:success] = "The new recipe has been created."
    redirect "/recipes/#{recipe_id}"
  end
end

# Create a new ingredient
post '/ingredients' do
  session[:requested_url] = "/ingredients"
  require_signed_in_user

  ingredient_name = params[:ingredient_name].strip.downcase

  error = error_for_ingredient_name(ingredient_name)
  if error
    session[:error] = error
    require_signed_in_user
    erb :new_ingredient
  else
    @storage.create_new_ingredient(ingredient_name)
    session[:success] = "The ingredient has been created."
    redirect "/ingredients"
  end
end

# Create a new family member
post '/family_members' do
  session[:requested_url] = "/family_members"
  require_signed_in_user

  family_member_name = params[:family_member_name].strip.capitalize

  error = error_for_family_member_name(family_member_name)
  if error
    session[:error] = error
    require_signed_in_user
    erb :new_family_member
  else
    @storage.create_new_family_member(family_member_name)
    session[:success] = "The family_member has been created."
    redirect "/family_members"
  end
end

# Load recipe by id, or error message if invalid
def load_recipe(recipe_id)
  recipe_id_list = @storage.all_recipe_ids

  if recipe_id_list.include?(recipe_id)
    recipe = @storage.find_recipe(recipe_id)
    return recipe
  else
    session[:error] = "The requested recipe doesn't exist."
    redirect "/recipes"
  end
end

# Load recipe by name, or error message if invalid
def load_recipe_id_by_name(recipe_name)
  recipe = @storage.find_recipe_id_by_name(recipe_name)
  return recipe if recipe

  session[:error] = "The requested recipe doesn't exist."
  redirect "/recipes"
end

# Load an ingredient by id, or error message if invalid
def load_ingredient(ingredient_id)
  ingredient_id_list = @storage.all_ingredient_ids

  if ingredient_id_list.include?(ingredient_id)
    ingredient = @storage.find_ingredient(ingredient_id)
    return ingredient if ingredient
  else
    session[:error] = "The requested ingredient doesn't exist."
    redirect "/ingredients"
  end
end

# Load a family member if valid, or error message if invalid
def load_family_member(family_member_id)
  family_member_id_list = @storage.all_family_member_ids
  
  if family_member_id_list.include?(family_member_id)
    family_member = @storage.find_family_member(family_member_id)
    return family_member if family_member
  else
    session[:error] = "The requested family member doesn't exist."
    redirect "/family_members"
  end
end

# View a single recipe, incl ingredients and family members
get '/recipes/:recipe_id' do
  recipe_id = params[:recipe_id].to_i
  session[:requested_url] = "/recipes/#{recipe_id}"
  require_signed_in_user

  @recipe = load_recipe(recipe_id)
  @ingredients = @storage.find_ingredients_for_recipe(recipe_id)
  @family_members = @storage.find_family_members_for_recipe(recipe_id)

  erb :recipe_detail, layout: :layout
end

# View a single ingredient and associated recipes
get '/ingredients/:ingredient_id' do
  ingredient_id = params[:ingredient_id].to_i
  session[:requested_url] = "/ingredients/#{ingredient_id}"
  require_signed_in_user

  @ingredient = load_ingredient(ingredient_id)
  @recipes = @storage.find_recipes_for_ingredient(ingredient_id)

  erb :ingredient_detail, layout: :layout
end

# View a single family member and the recipes they liked
get '/family_members/:family_member_id' do
  family_member_id = params[:family_member_id].to_i
  session[:requested_url] = "/family_members/#{family_member_id}"
  require_signed_in_user

  @family_member = load_family_member(family_member_id)
  @recipes = @storage.find_recipes_for_family_member(family_member_id)

  erb :family_member_detail
end

# Render form to edit a recipe details
get '/recipes/:recipe_id/edit_recipe' do
  recipe_id = params[:recipe_id].to_i
  session[:requested_url] = "/recipes/#{recipe_id}/edit_recipe"
  require_signed_in_user

  @recipe = load_recipe(recipe_id)
  @ingredients = @storage.find_ingredients_for_edit_recipe(recipe_id)
  @family_members = @storage.find_family_members_for_edit_recipe(recipe_id)

  erb :edit_recipe
end

# Edit a recipe
post '/recipes/:recipe_id' do
  recipe_id = params[:recipe_id].to_i
  session[:requested_url] = "/recipes/#{recipe_id}"
  require_signed_in_user

  recipe_name = params[:recipe_name].strip
  recipe_meal = params[:recipe_meal]
  recipe_directions = params[:recipe_directions].strip
  recipe_notes = params[:recipe_notes].strip
  @storage.update_recipe_details(recipe_id, recipe_meal, recipe_directions, recipe_notes)

  recipe_likes = params[:recipe_likes].nil? ? [] : params[:recipe_likes]
  @storage.update_recipe_likes(recipe_id, recipe_likes) unless recipe_likes.empty?

  recipe_ingredients = params[:recipe_ingredients].nil? ? [] : params[:recipe_ingredients]
  @storage.update_recipe_ingredients(recipe_id, recipe_ingredients) unless recipe_ingredients.empty?

  error = error_for_edit_recipe(recipe_name, recipe_id, recipe_ingredients, recipe_directions)
  if error
    session[:error] = error
    require_signed_in_user

    @recipe = load_recipe(recipe_id)
    @ingredients = @storage.find_ingredients_for_edit_recipe(recipe_id)
    @family_members = @storage.find_family_members_for_edit_recipe(recipe_id)

    erb :edit_recipe, layout: :layout
  else
    @storage.update_recipe_name(recipe_id, recipe_name)
    session[:success] = "The recipe has been updated."
    redirect "/recipes/#{recipe_id}"
  end
end

# Render edit ingredient form
get '/ingredients/:ingredient_id/edit_ingredient' do
  ingredient_id = params[:ingredient_id].to_i
  session[:requested_url] = "/ingredients/#{ingredient_id}/edit_ingredient"
  require_signed_in_user

  @ingredient = load_ingredient(ingredient_id)

  erb :edit_ingredient
end

# Edit an ingredient
post '/ingredients/:ingredient_id' do
  ingredient_id = params[:ingredient_id].to_i
  session[:requested_url] = "/ingredients/#{ingredient_id}"
  require_signed_in_user

  ingredient_name = params[:ingredient_name].strip

  error = error_for_ingredient_name(ingredient_name)
  if error
    session[:error] = error
    require_signed_in_user
    @ingredient = load_ingredient(ingredient_id)
    erb :edit_ingredient, layout: :layout
  else
    @storage.update_ingredient_details(ingredient_id, ingredient_name)
    session[:success] = "The ingredient has been updated."
    redirect "/ingredients/#{ingredient_id}"
  end
end

# Render edit family member form
get '/family_members/:family_member_id/edit_family_member' do
  family_member_id = params[:family_member_id].to_i
  session[:requested_url] = "/family_members/#{family_member_id}/edit_family_member"
  require_signed_in_user

  @family_member = load_family_member(family_member_id)

  erb :edit_family_member
end

# Edit a family member
post '/family_members/:family_member_id' do
  family_member_id = params[:family_member_id].to_i
  session[:requested_url] = "/family_members/#{family_member_id}"
  require_signed_in_user

  family_member_name = params[:family_member_name].strip

  error = error_for_family_member_name(family_member_name)
  if error
    session[:error] = error
    require_signed_in_user
    @family_member = load_family_member(family_member_id)
    erb :edit_family_member, layout: :layout
  else
    @storage.update_family_member_details(family_member_id, family_member_name)
    session[:success] = "The family_member has been updated."
    redirect "/family_members/#{family_member_id}"
  end
end

# Delete a recipe
post '/recipes/:recipe_id/delete' do
  recipe_id = params[:recipe_id].to_i
  session[:requested_url] = "/recipes/#{recipe_id}/delete"
  require_signed_in_user

  @storage.delete_recipe_and_relations(recipe_id)
  if env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest"
    "/recipes"
  else
    session[:success] = "The recipe has been deleted."
    redirect "/recipes"
  end
end

def error_for_ingredient_delete(ingredient_id, recipes)
  unless recipes.empty?
    "An ingredient cannot be deleted if it is still included in any recipe."
  end
end

# Delete an ingredient
post '/ingredients/:ingredient_id/delete' do
  ingredient_id = params[:ingredient_id].to_i
  session[:requested_url] = "/ingredients/#{ingredient_id}/delete"
  require_signed_in_user

  @recipes = @storage.find_recipes_for_ingredient(ingredient_id)

  error = error_for_ingredient_delete(ingredient_id, @recipes)

  if error
    session[:error] = error
    require_signed_in_user

    @ingredient = load_ingredient(ingredient_id)

    redirect "/ingredients/#{ingredient_id}"
  else 
    @storage.delete_ingredient_and_relations(ingredient_id)
  end

  if env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest"
    "/ingredients"
  else
    session[:success] = "The ingredient has been deleted."
    redirect "/ingredients"
  end
end

# Delete a family member
post '/family_members/:member_id/delete' do
  member_id = params[:member_id].to_i
  session[:requested_url] = "/family_members/#{family_member_id}/delete"
  require_signed_in_user

  @storage.delete_family_member_and_relations(member_id)
  if env["HTTP_X_REQUESTED_WITH"] == "XMLHttpRequest"
    "/family_members"
  else
    session[:success] = "The family member has been deleted."
    redirect "/family_members"
  end
end
