class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    if (session[:is_set].present? and params[:commit] != "Refresh" and not params[:sort].present?)
      params[:ratings] = session[:ratings]
      params[:sort] = session[:sort]
    elsif ((not session[:is_set].present?) and params[:commit] != "Refresh" and not params[:sort].present?)
      params[:ratings] = Hash[@all_ratings.map {|rating| [rating,1]}]
    end
#     if ()
#       params[:ratings] = Hash['PG'=>1]
#     end
      @title_sort = ''
      @date_sort = ''
    if (params[:sort] == 'title')
      @title_sort = 'hilite bg-warning'
      @movies = Movie.with_ratings(params[:ratings]).order(params[:sort])
    elsif (params[:sort] == 'date')
      @date_sort = 'hilite bg-warning'
      @movies = Movie.with_ratings(params[:ratings]).sort_by{|movie| movie.release_date}
    else
      @movies = Movie.with_ratings(params[:ratings])
    end
    @ratings_to_show = params[:ratings] != nil ? params[:ratings].keys : []
    session[:ratings] = params[:ratings]
    session[:sort] = params[:sort]
    session[:is_set] = 1
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
