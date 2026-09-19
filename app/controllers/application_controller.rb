class ApplicationController < ActionController::API
  private

  def authenticate_user!
    header = request.headers["Authorization"]

    if header.nil?
      return render json: {
        error: "Authorization header is missing"
      }, status: :unauthorized
    end

    token = header.split(" ").last

    payload = JwtService.decode(token)

    if payload.nil?
      return render json: {
        error: "Invalid or expired token"
      }, status: :unauthorized
    end

    @current_user = User.find_by(id: payload["user_id"])

    if @current_user.nil?
      render json: {
        error: "User not found"
      }, status: :unauthorized
    end
  end
end