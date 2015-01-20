require 'sidekiq/web'
Rails.application.routes.draw do


  #-------开始-----------
  scope '/:locale' do
    resources :products
    resources :orders
    resources :carts
    resources :comments
    resource :tags

    namespace :admin do

      resources :notices
      resources :users, only: [:index, :edit, :update]

      %w(status seo).each { |a| get "site/#{a}" }

      %w(google baidu favicon clear).each { |a| post "site/#{a}" }

      %w(info).each do |a|
        get "site/#{a}"
        post "site/#{a}"
      end

    end

    resources :documents

    get 'home' => 'home/index'

    get 'search' => 'search#index'
  end

  authenticate :user, lambda { |u| u.is_admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users


  get 'robots' => 'home#robots', constraints: {format: 'txt'}
  %w(sitemap rss).each { |a| get a => "home##{a}", constraints: {format: 'xml'} }
  %w(google baidu).each { |a| match a, to: "home##{a}", anchor: false, constraints: {format: 'html'}, via: [:get] }

  root 'home#index'

end
