class HomeController < ApplicationController
  before_action :authenticate_user!
  def top
  end
  def setting
  end
end
