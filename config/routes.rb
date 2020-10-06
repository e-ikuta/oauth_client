Rails.application.routes.draw do
  root to: "application#index"
  get "error", to: "application#error"
  get "authorize", to: "application#authorize"
  get "callback", to: "application#callback"
end
