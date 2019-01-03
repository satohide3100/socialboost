class HomeController < ApplicationController
  before_action :authenticate_user!
  def top
  end
  def setting
  end
  def test
    Thread.start do
      100000.times.each do |i|
        puts i
      end
    end
    redirect_to("/account/list")
  end
end
