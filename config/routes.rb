Rails.application.routes.draw do
  root 'hotels#index'

  scope '/api', defaults: { format: :json } do
    resources :hotels, only: [:index]
  end
end
