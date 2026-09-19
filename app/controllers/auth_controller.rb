class AuthController < ApplicationController
  before_action :authenticate_user!, only: [:whoami]

  def register
    data = JSON.parse(request.body.read)

    user = User.new(
      name: data["name"],
      email: data["email"],
      password: data["password"]
    )

    if user.save
      render json: {
        message: "User registered successfully",
        user: {
          id: user.id,
          name: user.name,
          email: user.email
        }
      }, status: :created
    else
      render json: {
        errors: user.errors.full_messages
      }, status: :unprocessable_entity
    end

  rescue JSON::ParserError
    render json: {
      error: "Invalid JSON"
    }, status: :bad_request
  end

  def login
    data = JSON.parse(request.body.read)

    user = User.find_by(email: data["email"])

    if user && user.authenticate(data["password"])
      token = JwtService.encode(
        user_id: user.id
      )

      render json: {
        message: "Login successful",
        token: token,
        user: {
          id: user.id,
          name: user.name,
          email: user.email
        }
      }, status: :ok
    else
      render json: {
        error: "Invalid email or password"
      }, status: :unauthorized
    end

  rescue JSON::ParserError
    render json: {
      error: "Invalid JSON"
    }, status: :bad_request
  end

  def whoami
    render json: {
      user: {
        id: @current_user.id,
        name: @current_user.name,
        email: @current_user.email
      }
    }, status: :ok
  end
end