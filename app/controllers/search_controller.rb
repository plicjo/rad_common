class SearchController < ApplicationController
  before_action :authenticate_user!
  before_action :check_tenant

  def global_search
    # authorization is checked within the global_autocomplete_result
    global_autocomplete = GlobalAutocomplete.new(params, view_context.global_search_scopes, current_member)
    render json: global_autocomplete.global_autocomplete_result
  end

  def global_search_result
    # authorization is checked by the redirect destination

    if params[:global_search_model_name].blank? || params[:global_search_id].blank?
      flash[:error] = 'Missing parameters'
      redirect_to root_path
    else
      model_name = params[:global_search_model_name]
      the_id = params[:global_search_id]
      klass = Object.const_get model_name
      the_object = klass.find_by(id: the_id)

      if params[:global_search_scope].present?
        current_member.update_column(:global_search_default, params[:global_search_scope])
      end

      if the_object
        redirect_to the_object
      else
        flash[:error] = 'Could not find record, please try your search again.'
        redirect_to root_path
      end
    end
  end
end
