ActiveAdmin.register OrganisationType do
  menu :if => proc{ current_user.is_dccadmin? }, :priority => 3

  config.clear_sidebar_sections!

  controller do 
    authorize_resource

    def show
      if params[:version] && params[:version].to_i > 0
        @organisation_type = OrganistionType.find(params[:id]).versions[params[:version].to_i - 1].try(:reify)
      end
      show!
    end
    
    def destroy
      @organisation_type = OrganisationType.find(params[:id])
      @organisation_type.destroy
      respond_to do |format| 
        if @organisation_type.errors[:base].present?
          flash.now[:error] = @organisation_type.errors[:base].to_sentence
          format.html { render action: 'show' }
        else
          flash[:notice] = I18n.t('dmp.admin.model_destroyed', model: I18n.t('activerecord.models.organisation_type.one'))
          format.html { redirect_to admin_organisation_types_url }
        end
      end
    end
    
  end

  sidebar :versions, partial: 'admin/shared/version', :only => :show
  member_action :history do
    @organisation_type = OrganisationType.find(params[:id])
    @page_title = I18n.t('dmp.admin.item_history', item: @organisation_type.title)
    render "admin/shared/history"
  end
  action_item :only => :history do
    link_to I18n.t('active_admin.edit_model', model: I18n.t('activerecord.models.organisation_type.one')), edit_admin_organisation_type_path(organisation_type)
  end
  action_item :only => :history do
    link_to I18n.t('active_admin.details', model: I18n.t('activerecord.models.organisation_type.one')), admin_currency_path(organisation_type)
  end
  action_item :only => [:show, :edit] do
    if !organisation_type.checklist_owner && current_user.is_sysadmin?
      link_to I18n.t('dmp.admin.make_checklist_owner'), checklist_admin_organisation_type_path(organisation_type), :method => :put
    end
  end

  member_action :checklist, :method => :put do
    organisation_type = OrganisationType.find(params[:id])
    organisation_type.make_checklist_owner
    if organisation_type.errors[:base].present?
      flash[:error] = organisation_type.errors[:base].to_sentence
      redirect_to :back
    else
      flash[:notice] = I18n.t('dmp.admin.checklist_owner_set')
      redirect_to admin_organisation_type_path(organisation_type)
    end
  end


  form do |f|
    f.inputs do
      f.input :title
      f.input :description
      f.input :position, :as => :select, :collection => (1..20)
    end
    
    f.buttons
  end
  
  index do 
    column :title
    column :description
    column :position
    column :checklist_owner
    default_actions
  end
  
  show :title => :title do
    attributes_table :title, :description, :position
    
    active_admin_comments
  end
 
end
