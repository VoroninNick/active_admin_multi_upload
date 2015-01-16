module ActiveAdminMultiUpload::Uploadable
  extend ActiveSupport::Concern

  included do
    include Rails.application.routes.url_helpers
  end

  module ClassMethods
    def allows_upload(name, *args)
      options = args.extract_options!
      attribute_name = options[:attribute] || :file
      version_name_for_admin = options[:version] || :thumb
      delete_url_method_name = options[:delete_url_method_name] || "destroy_upload_admin_#{self.name.underscore}_url"
      code = <<-eoruby
        def to_jq_upload
          {
            "name" => read_attribute(#{name}),
            "size" => #{attribute_name}.size,
            "url" => #{attribute_name}.url,
            "thumbnail_url" => #{attribute_name}.#{version_name_for_admin}.url,
            "delete_url" => #{delete_url_method_name}(self, only_path: true),
            "id" => id,
            "delete_type" => "DELETE"
          }
        end
      eoruby
      class_eval(code)
    end
  end
end
