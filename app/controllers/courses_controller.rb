class CoursesController < ApplicationController
  def index
    @courses = Course.all
  end

  def show
    @course = Course.find(params[:id])
    @user_course = current_user.user_courses.find_by(course_id: @course.id) if current_user
  end

  def new
    @course = Course.new
  end

  def edit
    @course = Course.includes(course_books: :book).find(params[:id])
  end

  def create
    @course = Course.new course_params
    params[:course][:course_books].each.with_index(1) do |cb, index|
      @course.course_books.new(book_id: cb[:id], index: index)
    end

    if @course.save
      redirect_to course_path @course
    else
    end
  end

  def update
    @course = Course.find(params[:id])

    if @course.update(course_params)
      redirect_to course_path @course
    else
    end
  end


  private
    def course_params
      params.require(:course).permit(:title, :description, course_books_attributes: [:id, :index, :book_id, :_destroy])
    end
end
