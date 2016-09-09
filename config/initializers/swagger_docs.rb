Swagger::Docs::Config.register_apis({
  "1.0" => {
    :api_extension_type => :json,
    :api_file_path => "public/api/",
    :base_path => "http://diustt.club",
    :clean_directory => true,
    :parent_controller => ActionController::API,
    :attributes => {
      :info => {
        "title" => "DiUS Table Tennis api",
        "description" => "This is a sample description."
      }
    }
  }
})

