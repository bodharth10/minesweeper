Rails.application.routes.draw do
  resources :scores
  root "games#index"
  get '/:row_id/:column_id', to: 'games#index', :constraints => { :row_id => /[0-9]+(\%7C[0-9]+)*/, :column_id => /[0-9]+(\%7C[0-9]+)*/ }
end
