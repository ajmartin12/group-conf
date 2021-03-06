class SignupController < ApplicationController
  def index
  end

  def oatoken
    code = params[:code]
    access_token = @@oauth.get_access_token(code)
    api = LinkedIn::API.new(access_token)
    # https://developer.linkedin.com/docs/fields/basic-profile
    # can get as many of these fields as we want, simply add elements to the array below:
    api_response = api.profile(fields: [
      "picture-urls::(original)",
      "location",
      "industry",
      "headline",
      "id",
      "public-profile-url"
      ])

    user = current_user
    user.linkedin_id = api_response.id
    user.linkedin_image_url = api_response.picture_urls.all[0]
    user.linkedin_headline = api_response.headline
    user.linkedin_specialities = api_response.public_profile_url
    user.linkedin_location = api_response.location.name
    user.linkedin_industry = api_response.industry

    user.save
    redirect_to "/users/#{current_user.id}"
  end

  def oauth2
    LinkedIn.configure do |config|
      config.client_id     = "7507jes2q9gtbj"
      config.client_secret = "fAqqMb4Lu77Iubvn"
      config.redirect_uri  = "http://127.0.0.1:3000/login/oatoken"
    end
    @@oauth = LinkedIn::OAuth2.new
    url = @@oauth.auth_code_url
    redirect_to url
  end
end
