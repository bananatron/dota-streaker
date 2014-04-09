require 'sinatra'

get '/' do 
	erb :form
end

get '/about' do
    erb :about
end

post '/form' do 
    erb :result, :locals => { :username => params[:username] }
end

post '/result' do
    erb :result, :locals => { :username => params[:username] }
end

