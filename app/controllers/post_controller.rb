class PostController < ApplicationController
  before_action :authenticate_user!
  def bulk
    @twitterActive = Account.find_by(user_id:current_user.id,sns_type:1,active_flg:1)
    @instagramActive = Account.find_by(user_id:current_user.id,sns_type:2,active_flg:1)
    @facebookActive = Account.find_by(user_id:current_user.id,sns_type:3,active_flg:1)
    @monthOptions = []
    @dayOptions = []
    @hourOptions = []
    @minOptions = []
    1..12.times.each do |i|
      @monthOptions << i + 1
    end
    1..31.times.each do |i|
      @dayOptions << i + 1
    end
    1..24.times.each do |i|
      @hourOptions << i + 1
    end
    0..60.times.each do |i|
      if i % 10 == 0
        @minOptions << i
      end

    end
  end
  def auto
    @twitterActive = Account.find_by(user_id:current_user.id,sns_type:1,active_flg:1)
    @instagramActive = Account.find_by(user_id:current_user.id,sns_type:2,active_flg:1)
    @facebookActive = Account.find_by(user_id:current_user.id,sns_type:3,active_flg:1)
  end
end
