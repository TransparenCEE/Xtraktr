class ApiController < ApplicationController

  def index
   @page_content = PageContent.by_name('api')
   @api_versions = ApiVersion.is_public.sorted
   @klass=@klass_footer=' white'
   @css.push('api.css', 'list.css')
   @show_title = false

   respond_to do |format|
   format.html # index.html.erb
   end
  end

end
