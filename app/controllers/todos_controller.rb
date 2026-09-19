class TodosController < ApplicationController
  before_action :authenticate_user!
  before_action :set_todo, only: [:show, :update, :destroy]

  # GET /todos
  def index
    todos = @current_user.todos.order(created_at: :desc)

    render json: todos
  end

  # GET /todos/:id
  def show
    render json: @todo
  end

  # POST /todos
  def create
    data = JSON.parse(request.body.read)

    todo = @current_user.todos.new(
      title: data["title"],
      description: data["description"],
      completed: data["completed"] || false
    )

    if todo.save
      render json: todo, status: :created
    else
      render json: {
        errors: todo.errors.full_messages
      }, status: :unprocessable_entity
    end

  rescue JSON::ParserError
    render json: {
      error: "Invalid JSON"
    }, status: :bad_request
  end

  # PATCH /todos/:id
  def update
    data = JSON.parse(request.body.read)

    attributes = {}

    attributes[:title] = data["title"] if data.key?("title")
    attributes[:description] = data["description"] if data.key?("description")
    attributes[:completed] = data["completed"] if data.key?("completed")

    if @todo.update(attributes)
      render json: @todo
    else
      render json: {
        errors: @todo.errors.full_messages
      }, status: :unprocessable_entity
    end

  rescue JSON::ParserError
    render json: {
      error: "Invalid JSON"
    }, status: :bad_request
  end

  # DELETE /todos/:id
  def destroy
    @todo.destroy

    render json: {
      message: "Todo deleted successfully"
    }
  end

  private

  def set_todo
    todo_id = request.path.split("/").last

    @todo = @current_user.todos.find_by(id: todo_id)

    if @todo.nil?
      render json: {
        error: "Todo not found"
      }, status: :not_found
    end
  end
end