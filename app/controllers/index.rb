get '/' do
  @deck_names = []
  Deck.all.each{|deck| @deck_names << deck.name}
  erb :index
end

get '/create_user' do
  erb :create_user
end

get '/profile_page' do
  @user = User.find(session[:current_user])
  erb :profile_page
end

get '/logout' do
  session.clear
  # binding.pry
  redirect '/'
end

get '/end' do
  if params[:quit]
    redirect '/'
  elsif params[:replay]
    erb :start
  end
end

get '/:deck_name/start' do
  session[:current_deck] = Deck.find_by_name(params[:deck_name])
  session[:current_score] = 0
  erb :start
end

get '/:deck_name/end' do
  erb :end
end

get "/:deck_name/:card_number" do
  @deck = session[:current_deck].cards
  binding.pry
  @score = session[:current_score]
  erb :game_play
end



#We can store the decks, scores, other things in the session
#POST===========================================

post '/validate_user' do
  @deck_names = []
  Deck.all.each{|deck| @deck_names << deck.name}

  @user = User.find_by_email(params[:email])

  if session[:current_user]

    @two_users = true # binding.pry
    if session[:current_user] == @user.id
      @same_user = true
      @two_users = false
    end

    erb :index
  elsif @user
    if @user.authenticate(params[:password])
      session[:current_user] = @user.id
      redirect '/profile_page'
    else
      @wrong_password = true
      @no_user = false
      erb :index
    end
  else
    @wrong_password = false
    @no_user = true
    erb :index
  end
end


post '/creation/validate_user' do
  @deck_names = []
  Deck.all.each{|deck| @deck_names << deck.name}

  @user = User.new(params[:user])
  if @user.save

    session[:current_user] = @user.id
    redirect '/profile_page'
  else
    @errors = true
    erb :create_user
  end
end

post "/:deck_name/:card_number" do
  @deck = session[:current_deck].cards
  @num = params[:card_number].to_i
  card = Card.find_by_question(params[:question])

  if params[:answer].downcase == card.answer.downcase
    # @deck_name = params[:deck_name]
    @num += 1

    # binding.pry
    session[:current_score] += 1
    session[:correct] = true
    if @num >= @deck.length
      redirect "/#{params[:deck_name]}/end"
    end
  else
    @num += 1
    # @correct = false
    session[:correct] = false
    # erb :game_play

    if @num >= @deck.length
      redirect "/#{params[:deck_name]}/end"
    end
  end
  redirect "/#{params[:deck_name]}/#{@num}"
end
