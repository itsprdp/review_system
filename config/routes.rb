Rails.application.routes.draw do

  root 'users#new'

  get 'auth/:provider/callback', to: 'users#create'
  get 'auth/failure', to: redirect('/')

  delete '/logout',  to: 'users#destroy'

  put 'select_team_leads', to: 'users#team_leads', as: :select_team_leads
  put 'approve_goals_by_team_lead', to: 'reviews#approve_goals', as: :approve_goals_by_team_lead

  #TODO use only action routes
  resources :reviews

  #TODO use only action routes
  resources :users do
    member do
      get 'reviews'
    end
  end
end
