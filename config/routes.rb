OpalLearningWebGL::Application.routes.draw do
  root 'lessons#index'
  get ':id' => 'lessons#show'
end
