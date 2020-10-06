require "net/http"
require "base64"

class ApplicationController < ActionController::Base
  def index; end

  def error; end

  def authorize
    session[:state] = SecureRandom.alphanumeric
    queries = {
      client_id: ENV.fetch("CLIENT_ID"),
      redirect_uri: ENV.fetch("REDIRECT_URL"),
      state: session[:state],
      response_type: "code",
      scope: "foo bar",
    }
    uri = URI.parse(ENV.fetch("AUTH_SERVER_AUTHORIZE_ENDPOINT"))
    uri.query = URI.encode_www_form(queries)
    redirect_to uri.to_s
  end

  def callback
    if params[:error]
      flash.now[:error] = params[:error]
      render :error and return
    end

    if params[:state] != session[:state]
      flash.now[:error] = "State value did not match"
      render :error and return
    end

    code = params[:code]
    request_body = {
      grant_type: "authorization_code",
      code: code,
      redirect_uri: ENV.fetch("REDIRECT_URL"),
    }
    request_headers = {
      "Content-Type": "application/x-www-form-urlencoded",
      "Authorization": Base64.encode64("Basic #{ENV.fetch('CLIENT_ID')}:#{ENV.fetch('CLIENT_SECRET')}"),
    }
    res = Net::HTTP.post(URI.parse(ENV.fetch("AUTH_SERVER_TOKEN_ENDPOINT")), request_body.to_json, request_headers)

    if !res.is_a?(Net::HTTPSuccess)
      flash.now[:error] = "Unable to fetch access token, server response: #{res.code}"
      render :error and return
    end

    response_body = JSON.parse(res.body).deep_symbolize_keys
    session[:access_token] = response_body[:access_token]
    session[:refresh_token] = response_body[:refresh_token]
    session[:scope] = response_body[:scope]

    @access_token = session[:access_token]
    @refresh_token = session[:refresh_token]
    @scope = session[:scope]
    render :index
  end
end
