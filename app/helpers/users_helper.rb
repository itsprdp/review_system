# frozen_string_literal: true

module UsersHelper
  # Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id unless user.nil?
  end

  # Returns the user corresponding to the remember token cookie.
  def current_user
    if !session[:user_id].nil?
      user ||= User.find_by(id: session[:user_id])
      log_in user
      @current_user = user
    elsif !cookies.signed[:user_id].nil?
      user = User.find_by(id: cookies.signed[:user_id])
      log_in user
      @current_user = user
    end
  end

  def save_tab_mode(mode)
    session[:tab_mode] = mode
  end

  def tab_mode
    session[:tab_mode]
  end

  def current_user?(user)
    user == current_user
  end

  def log_out
    forget
    session.delete(:user_id)
    @current_user = nil
  end

  def forget
    cookies.delete(:user_id)
  end

  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end

  def logged_in?
    !current_user.nil?
  end

  def review_status(review_state)
    case review_state
    when 'started' then "Goals not submitted. Discuss with manager/reportee and
      finalize goals"
    when 'saved' then "Goals not submitted. Discuss with manager/reportee and
      finalize goals"
    when 'submitted' then "Goals submitted. Awaiting manager's approval"
    when 'accepted' then 'Goals accepted. Awaiting
      temporary feedback'
    when 'self_rating_submitted' then 'Self rating submitted. Awaiting
      final feedback'
    when 'feedback_submitted' then 'Temporary feedback submitted. Awaiting
      Self rating'
    when 'completed' then 'Final feedback provided. Appraisal closed!'
    else review_state
    end
  end

  def user_action(review_state)
    case review_state
    when 'started' then 'Create'
    when 'saved' then 'View and Submit'
    when 'feedback_submitted' then 'Submit Self Rating'
    else 'View'
    end
  end

  def manager_action(review_state)
    case review_state
    when 'self_rating_submitted' then 'Submit feedback'
    when 'accepted' then 'Submit feedback'
    when 'feedback_submitted' then 'View'
    when 'submitted' then 'View'
    when 'started' then ''
    when 'saved' then ''
    else 'View'
    end
  end

  def review_state
    case params[:commit].values[0]
    when 'Submit for approval' then Review.modes['submitted']
    when 'Approve' then Review.modes['accepted']
    when 'Interim Feedback' then Review.modes['feedback_submitted']
    when 'Final Feedback' then Review.modes['completed']
    when 'Submit Self Rating' then Review.modes['self_rating_submitted']
    else Review.modes['saved']
    end
  end
end
